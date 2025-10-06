import 'package:flutter/material.dart';
import '/models/category.dart';
import '/models/product.dart';
import '/services/api_service.dart';
import 'product_detail_screen.dart';
import '/widgets/navbar.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;

  const CategoryScreen({
    Key? key,
    required this.categoryName,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoadingCategories = true;
  bool _isLoadingProducts = false;

  List<Category> _categories = [];
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  Category? _selectedCategory;

  Map<int, String> _brandsMap = {};
  List<int> _selectedBrandIds = [];
  
  late double _minPrice;
  late double _maxPrice;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.firstWhere(
            (c) => c.id == widget.categoryId,
            orElse: () => _categories.first,
          );
          _fetchProducts(_selectedCategory!.id);
        }
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch categories: $e')),
      );
    }
  }

  Future<void> _fetchProducts(int categoryId) async {
    setState(() => _isLoadingProducts = true);
    try {
      final categoryProducts = await _apiService.getProductsByCategory(categoryId);

      if (categoryProducts.isNotEmpty) {
        _minPrice = categoryProducts.map((p) => p.price).reduce((a, b) => a < b ? a : b);
        _maxPrice = categoryProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b);
        _priceRange = RangeValues(_minPrice, _maxPrice);
      } else {
        _minPrice = 0;
        _maxPrice = 0;
        _priceRange = RangeValues(0, 0);
      }

      // Extract unique brands from products
      final brandsMap = <int, String>{};
      for (var product in categoryProducts) {
        if (product.brandId != null && product.brandName != null) {
          brandsMap[product.brandId!] = product.brandName!;
        }
      }

      setState(() {
        _products = categoryProducts;
        _filteredProducts = categoryProducts;
        _brandsMap = brandsMap;
        _selectedBrandIds = [];
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch products: $e')),
      );
    }
  }

  void _applyFilters() {
    List<Product> filtered = _products
        .where((p) => p.price >= _priceRange.start && p.price <= _priceRange.end)
        .toList();

    if (_selectedBrandIds.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.brandId != null && _selectedBrandIds.contains(p.brandId)
      ).toList();
    }

    setState(() => _filteredProducts = filtered);
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          productId: product.id,
        ),
      ),
    );
  }

  void _onCategorySelected(Category category) {
    setState(() => _selectedCategory = category);
    _fetchProducts(category.id);
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _buildFiltersSheet(setModalState),
      ),
    );
  }

  Widget _buildFiltersSheet(StateSetter setModalState) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildPriceFilter(setModalState),
                SizedBox(height: 24),
                _buildBrandFilter(setModalState),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 16),
        RangeSlider(
          values: _priceRange,
          min: _minPrice,
          max: _maxPrice,
          divisions: _maxPrice > _minPrice ? 50 : 1,
          onChanged: (RangeValues values) {
            setModalState(() => _priceRange = values);
            setState(() => _priceRange = values);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LKR ${_priceRange.start.round()}'),
            Text('LKR ${_priceRange.end.round()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandFilter(StateSetter setModalState) {
    final sortedBrands = _brandsMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 16),
        Container(
          height: 200,
          child: _brandsMap.isEmpty
              ? Center(child: Text('No brands available'))
              : ListView.builder(
                  itemCount: sortedBrands.length,
                  itemBuilder: (context, index) {
                    final brandId = sortedBrands[index].key;
                    final brandName = sortedBrands[index].value;
                    final isSelected = _selectedBrandIds.contains(brandId);

                    return CheckboxListTile(
                      title: Text(brandName),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setModalState(() {
                          if (value == true) {
                            _selectedBrandIds.add(brandId);
                          } else {
                            _selectedBrandIds.remove(brandId);
                          }
                        });
                        setState(() {
                          if (value == true) {
                            _selectedBrandIds.add(brandId);
                          } else {
                            _selectedBrandIds.remove(brandId);
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _onProductTap(product),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300.withOpacity(0.5),
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: product.image != null
                    ? Image.network(
                        product.fullImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'LKR ${(product.discountPrice ?? product.price).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A5CE6),
                        ),
                      ),
                      if (product.discountPrice != null) ...[
                        SizedBox(width: 8),
                        Text(
                          'LKR ${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationLayout(
      title: widget.categoryName,
      currentIndex: 1,
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      additionalActions: [
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: _showFiltersSheet,
        ),
      ],
      onTabChanged: (index) {},
      body: _isLoadingCategories
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory?.id == category.id;

                      return GestureDetector(
                        onTap: () => _onCategorySelected(category),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFF5A5CE6) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _isLoadingProducts
                      ? Center(child: CircularProgressIndicator())
                      : _filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No products found',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) => _buildProductCard(_filteredProducts[index]),
                            ),
                ),
              ],
            ),
    );
  }
}
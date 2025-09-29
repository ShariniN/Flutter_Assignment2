import 'package:flutter/material.dart';
import '/models/product.dart';
import '/models/cart.dart';
import '/widgets/navbar.dart'; 
import '/data/product_data.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  
  const ProductDetailsPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String selectedColor = 'Default';
  String selectedStorage = '128GB';
  int selectedColorIndex = 0;
  int selectedStorageIndex = 0;
  final CartManager _cartManager = CartManager();
  ImageProvider? _cachedImage;
  bool _isLoadingImage = true;

  List<Map<String, dynamic>> get colors {
    return ProductData.getColorsByCategory(widget.product.category);
  }

  List<Map<String, dynamic>> get variantOptions {
    return ProductData.getVariantOptionsByCategory(widget.product.category, widget.product.price);
  }

  List<Map<String, dynamic>> get productFeatures {
    return ProductData.getFeaturesByCategory(widget.product.category);
  }

  List<Map<String, String>> get specifications {
    return ProductData.getSpecificationsByCategory(widget.product.category, widget.product, selectedColor);
  }

  String get productDescription {
    return ProductData.getDescriptionByCategory(widget.product.category);
  }

  @override
  void initState() {
    super.initState();
    selectedColor = colors.first['name'];
    selectedStorage = variantOptions.first['size'];
    _cartManager.addListener(_updateUI);
    _loadCachedImage();
  }

  @override
  void dispose() {
    _cartManager.removeListener(_updateUI);
    super.dispose();
  }

  Future<void> _loadCachedImage() async {
    try {
      final cachedImage = await ProductData.getCachedImage(widget.product.imageUrl);
      if (mounted) {
        setState(() {
          _cachedImage = cachedImage;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cachedImage = const AssetImage('images/placeholder.png');
          _isLoadingImage = false;
        });
      }
    }
  }

  void _updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    List<Widget> contentItems = _buildContentItems(theme);
    
    return NavigationLayout(
      title: 'Product Details',
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      body: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: ListView.builder(
          itemCount: contentItems.length,
          itemBuilder: (context, index) {
            return contentItems[index];
          },
        ),
        floatingActionButton: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: FloatingActionButton.extended(
            onPressed: () {
              _addToCart();
            },
            backgroundColor: colorScheme.onSurface,
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart, 
                  color: colorScheme.surface
                ),
                const SizedBox(width: 8),
                Text(
                  'Add to Cart - LKR ${_formatPrice(variantOptions[selectedStorageIndex]['price'])}',
                  style: TextStyle(
                    color: colorScheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  String _formatPrice(dynamic price) {
    String priceStr = price.toString().replaceAll('LKR ', '').replaceAll(',', '');
    return priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  List<Widget> _buildContentItems(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    List<Widget> items = [];

    items.add(
      Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardColor,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
          border: Border.all(
            width: 2,
            color: Colors.transparent,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
                colorScheme.tertiary,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildImageWidget(colorScheme),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0 
                        ? colorScheme.onSurface
                        : colorScheme.outline,
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    items.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.product.subtitle,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'LKR ${_formatPrice(variantOptions[selectedStorageIndex]['price'])}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.product.rating}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (colors.length > 1 && colors.first['name'] != 'Default') {
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(colors.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColorIndex = index;
                        selectedColor = colors[index]['name'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors[index]['color'],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColorIndex == index
                                    ? colorScheme.onSurface
                                    : colorScheme.outline,
                                width: selectedColorIndex == index ? 2 : 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (selectedColorIndex == index)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: colorScheme.onSurface,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    }

    if (variantOptions.length > 1) {
      String variantLabel = _getVariantLabel();
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                variantLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: List.generate(variantOptions.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStorageIndex = index;
                        selectedStorage = variantOptions[index]['size'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedStorageIndex == index
                              ? colorScheme.onSurface
                              : colorScheme.outline,
                          width: selectedStorageIndex == index ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        variantOptions[index]['size'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedStorageIndex == index
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    }

    for (var feature in productFeatures) {
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _buildFeatureItem(
            feature['icon'],
            feature['title'],
            feature['description'],
            theme,
          ),
        ),
      );
    }

    items.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Text(
          'Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );

    items.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Text(
          productDescription,
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ),
    );

    items.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Text(
          'Specifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );

    for (var spec in specifications) {
      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: _buildSpecItem(
            spec['title']!,
            spec['value']!,
            theme,
          ),
        ),
      );
    }

    items.add(const SizedBox(height: 100));

    return items;
  }

  Widget _buildImageWidget(ColorScheme colorScheme) {
    if (_isLoadingImage) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.onSurface,
        ),
      );
    }

    if (_cachedImage != null && widget.product.hasValidImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: _cachedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Icon(
      widget.product.categoryIcon,
      size: 200,
      color: colorScheme.onSurface,
    );
  }

  String _getVariantLabel() {
    switch (widget.product.category) {
      case 'phone':
      case 'laptop':
        return 'Storage';
      case 'wearables':
        return 'Size';
      case 'audio':
        return 'Version';
      default:
        return 'Options';
    }
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecItem(String title, String value, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  void _addToCart() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    _cartManager.addToCart(
      product: widget.product,
      selectedColor: selectedColor,
      selectedVariant: selectedStorage,
      price: variantOptions[selectedStorageIndex]['price'].toDouble(),
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'Added to Cart',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (selectedColor != 'Default')
                Text(
                  'Color: $selectedColor',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              Text(
                '${_getVariantLabel()}: $selectedStorage',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: LKR ${_formatPrice(variantOptions[selectedStorageIndex]['price'])}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Shopping',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/cart');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onSurface,
              ),
              child: Text(
                'View Cart (${_cartManager.itemCount})',
                style: TextStyle(color: colorScheme.surface),
              ),
            ),
          ],
        );
      },
    );
  }
}
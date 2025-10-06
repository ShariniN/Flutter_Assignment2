import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/widgets/large_product_card.dart';
import '/widgets/navbar.dart';
import '/models/product.dart';
import '/services/api_service.dart';
import '/services/cart_manager.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => ElectronicsStoreState();
}

class ElectronicsStoreState extends State<HomeScreen> {
  int currentIndex = 0;
  List<Product> _products = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: $e')),
        );
      }
    }
  }

  void onTabChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(productId: product.id),
      ),
    );
  }

  Widget buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5A5CE6), Color(0xFF7C83FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF5A5CE6).withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Product Image ----------
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: (product.image != null && product.fullImageUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.fullImageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            // ---------- Product Info ----------
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.description != null && product.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          product.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.discountPrice != null
                              ? 'LKR ${product.discountPrice!.toStringAsFixed(2)}'
                              : 'LKR ${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5A5CE6),
                              ),
                        ),
                        if (product.discountPrice != null)
                          Text(
                            'LKR ${product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[500],
                                ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartManager = context.watch<CartManager>();
    
    // Filter featured products (you can add isFeatured field to your Product model)
    final featuredProducts = _products.take(4).toList();

    return NavigationLayout(
      title: 'Tech Store',
      currentIndex: currentIndex,
      onTabChanged: onTabChanged,
      cartManager: cartManager,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Banner ----------
                  Container(
                    height: 400,
                    width: double.infinity,
                    child: Image.asset(
                      'images/banner.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Color(0xFF5A5CE6),
                        child: Center(
                          child: Icon(Icons.shopping_bag, size: 100, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // ---------- Featured Products ----------
                  if (featuredProducts.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Featured Products',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          for (int i = 0; i < featuredProducts.length; i += 2)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => onProductTap(featuredProducts[i]),
                                      child: AspectRatio(
                                        aspectRatio: 0.75,
                                        child: buildProductCard(featuredProducts[i]),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  if (i + 1 < featuredProducts.length)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => onProductTap(featuredProducts[i + 1]),
                                        child: AspectRatio(
                                          aspectRatio: 0.75,
                                          child: buildProductCard(featuredProducts[i + 1]),
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(child: Container()),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16),

                  // ---------- Categories ----------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Categories',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  LargeProductCard(
                    title: 'Apple',
                    subtitle: 'iPhone Max',
                    backgroundColor: isDark ? Color(0xFF2D3748) : Color(0xFFe8f5e8),
                  ),
                  LargeProductCard(
                    title: 'Apple Vision Pro',
                    subtitle: '',
                    backgroundColor: isDark ? Color(0xFF1A202C) : Color(0xFFf3e5f5),
                  ),
                  LargeProductCard(
                    title: 'MacBook Air',
                    subtitle: '',
                    backgroundColor: isDark ? Color(0xFF4A5568) : Color(0xFFfff3e0),
                  ),
                  LargeProductCard(
                    title: 'iPad Pro',
                    subtitle: '',
                    backgroundColor: isDark ? Color(0xFF2D3748) : Color(0xFFfce4ec),
                  ),

                  // ---------- Promo Section ----------
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Big Summer Sale',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Up to 50% off',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 100),
                ],
              ),
            ),
    );
  }
}
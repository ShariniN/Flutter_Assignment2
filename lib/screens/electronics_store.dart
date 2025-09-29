import 'package:flutter/material.dart';
import '/widgets/large_product_card.dart';
import '/widgets/navbar.dart';
import '/data/product_data.dart';
import '/models/product.dart';
import 'product_screen.dart';

class ElectronicsStore extends StatefulWidget {
  @override
  State<ElectronicsStore> createState() => ElectronicsStoreState();
}

class ElectronicsStoreState extends State<ElectronicsStore> {
  int currentIndex = 0;
  
  void onTabChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(product: product),
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
            color: Color(0xFF5A5CE6), 
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
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: product.hasValidImage
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          product.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      product.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Flexible(child: Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A5CE6),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${product.rating}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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
    final allProducts = ProductData.getAllProducts();
    final featuredProducts = allProducts.take(4).toList();
    
    return NavigationLayout(
      title: 'Tech Store',
      currentIndex: currentIndex,
      onTabChanged: onTabChanged,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 400,
              width: double.infinity,
              child: Image.asset(
                'images/banner.png', 
                fit: BoxFit.cover,
              ),
            ),
            
            SizedBox(height: 20),

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
            
            SizedBox(height: 16),
            
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
                    color: Color(0xFF667eea), 
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
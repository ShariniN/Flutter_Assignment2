import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/product.dart';
import '/services/api_service.dart';
import '/services/cart_manager.dart';
import '/widgets/navbar.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Product? _product;
  bool _isLoading = true;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      Product product = await ApiService().getProductDetails(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load product: $e')),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) return;

    setState(() => _isAddingToCart = true);

    try {
      // Access CartManager from Provider
      context.read<CartManager>().addToCart(
        product: _product!,
        quantity: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_product!.name} added to cart')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cartManager = context.watch<CartManager>();

    return NavigationLayout(
      title: 'Product Details',
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      cartManager: cartManager,
      body: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _product == null
                ? Center(child: Text('Product not found', style: theme.textTheme.bodyLarge))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_product!.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _product!.image!,
                            fit: BoxFit.cover,
                            height: 300,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.image, size: 100, color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _product!.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_product!.description != null)
                        Text(
                          _product!.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            "LKR ${_product!.discountPrice ?? _product!.price}",
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                          if (_product!.discountPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              "LKR ${_product!.price}",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Specifications",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_product!.specifications != null)
                        ..._product!.specifications!.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(entry.key, style: TextStyle(color: colorScheme.onSurfaceVariant))),
                                Expanded(
                                    child: Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
        floatingActionButton: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: _isAddingToCart ? null : _addToCart,
              icon: _isAddingToCart
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.shopping_cart),
              label: Text(
                _isAddingToCart ? 'Adding...' : 'Add to Cart',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
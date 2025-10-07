import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '/models/product.dart';
import '/models/review.dart';
import '/services/api_service.dart';
import '/services/cart_manager.dart';
import '/widgets/navbar.dart';
import '../db/reviews_database.dart';

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

  List<Review> _reviews = [];
  bool _isLoadingReviews = true;

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
      await _loadReviews();
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

  Future<void> _loadReviews() async {
    if (_product == null) return;
    final rows = await ReviewsDatabase().getReviews(_product!.id);
    setState(() {
      _reviews = rows
          .map((r) => Review(
                id: r['id'],
                productId: r['product_id'],
                userId: 0, 
                user: null,
                comment: r['comment'],
                rating: double.tryParse(r['rating'].toString()) ?? 0.0,
                createdAt: r['timestamp'],
                imagePath: r['image_path'],
              ))
          .toList();
      _isLoadingReviews = false;
    });
  }

  Future<void> _addReview() async {
    final commentController = TextEditingController();
    double rating = 5.0;
    String? imagePath;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Review"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Comment'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Rating: "),
                  DropdownButton<double>(
                    value: rating,
                    items: [1, 2, 3, 4, 5]
                        .map((e) => DropdownMenuItem(
                              value: e.toDouble(),
                              child: Text(e.toString()),
                            ))
                        .toList(),
                    onChanged: (v) => rating = v ?? 5.0,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final picked =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (picked != null) imagePath = picked.path;
                },
                child: const Text("Add Photo"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ReviewsDatabase().insertReview({
                'product_id': _product!.id,
                'user_name': "You",
                'rating': rating,
                'comment': commentController.text,
                'image_path': imagePath ?? '',
                'timestamp': DateTime.now().toIso8601String(),
              });
              Navigator.pop(context);
              _loadReviews();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String getImageUrl(Product product) {
      if (product.image == null || product.image!.isEmpty) return '';
      if (product.image!.startsWith('http')) return product.image!;
      return 'https://your-custom-base-url.com/${product.image!}';
    }

    return NavigationLayout(
      title: 'Product Details',
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      body: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _product == null
                ? Center(
                    child:
                        Text('Product not found', style: theme.textTheme.bodyLarge))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_product!.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            getImageUrl(_product!),
                            fit: BoxFit.cover,
                            height: 300,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.image,
                              size: 100,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _product!.name,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_product!.description != null)
                        Text(
                          _product!.description!,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            "LKR ${_product!.discountPrice ?? _product!.price}",
                            style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold),
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
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_product!.specifications != null)
                        ..._product!.specifications!.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(entry.key,
                                        style: TextStyle(
                                            color:
                                                colorScheme.onSurfaceVariant))),
                                Expanded(
                                    child: Text(entry.value.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        "Reviews",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _isLoadingReviews
                          ? const Center(child: CircularProgressIndicator())
                          : _reviews.isEmpty
                              ? const Text("No reviews yet")
                              : Column(
                                  children: _reviews.map((r) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      child: ListTile(
                                        leading: r.user != null
                                            ? CircleAvatar(
                                                child: Text(r.user!.name[0]))
                                            : const Icon(Icons.person),
                                        title: Row(
                                          children: [
                                            Text(r.user?.name ?? "Anonymous"),
                                            const SizedBox(width: 8),
                                            Text("(${r.rating}/5)",
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (r.comment != null) Text(r.comment!),
                                            if (r.createdAt != null)
                                              Text(
                                                r.createdAt!,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                              ),
                                            if (r.imagePath != null && r.imagePath!.isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 4),
                                                child: Image.file(File(r.imagePath!),
                                                    height: 100,
                                                    fit: BoxFit.cover),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                      const SizedBox(height: 100),
                    ],
                  ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _isAddingToCart ? null : _addToCart,
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.shopping_cart),
                label: Text(_isAddingToCart ? 'Adding...' : 'Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              onPressed: _addReview,
              icon: const Icon(Icons.rate_review),
              label: const Text("Add Review"),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '/models/cart.dart';
import '/models/cart_item.dart';
import '/models/product.dart';
import '/services/api_service.dart';

class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + (item.product?.discountPrice ?? item.product?.price ?? 0) * item.quantity);

  /// Add product to cart
  void addToCart({required Product product, int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // Increase quantity if product already in cart
      final existingItem = _items[existingIndex];
      _items[existingIndex] = CartItem(
        id: existingItem.id,
        cartId: existingItem.cartId,
        productId: existingItem.productId,
        quantity: existingItem.quantity + quantity,
        product: existingItem.product,
      );
    } else {
      // Add new item
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch, // temporary ID for local cart
        cartId: 0, // can be updated if syncing with backend
        productId: product.id,
        quantity: quantity,
        product: product,
      ));
    }

    notifyListeners();
  }

  /// Remove item from cart
  void removeFromCart(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Update quantity of an item
  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        removeFromCart(index);
      } else {
        final item = _items[index];
        _items[index] = CartItem(
          id: item.id,
          cartId: item.cartId,
          productId: item.productId,
          quantity: quantity,
          product: item.product,
        );
        notifyListeners();
      }
    }
  }

  /// Clear entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

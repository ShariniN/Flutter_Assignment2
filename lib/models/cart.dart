import 'package:flutter/material.dart';
import 'product.dart';

class CartItem {
  final Product product;
  final String selectedColor;
  final String selectedVariant;
  final double price;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedColor,
    required this.selectedVariant,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart({
    required Product product,
    required String selectedColor,
    required String selectedVariant,
    required double price,
  }) {
    final existingIndex = _items.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedColor == selectedColor &&
        item.selectedVariant == selectedVariant);

    if (existingIndex != -1) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        product: product,
        selectedColor: selectedColor,
        selectedVariant: selectedVariant,
        price: price,
      ));
    }
    
    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _items.length) {
      if (newQuantity <= 0) {
        removeFromCart(index);
      } else {
        _items[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
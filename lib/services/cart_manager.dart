import 'package:flutter/material.dart';
import '/models/cart_item.dart';
import '/models/product.dart';
import '/services/api_service.dart';

class CartManager extends ChangeNotifier {
  final ApiService _apiService;
  List<CartItem> _items = [];
  bool _isLoading = false;

  CartManager(this._apiService);

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(
      0,
      (sum, item) =>
          sum +
          (item.product?.discountPrice ?? item.product?.price ?? 0) *
              item.quantity);

  /// Load cart from backend
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📦 Loading cart from API...');
      _items = await _apiService.getCart();
      print('✅ Cart loaded: ${_items.length} items');
    } catch (e) {
      print('❌ Error loading cart: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add product to cart (syncs with backend)
  Future<void> addToCart({required Product product, int quantity = 1}) async {
    try {
      print('🛒 Adding to cart: ${product.name} (qty: $quantity)');
      
      // Call API first - this saves to database
      final cartItem = await _apiService.addToCart(product.id, quantity);
      print('✅ API responded with cart item: ${cartItem.id}');
      
      // Then update local state with the actual cart item from the database
      final existingIndex = _items.indexWhere((item) => item.productId == product.id);
      
      if (existingIndex >= 0) {
        _items[existingIndex] = cartItem;
        print('📝 Updated existing item at index $existingIndex');
      } else {
        _items.add(cartItem);
        print('➕ Added new item to cart');
      }
      
      notifyListeners();
      print('🔔 Listeners notified');
    } catch (e) {
      print('❌ Error adding to cart: $e');
      rethrow;
    }
  }

  /// Remove item from cart (syncs with backend)
  Future<void> removeFromCart(int index) async {
    if (index >= 0 && index < _items.length) {
      try {
        final item = _items[index];
        print('🗑️ Removing cart item: ${item.id}');
        
        await _apiService.removeFromCart(item.id);
        print('✅ API confirmed removal');
        
        _items.removeAt(index);
        notifyListeners();
        print('🔔 Local state updated');
      } catch (e) {
        print('❌ Error removing from cart: $e');
        rethrow;
      }
    }
  }

  /// Update quantity (syncs with backend)
  Future<void> updateQuantity(int index, int quantity) async {
    if (index >= 0 && index < _items.length) {
      try {
        if (quantity <= 0) {
          await removeFromCart(index);
        } else {
          final item = _items[index];
          print('🔄 Updating quantity for item ${item.id} to $quantity');
          
          final updatedItem = await _apiService.updateCartItem(item.id, quantity);
          print('✅ API confirmed update');
          
          _items[index] = updatedItem;
          notifyListeners();
          print('🔔 Local state updated');
        }
      } catch (e) {
        print('❌ Error updating quantity: $e');
        rethrow;
      }
    }
  }

  /// Clear entire cart (syncs with backend)
  Future<void> clearCart() async {
    try {
      print('🧹 Clearing cart...');
      await _apiService.clearCart();
      print('✅ API confirmed cart cleared');
      
      _items.clear();
      notifyListeners();
      print('🔔 Local state cleared');
    } catch (e) {
      print('❌ Error clearing cart: $e');
      rethrow;
    }
  }
}
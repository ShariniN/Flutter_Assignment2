import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/wishlist_item.dart';
import '../models/category.dart';
import '../models/cart_item.dart';

class ApiService {
  static const String baseUrl = "https://ssp2-assignment-production.up.railway.app/api";
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        "name": name,
        "email": email,
        "password": password,
      });
      await _secureStorage.write(key: 'auth_token', value: response.data['token']);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        "email": email,
        "password": password,
      });
      await _secureStorage.write(key: 'auth_token', value: response.data['token']);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {} 
    finally {
      await _secureStorage.delete(key: 'auth_token');
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      return (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProductDetails(int id) async {
    try {
      final response = await _dio.get('/products/$id');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final data = response.data;
      List<dynamic> list;
      if (data is Map && data.containsKey('data')) {
        list = data['data'];
      } else {
        list = data;
      }
      return list.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _dio.get('/categories/$categoryId/products');
      final data = response.data;
      List<dynamic> list;
      if (data is Map && data.containsKey('products')) {
        list = data['products'];
      } else {
        list = data;
      }
      return list.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _dio.get('/wishlist');
      return (response.data as List)
          .map((json) => WishlistItem.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> addToWishlist(int productId) async {
    try {
      await _dio.post('/wishlist', data: {"product_id": productId});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    try {
      await _dio.delete('/wishlist/$productId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> placeOrder(List<int> productIds) async {
    try {
      final response = await _dio.post('/orders', data: {"products": productIds});
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      return (response.data as List).map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

    // Get cart items
  Future<List<CartItem>> getCart() async {
    try {
      final response = await _dio.get('/cart');
      return (response.data as List)
          .map((json) => CartItem.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CartItem> addToCart(int productId, int quantity) async {
  try {
    print('🌐 API Call: POST /cart with product_id=$productId, quantity=$quantity');
    
    final response = await _dio.post('/cart', data: {
      "product_id": productId,
      "quantity": quantity,
    });
    
    print('📡 Response status: ${response.statusCode}');
    print('📄 Response data: ${response.data}');
    
    return CartItem.fromJson(response.data);
  } on DioException catch (e) {
    print('⚠️ DioException: ${e.message}');
    print('📄 Error response: ${e.response?.data}');
    throw _handleError(e);
  }
}

// Update cart item quantity
Future<CartItem> updateCartItem(int cartItemId, int quantity) async {
  try {
    final response = await _dio.put('/cart/$cartItemId', data: {
      "quantity": quantity,
    });
    return CartItem.fromJson(response.data); 
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

  // Remove item from cart
  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _dio.delete('/cart/$cartItemId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      await _dio.delete('/cart/clear');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout. Check server.";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout. Server not responding.";
      case DioExceptionType.badResponse:
        return "Bad response: ${e.response?.statusCode}";
      case DioExceptionType.unknown:
        return "Unable to connect to server.";
      default:
        return "Unexpected error: ${e.message}";
    }
  }
}

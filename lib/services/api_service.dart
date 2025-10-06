import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
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

  // Authentication Methods
  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        "name": name,
        "email": email,
        "password": password,
      });
      
      final token = response.data['token'];
      final user = User.fromJson(response.data);
      
      // Store token and user data
      await _secureStorage.write(key: 'auth_token', value: token);
      await _saveUserData(user);
      
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> login(String email, String password) async {
    try {
      print('Attempting login for: $email');
      final response = await _dio.post('/login', data: {
        "email": email,
        "password": password,
      });
      
      print('📡 Login response received');
      print('Response data: ${response.data}');
      
      final token = response.data['token'];
      print('🔑 Token received: ${token?.substring(0, 20)}...');
      
      final user = User.fromJson(response.data);
      print('👤 User parsed: ${user.name} (${user.email})');
      
      // Store token and user data
      await _secureStorage.write(key: 'auth_token', value: token);
      print('✅ Token stored');
      
      await _saveUserData(user);
      print('User data stored');
      
      return user;
    } on DioException catch (e) {
      print('Login failed: ${e.message}');
      print('Response: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_data');
    }
  }

  // User Data Management
  Future<void> _saveUserData(User user) async {
    try {
      print('Saving user data: ${user.name} (${user.email})');
      final userJson = jsonEncode(user.toJson());
      print('User JSON to save: $userJson');
      await _secureStorage.write(key: 'user_data', value: userJson);
      print('User data saved successfully');
    } catch (e, stackTrace) {
      print('Error saving user data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

 Future<User?> getCurrentUser() async {
  try {
    print('Reading user data from secure storage...');
    final userJson = await _secureStorage.read(key: 'user_data');
    print('Stored user JSON: $userJson'); 
    
    if (userJson == null) {
      print('No user data found in storage');
      return null;
    }
    
    print('User JSON found: $userJson');
    final userData = jsonDecode(userJson);
    print('User data decoded successfully');
    
    return User.fromJson(userData);
  } catch (e, stackTrace) {
    print('Error getting current user: $e');
    print('Stack trace: $stackTrace');
    return null;
  }
}

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return token != null;
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

  // Category Methods
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

  // Order Methods
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

  // Cart Methods
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
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      return CartItem.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Error response: ${e.response?.data}');
      throw _handleError(e);
    }
  }

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

  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _dio.delete('/cart/$cartItemId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/cart/clear');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
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
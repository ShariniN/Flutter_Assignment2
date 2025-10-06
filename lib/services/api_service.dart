import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/wishlist_item.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = "https://ssp2-assignment-production.up.railway.app/api";
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('🚀 REQUEST[${options.method}] => ${options.path}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ RESPONSE[${response.statusCode}] => ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('❌ ERROR[${e.response?.statusCode}]: ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  // -----------------------------
  // Auth
  // -----------------------------
  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        "name": name,
        "email": email,
        "password": password,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['token']);

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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['token']);

      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {
      print('Logout API call failed: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }

  // -----------------------------
  // Products
  // -----------------------------
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products');

      print('Raw Products JSON: ${response.data}');

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
      print('Raw Product JSON: ${response.data}');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // -----------------------------
  // Categories
  // -----------------------------
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      print('Raw Categories JSON: ${response.data}');

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
      print('Raw Products by Category JSON: ${response.data}');

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

  // -----------------------------
  // Wishlist
  // -----------------------------
  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _dio.get('/wishlist');
      print('Raw Wishlist JSON: ${response.data}');
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

  // -----------------------------
  // Orders
  // -----------------------------
  Future<Order> placeOrder(List<int> productIds) async {
    try {
      final response = await _dio.post('/orders', data: {"products": productIds});
      print('Raw Order JSON: ${response.data}');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      print('Raw Orders JSON: ${response.data}');
      return (response.data as List).map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // -----------------------------
  // Error handling
  // -----------------------------
 String _handleError(DioException e) {
  print("⚠️ Dio error type: ${e.type}");
  print("⚠️ Dio error message: ${e.message}");
  print("⚠️ Dio error response: ${e.response?.data}");

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


  // Add this temporary method to debug categories
Future<void> debugCategories() async {
  try {
    print('=== DEBUGGING CATEGORIES ===');
    final response = await _dio.get('/categories');
    
    print('Categories Response Type: ${response.data.runtimeType}');
    print('Categories Full Response: ${response.data}');
    
    if (response.data is List) {
      print('✅ Categories is a List with ${(response.data as List).length} items');
      for (int i = 0; i < (response.data as List).length; i++) {
        print('Item $i: ${(response.data as List)[i]}');
      }
    } else if (response.data is Map) {
      print('✅ Categories is a Map with keys: ${(response.data as Map).keys}');
    }
    
    // Try to parse categories
    final categories = await getCategories();
    print('✅ Successfully parsed ${categories.length} categories');
    
  } catch (e) {
    print('❌ Categories error: $e');
    print('Stack trace: ${e.toString()}');
  }
}
}

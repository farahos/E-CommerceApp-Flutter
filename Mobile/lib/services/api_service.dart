import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart' as models;
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

// Cookie management - only imported on non-web platforms
// On web, browsers handle cookies automatically

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    // On web, cookies are handled automatically by the browser
    // Dio will send/receive cookies through the browser's fetch API
    // No additional configuration needed for web
    
    // Only use cookie manager on non-web platforms (mobile/desktop)
    if (!kIsWeb) {
      _setupCookieManager();
    }
  }
  
  void _setupCookieManager() {
    // Cookie manager setup for mobile/desktop platforms
    // On web, this is not called and cookies are handled by the browser
    // For now, we'll skip cookie manager setup
    // If needed for mobile, uncomment and ensure proper imports:
    /*
    try {
      final cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(cookieJar));
    } catch (e) {
      // Cookie manager not available
    }
    */
  }

  // User APIs
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    String? role,
  }) async {
    try {
      final response = await _dio.post(
        '/user/registerUser',
        data: {
          'email': email,
          'username': username,
          'password': password,
          if (role != null) 'role': role,
        },
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': response.data['message']};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Registration failed'};
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Error: ${e.message}'
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/user/loginUser',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userIdKey, data['_id']);
        await prefs.setString(AppConstants.userEmailKey, data['email']);
        await prefs.setString(AppConstants.userNameKey, data['username']);
        await prefs.setString(AppConstants.userRoleKey, data['role'] ?? 'user');
        
        // Token is in cookie, but we'll store a flag
        await prefs.setBool(AppConstants.userTokenKey, true);
        
        return {
          'success': true,
          'user': User.fromJson(data),
        };
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Login failed'};
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Error: ${e.message}'
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Product APIs
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Category APIs
  Future<List<models.Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => models.Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Cart APIs
  Future<Cart?> addToCart({
    required String userId,
    required String productId,
    int qty = 1,
  }) async {
    try {
      final response = await _dio.post(
        '/cart/add',
        data: {
          'userId': userId,
          'productId': productId,
          'qty': qty,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Cart.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Cart?> getCart(String userId) async {
    try {
      final response = await _dio.get('/cart/$userId');

      if (response.statusCode == 200) {
        return Cart.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Cart?> updateCartItem({
    required String userId,
    required String productId,
    required int qty,
  }) async {
    try {
      final response = await _dio.put(
        '/cart/$userId/$productId',
        data: {'qty': qty},
      );

      if (response.statusCode == 200) {
        return Cart.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeCartItem({
    required String userId,
    required String productId,
  }) async {
    try {
      final response = await _dio.delete('/cart/$userId/$productId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearCart(String userId) async {
    try {
      final response = await _dio.delete('/cart/$userId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Order APIs
  Future<Order?> createOrder(String userId) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: {'userId': userId},
      );

      if (response.statusCode == 201) {
        return Order.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final response = await _dio.get('/orders/user/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Order?> getOrderById(String id) async {
    try {
      final response = await _dio.get('/orders/$id');

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Password Reset
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '/forgetpassword',
        data: {'email': email},
      );

      return {
        'success': response.statusCode == 200,
        'message': response.data['message'] ?? 'Request sent',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Error: ${e.message}'
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}

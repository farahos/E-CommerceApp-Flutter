import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_app/core/constants/api_constants.dart';
import 'package:your_app/core/utils/helpers.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      'Cookie': 'token=$token',
    };
  }

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Token expired or invalid
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      throw Exception('Unauthorized');
    }
    
    if (response.statusCode >= 400) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Something went wrong');
    }
    
    return response;
  }

  // Auth APIs
  Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Product APIs
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.products),
        headers: await _getHeaders(),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.products}/$id'),
        headers: await _getHeaders(),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.products),
        headers: await _getHeaders(),
        body: json.encode(data),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.products}/$id'),
        headers: await _getHeaders(),
        body: json.encode(data),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.products}/$id'),
        headers: await _getHeaders(),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Category APIs
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.categories),
        headers: await _getHeaders(),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.categories),
        headers: await _getHeaders(),
        body: json.encode(data),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Cart APIs
  Future<dynamic> getCart(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.cart}/$userId'),
        headers: await _getHeaders(),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> addToCart(String userId, String productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.cart}/add'),
        headers: await _getHeaders(),
        body: json.encode({
          'userId': userId,
          'productId': productId,
          'qty': quantity,
        }),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Order APIs
  Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.orders}/user/$userId'),
        headers: await _getHeaders(),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.orders),
        headers: await _getHeaders(),
        body: json.encode(data),
      ).timeout(ApiConstants.connectTimeout);

      final handledResponse = await _handleResponse(response);
      return json.decode(handledResponse.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
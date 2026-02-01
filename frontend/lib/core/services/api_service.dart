import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static late Dio _dio;
  
  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token from cookies
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Cookie'] = 'token=$token';
        }
        
        // For Flutter Web, we need to handle cookies differently
        options.headers['credentials'] = 'include';
        
        if (kDebugMode) {
          print('Request: ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('Response: ${response.statusCode} ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          print('Error: ${error.response?.statusCode} ${error.message}');
        }
        
        // Handle token expiration
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          await StorageService.clear();
          // You might want to navigate to login screen here
        }
        
        return handler.next(error);
      },
    ));
  }
  
  // GET request
  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'credentials': 'include',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // POST request
  static Future<Response> post(String endpoint, dynamic data) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'credentials': 'include',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // PUT request
  static Future<Response> put(String endpoint, dynamic data) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        options: Options(
          headers: {
            'credentials': 'include',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // DELETE request
  static Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(
        endpoint,
        options: Options(
          headers: {
            'credentials': 'include',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Multipart request for file uploads
  static Future<Response> multipartPost(String endpoint, FormData formData) async {
    try {
      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'credentials': 'include',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
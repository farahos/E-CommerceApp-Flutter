import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ecommerce_app/core/constants/api_constants.dart';

class ApiService {
  static late Dio _dio;

  // 🔹 INIT
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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('➡️ ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ ${response.statusCode} ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('❌ ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ================== REQUEST METHODS ==================

  /// GET
  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    return await _dio.get(
      endpoint,
      queryParameters: queryParams,
      options: Options(
        extra: {'withCredentials': true}, // ✅ COOKIE
      ),
    );
  }

  /// POST
  static Future<Response> post(String endpoint, dynamic data) async {
    return await _dio.post(
      endpoint,
      data: data,
      options: Options(
        extra: {'withCredentials': true}, // ✅ COOKIE
      ),
    );
  }

  /// PUT
  static Future<Response> put(String endpoint, dynamic data) async {
    return await _dio.put(
      endpoint,
      data: data,
      options: Options(
        extra: {'withCredentials': true}, // ✅ COOKIE
      ),
    );
  }

  /// DELETE
  static Future<Response> delete(String endpoint) async {
    return await _dio.delete(
      endpoint,
      options: Options(
        extra: {'withCredentials': true}, // ✅ COOKIE
      ),
    );
  }

  /// MULTIPART (UPLOAD)
  static Future<Response> multipartPost(
    String endpoint,
    FormData formData,
  ) async {
    return await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        extra: {'withCredentials': true}, // ✅ COOKIE
      ),
    );
  }
}

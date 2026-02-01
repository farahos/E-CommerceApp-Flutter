class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  static const String login = '$baseUrl/user/loginUser';
  static const String register = '$baseUrl/user/registerUser';
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/categories';
  static const String cart = '$baseUrl/cart';
  static const String orders = '$baseUrl/orders';
  static const String forgetPassword = '$baseUrl/forgetpassword';
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
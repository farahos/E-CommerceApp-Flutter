class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // User endpoints
  static const String register = '$baseUrl/user/registerUser';
  static const String login = '$baseUrl/user/loginUser';
  
  // Product endpoints
  static const String products = '$baseUrl/products';
  
  // Category endpoints
  static const String categories = '$baseUrl/categories';
  
  // Cart endpoints
  static const String cart = '$baseUrl/cart';
  
  // Order endpoints
  static const String orders = '$baseUrl/orders';
  
  // Password reset
  static const String forgetPassword = '$baseUrl/forgetpassword';
}

class AppConstants {
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String userRoleKey = 'user_role';
}

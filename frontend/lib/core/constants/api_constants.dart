class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  // For production: 'https://your-domain.com/api'
  
  // Auth endpoints
  static const String login = '/user/loginUser';
  static const String register = '/user/registerUser';
  static const String forgotPassword = '/forgetpassword';
  
  // Product endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  
  // Category endpoints
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';
  
  // Cart endpoints
  static const String cart = '/cart';
  static String userCart(String userId) => '/cart/$userId';
  static String cartAdd = '/cart/add';
  static String cartUpdate(String userId, String productId) => '/cart/$userId/$productId';
  static String cartRemove(String userId, String productId) => '/cart/$userId/$productId';
  static String clearCart(String userId) => '/cart/$userId';
  
  // Order endpoints
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String userOrders(String userId) => '/orders/user/$userId';
  static String updateOrderStatus(String id) => '/orders/$id/status';
}
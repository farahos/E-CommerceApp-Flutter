import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _prefs;
    await prefs.setString('userId', userData['_id'] ?? '');
    await prefs.setString('username', userData['username'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('role', userData['role'] ?? 'user');
    await prefs.setString('token', userData['token'] ?? '');
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await _prefs;
    return {
      'userId': prefs.getString('userId') ?? '',
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'role': prefs.getString('role') ?? 'user',
      'token': prefs.getString('token') ?? '',
    };
  }

  Future<String> getToken() async {
    final prefs = await _prefs;
    return prefs.getString('token') ?? '';
  }

  Future<String> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString('userId') ?? '';
  }

  Future<String> getUserRole() async {
    final prefs = await _prefs;
    return prefs.getString('role') ?? 'user';
  }

  Future<void> clearUserData() async {
    final prefs = await _prefs;
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('token');
  }

  // Cart data (local cache)
  Future<void> saveCartData(List<dynamic> cartItems) async {
    final prefs = await _prefs;
    await prefs.setString('cart', json.encode(cartItems));
  }

  Future<List<dynamic>> getCartData() async {
    final prefs = await _prefs;
    final cartJson = prefs.getString('cart');
    if (cartJson != null) {
      return json.decode(cartJson);
    }
    return [];
  }

  Future<void> clearCartData() async {
    final prefs = await _prefs;
    await prefs.remove('cart');
  }
}
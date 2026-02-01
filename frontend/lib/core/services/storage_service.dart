import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _preferences;
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  // Token methods
  static Future<void> setToken(String token) async {
    await _preferences.setString(_tokenKey, token);
  }
  
  static String? getToken() {
    return _preferences.getString(_tokenKey);
  }
  
  static Future<void> clearToken() async {
    await _preferences.remove(_tokenKey);
  }
  
  // User data methods
  static Future<void> setUserData(Map<String, dynamic> userData) async {
    await _preferences.setString(_userKey, jsonEncode(userData));
    if (userData['_id'] != null) {
      await _preferences.setString(_userIdKey, userData['_id']);
    }
    if (userData['role'] != null) {
      await _preferences.setString(_userRoleKey, userData['role']);
    }
  }
  
  static Map<String, dynamic>? getUserData() {
    final data = _preferences.getString(_userKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }
  
  static String? getUserId() {
    return _preferences.getString(_userIdKey);
  }
  
  static String? getUserRole() {
    return _preferences.getString(_userRoleKey);
  }
  
  static Future<void> clearUserData() async {
    await _preferences.remove(_userKey);
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_userRoleKey);
  }
  
  // Clear all storage
  static Future<void> clear() async {
    await clearToken();
    await clearUserData();
  }
  
  // Check if user is logged in
  static bool isLoggedIn() {
    return getToken() != null && getUserData() != null;
  }
  
  // Check if user is admin
  static bool isAdmin() {
    return getUserRole() == 'admin';
  }
}
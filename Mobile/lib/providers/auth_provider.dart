import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();
  bool _isCheckingAuth = false;

  Future<void> checkAuth() async {
    if (_isCheckingAuth) return;
    
    _isCheckingAuth = true;
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.getBool(AppConstants.userTokenKey) ?? false;
      final userId = prefs.getString(AppConstants.userIdKey);
      final email = prefs.getString(AppConstants.userEmailKey);
      final username = prefs.getString(AppConstants.userNameKey);
      final role = prefs.getString(AppConstants.userRoleKey);

      if (hasToken && userId != null && email != null && username != null) {
        _user = User(
          id: userId,
          email: email,
          username: username,
          role: role ?? 'user',
        );
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    }

    _isLoading = false;
    _isCheckingAuth = false;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    String? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(
        email: email,
        username: username,
        password: password,
        role: role,
      );

      _isLoading = false;
      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Registration failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(
        username: username,
        password: password,
      );

      _isLoading = false;
      if (result['success']) {
        _user = result['user'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userEmailKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.remove(AppConstants.userRoleKey);

    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

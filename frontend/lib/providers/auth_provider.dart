import 'package:flutter/material.dart';
import 'dart:convert';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String _error = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await ApiService.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Save token (cookies are handled by browser)
        if (data['token'] != null) {
          await StorageService.setToken(data['token']);
        }
        
        // Save user data
        final userData = data['user'] ?? data;
        _user = UserModel.fromJson(userData);
        await StorageService.setUserData(userData);
        
        _error = '';
      } else {
        _error = response.data['message'] ?? 'Login failed';
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String username, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await ApiService.post(ApiConstants.register, {
        'email': email,
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        if (data['token'] != null) {
          await StorageService.setToken(data['token']);
        }
        
        final userData = data['user'] ?? data;
        _user = UserModel.fromJson(userData);
        await StorageService.setUserData(userData);
        
        _error = '';
      } else {
        _error = response.data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> autoLogin() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = StorageService.getUserData();
      if (userData != null) {
        _user = UserModel.fromJson(userData);
      }
    } catch (e) {
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _error = '';
    await StorageService.clear();
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
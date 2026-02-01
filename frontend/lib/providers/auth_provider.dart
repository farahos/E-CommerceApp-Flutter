import 'package:flutter/material.dart';
import 'package:e-commerce_app/core/services/api_service.dart';
import 'package:e-commerce_app/core/services/storage_service.dart';
import 'package:e-commerce_app/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize from storage
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userData = await StorageService().getUserData();
      if (userData['userId']!.isNotEmpty) {
        _user = UserModel.fromJson(userData);
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().login(email, password);
      
      if (response['success'] == true) {
        final userData = response['data'];
        userData['token'] = response['token'];
        
        _user = UserModel.fromJson(userData);
        await StorageService().saveUserData(_user!.toJson());
        
        return true;
      } else {
        _error = response['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(String username, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().register(username, email, password);
      
      if (response['success'] == true) {
        final userData = response['data'];
        userData['token'] = response['token'];
        
        _user = UserModel.fromJson(userData);
        await StorageService().saveUserData(_user!.toJson());
        
        return true;
      } else {
        _error = response['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    await StorageService().clearUserData();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
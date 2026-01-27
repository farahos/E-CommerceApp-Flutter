import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class CartProvider with ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get itemCount => _cart?.totalItems ?? 0;
  double get totalPrice => _cart?.totalPrice ?? 0.0;

  final ApiService _apiService = ApiService();

  Future<void> fetchCart(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _apiService.getCart(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load cart: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required String userId,
    required String productId,
    int qty = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCart = await _apiService.addToCart(
        userId: userId,
        productId: productId,
        qty: qty,
      );

      if (updatedCart != null) {
        _cart = updatedCart;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'Failed to add item to cart';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCartItem({
    required String userId,
    required String productId,
    required int qty,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCart = await _apiService.updateCartItem(
        userId: userId,
        productId: productId,
        qty: qty,
      );

      if (updatedCart != null) {
        _cart = updatedCart;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'Failed to update cart item';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeCartItem({
    required String userId,
    required String productId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.removeCartItem(
        userId: userId,
        productId: productId,
      );

      if (success) {
        await fetchCart(userId);
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'Failed to remove item from cart';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.clearCart(userId);
      if (success) {
        _cart = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'Failed to clear cart';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

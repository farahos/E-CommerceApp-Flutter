import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/constants/api_constants.dart';
import 'package:ecommerce_app/core/services/api_service.dart';
import 'package:ecommerce_app/core/services/storage_service.dart';
import 'package:ecommerce_app/models/cart_item_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String _error = '';

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get itemCount => _cartItems.length;
  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.total);

  Future<void> fetchCart() async {
    try {
      final userId = StorageService.getUserId();
      if (userId == null) return;

      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await ApiService.get(ApiConstants.userCart(userId));
      
      if (response.statusCode == 200) {
        final cartData = response.data;
        if (cartData['items'] != null) {
          _cartItems = (cartData['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
        }
      } else if (response.statusCode == 404) {
        // Cart doesn't exist yet, create empty cart
        _cartItems = [];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    try {
      final userId = StorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      _isLoading = true;
      notifyListeners();

      final response = await ApiService.post(ApiConstants.cartAdd, {
        'userId': userId,
        'productId': product.id,
        'qty': quantity,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update local cart
        final existingIndex = _cartItems
            .indexWhere((item) => item.productId == product.id);
        
        if (existingIndex >= 0) {
          _cartItems[existingIndex].qty += quantity;
        } else {
          _cartItems.add(CartItem(
            productId: product.id,
            productName: product.name,
            productPrice: product.price,
            productImage: product.images.isNotEmpty ? product.images.first : null,
            qty: quantity,
          ));
        }
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    try {
      final userId = StorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      _isLoading = true;
      notifyListeners();

      final response = await ApiService.put(
        ApiConstants.cartUpdate(userId, productId),
        {'qty': quantity},
      );

      if (response.statusCode == 200) {
        final index = _cartItems.indexWhere((item) => item.productId == productId);
        if (index >= 0) {
          if (quantity <= 0) {
            _cartItems.removeAt(index);
          } else {
            _cartItems[index].qty = quantity;
          }
        }
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final userId = StorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      _isLoading = true;
      notifyListeners();

      final response = await ApiService.delete(
        ApiConstants.cartRemove(userId, productId),
      );

      if (response.statusCode == 200) {
        _cartItems.removeWhere((item) => item.productId == productId);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      final userId = StorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      _isLoading = true;
      notifyListeners();

      final response = await ApiService.delete(
        ApiConstants.clearCart(userId),
      );

      if (response.statusCode == 200) {
        _cartItems.clear();
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getProductQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(productId: '', qty: 0),
    );
    return item.qty;
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
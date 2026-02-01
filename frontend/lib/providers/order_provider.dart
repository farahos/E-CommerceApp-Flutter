import 'package:flutter/material.dart';
import 'package:e_commerce_app/core/services/api_service.dart';
import 'package:e_commerce_app/core/services/storage_service.dart';
import 'package:e_commerce_app/models/cart_item_model.dart';
import 'package:e_commerce_app/models/product_model.dart';
import 'package:e_commerce_app/providers/product_provider.dart';
class CartProvider with ChangeNotifier {
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _cartItems.length;
  double get totalAmount {
    return _cartItems.fold(0, (total, item) => total + item.totalPrice);
  }

  // Load cart from server
  Future<void> loadCart(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().getCart(userId);
      
      if (response['success'] == true) {
        final items = response['data']['items'] ?? [];
        final productProvider = ProductProvider();
        await productProvider.fetchProducts();
        
        _cartItems = [];
        for (var item in items) {
          final product = productProvider.products.firstWhere(
            (p) => p.id == item['productId'],
            orElse: () => ProductModel(
              id: '',
              name: '',
              price: 0,
              stock: 0,
              description: '',
              images: [],
              categoryId: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          
          if (product.id.isNotEmpty) {
            _cartItems.add(CartItemModel.fromJson(item, product));
          }
        }
        
        // Save locally for offline access
        await StorageService().saveCartData(
          _cartItems.map((item) => item.toJson()).toList(),
        );
      }
    } catch (e) {
      // Fallback to local storage
      final localCart = await StorageService().getCartData();
      if (localCart.isNotEmpty) {
        // TODO: Convert local cart data to CartItemModel
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<bool> addToCart(String userId, ProductModel product, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if already in cart
      final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
      
      if (existingIndex >= 0) {
        // Update quantity
        final newQuantity = _cartItems[existingIndex].quantity + quantity;
        if (newQuantity <= product.stock) {
          await ApiService().addToCart(userId, product.id, newQuantity);
          _cartItems[existingIndex].quantity = newQuantity;
        } else {
          throw Exception('Insufficient stock');
        }
      } else {
        // Add new item
        await ApiService().addToCart(userId, product.id, quantity);
        _cartItems.add(CartItemModel(
          productId: product.id,
          productName: product.name,
          price: product.price,
          image: product.images.isNotEmpty ? product.images[0] : '',
          quantity: quantity,
          stock: product.stock,
        ));
      }
      
      // Save locally
      await StorageService().saveCartData(
        _cartItems.map((item) => item.toJson()).toList(),
      );
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update item quantity
  Future<bool> updateQuantity(String userId, String productId, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();

      final index = _cartItems.indexWhere((item) => item.productId == productId);
      
      if (index >= 0 && quantity > 0 && quantity <= _cartItems[index].stock) {
        await ApiService().addToCart(userId, productId, quantity);
        _cartItems[index].quantity = quantity;
        
        // Save locally
        await StorageService().saveCartData(
          _cartItems.map((item) => item.toJson()).toList(),
        );
        
        return true;
      } else if (quantity == 0) {
        return await removeItem(userId, productId);
      } else {
        throw Exception('Invalid quantity');
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<bool> removeItem(String userId, String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Call API to remove item
      // await ApiService().removeFromCart(userId, productId);
      
      _cartItems.removeWhere((item) => item.productId == productId);
      
      // Save locally
      await StorageService().saveCartData(
        _cartItems.map((item) => item.toJson()).toList(),
      );
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TODO: Call API to clear cart
      // await ApiService().clearCart(userId);
      
      _cartItems.clear();
      await StorageService().clearCartData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
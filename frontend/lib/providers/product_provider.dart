import 'package:flutter/material.dart';
import 'package:e_commerce_app/core/services/api_service.dart';
import 'package:e_commerce_app/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = '';

  List<ProductModel> get products => _filteredProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all products
  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().getProducts();
      _products = List<ProductModel>.from(
        response.map((item) => ProductModel.fromJson(item)),
      );
      
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch single product
  Future<void> fetchProductById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().getProductById(id);
      _selectedProduct = ProductModel.fromJson(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create product (admin)
  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      await ApiService().createProduct(data);
      await fetchProducts(); // Refresh list
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update product (admin)
  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      await ApiService().updateProduct(id, data);
      await fetchProducts(); // Refresh list
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete product (admin)
  Future<bool> deleteProduct(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await ApiService().deleteProduct(id);
      await fetchProducts(); // Refresh list
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Filter by category
  void filterByCategory(String categoryId) {
    _selectedCategory = categoryId;
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty || 
          product.name.toLowerCase().contains(_searchQuery) ||
          product.description.toLowerCase().contains(_searchQuery);
      
      final matchesCategory = _selectedCategory.isEmpty || 
          product.categoryId == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
    
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _applyFilters();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
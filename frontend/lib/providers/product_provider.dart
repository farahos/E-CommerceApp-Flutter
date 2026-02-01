import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../models/product_model.dart';
import '../core/constants/api_constants.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String? _selectedCategory;

  List<ProductModel> get products => _filteredProducts;
  List<ProductModel> get allProducts => _products;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await ApiService.get(ApiConstants.products);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _products = data.map((json) => ProductModel.fromJson(json)).toList();
        _filteredProducts = List.from(_products);
        _error = '';
      } else {
        _error = 'Failed to load products';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> fetchProductById(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.get(ApiConstants.productById(id));
      
      if (response.statusCode == 200) {
        _selectedProduct = ProductModel.fromJson(response.data);
        return _selectedProduct;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(ProductModel product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.post(
        ApiConstants.products,
        product.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.put(
        ApiConstants.productById(product.id),
        product.toJson(),
      );

      if (response.statusCode == 200) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.delete(ApiConstants.productById(id));

      if (response.statusCode == 200) {
        _products.removeWhere((product) => product.id == id);
        _filteredProducts.removeWhere((product) => product.id == id);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByCategory(String? categoryId) {
    _selectedCategory = categoryId;
    if (categoryId == null) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((product) => product.categoryId == categoryId)
          .toList();
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  void setSelectedProduct(ProductModel? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  final ApiService _apiService = ApiService();

  List<Product> get filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _apiService.getProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load products: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> fetchProductById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await _apiService.getProductById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load product: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}

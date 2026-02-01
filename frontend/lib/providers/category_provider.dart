import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/services/api_service.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/core/constants/api_constants.dart';
class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;
  String _error = '';

  List<CategoryModel> get categories => _categories;
  CategoryModel? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await ApiService.get(ApiConstants.categories);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
        _error = '';
      } else {
        _error = 'Khalad ayaa dhacay markii la soo dejiyay qaybaha';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CategoryModel?> fetchCategoryById(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.get(ApiConstants.categoryById(id));
      
      if (response.statusCode == 200) {
        _selectedCategory = CategoryModel.fromJson(response.data);
        return _selectedCategory;
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

  Future<bool> createCategory(CategoryModel category) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.post(
        ApiConstants.categories,
        category.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCategories();
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

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.put(
        ApiConstants.categoryById(category.id),
        category.toJson(),
      );

      if (response.statusCode == 200) {
        await fetchCategories();
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

  Future<bool> deleteCategory(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.delete(ApiConstants.categoryById(id));

      if (response.statusCode == 200) {
        _categories.removeWhere((category) => category.id == id);
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

  void filterByCategory(String? categoryId) {
    _selectedCategory = categoryId != null
        ? _categories.firstWhere((cat) => cat.id == categoryId)
        : null;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    notifyListeners();
  }

  String? getCategoryName(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return null;
    }
  }

  void setSelectedCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
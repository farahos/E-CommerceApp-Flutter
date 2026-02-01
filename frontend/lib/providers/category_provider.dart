import 'package:flutter/material.dart';
import 'package:e_commerce_app/core/services/api_service.dart';
import 'package:e_commerce_app/models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;
  String? _error;
  FormMode _formMode = FormMode.create;

  List<CategoryModel> get categories => _categories;
  CategoryModel? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FormMode get formMode => _formMode;

  // Fetch all categories
  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().getCategories();
      _categories = List<CategoryModel>.from(
        response.map((item) => CategoryModel.fromJson(item)),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create category
  Future<bool> createCategory(String name, String description) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await ApiService().createCategory({
        'name': name,
        'description': description,
      });

      await fetchCategories(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update category
  Future<bool> updateCategory(String id, String name, String description) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await ApiService().updateCategory(id, {
        'name': name,
        'description': description,
      });

      await fetchCategories(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete category
  Future<bool> deleteCategory(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await ApiService().deleteCategory(id);
      
      // Remove from local list
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select category
  void selectCategory(CategoryModel category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear selected category
  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  // Set form mode
  void setFormMode(FormMode mode) {
    _formMode = mode;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category name by ID
  String getCategoryNameById(String id) {
    final category = getCategoryById(id);
    return category?.name ?? 'Unknown Category';
  }

  // Check if category exists
  bool categoryExists(String name) {
    return _categories.any((category) => 
        category.name.toLowerCase() == name.toLowerCase());
  }
}
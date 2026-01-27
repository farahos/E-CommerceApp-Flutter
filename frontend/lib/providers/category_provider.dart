import 'package:flutter/foundation.dart';
import '../models/category_model.dart' as models;
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<models.Category> _categories = [];
  models.Category? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  List<models.Category> get categories => _categories;
  models.Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load categories: ${e.toString()}';
      notifyListeners();
    }
  }

  void setSelectedCategory(models.Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }
}

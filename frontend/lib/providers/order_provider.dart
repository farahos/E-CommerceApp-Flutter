import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/services/api_service.dart';
import 'package:ecommerce_app/core/services/storage_service.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/core/constants/api_constants.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  List<OrderModel> _adminOrders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String _error = '';
  String _filterStatus = 'all';

  List<OrderModel> get orders => _orders;
  List<OrderModel> get adminOrders => _adminOrders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get filterStatus => _filterStatus;

  Future<void> fetchUserOrders() async {
    try {
      final userId = StorageService.getUserId();
      if (userId == null) throw Exception('User ma login ahayn');

      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await ApiService.get(ApiConstants.userOrders(userId));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _orders = data.map((json) => OrderModel.fromJson(json)).toList();
        _error = '';
      } else {
        _error = 'Khalad ayaa dhacay markii la soo dejiyay dalabaadka';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Note: Your backend needs to implement GET /api/orders to get all orders
      final response = await ApiService.get('${ApiConstants.baseUrl}/orders');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _adminOrders = data.map((json) => OrderModel.fromJson(json)).toList();
        _error = '';
      } else {
        _error = 'Khalad ayaa dhacay markii la soo dejiyay dalabaadka';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> fetchOrderById(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.get(ApiConstants.orderById(id));
      
      if (response.statusCode == 200) {
        _selectedOrder = OrderModel.fromJson(response.data);
        return _selectedOrder;
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

  Future<bool> createOrder(List<Map<String, dynamic>> items, double totalPrice) async {
    try {
      final userId = StorageService.getUserId();
      if (userId == null) throw Exception('User ma login ahayn');

      _isLoading = true;
      notifyListeners();

      final response = await ApiService.post(ApiConstants.orders, {
        'userId': userId,
        'items': items,
        'totalPrice': totalPrice,
        'status': 'pending',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchUserOrders();
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

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.put(
        ApiConstants.updateOrderStatus(orderId),
        {'status': status},
      );

      if (response.statusCode == 200) {
        await fetchAllOrders();
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

  List<OrderModel> getFilteredOrders() {
    if (_filterStatus == 'all') {
      return _orders;
    }
    return _orders.where((order) => order.status == _filterStatus).toList();
  }

  List<OrderModel> getFilteredAdminOrders() {
    if (_filterStatus == 'all') {
      return _adminOrders;
    }
    return _adminOrders.where((order) => order.status == _filterStatus).toList();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSelectedOrder(OrderModel? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Map<String, int> getOrderStats() {
    final stats = {
      'pending': 0,
      'paid': 0,
      'shipped': 0,
      'delivered': 0,
      'cancelled': 0,
      'total': _adminOrders.length,
    };

    for (var order in _adminOrders) {
      stats[order.status] = (stats[order.status] ?? 0) + 1;
    }

    return stats;
  }
}
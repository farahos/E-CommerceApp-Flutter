import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_constants.dart';
import 'storage_service.dart';

enum SocketEvent {
  connect,
  disconnect,
  connectError,
  connectTimeout,
  error,
  reconnect,
  reconnectAttempt,
  reconnectError,
  reconnectFailed,
}

class SocketService {
  static SocketService? _instance;
  io.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  final List<Function(String, dynamic)> _listeners = [];
  final Map<String, List<Function(dynamic)>> _eventListeners = {};
  StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  StreamController<SocketEvent> _eventController = StreamController.broadcast();

  // Private constructor
  SocketService._internal();

  // Singleton instance
  static SocketService get instance {
    _instance ??= SocketService._internal();
    return _instance!;
  }

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<SocketEvent> get eventStream => _eventController.stream;

  // Initialize and connect to socket
  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;

    try {
      _isConnecting = true;
      
      // Get base URL and token
      final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
      final token = await StorageService.getToken();
      
      if (kDebugMode) {
        print('🔄 Connecting to socket at: $baseUrl');
      }

      // Create socket connection
      _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .setTimeout(20000)
            .setAuth({'token': token})
            .build(),
      );

      // Setup event listeners
      _setupEventListeners();
      
      // Connect
      _socket?.connect();

    } catch (e) {
      _isConnecting = false;
      if (kDebugMode) {
        print('❌ Socket connection error: $e');
      }
      _eventController.add(SocketEvent.connectError);
      rethrow;
    }
  }

  // Setup socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket?.on('connect', (_) {
      _isConnected = true;
      _isConnecting = false;
      if (kDebugMode) {
        print('✅ Socket connected successfully');
      }
      _eventController.add(SocketEvent.connect);
      
      // Emit user join event if user is logged in
      _emitUserJoin();
    });

    _socket?.on('disconnect', (_) {
      _isConnected = false;
      if (kDebugMode) {
        print('❌ Socket disconnected');
      }
      _eventController.add(SocketEvent.disconnect);
    });

    _socket?.on('connect_error', (error) {
      _isConnected = false;
      _isConnecting = false;
      if (kDebugMode) {
        print('❌ Socket connection error: $error');
      }
      _eventController.add(SocketEvent.connectError);
    });

    _socket?.on('connect_timeout', (_) {
      if (kDebugMode) {
        print('⏰ Socket connection timeout');
      }
      _eventController.add(SocketEvent.connectTimeout);
    });

    _socket?.on('error', (error) {
      if (kDebugMode) {
        print('⚠️ Socket error: $error');
      }
      _eventController.add(SocketEvent.error);
    });

    _socket?.on('reconnect', (_) {
      if (kDebugMode) {
        print('🔄 Socket reconnected');
      }
      _eventController.add(SocketEvent.reconnect);
    });

    _socket?.on('reconnect_attempt', (_) {
      if (kDebugMode) {
        print('🔄 Attempting to reconnect...');
      }
      _eventController.add(SocketEvent.reconnectAttempt);
    });

    _socket?.on('reconnect_error', (error) {
      if (kDebugMode) {
        print('❌ Socket reconnection error: $error');
      }
      _eventController.add(SocketEvent.reconnectError);
    });

    _socket?.on('reconnect_failed', (_) {
      if (kDebugMode) {
        print('❌ Socket reconnection failed');
      }
      _eventController.add(SocketEvent.reconnectFailed);
    });

    // Custom application events
    _setupApplicationListeners();
  }

  // Setup application-specific listeners
  void _setupApplicationListeners() {
    if (_socket == null) return;

    // Order updates
    _socket?.on('order_created', (data) {
      if (kDebugMode) {
        print('📦 New order created: $data');
      }
      _messageController.add({
        'event': 'order_created',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Notify event listeners
      _notifyEventListeners('order_created', data);
    });

    _socket?.on('order_updated', (data) {
      if (kDebugMode) {
        print('📦 Order updated: $data');
      }
      _messageController.add({
        'event': 'order_updated',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('order_updated', data);
    });

    _socket?.on('order_status_changed', (data) {
      if (kDebugMode) {
        print('📦 Order status changed: $data');
      }
      _messageController.add({
        'event': 'order_status_changed',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('order_status_changed', data);
    });

    // Product updates
    _socket?.on('product_created', (data) {
      if (kDebugMode) {
        print('🛍️ New product created: $data');
      }
      _messageController.add({
        'event': 'product_created',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('product_created', data);
    });

    _socket?.on('product_updated', (data) {
      if (kDebugMode) {
        print('🛍️ Product updated: $data');
      }
      _messageController.add({
        'event': 'product_updated',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('product_updated', data);
    });

    _socket?.on('product_deleted', (data) {
      if (kDebugMode) {
        print('🛍️ Product deleted: $data');
      }
      _messageController.add({
        'event': 'product_deleted',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('product_deleted', data);
    });

    // User notifications
    _socket?.on('user_notification', (data) {
      if (kDebugMode) {
        print('🔔 User notification: $data');
      }
      _messageController.add({
        'event': 'user_notification',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('user_notification', data);
    });

    // Admin notifications
    _socket?.on('admin_notification', (data) {
      if (kDebugMode) {
        print('👨‍💼 Admin notification: $data');
      }
      _messageController.add({
        'event': 'admin_notification',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('admin_notification', data);
    });

    // Chat messages
    _socket?.on('chat_message', (data) {
      if (kDebugMode) {
        print('💬 Chat message: $data');
      }
      _messageController.add({
        'event': 'chat_message',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('chat_message', data);
    });

    // System messages
    _socket?.on('system_message', (data) {
      if (kDebugMode) {
        print('⚙️ System message: $data');
      }
      _messageController.add({
        'event': 'system_message',
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _notifyEventListeners('system_message', data);
    });
  }

  // Emit user join event
  void _emitUserJoin() async {
    final userId = await StorageService.getUserId();
    final userRole = await StorageService.getUserRole();
    
    if (userId != null) {
      emit('user_join', {
        'userId': userId,
        'role': userRole ?? 'user',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Emit an event to server
  void emit(String event, dynamic data) {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ Cannot emit $event: Socket not connected');
      }
      return;
    }

    if (kDebugMode) {
      print('📤 Emitting $event: $data');
    }

    _socket?.emit(event, data);
  }

  // Subscribe to specific event
  void on(String event, Function(dynamic) callback) {
    if (!_eventListeners.containsKey(event)) {
      _eventListeners[event] = [];
    }
    _eventListeners[event]?.add(callback);
    
    // Also listen via socket if connected
    if (_socket != null && _isConnected) {
      _socket?.on(event, callback);
    }
  }

  // Unsubscribe from specific event
  void off(String event, Function(dynamic) callback) {
    _eventListeners[event]?.remove(callback);
    
    if (_socket != null) {
      _socket?.off(event, callback);
    }
  }

  // Notify event listeners
  void _notifyEventListeners(String event, dynamic data) {
    final listeners = _eventListeners[event];
    if (listeners != null) {
      for (final listener in listeners) {
        try {
          listener(data);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error in event listener for $event: $e');
          }
        }
      }
    }
  }

  // Add a message listener
  void addMessageListener(Function(String, dynamic) listener) {
    _listeners.add(listener);
  }

  // Remove a message listener
  void removeMessageListener(Function(String, dynamic) listener) {
    _listeners.remove(listener);
  }

  // Send chat message
  void sendChatMessage({
    required String roomId,
    required String message,
    String? senderId,
    String? senderName,
  }) {
    emit('send_message', {
      'roomId': roomId,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Join a room/group
  void joinRoom(String roomId) {
    emit('join_room', {
      'roomId': roomId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Leave a room/group
  void leaveRoom(String roomId) {
    emit('leave_room', {
      'roomId': roomId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Subscribe to order updates
  void subscribeToOrder(String orderId) {
    emit('subscribe_order', {
      'orderId': orderId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Unsubscribe from order updates
  void unsubscribeFromOrder(String orderId) {
    emit('unsubscribe_order', {
      'orderId': orderId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Subscribe to product updates
  void subscribeToProduct(String productId) {
    emit('subscribe_product', {
      'productId': productId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Unsubscribe from product updates
  void unsubscribeFromProduct(String productId) {
    emit('unsubscribe_product', {
      'productId': productId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Send notification to user
  void sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) {
    emit('send_notification', {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type ?? 'info',
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Send notification to all admins
  void sendNotificationToAdmins({
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) {
    emit('send_admin_notification', {
      'title': title,
      'message': message,
      'type': type ?? 'info',
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Disconnect socket
  Future<void> disconnect() async {
    if (_socket != null) {
      if (kDebugMode) {
        print('🔌 Disconnecting socket...');
      }
      
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _isConnected = false;
      _isConnecting = false;
      
      // Clear listeners
      _listeners.clear();
      _eventListeners.clear();
      
      // Close controllers
      if (!_messageController.isClosed) {
        _messageController.close();
      }
      if (!_eventController.isClosed) {
        _eventController.close();
      }
      
      // Create new controllers for reconnection
      _messageController = StreamController.broadcast();
      _eventController = StreamController.broadcast();
      
      if (kDebugMode) {
        print('✅ Socket disconnected successfully');
      }
    }
  }

  // Reconnect socket
  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }

  // Check connection status
  bool getConnectionStatus() {
    return _isConnected && _socket?.connected == true;
  }

  // Get socket ID
  String? getSocketId() {
    return _socket?.id;
  }

  // Cleanup resources
  void dispose() {
    disconnect();
    if (!_messageController.isClosed) {
      _messageController.close();
    }
    if (!_eventController.isClosed) {
      _eventController.close();
    }
  }
}

// Helper extension for SocketService
extension SocketServiceExtension on SocketService {
  // Send order status update
  void updateOrderStatus(String orderId, String status, {String? message}) {
    emit('update_order_status', {
      'orderId': orderId,
      'status': status,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Request order details
  void requestOrderDetails(String orderId) {
    emit('request_order_details', {
      'orderId': orderId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Subscribe to user's own orders
  void subscribeToMyOrders() async {
    final userId = await StorageService.getUserId();
    if (userId != null) {
      emit('subscribe_my_orders', {
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Get online users count
  void getOnlineUsersCount() {
    emit('get_online_users', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Ping server to check connection
  void ping() {
    emit('ping', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
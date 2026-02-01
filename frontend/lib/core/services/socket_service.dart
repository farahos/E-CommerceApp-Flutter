import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  final List<void Function(dynamic)> _messageListeners = [];

  bool get isConnected => _isConnected;
  io.Socket? get socket => _socket;

  // Initialize socket connection
  Future<void> initializeSocket(String token) async {
    try {
      if (_socket != null && _isConnected) {
        return;
      }

      // Connect to socket server
      _socket = io.io(
        'http://localhost:8000', // Sesuaikan dengan URL backend
        io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders({'token': token})
          .build(),
      );

      // Socket event listeners
      _socket!.onConnect((_) {
        _isConnected = true;
        if (kDebugMode) {
          print('Socket connected');
        }
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        if (kDebugMode) {
          print('Socket disconnected');
        }
      });

      _socket!.onError((error) {
        if (kDebugMode) {
          print('Socket error: $error');
        }
      });

      // Listen for messages
      _socket!.on('new_order', (data) {
        _notifyListeners(data);
      });

      _socket!.on('order_updated', (data) {
        _notifyListeners(data);
      });

      _socket!.on('new_product', (data) {
        _notifyListeners(data);
      });

      _socket!.connect();
    } catch (e) {
      if (kDebugMode) {
        print('Socket initialization error: $e');
      }
    }
  }

  // Add message listener
  void addMessageListener(void Function(dynamic) listener) {
    _messageListeners.add(listener);
  }

  // Remove message listener
  void removeMessageListener(void Function(dynamic) listener) {
    _messageListeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners(dynamic data) {
    for (final listener in _messageListeners) {
      listener(data);
    }
  }

  // Emit event
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    }
  }

  // Disconnect socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.clearListeners();
      _socket = null;
      _isConnected = false;
    }
  }

  // Join order room (for admin)
  void joinOrderRoom(String orderId) {
    emit('join_order_room', {'orderId': orderId});
  }

  // Leave order room
  void leaveOrderRoom(String orderId) {
    emit('leave_order_room', {'orderId': orderId});
  }

  // Send chat message
  void sendChatMessage(String orderId, String message, String userId) {
    emit('chat_message', {
      'orderId': orderId,
      'message': message,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Subscribe to order updates
  void subscribeToOrder(String orderId) {
    emit('subscribe_order', {'orderId': orderId});
  }

  // Unsubscribe from order updates
  void unsubscribeFromOrder(String orderId) {
    emit('unsubscribe_order', {'orderId': orderId});
  }
}
import 'product_model.dart';

class OrderItem {
  final String productId;
  final int qty;
  final double price;
  final Product? product;

  OrderItem({
    required this.productId,
    required this.qty,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] is String
          ? json['productId']
          : json['productId']?['_id'] ?? '',
      qty: json['qty'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      product: json['productId'] is Map
          ? Product.fromJson(json['productId'])
          : null,
    );
  }
}

enum OrderStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final OrderStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is String
          ? json['userId']
          : json['userId']?['_id'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: _parseStatus(json['status'] ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  static OrderStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'paid':
        return OrderStatus.paid;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

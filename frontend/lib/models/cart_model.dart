import 'product_model.dart';

class CartItem {
  final String productId;
  final int qty;
  final Product? product;

  CartItem({
    required this.productId,
    required this.qty,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] is String
          ? json['productId']
          : json['productId']?['_id'] ?? '',
      qty: json['qty'] ?? 1,
      product: json['productId'] is Map
          ? Product.fromJson(json['productId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'qty': qty,
    };
  }
}

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is String
          ? json['userId']
          : json['userId']?['_id'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  double get totalPrice {
    return items.fold(0.0, (sum, item) {
      if (item.product != null) {
        return sum + (item.product!.price * item.qty);
      }
      return sum;
    });
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.qty);
  }
}

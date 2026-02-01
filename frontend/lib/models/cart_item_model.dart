class CartItem {
  final String productId;
  final String? productName;
  final double? productPrice;
  final String? productImage;
  int qty;

  CartItem({
    required this.productId,
    this.productName,
    this.productPrice,
    this.productImage,
    this.qty = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      qty: json['qty'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'qty': qty,
    };
  }

  double get total => (productPrice ?? 0) * qty;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? productPrice,
    String? productImage,
    int? qty,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
      qty: qty ?? this.qty,
    );
  }
}

class CartModel {
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  int get itemCount => items.length;

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.total);
  }
}
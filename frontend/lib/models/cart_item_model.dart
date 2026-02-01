class CartItemModel {
  final String productId;
  final String productName;
  final double price;
  final String image;
  int quantity;
  final int stock;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.image,
    required this.quantity,
    required this.stock,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json, ProductModel product) {
    return CartItemModel(
      productId: json['productId'] ?? '',
      productName: product.name,
      price: product.price,
      image: product.images.isNotEmpty ? product.images[0] : '',
      quantity: json['qty'] ?? 1,
      stock: product.stock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'qty': quantity,
    };
  }

  double get totalPrice => price * quantity;

  void increaseQuantity() {
    if (quantity < stock) {
      quantity++;
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}
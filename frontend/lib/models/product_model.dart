class ProductModel {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String description;
  final List<String> images;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.images,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      categoryId: json['categoryId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'description': description,
      'images': images,
      'categoryId': categoryId,
    };
  }
}
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
  String? categoryName; // For display purposes

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
    this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      categoryId: json['categoryId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      categoryName: json['category']?['name'],
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

  bool get isInStock => stock > 0;

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? description,
    List<String>? images,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
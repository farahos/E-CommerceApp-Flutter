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
    name: json['name'],
    description: json['description'],
    price: (json['price'] as num).toDouble(),
    stock: json['stock'],
    categoryName: json['category']?['name'],
    categoryId: json['category']?['_id'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    images: (json['images'] as List)
        .map((img) => img['url'].toString())
        .toList(),
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
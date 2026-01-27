class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String description;
  final List<String> images;
  final String categoryId;
  final String? categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.images,
    required this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      categoryId: json['categoryId'] is String
          ? json['categoryId']
          : json['categoryId']?['_id'] ?? '',
      categoryName: json['categoryId'] is Map
          ? json['categoryId']['name']
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'description': description,
      'images': images,
      'categoryId': categoryId,
    };
  }
}

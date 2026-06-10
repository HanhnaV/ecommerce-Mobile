class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int productCount;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.productCount = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      productCount: json['productCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'productCount': productCount,
      'isActive': isActive,
    };
  }
}

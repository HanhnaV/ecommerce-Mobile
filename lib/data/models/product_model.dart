class ProductImage {
  final int id;
  final String imageUrl;
  final bool isThumbnail;

  const ProductImage({
    required this.id,
    required this.imageUrl,
    this.isThumbnail = false,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      isThumbnail: json['isThumbnail'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'isThumbnail': isThumbnail,
    };
  }
}

class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double basePrice;
  final String? sku;
  final String? categoryId;
  final String? categoryName;
  final int? shopId;
  final String? shopName;
  final String status;
  final List<ProductImage> images;
  final String? thumbnailUrl;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.basePrice,
    this.sku,
    this.categoryId,
    this.categoryName,
    this.shopId,
    this.shopName,
    this.status = 'PUBLISHED',
    this.images = const [],
    this.thumbnailUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['images'] as List<dynamic>?)
            ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final thumbnail = imagesList.where((img) => img.isThumbnail).firstOrNull ?? imagesList.firstOrNull;

    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      basePrice: (json['basePrice'] is num)
          ? (json['basePrice'] as num).toDouble()
          : double.tryParse(json['basePrice']?.toString() ?? '') ?? 0,
      sku: json['sku'] as String?,
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName'] as String?,
      shopId: json['shopId'] as int?,
      shopName: json['shopName'] as String?,
      status: json['status'] as String? ?? 'PUBLISHED',
      images: imagesList,
      thumbnailUrl: thumbnail?.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'sku': sku,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'shopId': shopId,
      'shopName': shopName,
      'status': status,
      'images': images.map((e) => e.toJson()).toList(),
      'thumbnailUrl': thumbnailUrl,
    };
  }

  String get formattedPrice {
    final formatted = basePrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '$formatted VND';
  }

  bool get isPublished => status == 'PUBLISHED';
}

class ProductPage {
  final List<ProductModel> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;

  const ProductPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
  });

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    return ProductPage(
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
    );
  }
}

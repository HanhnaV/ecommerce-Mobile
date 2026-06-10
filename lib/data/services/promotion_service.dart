import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class PromotionService {
  PromotionService();

  Future<FlashSaleData> getFlashSale() async {
    try {
      final response = await apiClient.get('/api/v1/promotions/flash-sale');
      return FlashSaleData.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const FlashSaleData(
          isActive: false,
          products: [],
          message: 'Khong co khuyen mai Flash Sale hien tai.',
        );
      }
      throw Exception(_extractError(e));
    }
  }

  Future<List<DealProduct>> getDeals({int page = 0, int size = 20}) async {
    try {
      final response = await apiClient.get(
        '/api/v1/promotions/deals',
        queryParameters: {'page': page, 'size': size},
      );
      final list = response.data['content'] as List<dynamic>? ?? response.data as List<dynamic>;
      return list.map((e) => DealProduct.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<PromotionBanner>> getBanners() async {
    try {
      final response = await apiClient.get('/api/v1/promotions/banners');
      final list = response.data as List<dynamic>;
      return list.map((e) => PromotionBanner.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception(_extractError(e));
    }
  }

  String _extractError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ?? data['error'] ?? data.toString();
      }
      if (data is String) return data;
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Khong the ket noi server.';
    }
    return 'Da xay ra loi. Vui long thu lai.';
  }
}

class FlashSaleData {
  final bool isActive;
  final DateTime? endTime;
  final List<FlashSaleProduct> products;
  final String? message;

  const FlashSaleData({
    required this.isActive,
    this.endTime,
    required this.products,
    this.message,
  });

  factory FlashSaleData.fromJson(Map<String, dynamic> json) {
    return FlashSaleData(
      isActive: json['isActive'] as bool? ?? false,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'] as String) : null,
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => FlashSaleProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] as String?,
    );
  }
}

class FlashSaleProduct {
  final int productId;
  final String name;
  final String? imageUrl;
  final double originalPrice;
  final double salePrice;
  final int discountPercent;
  final int stock;
  final int sold;

  const FlashSaleProduct({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.originalPrice,
    required this.salePrice,
    required this.discountPercent,
    required this.stock,
    required this.sold,
  });

  factory FlashSaleProduct.fromJson(Map<String, dynamic> json) {
    return FlashSaleProduct(
      productId: json['productId'] as int,
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      discountPercent: json['discountPercent'] as int? ?? 0,
      stock: json['stock'] as int? ?? 0,
      sold: json['sold'] as int? ?? 0,
    );
  }
}

class DealProduct {
  final int productId;
  final String name;
  final String? imageUrl;
  final double originalPrice;
  final double dealPrice;
  final int discountPercent;
  final String dealType;

  const DealProduct({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.originalPrice,
    required this.dealPrice,
    required this.discountPercent,
    required this.dealType,
  });

  factory DealProduct.fromJson(Map<String, dynamic> json) {
    return DealProduct(
      productId: json['productId'] as int,
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      dealPrice: (json['dealPrice'] as num?)?.toDouble() ?? 0.0,
      discountPercent: json['discountPercent'] as int? ?? 0,
      dealType: json['dealType'] as String? ?? 'DEAL',
    );
  }
}

class PromotionBanner {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? actionUrl;
  final int position;

  const PromotionBanner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.actionUrl,
    required this.position,
  });

  factory PromotionBanner.fromJson(Map<String, dynamic> json) {
    return PromotionBanner(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String,
      actionUrl: json['actionUrl'] as String?,
      position: json['position'] as int? ?? 0,
    );
  }
}

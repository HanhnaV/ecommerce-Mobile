import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class SellerService {
  SellerService();

  Future<void> registerAsSeller({
    required String shopName,
    required String shopDescription,
    required String businessEmail,
    required String businessPhone,
    String? businessAddress,
  }) async {
    try {
      await apiClient.post(
        '/api/v1/seller/register',
        data: {
          'shopName': shopName,
          'shopDescription': shopDescription,
          'businessEmail': businessEmail,
          'businessPhone': businessPhone,
          if (businessAddress != null) 'businessAddress': businessAddress,
        },
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<SellerShop> getMyShop() async {
    try {
      final response = await apiClient.get('/api/v1/seller/me');
      return SellerShop.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> updateShop({
    String? shopName,
    String? shopDescription,
    String? businessEmail,
    String? businessPhone,
    String? businessAddress,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (shopName != null) data['shopName'] = shopName;
      if (shopDescription != null) data['shopDescription'] = shopDescription;
      if (businessEmail != null) data['businessEmail'] = businessEmail;
      if (businessPhone != null) data['businessPhone'] = businessPhone;
      if (businessAddress != null) data['businessAddress'] = businessAddress;

      await apiClient.put('/api/v1/seller/me', data: data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<ShopProduct>> getShopProducts(int shopId, {int page = 0, int size = 20}) async {
    try {
      final response = await apiClient.get(
        '/api/v1/seller/$shopId/products',
        queryParameters: {'page': page, 'size': size},
      );
      final list = response.data['content'] as List<dynamic>? ?? response.data as List<dynamic>;
      return list.map((e) => ShopProduct.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<SellerOrderPage> getShopOrders(int shopId, {String? status, int page = 0, int size = 20}) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (status != null) params['status'] = status;
      final response = await apiClient.get('/api/v1/seller/$shopId/orders', queryParameters: params);
      return SellerOrderPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await apiClient.patch('/api/v1/seller/orders/$orderId/status', data: {'status': status});
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> replyToReview(int reviewId, String reply) async {
    try {
      await apiClient.post('/api/v1/seller/reviews/$reviewId/reply', data: {'reply': reply});
    } on DioException catch (e) {
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

class SellerShop {
  final int id;
  final int userId;
  final String shopName;
  final String? shopDescription;
  final String? shopAvatarUrl;
  final String? businessEmail;
  final String? businessPhone;
  final String? businessAddress;
  final String status;
  final double? rating;
  final int? totalProducts;
  final int? totalOrders;

  const SellerShop({
    required this.id,
    required this.userId,
    required this.shopName,
    this.shopDescription,
    this.shopAvatarUrl,
    this.businessEmail,
    this.businessPhone,
    this.businessAddress,
    required this.status,
    this.rating,
    this.totalProducts,
    this.totalOrders,
  });

  factory SellerShop.fromJson(Map<String, dynamic> json) {
    return SellerShop(
      id: json['id'] as int,
      userId: json['userId'] as int,
      shopName: json['shopName'] as String,
      shopDescription: json['shopDescription'] as String?,
      shopAvatarUrl: json['shopAvatarUrl'] as String?,
      businessEmail: json['businessEmail'] as String?,
      businessPhone: json['businessPhone'] as String?,
      businessAddress: json['businessAddress'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      rating: (json['rating'] as num?)?.toDouble(),
      totalProducts: json['totalProducts'] as int?,
      totalOrders: json['totalOrders'] as int?,
    );
  }
}

class ShopProduct {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;
  final int stock;
  final String status;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.stock,
    required this.status,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
      stock: json['stock'] as int? ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}

class SellerOrderPage {
  final List<SellerOrderDetail> content;
  final int totalPages;
  final int totalElements;
  final int number;

  const SellerOrderPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
  });

  factory SellerOrderPage.fromJson(Map<String, dynamic> json) {
    return SellerOrderPage(
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => SellerOrderDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
    );
  }
}

class SellerOrderDetail {
  final int id;
  final String orderCode;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? shippingAddress;
  final double totalAmount;
  final double shippingFee;
  final List<OrderItem> items;
  final DateTime? createdAt;

  const SellerOrderDetail({
    required this.id,
    required this.orderCode,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.shippingAddress,
    required this.totalAmount,
    required this.shippingFee,
    required this.items,
    this.createdAt,
  });

  factory SellerOrderDetail.fromJson(Map<String, dynamic> json) {
    return SellerOrderDetail(
      id: json['id'] as int,
      orderCode: json['orderCode'] as String? ?? '',
      status: json['status'] as String? ?? '',
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      shippingAddress: json['shippingAddress'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? imageUrl;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as int,
      productName: json['productName'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class CartService {
  CartService();

  Future<CartApiResponse> getCart() async {
    try {
      final response = await apiClient.get('/api/v1/cart');
      return CartApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<CartApiResponse> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/cart/items',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );
      return CartApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<CartApiResponse> increaseQuantity(String cartItemId) async {
    try {
      final response = await apiClient.post('/api/v1/cart/items/$cartItemId/plus');
      return CartApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<CartApiResponse> decreaseQuantity(String cartItemId) async {
    try {
      final response = await apiClient.post('/api/v1/cart/items/$cartItemId/minus');
      return CartApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<CartApiResponse> removeItem(String cartItemId) async {
    try {
      final response = await apiClient.delete('/api/v1/cart/items/$cartItemId');
      return CartApiResponse.fromJson(response.data as Map<String, dynamic>);
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
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Ket noi qua lau. Vui long thu lai.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Khong the ket noi server.';
    }
    return 'Da xay ra loi. Vui long thu lai.';
  }
}

class CartApiResponse {
  final List<CartApiItem> items;
  final double totalPrice;

  const CartApiResponse({required this.items, required this.totalPrice});

  factory CartApiResponse.fromJson(Map<String, dynamic> json) {
    return CartApiResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartApiItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

class CartApiItem {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String shopId;
  final String shopName;
  final String? productImageUrl;

  const CartApiItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.shopId,
    required this.shopName,
    this.productImageUrl,
  });

  factory CartApiItem.fromJson(Map<String, dynamic> json) {
    return CartApiItem(
      id: json['id'].toString(),
      productId: json['productId'].toString(),
      productName: json['productName'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      shopId: json['shopId'].toString(),
      shopName: json['shopName'] as String? ?? '',
      productImageUrl: json['productImageUrl'] as String?,
    );
  }
}

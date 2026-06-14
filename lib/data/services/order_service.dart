import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class OrderService {
  OrderService();

  Future<OrderCreateResponse> createOrder({
    required String shopId,
    required String addressId,
    String? notes,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/order',
        data: {
          'shopId': shopId,
          'addressId': addressId,
          'notes': notes,
        },
      );
      return OrderCreateResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<VnpayPaymentResponse> createVnpayPayment(String orderId) async {
    try {
      final response = await apiClient.post('/api/v1/payment/orders/$orderId/vnpay');
      return VnpayPaymentResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> verifyVnpayPayment({
    Map<String, String>? params,
    String? rawQuery,
  }) async {
    try {
      if (rawQuery != null && rawQuery.isNotEmpty) {
        await apiClient.get('/api/v1/payment/vnpay/return?$rawQuery');
      } else {
        await apiClient.get(
          '/api/v1/payment/vnpay/return',
          queryParameters: params,
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<CheckoutQuoteResponse> getCheckoutQuote({
    required String shopId,
    required String addressId,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/checkout/quote',
        data: {'shopId': shopId, 'addressId': addressId},
      );
      return CheckoutQuoteResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<OrderPage> getMyOrders({String? status}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null && status.isNotEmpty) params['status'] = status;
      final response = await apiClient.get('/api/v1/order/me', queryParameters: params);
      
      final data = response.data;
      if (data is List) {
        final content = data
            .map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
            .toList();
        return OrderPage(
          content: content,
          totalPages: 1,
          totalElements: content.length,
          number: 0,
        );
      } else if (data is Map<String, dynamic>) {
        return OrderPage.fromJson(data);
      } else {
        return const OrderPage(
          content: [],
          totalPages: 0,
          totalElements: 0,
          number: 0,
        );
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<OrderDetail> getMyOrderById(String orderId) async {
    try {
      final response = await apiClient.get('/api/v1/order/$orderId/me');
      return OrderDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> markOrderReceived(String orderId) async {
    try {
      await apiClient.patch('/api/v1/order/$orderId/received');
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await apiClient.patch('/api/v1/order/$orderId/cancel');
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

class OrderCreateResponse {
  final String id;
  final String status;

  const OrderCreateResponse({required this.id, required this.status});

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) {
    return OrderCreateResponse(
      id: json['id'].toString(),
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}

class VnpayPaymentResponse {
  final String paymentUrl;

  const VnpayPaymentResponse({required this.paymentUrl});

  factory VnpayPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VnpayPaymentResponse(
      paymentUrl: json['paymentUrl'] as String? ?? '',
    );
  }
}

class OrderPage {
  final List<OrderDetail> content;
  final int totalPages;
  final int totalElements;
  final int number;

  const OrderPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
  });

  factory OrderPage.fromJson(Map<String, dynamic> json) {
    return OrderPage(
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
    );
  }
}

class OrderDetail {
  final String id;
  final String orderNumber;
  final String status;
  final String shopId;
  final String shopName;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String? notes;
  final List<OrderItem> items;
  final String? shippingName;
  final String? shippingPhone;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingDistrict;
  final String? shippingWard;
  final int? shippingDistrictId;
  final String? shippingWardCode;
  final String? ghnOrderCode;
  final DateTime? createdAt;

  const OrderDetail({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.shopId,
    required this.shopName,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    this.notes,
    required this.items,
    this.shippingName,
    this.shippingPhone,
    this.shippingAddress,
    this.shippingCity,
    this.shippingDistrict,
    this.shippingWard,
    this.shippingDistrictId,
    this.shippingWardCode,
    this.ghnOrderCode,
    this.createdAt,
  });

  String get orderCode => orderNumber;
  double get totalAmount => total;

  AddressInfo? get address {
    if (shippingName == null && shippingAddress == null) return null;
    return AddressInfo(
      id: '',
      receiverName: shippingName ?? '',
      receiverPhone: shippingPhone ?? '',
      addressLine: shippingAddress ?? '',
      city: shippingCity ?? '',
      district: shippingDistrict ?? '',
      ward: shippingWard ?? '',
      districtId: shippingDistrictId,
      wardCode: shippingWardCode,
    );
  }

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'].toString(),
      orderNumber: json['orderNumber'] as String? ?? json['orderCode'] as String? ?? '',
      status: json['status'] as String? ?? '',
      shopId: json['shopId'].toString(),
      shopName: json['shopName'] as String? ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shippingName: json['shippingName'] as String?,
      shippingPhone: json['shippingPhone'] as String?,
      shippingAddress: json['shippingAddress'] as String?,
      shippingCity: json['shippingCity'] as String?,
      shippingDistrict: json['shippingDistrict'] as String?,
      shippingWard: json['shippingWard'] as String?,
      shippingDistrictId: (json['shippingDistrictId'] as num?)?.toInt(),
      shippingWardCode: json['shippingWardCode']?.toString(),
      ghnOrderCode: json['ghnOrderCode'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? productImageUrl;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.productImageUrl,
  });

  String? get imageUrl => productImageUrl;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'].toString(),
      productName: json['productName'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      productImageUrl: json['productImageUrl'] as String? ?? json['imageUrl'] as String?,
    );
  }
}

class AddressInfo {
  final String id;
  final String receiverName;
  final String receiverPhone;
  final String addressLine;
  final String city;
  final String district;
  final String ward;
  final int? districtId;
  final String? wardCode;
  final bool isDefault;

  const AddressInfo({
    required this.id,
    required this.receiverName,
    required this.receiverPhone,
    required this.addressLine,
    required this.city,
    required this.district,
    required this.ward,
    this.districtId,
    this.wardCode,
    this.isDefault = false,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      id: json['id'].toString(),
      receiverName: json['receiverName'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      ward: json['ward'] as String? ?? '',
      districtId: (json['districtId'] as num?)?.toInt(),
      wardCode: json['wardCode']?.toString(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class CheckoutQuoteResponse {
  final double shippingFee;
  final double total;

  const CheckoutQuoteResponse({required this.shippingFee, required this.total});

  factory CheckoutQuoteResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutQuoteResponse(
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

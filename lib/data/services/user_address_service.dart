import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class UserAddressService {
  UserAddressService();

  Future<List<UserAddress>> listMyAddresses() async {
    try {
      final response = await apiClient.get('/api/v1/address');
      final list = response.data as List<dynamic>;
      return list.map((e) => UserAddress.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<UserAddress> createAddress(UserAddress address) async {
    try {
      final response = await apiClient.post(
        '/api/v1/address',
        data: address.toJson(),
      );
      return UserAddress.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<UserAddress> updateAddress(int addressId, UserAddress address) async {
    try {
      final response = await apiClient.put(
        '/api/v1/address/$addressId',
        data: address.toJson(),
      );
      return UserAddress.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> deleteAddress(int addressId) async {
    try {
      await apiClient.delete('/api/v1/address/$addressId');
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> setDefaultAddress(int addressId) async {
    try {
      await apiClient.patch('/api/v1/address/$addressId/default');
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

class UserAddress {
  final int? id;
  final String receiverName;
  final String receiverPhone;
  final String addressLine;
  final String city;
  final String district;
  final String ward;
  final int? districtId;
  final String? wardCode;
  final bool isDefault;

  const UserAddress({
    this.id,
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

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as int?,
      receiverName: json['receiverName'] as String? ?? '',
      receiverPhone: json['receiverPhone'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      ward: json['ward'] as String? ?? '',
      districtId: json['districtId'] as int?,
      wardCode: json['wardCode'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'addressLine': addressLine,
      'city': city,
      'district': district,
      'ward': ward,
      if (districtId != null) 'districtId': districtId,
      if (wardCode != null) 'wardCode': wardCode,
    };
  }

  UserAddress copyWith({
    int? id,
    String? receiverName,
    String? receiverPhone,
    String? addressLine,
    String? city,
    String? district,
    String? ward,
    int? districtId,
    String? wardCode,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      districtId: districtId ?? this.districtId,
      wardCode: wardCode ?? this.wardCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

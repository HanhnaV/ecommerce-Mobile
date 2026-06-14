import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class ShippingService {
  ShippingService();

  Future<List<Province>> getProvinces() async {
    try {
      final response = await apiClient.get('/api/v1/shipping/provinces');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => Province.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<District>> getDistricts(int provinceId) async {
    try {
      final response = await apiClient.get(
        '/api/v1/shipping/districts',
        queryParameters: {'provinceId': provinceId},
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => District.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<Ward>> getWards(int districtId) async {
    try {
      final response = await apiClient.get(
        '/api/v1/shipping/wards',
        queryParameters: {
          'districtId': districtId,
        },
      );

      final list = response.data as List<dynamic>;

      return list
          .map((e) => Ward.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ShippingFeeResponse> calculateFee({
    required int fromDistrictId,
    required String fromWardCode,
    required int toDistrictId,
    required String toWardCode,
    required int weight,
    int serviceTypeId = 2,
    int insuranceValue = 0,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/shipping/fee',
        data: {
          'from_district_id': fromDistrictId,
          'from_ward_code': fromWardCode,
          'to_district_id': toDistrictId,
          'to_ward_code': toWardCode,
          'weight': weight,
          'service_type_id': serviceTypeId,
          'insurance_value': insuranceValue,
        },
      );
      return ShippingFeeResponse.fromJson(
          response.data as Map<String, dynamic>);
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

class Province {
  final int id;
  final String name;

  const Province({
    required this.id,
    required this.name,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: (json['ProvinceID']
          ?? json['province_id']
          ?? json['id']
          ?? 0) as int,
      name: (json['ProvinceName']
          ?? json['province_name']
          ?? json['name']
          ?? '')
          .toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Province && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
class District {
  final int id;
  final String name;
  final int provinceId;

  const District({
    required this.id,
    required this.name,
    required this.provinceId,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: (json['DistrictID']
          ?? json['district_id']
          ?? json['id']
          ?? 0) as int,
      name: (json['DistrictName']
          ?? json['district_name']
          ?? json['name']
          ?? '')
          .toString(),
      provinceId: (json['ProvinceID']
          ?? json['province_id']
          ?? 0) as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is District && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
class Ward {
  final String code;
  final String name;

  const Ward(
      {required this.code, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: (json['WardCode']
          ?? json['ward_code']
          ?? json['code']
          ?? '')
          .toString(),
      name: (json['WardName']
          ?? json['ward_name']
          ?? json['name']
          ?? '')
          .toString(),
    );
  }
}

class ShippingFeeResponse {
  final double total;

  const ShippingFeeResponse({required this.total});

  factory ShippingFeeResponse.fromJson(Map<String, dynamic> json) {
    return ShippingFeeResponse(
      total: (json['total'] as num?)?.toDouble() ??
          (json['fee'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

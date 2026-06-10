import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/kyc_model.dart';

class KycService {
  KycService();

  Future<KycModel> getMyKyc() async {
    try {
      final response = await apiClient.get('/api/v1/kyc/me');
      final data = response.data as Map<String, dynamic>;
      return KycModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const KycModel();
      }
      final msg = _extractError(e);
      throw Exception(msg);
    }
  }

  Future<KycModel> submitKyc({
    required String idCardNumber,
    required String frontImagePath,
    required String backImagePath,
    required String selfieImagePath,
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('idCardNumber', idCardNumber));

      formData.files.add(MapEntry(
        'frontImage',
        await MultipartFile.fromFile(frontImagePath),
      ));
      formData.files.add(MapEntry(
        'backImage',
        await MultipartFile.fromFile(backImagePath),
      ));
      formData.files.add(MapEntry(
        'selfieImage',
        await MultipartFile.fromFile(selfieImagePath),
      ));

      final response = await apiClient.post(
        '/api/v1/kyc/individual',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data as Map<String, dynamic>;
      return KycModel.fromJson(data);
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw Exception(msg);
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
      return 'Khong the ket noi server. Kiem tra mang.';
    }
    return 'Da xay ra loi. Vui long thu lai.';
  }
}

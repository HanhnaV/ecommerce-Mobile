import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/kyc_model.dart';

class KycService {
  KycService();

  /// Tạo session KYC mới.
  Future<KycStartResponse> startSession() async {
    try {
      final response = await apiClient.post('/api/v1/kyc/sessions:start');
      return KycStartResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Upload một file kèm type (FRONT / BACK / SELFIE) — cross-platform.
  Future<KycUploadResponse> uploadWithBytes({
    required String sessionId,
    required String type,
    required List<int> bytes,
    String? title,
    String? description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        'file': MultipartFile.fromBytes(bytes, filename: 'kyc-$type.jpg'),
      });
      final response = await apiClient.post(
        '/api/v1/kyc/session/$sessionId/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return KycUploadResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Lấy trạng thái session KYC hiện tại.
  Future<KycSessionResponse> getSession(String sessionId) async {
    try {
      final response = await apiClient.get('/api/v1/kyc/sessions/$sessionId');
      return KycSessionResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// So sánh khuôn mặt (front vs selfie) để xác minh.
  Future<KycCompareResponse> compare(String sessionId) async {
    try {
      final response = await apiClient.post('/api/v1/kyc/sessions/$sessionId/compare');
      return KycCompareResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Gắn file đã upload vào session (dùng hash).
  Future<void> attachFile({
    required String sessionId,
    required String type,
    required String fileHash,
  }) async {
    try {
      await apiClient.post(
        '/api/v1/kyc/session/$sessionId/attach',
        data: {
          'type': type,
          'fileHash': fileHash,
        },
      );
    } on DioException catch (e) {
      throw _extractError(e);
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
      return 'Kết nối quá lâu. Vui lòng thử lại.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối server. Kiểm tra mạng.';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}

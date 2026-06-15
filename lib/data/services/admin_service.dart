import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/admin_request_model.dart';
import 'seller_service.dart'; // To use SellerOrderPage

class AdminService {
  AdminService();

  Future<AdminRequestPage> getRequests({String? status, int page = 0, int size = 20}) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (status != null) params['status'] = status;
      
      final response = await apiClient.get('/api/v1/request/admin', queryParameters: params);
      return AdminRequestPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> approveRequest(String requestId, String responseMessage) async {
    try {
      await apiClient.put(
        '/api/v1/request/approve',
        queryParameters: {'requestId': requestId, 'response': responseMessage},
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> rejectRequest(String requestId, String responseMessage) async {
    try {
      await apiClient.put(
        '/api/v1/request/reject',
        queryParameters: {'requestId': requestId, 'response': responseMessage},
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<SellerOrderDetail>> getAllOrders({String? status, int page = 0, int size = 20}) async {
    try {
      final params = <String, dynamic>{'page': page, 'size': size};
      if (status != null) params['status'] = status;
      
      final response = await apiClient.get('/api/v1/order', queryParameters: params);
      
      if (response.data is List) {
        final list = response.data as List;
        return list.map((e) => SellerOrderDetail.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        return SellerOrderPage.fromJson(response.data as Map<String, dynamic>).content;
      }
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
      return 'Không thể kết nối server.';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}

final adminService = AdminService();

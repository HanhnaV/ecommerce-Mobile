import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  DashboardService();

  Future<SellerStatistics> getSellerStatistics() async {
    try {
      final response = await apiClient.get('/api/v1/statistics/seller');
      return SellerStatistics.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<TopProduct>> getTopProducts(int shopId, {int limit = 5}) async {
    try {
      final response = await apiClient.get(
        '/api/v1/order/shops/$shopId/top-products',
        queryParameters: {'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list.map((e) => TopProduct.fromJson(e as Map<String, dynamic>)).toList();
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

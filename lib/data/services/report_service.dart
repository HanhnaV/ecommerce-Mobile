import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/report_model.dart';

class ReportService {
  ReportService();

  Future<List<Report>> getMyReports({String? status}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null && status.isNotEmpty) params['status'] = status;
      final response = await apiClient.get(
        '/api/v1/report/me',
        queryParameters: params,
      );
      final List<dynamic> list = response.data as List<dynamic>;
      return list.map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<Report> submitReport(ReportSubmitBody body) async {
    try {
      final response = await apiClient.post(
        '/api/v1/report',
        data: body.toJson(),
      );
      return Report.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<Report> getReportById(int reportId) async {
    try {
      final response = await apiClient.get('/api/v1/report/$reportId');
      return Report.fromJson(response.data as Map<String, dynamic>);
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

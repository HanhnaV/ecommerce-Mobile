import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  CategoryService();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.get('/api/v1/category');
      final list = response.data as List<dynamic>;
      return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
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

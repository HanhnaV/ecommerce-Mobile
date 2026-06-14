import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/product_model.dart';

class ProductService {
  ProductService();

  Future<ProductPage> getProducts({
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
    String? search,
    String? categoryId,
    String? shopId,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDir': sortDir,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (categoryId != null && categoryId.isNotEmpty) params['categoryId'] = categoryId;
      if (shopId != null && shopId.isNotEmpty) params['shopId'] = shopId;
      if (minPrice != null) params['minPrice'] = minPrice;
      if (maxPrice != null) params['maxPrice'] = maxPrice;

      final response = await apiClient.get('/api/v1/product', queryParameters: params);
      return ProductPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ProductModel> getProductById(String productId) async {
    try {
      final response = await apiClient.get('/api/v1/product/$productId');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<ProductModel>> getRecommendations({int limit = 8}) async {
    try {
      final response = await apiClient.get(
        '/api/v1/recommendations',
        queryParameters: {'limit': limit},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return [];
      throw Exception(_extractError(e));
    }
  }

  Future<List<ProductModel>> getSimilarProducts(String productId, {int limit = 8}) async {
    try {
      final response = await apiClient.get(
        '/api/v1/product/$productId/similar',
        queryParameters: {'limit': limit},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
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

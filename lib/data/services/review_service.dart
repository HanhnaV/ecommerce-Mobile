import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/review_model.dart';

class ReviewService {
  ReviewService();

  Future<ReviewPage> getProductReviews(
    int productId, {
    int page = 0,
    int size = 5,
    int? rating,
    bool? hasImages,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (rating != null) params['rating'] = rating;
      if (hasImages != null) params['hasImages'] = hasImages;

      final response = await apiClient.get(
        '/api/v1/review/products/$productId',
        queryParameters: params,
      );
      return ReviewPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ReviewStats> getProductReviewStats(int productId) async {
    try {
      final response = await apiClient.get('/api/v1/review/products/$productId/reviews/stats');
      return ReviewStats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> submitReview({
    required int productId,
    required int rating,
    String? comment,
    List<String>? imagePaths,
  }) async {
    try {
      final data = <String, dynamic>{
        'productId': productId,
        'rating': rating,
      };
      if (comment != null && comment.isNotEmpty) data['comment'] = comment;

      if (imagePaths != null && imagePaths.isNotEmpty) {
        final formData = FormData();
        formData.fields.addAll(data.entries.map((e) => MapEntry(e.key, e.value.toString())));
        for (final path in imagePaths) {
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(path),
          ));
        }
        await apiClient.post('/api/v1/review/products/$productId', data: formData);
      } else {
        await apiClient.post('/api/v1/review/products/$productId', data: data);
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
      return 'Khong the ket noi server.';
    }
    return 'Da xay ra loi. Vui long thu lai.';
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/chatbot_response_model.dart';

class ChatbotService {
  ChatbotService();

  Future<ChatbotResponse> initChatbot() async {
    try {
      final response = await apiClient.get('/api/v1/chat/init');
      return ChatbotResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ChatbotResponse> interactChatbot({
    String? action,
    String? text,
    String? categoryId,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/chat/interact',
        data: {
          if (action != null) 'action': action,
          if (text != null) 'text': text,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );
      return ChatbotResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Stream<String> streamChatbot(String text) async* {
    try {
      final response = await apiClient.get<ResponseBody>(
        '/api/v1/chat/stream',
        queryParameters: {'text': text},
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
          },
        ),
      );

      // Giải mã luồng byte thành luồng văn bản theo dòng (UTF-8)
      final stream = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (line.startsWith('data:')) {
          final dataContent = line.substring(5).trim();
          if (dataContent.isNotEmpty) {
            yield dataContent;
          }
        }
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception('Lỗi luồng AI: $e');
    }
  }

  String _extractError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            data.toString();
      }
      if (data is String) {
        return data;
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá lâu. Vui lòng thử lại.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới server.';
      case DioExceptionType.badResponse:
        return 'Server trả về lỗi ${e.response?.statusCode}.';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}

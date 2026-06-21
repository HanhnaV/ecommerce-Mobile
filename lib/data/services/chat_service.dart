import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_client.dart';
import '../models/chat_message_model.dart';

class ChatService {
  ChatService();

  static const _storage = FlutterSecureStorage();

  Future<Conversation> getOrCreateConversation() async {
    try {
      final response = await apiClient.get(
        '/api/v1/chat/conversation',
      );

      return Conversation.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<ChatMessage>> getMessages(
      String conversationId, {
        int page = 0,
        int size = 50,
      }) async {
    try {
      final response = await apiClient.get(
        '/api/v1/chat/$conversationId/messages',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final List<dynamic> list =
      response.data as List<dynamic>;

      return list
          .map(
            (e) => ChatMessage.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ChatMessage> sendMessage(
      String conversationId,
      String content,
      ) async {
    try {
      final response = await apiClient.post(
        '/api/v1/chat/$conversationId/messages',
        data: {
          'content': content,
        },
      );

      return ChatMessage.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> markAsRead(
      String conversationId,
      String messageId,
      ) async {
    try {
      await apiClient.patch(
        '/api/v1/chat/$conversationId/messages/$messageId/read',
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<String> uploadChatImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: file.name,
        ),
      });

      final response = await apiClient.post(
        '/api/v1/chat/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data as Map<String, dynamic>;
      return data['url']?.toString() ?? '';
    } on DioException catch (e) {
      throw Exception(_extractError(e));
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
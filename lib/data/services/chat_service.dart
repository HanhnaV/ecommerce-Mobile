import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../models/chat_message_model.dart';

class ChatService {
  ChatService();

  Future<Conversation> getOrCreateConversation() async {
    try {
      final response = await apiClient.get('/api/v1/chat/conversation');
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId, {int page = 0, int size = 50}) async {
    try {
      final response = await apiClient.get(
        '/api/v1/chat/$conversationId/messages',
        queryParameters: {'page': page, 'size': size},
      );
      final List<dynamic> list = response.data as List<dynamic>;
      return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ChatMessage> sendMessage(String conversationId, String content) async {
    try {
      final response = await apiClient.post(
        '/api/v1/chat/$conversationId/messages',
        data: {'content': content},
      );
      return ChatMessage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> markAsRead(String conversationId, String messageId) async {
    try {
      await apiClient.patch('/api/v1/chat/$conversationId/messages/$messageId/read');
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<String> uploadChatImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await apiClient.post(
        '/api/v1/chat/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      
      return response.data['url'] ?? '';
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

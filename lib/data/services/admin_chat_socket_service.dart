import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class AdminLiveChatMessage {
  final String sessionId; 
  final String text;
  final String from;
  final bool fromAdmin;
  final String? imageUrl;
  final DateTime createdAt;

  const AdminLiveChatMessage({
    required this.sessionId,
    required this.text,
    required this.from,
    required this.fromAdmin,
    this.imageUrl,
    required this.createdAt,
  });

  factory AdminLiveChatMessage.customerFromJson(Map<String, dynamic> json) {
    return AdminLiveChatMessage(
      // Backend Java của bạn gửi accountId, chúng ta dùng nó làm sessionId để gộp khung chat
      sessionId: json['accountId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      from: json['userName']?.toString() ?? 'Khách',
      fromAdmin: false,
      createdAt: DateTime.now(),
    );
  }

  factory AdminLiveChatMessage.admin({
    required String sessionId,
    required String text,
    String? imageUrl,
  }) {
    return AdminLiveChatMessage(
      sessionId: sessionId,
      text: text,
      imageUrl: imageUrl,
      from: 'Admin',
      fromAdmin: true,
      createdAt: DateTime.now(),
    );
  }
}

class AdminChatSocketService {
  static const String adminTopic = '/topic/admin/live-chat';
  static const String replyDestination = '/app/chat/reply';

  final _storage = const FlutterSecureStorage();
  StompClient? _stompClient;

  Future<void> connect({
    required void Function(AdminLiveChatMessage message) onMessageReceived,
    void Function(StompFrame frame)? onConnect,
    void Function(StompFrame frame)? onError,
    void Function(dynamic error)? onWebSocketError,
  }) async {
    if (_stompClient?.connected == true) return;

    final token = await _storage.read(key: 'access_token');
    final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');
    final wsUrl = '$baseUrl/api/v1/ws-chat?token=$token';

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: wsUrl,
        onConnect: (frame) {
          _stompClient?.subscribe(
            destination: adminTopic,
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.isEmpty) return;
              final decoded = json.decode(body);
              if (decoded is! Map<String, dynamic>) return;
              final message = AdminLiveChatMessage.customerFromJson(decoded);
              if (message.sessionId.isEmpty) return;
              onMessageReceived(message);
            },
          );
          onConnect?.call(frame);
        },
        onStompError: (frame) => onError?.call(frame),
        onWebSocketError: (error) => onWebSocketError?.call(error),
      ),
    );

    _stompClient?.activate();
  }

  void sendReply({
    required String sessionId,
    required String text,
    String? imageUrl,
  }) {
    if (!isConnected || sessionId.isEmpty) return;

    _stompClient?.send(
      destination: replyDestination,
      body: json.encode({
        // Gửi key "sessionId" chứa accountId của khách để Backend xử lý
        'sessionId': sessionId,
        'text': text.trim(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  bool get isConnected => _stompClient?.connected ?? false;
}

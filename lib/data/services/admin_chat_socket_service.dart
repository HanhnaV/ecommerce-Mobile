import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class AdminLiveChatMessage {
  final String sessionId;
  final String text;
  final String from;
  final bool fromAdmin;
  final DateTime createdAt;

  const AdminLiveChatMessage({
    required this.sessionId,
    required this.text,
    required this.from,
    required this.fromAdmin,
    required this.createdAt,
  });

  factory AdminLiveChatMessage.customerFromJson(Map<String, dynamic> json) {
    return AdminLiveChatMessage(
      sessionId: json['sessionId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      from: json['from']?.toString() ?? 'Khach',
      fromAdmin: false,
      createdAt: DateTime.now(),
    );
  }

  factory AdminLiveChatMessage.admin({
    required String sessionId,
    required String text,
  }) {
    return AdminLiveChatMessage(
      sessionId: sessionId,
      text: text,
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
    final wsUrl =
        '$baseUrl/api/v1/ws-chat?token=$token';
    final headers =
        token == null ? <String, String>{} : {'Authorization': 'Bearer $token'};

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: wsUrl,
        // stompConnectHeaders: headers,
        // webSocketConnectHeaders: headers,
        onConnect: (frame) {
          _stompClient?.subscribe(
            destination: adminTopic,
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.isEmpty) return;
              final decoded = json.decode(body);
              if (decoded is! Map<String, dynamic>) return;
              final message = AdminLiveChatMessage.customerFromJson(decoded);
              if (message.sessionId.isEmpty || message.text.isEmpty) return;
              onMessageReceived(message);
            },
          );
          onConnect?.call(frame);
        },
        onStompError: (frame) {
          onError?.call(frame);
        },
        onWebSocketError: (error) {
          onWebSocketError?.call(error);
        },
      ),
    );

    _stompClient?.activate();
  }

  void sendReply({
    required String sessionId,
    required String text,
  }) {
    if (!isConnected || sessionId.isEmpty || text.trim().isEmpty) return;

    _stompClient?.send(
      destination: replyDestination,
      body: json.encode({
        'sessionId': sessionId,
        'text': text.trim(),
      }),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  bool get isConnected => _stompClient?.connected ?? false;
}

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatSocketService {
  StompClient? _stompClient;
  String? _sessionId;
  final _storage = const FlutterSecureStorage();

  Future<void> connect({
    required void Function(Map<String, dynamic>) onMessageReceived,
    void Function(StompFrame)? onConnect,
    void Function(StompFrame)? onError,
  }) async {
    final token = await _storage.read(key: 'access_token');

    final baseUrl = dotenv.get('API_BASE_URL');
    final wsUrl = '$baseUrl/api/v1/ws-chat';

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: wsUrl,

        stompConnectHeaders: {
          if (token != null)
            'Authorization': 'Bearer $token',
        },

        webSocketConnectHeaders: {
          if (token != null)
            'Authorization': 'Bearer $token',
        },

          onConnect: (frame) {
            print('========== CONNECTED ==========');
            print(frame.headers);

            _sessionId = frame.headers['user-name'];

            print('SESSION = $_sessionId');

            final topic =
                '/topic/live-chat-reply/$_sessionId';

            print('SUBSCRIBE = $topic');

            _stompClient?.subscribe(
              destination: topic,
              callback: (frame) {
                print('========== RECEIVE ==========');
                print(frame.body);

                if (frame.body != null) {
                  final data =
                  jsonDecode(frame.body!);

                  onMessageReceived(data);
                }
              },
            );
          },
        onStompError: (frame) {
          print(
              'STOMP Error: ${frame.body}');
          onError?.call(frame);
        },

        onWebSocketError: (error) {
          print('WS Error: $error');
        },
      ),
    );

    _stompClient?.activate();
  }

  void sendMessage(String text) {
    if (_stompClient == null ||
        !_stompClient!.connected) {
      return;
    }

    _stompClient?.send(
      destination: '/app/chat',
      body: json.encode({
        'text': text,
      }),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  bool get isConnected =>
      _stompClient?.connected ?? false;
}
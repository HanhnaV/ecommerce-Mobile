import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatSocketService {
  StompClient? _stompClient;

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  String? _currentAccountId;

  Future<void> connect({
    required void Function(
        Map<String, dynamic>,
        ) onMessageReceived,
    void Function(StompFrame)? onConnect,
    void Function(StompFrame)? onError,
  }) async {
    if (_stompClient?.connected == true) {
      return;
    }

    final token = await _storage.read(
      key: 'access_token',
    );

    final baseUrl =
    dotenv.get('API_BASE_URL');

    final wsUrl =
        '$baseUrl/api/v1/ws-chat?token=$token';

    print('');
    print(
        '========== CONNECT SOCKET ==========');
    print('WS_URL = $wsUrl');

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: wsUrl,

        stompConnectHeaders: {
          if (token != null)
            'Authorization':
            'Bearer $token',
        },

        webSocketConnectHeaders: {
          if (token != null)
            'Authorization':
            'Bearer $token',
        },

        onConnect: (frame) {
          print('');
          print(
              '========== CONNECTED ==========');

          print(
              'HEADERS = ${frame.headers}');

          _currentAccountId =
          frame.headers['user-name'];

          print(
              'ACCOUNT_ID FROM SERVER = $_currentAccountId');

          if (_currentAccountId == null ||
              _currentAccountId!.isEmpty) {
            print(
                'ACCOUNT_ID NULL -> STOP SUBSCRIBE');
            return;
          }

          final topic =
              '/topic/live-chat-reply/$_currentAccountId';

          print(
              'SUBSCRIBE = $topic');

          _stompClient?.subscribe(
            destination: topic,
            callback: (frame) {
              print('');
              print(
                  '========== RECEIVE ==========');

              print(
                  'BODY = ${frame.body}');

              if (frame.body == null ||
                  frame.body!.isEmpty) {
                return;
              }

              try {
                final decoded =
                jsonDecode(frame.body!);

                if (decoded
                is Map<String, dynamic>) {
                  onMessageReceived(
                    decoded,
                  );
                }
              } catch (e) {
                print(
                    'JSON ERROR = $e');
              }
            },
          );

          onConnect?.call(frame);
        },

        onStompError: (frame) {
          print('');
          print(
              '========== STOMP ERROR ==========');
          print(frame.body);

          onError?.call(frame);
        },

        onWebSocketError: (error) {
          print('');
          print(
              '========== WS ERROR ==========');
          print(error);

          onError?.call(
            StompFrame(
              command: 'ERROR',
              headers: const {},
              body: error.toString(),
            ),
          );
        },

        onDisconnect: (_) {
          print('');
          print(
              '========== DISCONNECTED ==========');
        },
      ),
    );

    _stompClient?.activate();
  }

  void sendMessage({
    required String text,
    String? imageUrl,
    String? userName,
  }) {
    if (_stompClient == null ||
        !_stompClient!.connected) {
      print(
          'SEND FAIL: SOCKET NOT CONNECTED');
      return;
    }

    final payload = {
      'text': text,
      'userName':
      userName ?? 'Customer',
      if (imageUrl != null)
        'imageUrl': imageUrl,
    };

    print('');
    print(
        '========== SEND ==========');
    print(jsonEncode(payload));

    _stompClient?.send(
      destination: '/app/chat',
      body: jsonEncode(payload),
    );
  }

  void disconnect() {
    print('');
    print(
        '========== DISCONNECT ==========');

    _stompClient?.deactivate();

    _stompClient = null;
    _currentAccountId = null;
  }

  bool get isConnected =>
      _stompClient?.connected ?? false;

  String? get currentAccountId =>
      _currentAccountId;
}
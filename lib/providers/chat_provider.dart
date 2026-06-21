import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/chat_message_model.dart';
import '../data/services/chat_service.dart';
import '../data/services/chat_socket_services.dart';
import 'auth_provider.dart';

final chatSocketServiceProvider =
Provider<ChatSocketService>((ref) => ChatSocketService());

final chatServiceProvider =
Provider<ChatService>((ref) => ChatService());

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool isConnecting;
  final bool isConnected;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isConnecting = false,
    this.isConnected = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isConnecting,
    bool? isConnected,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatSocketService _socketService;
  final ChatService _apiService;
  final Ref _ref;

  ChatNotifier(
      this._socketService,
      this._apiService,
      this._ref,
      ) : super(const ChatState());

  Future<void> initChat() async {
    if (state.isConnected || state.isConnecting) {
      return;
    }

    final authState = _ref.read(authStateProvider);
    final accountId = authState.user?.id;

    if (accountId == null || accountId.isEmpty) {
      state = state.copyWith(
        error: 'User chưa đăng nhập',
      );
      return;
    }

    state = state.copyWith(
      isConnecting: true,
    );

    await _socketService.connect(
      onMessageReceived: (data) {
        debugPrint('RECEIVE: $data');

        final message = ChatMessage(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          conversationId: '',
          content: data['text'] ?? '',
          imageUrl: data['imageUrl'],
          senderType: 'ADMIN',
          createdAt: DateTime.now(),
        );

        state = state.copyWith(
          messages: [
            ...state.messages,
            message,
          ],
        );
      },

      onConnect: (_) {
        debugPrint(
          'SOCKET CONNECTED SUCCESS',
        );

        state = state.copyWith(
          isConnected: true,
          isConnecting: false,
          error: null,
        );
      },

      onError: (frame) {
        debugPrint(
          'SOCKET ERROR: ${frame.body}',
        );

        state = state.copyWith(
          isConnected: false,
          isConnecting: false,
          error: 'Không thể kết nối chat',
        );
      },
    );
  }

  Future<void> sendMessage(
      String content,
      ) async {
    if (content.trim().isEmpty) {
      return;
    }

    if (!_socketService.isConnected) {
      state = state.copyWith(
        error: 'Socket disconnected',
      );
      return;
    }

    final tempMessage = ChatMessage(
      id:
      'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: '',
      content: content.trim(),
      senderType: 'USER',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [
        ...state.messages,
        tempMessage,
      ],
    );

    _socketService.sendMessage(
      text: content.trim(),
    );
  }

  Future<void> sendImage(
      XFile file,
      ) async {
    if (!_socketService.isConnected) {
      state = state.copyWith(
        error: 'Socket disconnected',
      );
      return;
    }

    state = state.copyWith(
      isSending: true,
    );

    try {
      final imageUrl =
      await _apiService.uploadChatImage(
        file,
      );

      final tempMessage = ChatMessage(
        id:
        'temp-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: '',
        content: '',
        imageUrl: imageUrl,
        senderType: 'USER',
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [
          ...state.messages,
          tempMessage,
        ],
        isSending: false,
      );

      _socketService.sendMessage(
        text: '',
        imageUrl: imageUrl,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  Future<void> disconnectChat() async {
    _socketService.disconnect();

    state = state.copyWith(
      isConnected: false,
    );
  }

  void clearError() {
    state = state.copyWith(
      error: null,
    );
  }

  void resetState() {
    _socketService.disconnect();

    state = const ChatState();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}

final chatProvider =
StateNotifierProvider<
    ChatNotifier,
    ChatState>(
      (ref) {
    return ChatNotifier(
      ref.watch(
        chatSocketServiceProvider,
      ),
      ref.watch(
        chatServiceProvider,
      ),
      ref,
    );
  },
);
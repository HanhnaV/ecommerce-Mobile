import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_message_model.dart';
import '../data/services/chat_socket_services.dart';
import 'auth_provider.dart';

final chatSocketServiceProvider =
Provider<ChatSocketService>((ref) => ChatSocketService());

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final bool isConnected;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.isConnected = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool? isConnected,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatSocketService _socketService;
  final Ref _ref;

  ChatNotifier(this._socketService, this._ref)
      : super(const ChatState());

  Future<void> initChat() async {
    _connectSocket();
  }

  void _connectSocket() {
    _socketService.connect(
      onMessageReceived: (data) {
        final message = ChatMessage(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          conversationId: '',
          content: data['text'] ?? '',
          senderType:
          data['fromAdmin'] == true
              ? 'ADMIN'
              : 'USER',
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
        state = state.copyWith(
          isConnected: true,
        );
      },

      onError: (_) {
        state = state.copyWith(
          isConnected: false,
          error: 'Socket connection failed',
        );
      },
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    if (!_socketService.isConnected) {
      state = state.copyWith(
        error: 'Socket disconnected',
      );
      return;
    }

    // Hiển thị tin nhắn ngay trên UI
    final tempMessage = ChatMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: '',
      content: content.trim(),
      senderType: 'USER',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, tempMessage],
    );

    _socketService.sendMessage(content.trim());
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}

final chatProvider =
StateNotifierProvider<ChatNotifier, ChatState>(
      (ref) {
    final socketService =
    ref.watch(chatSocketServiceProvider);

    return ChatNotifier(
      socketService,
      ref,
    );
  },
);
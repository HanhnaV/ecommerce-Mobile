import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_message_model.dart';
import '../data/services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

class ChatState {
  final Conversation? conversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    Conversation? conversation,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _service;

  ChatNotifier(this._service) : super(const ChatState());

  Future<void> loadConversation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conv = await _service.getOrCreateConversation();
      final messages = await _service.getMessages(conv.id);
      state = state.copyWith(
        conversation: conv,
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.conversation == null || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final messages = await _service.getMessages(
        (state.conversation!.id).toString(),
        page: (state.messages.length / 50).floor() + 1,
      );
      state = state.copyWith(
        messages: [...state.messages, ...messages],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    if (state.conversation == null || content.trim().isEmpty) return;
    state = state.copyWith(isSending: true, error: null);

    final tempMessage = ChatMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: state.conversation!.id,
      content: content.trim(),
      senderType: 'USER',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, tempMessage]);

    try {
      final sent = await _service.sendMessage((state.conversation!.id).toString(), content.trim());
      final updated = state.messages.map((m) {
        return m.id == tempMessage.id ? sent : m;
      }).toList();
      state = state.copyWith(messages: updated, isSending: false);
    } catch (e) {
      final updated = state.messages.where((m) => m.id != tempMessage.id).toList();
      state = state.copyWith(
        messages: updated,
        isSending: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final service = ref.watch(chatServiceProvider);
  return ChatNotifier(service);
});

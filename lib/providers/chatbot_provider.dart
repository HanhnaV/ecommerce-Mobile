import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chatbot_response_model.dart';
import '../data/services/chatbot_service.dart';

final chatbotServiceProvider = Provider<ChatbotService>((ref) => ChatbotService());

class ChatbotState {
  final List<ChatbotUiMessage> messages;
  final List<ChatbotOption> options;
  final bool isLoading;
  final bool isSending;
  final bool inputExpected;
  final String inputHint;
  final bool liveChatMode;
  final String? error;

  const ChatbotState({
    this.messages = const [],
    this.options = const [],
    this.isLoading = false,
    this.isSending = false,
    this.inputExpected = false,
    this.inputHint = '',
    this.liveChatMode = false,
    this.error,
  });

  ChatbotState copyWith({
    List<ChatbotUiMessage>? messages,
    List<ChatbotOption>? options,
    bool? isLoading,
    bool? isSending,
    bool? inputExpected,
    String? inputHint,
    bool? liveChatMode,
    String? error,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      options: options ?? this.options,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      inputExpected: inputExpected ?? this.inputExpected,
      inputHint: inputHint ?? this.inputHint,
      liveChatMode: liveChatMode ?? this.liveChatMode,
      error: error,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final ChatbotService _apiService;

  ChatbotNotifier(this._apiService) : super(const ChatbotState());

  Future<void> initChatbot() async {
    if (state.messages.isNotEmpty) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.initChatbot();
      
      final botMessage = ChatbotUiMessage(
        id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
        type: 'bot',
        text: response.messageText,
        productCards: response.productCards,
      );

      state = state.copyWith(
        messages: [botMessage],
        options: response.options,
        inputExpected: response.inputExpected,
        inputHint: response.inputHint ?? '',
        liveChatMode: response.humanHandoffRequired,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectOption(ChatbotOption opt) async {
    final userMessage = ChatbotUiMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      type: 'user',
      text: opt.buttonLabel,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    );

    try {
      final response = await _apiService.interactChatbot(
        action: opt.actionPayload,
        categoryId: opt.categoryId,
      );

      final botMessage = ChatbotUiMessage(
        id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
        type: 'bot',
        text: response.messageText,
        productCards: response.productCards,
      );

      state = state.copyWith(
        messages: [...state.messages, botMessage],
        options: response.options,
        inputExpected: response.inputExpected,
        inputHint: response.inputHint ?? '',
        liveChatMode: response.humanHandoffRequired,
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatbotUiMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      type: 'user',
      text: text.trim(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    );

    try {
      final response = await _apiService.interactChatbot(text: text.trim());

      final botMessage = ChatbotUiMessage(
        id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
        type: 'bot',
        text: response.messageText,
        productCards: response.productCards,
      );

      state = state.copyWith(
        messages: [...state.messages, botMessage],
        options: response.options,
        inputExpected: response.inputExpected,
        inputHint: response.inputHint ?? '',
        liveChatMode: response.humanHandoffRequired,
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetState() {
    state = const ChatbotState();
  }
}

final chatbotProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier(ref.watch(chatbotServiceProvider));
});

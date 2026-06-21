import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/services/admin_chat_socket_service.dart';
import '../data/services/chat_service.dart';
import 'chat_provider.dart';

final adminChatSocketServiceProvider = Provider<AdminChatSocketService>((ref) {
  return AdminChatSocketService();
});

final adminChatProvider =
    StateNotifierProvider<AdminChatNotifier, AdminChatState>((ref) {
  final service = ref.watch(adminChatSocketServiceProvider);
  final apiService = ref.watch(chatServiceProvider);
  return AdminChatNotifier(service, apiService);
});

class AdminChatSession {
  final String sessionId;
  final String customerName;
  final List<AdminLiveChatMessage> messages;
  final int unreadCount;
  final DateTime lastMessageAt;

  const AdminChatSession({
    required this.sessionId,
    required this.customerName,
    required this.messages,
    required this.unreadCount,
    required this.lastMessageAt,
  });

  AdminChatSession copyWith({
    String? customerName,
    List<AdminLiveChatMessage>? messages,
    int? unreadCount,
    DateTime? lastMessageAt,
  }) {
    return AdminChatSession(
      sessionId: sessionId,
      customerName: customerName ?? this.customerName,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}

class AdminChatState {
  final Map<String, AdminChatSession> sessions;
  final String? selectedSessionId;
  final bool isConnected;
  final bool isConnecting;
  final bool isSending;
  final String? error;

  const AdminChatState({
    this.sessions = const {},
    this.selectedSessionId,
    this.isConnected = false,
    this.isConnecting = false,
    this.isSending = false,
    this.error,
  });

  List<AdminChatSession> get sortedSessions {
    final list = sessions.values.toList();
    list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return list;
  }

  AdminChatSession? get selectedSession {
    final id = selectedSessionId;
    return id == null ? null : sessions[id];
  }

  AdminChatState copyWith({
    Map<String, AdminChatSession>? sessions,
    String? selectedSessionId,
    bool clearSelectedSession = false,
    bool? isConnected,
    bool? isConnecting,
    bool? isSending,
    String? error,
  }) {
    return AdminChatState(
      sessions: sessions ?? this.sessions,
      selectedSessionId: clearSelectedSession
          ? null
          : selectedSessionId ?? this.selectedSessionId,
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class AdminChatNotifier extends StateNotifier<AdminChatState> {
  AdminChatNotifier(this._service, this._apiService) : super(const AdminChatState());

  final AdminChatSocketService _service;
  final ChatService _apiService;

  Future<void> connect() async {
    if (state.isConnecting || state.isConnected) return;

    state = state.copyWith(isConnecting: true, error: null);
    try {
      await _service.connect(
        onMessageReceived: _handleIncomingMessage,
        onConnect: (_) {
          state = state.copyWith(isConnected: true, isConnecting: false);
        },
        onError: (frame) {
          state = state.copyWith(
            isConnected: false,
            isConnecting: false,
            error: frame.body ?? 'Ket noi STOMP that bai',
          );
        },
        onWebSocketError: (error) {
          state = state.copyWith(
            isConnected: false,
            isConnecting: false,
            error: error.toString(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        error: e.toString(),
      );
    }
  }

  void _handleIncomingMessage(AdminLiveChatMessage message) {
    final current = state.sessions[message.sessionId];
    final isSelected = state.selectedSessionId == message.sessionId;

    final updated = (current ??
            AdminChatSession(
              sessionId: message.sessionId,
              customerName: message.from,
              messages: const [],
              unreadCount: 0,
              lastMessageAt: message.createdAt,
            ))
        .copyWith(
      messages: [...?current?.messages, message],
      unreadCount: isSelected ? 0 : (current?.unreadCount ?? 0) + 1,
      lastMessageAt: message.createdAt,
    );

    state = state.copyWith(
      sessions: {
        ...state.sessions,
        message.sessionId: updated,
      },
      selectedSessionId: state.selectedSessionId ?? message.sessionId,
    );
  }

  void selectSession(String sessionId) {
    final session = state.sessions[sessionId];
    if (session == null) return;

    state = state.copyWith(
      selectedSessionId: sessionId,
      sessions: {
        ...state.sessions,
        sessionId: session.copyWith(unreadCount: 0),
      },
    );
  }

  void sendReply(String text, {String? imageUrl}) {
    final sessionId = state.selectedSessionId;
    if (sessionId == null || !state.isConnected) return;
    if (text.trim().isEmpty && imageUrl == null) return;

    _service.sendReply(sessionId: sessionId, text: text.trim(), imageUrl: imageUrl);
    final message = AdminLiveChatMessage.admin(
      sessionId: sessionId,
      text: text.trim(),
      imageUrl: imageUrl,
    );
    final current = state.sessions[sessionId];
    if (current == null) return;

    state = state.copyWith(
      sessions: {
        ...state.sessions,
        sessionId: current.copyWith(
          messages: [...current.messages, message],
          lastMessageAt: message.createdAt,
        ),
      },
    );
  }

  Future<void> sendImageReply(XFile file) async {
    final sessionId = state.selectedSessionId;
    if (sessionId == null || !state.isConnected) return;

    state = state.copyWith(isSending: true);
    try {
      final imageUrl = await _apiService.uploadChatImage(file);
      if (imageUrl.isNotEmpty) {
        sendReply('', imageUrl: imageUrl);
      }
    } catch (e) {
      state = state.copyWith(error: 'Khong the gui anh: $e');
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetState() {
    _service.disconnect();
    state = const AdminChatState();
  }

  @override
  void dispose() {
    _service.disconnect();
    super.dispose();
  }
}

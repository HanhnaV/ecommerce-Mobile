import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/admin_chat_socket_service.dart';

final adminChatSocketServiceProvider = Provider<AdminChatSocketService>((ref) {
  return AdminChatSocketService();
});

final adminChatProvider =
    StateNotifierProvider<AdminChatNotifier, AdminChatState>((ref) {
  final service = ref.watch(adminChatSocketServiceProvider);
  return AdminChatNotifier(service);
});

class AdminChatSession {
  final String sessionId;
  final List<AdminLiveChatMessage> messages;
  final int unreadCount;
  final DateTime lastMessageAt;

  const AdminChatSession({
    required this.sessionId,
    required this.messages,
    required this.unreadCount,
    required this.lastMessageAt,
  });

  AdminChatSession copyWith({
    List<AdminLiveChatMessage>? messages,
    int? unreadCount,
    DateTime? lastMessageAt,
  }) {
    return AdminChatSession(
      sessionId: sessionId,
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
  final String? error;

  const AdminChatState({
    this.sessions = const {},
    this.selectedSessionId,
    this.isConnected = false,
    this.isConnecting = false,
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
    String? error,
  }) {
    return AdminChatState(
      sessions: sessions ?? this.sessions,
      selectedSessionId: clearSelectedSession
          ? null
          : selectedSessionId ?? this.selectedSessionId,
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error,
    );
  }
}

class AdminChatNotifier extends StateNotifier<AdminChatState> {
  AdminChatNotifier(this._service) : super(const AdminChatState());

  final AdminChatSocketService _service;

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

  void sendReply(String text) {
    final sessionId = state.selectedSessionId;
    if (sessionId == null || text.trim().isEmpty || !state.isConnected) return;

    _service.sendReply(sessionId: sessionId, text: text);
    final message = AdminLiveChatMessage.admin(
      sessionId: sessionId,
      text: text.trim(),
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

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _service.disconnect();
    super.dispose();
  }
}

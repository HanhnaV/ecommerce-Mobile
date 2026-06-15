import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/admin_chat_socket_service.dart';
import '../../providers/admin_chat_provider.dart';
import '../../providers/theme_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminChatProvider.notifier).connect());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final state = ref.read(adminChatProvider);
    if (state.selectedSessionId == null) {
      Fluttertoast.showToast(msg: 'Chon mot khach hang de tra loi');
      return;
    }
    if (!state.isConnected) {
      Fluttertoast.showToast(msg: 'Socket chua ket noi');
      return;
    }

    ref.read(adminChatProvider.notifier).sendReply(text);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDark;
    final chatState = ref.watch(adminChatProvider);

    ref.listen(adminChatProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        Fluttertoast.showToast(
          msg: next.error!,
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
        ref.read(adminChatProvider.notifier).clearError();
      }

      final previousCount = previous?.selectedSession?.messages.length ?? 0;
      final nextCount = next.selectedSession?.messages.length ?? 0;
      if (nextCount > previousCount) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: _ConnectionBadge(state: chatState)),
          ),
          IconButton(
            tooltip: 'Ket noi lai',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminChatProvider.notifier).connect(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          if (wide) {
            return Row(
              children: [
                SizedBox(
                  width: 320,
                  child: _SessionList(
                    state: chatState,
                    isDark: isDark,
                    onSelect:
                        ref.read(adminChatProvider.notifier).selectSession,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
                Expanded(child: _buildChatPanel(chatState, isDark)),
              ],
            );
          }

          return Column(
            children: [
              SizedBox(
                height: 132,
                child: _SessionList(
                  state: chatState,
                  isDark: isDark,
                  compact: true,
                  onSelect: ref.read(adminChatProvider.notifier).selectSession,
                ),
              ),
              Divider(
                height: 1,
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              Expanded(child: _buildChatPanel(chatState, isDark)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatPanel(AdminChatState state, bool isDark) {
    final session = state.selectedSession;
    if (session == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.support_agent,
              size: 64,
              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            Text(
              'Dang cho tin nhan tu khach hang',
              style: TextStyle(
                fontSize: 16,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _ChatHeader(sessionId: session.sessionId, isDark: isDark),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: session.messages.length,
            itemBuilder: (context, index) {
              return _AdminChatBubble(
                message: session.messages[index],
                isDark: isDark,
              );
            },
          ),
        ),
        _ReplyInput(
          controller: _messageController,
          enabled: state.isConnected,
          onSend: _sendReply,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final AdminChatState state;

  const _ConnectionBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = state.isConnected
        ? AppColors.success
        : state.isConnecting
            ? AppColors.warning
            : AppColors.error;
    final label = state.isConnected
        ? 'Online'
        : state.isConnecting
            ? 'Dang ket noi'
            : 'Offline';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final AdminChatState state;
  final bool isDark;
  final bool compact;
  final void Function(String sessionId) onSelect;

  const _SessionList({
    required this.state,
    required this.isDark,
    required this.onSelect,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = state.sortedSessions;

    if (sessions.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Center(
          child: Text(
            'Chua co khach nao',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    if (compact) {
      return Container(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final session = sessions[index];
            return SizedBox(
              width: 220,
              child: _SessionTile(
                session: session,
                selected: state.selectedSessionId == session.sessionId,
                isDark: isDark,
                onTap: () => onSelect(session.sessionId),
              ),
            );
          },
        ),
      );
    }

    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Khach dang chat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1C1917),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SessionTile(
                    session: session,
                    selected: state.selectedSessionId == session.sessionId,
                    isDark: isDark,
                    onTap: () => onSelect(session.sessionId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final AdminChatSession session;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _SessionTile({
    required this.session,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage =
        session.messages.isEmpty ? '' : session.messages.last.text;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  selected ? AppColors.primary : AppColors.secondary,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    session.sessionId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1C1917),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (session.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  session.unreadCount > 9
                      ? '9+'
                      : session.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final String sessionId;
  final bool isDark;

  const _ChatHeader({required this.sessionId, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khach hang',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1C1917),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sessionId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminChatBubble extends StatelessWidget {
  final AdminLiveChatMessage message;
  final bool isDark;

  const _AdminChatBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.fromAdmin;

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.68,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isAdmin
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 16 : 4),
            bottomRight: Radius.circular(isAdmin ? 4 : 16),
          ),
          border: isAdmin
              ? null
              : Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
        ),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isAdmin
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF1C1917)),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isAdmin
                    ? Colors.white70
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class _ReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;
  final bool isDark;

  const _ReplyInput({
    required this.controller,
    required this.enabled,
    required this.onSend,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1C1917)),
              decoration: InputDecoration(
                hintText: enabled ? 'Nhap phan hoi...' : 'Dang mat ket noi',
                hintStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.secondary,
              disabledForegroundColor: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

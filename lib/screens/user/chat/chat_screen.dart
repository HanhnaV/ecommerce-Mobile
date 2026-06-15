import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/chat/chat_bubble.dart';
import '../../../widgets/chat/chat_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(chatProvider.notifier).initChat();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleSend(String text) async {
    await ref.read(chatProvider.notifier).sendMessage(text);

    await Future.delayed(
      const Duration(milliseconds: 100),
    );

    if (mounted) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final themeState = ref.watch(themeProvider);

    final isDark = themeState.isDark;

    ref.listen<ChatState>(
      chatProvider,
          (prev, next) {
        if (next.error != null &&
            prev?.error != next.error) {
          Fluttertoast.showToast(
            msg: next.error!,
            backgroundColor: AppColors.error,
          );

          ref
              .read(chatProvider.notifier)
              .clearError();
        }

        // Auto scroll khi có tin nhắn mới
        if ((prev?.messages.length ?? 0) <
            next.messages.length) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      },
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,

        foregroundColor: isDark
            ? Colors.white
            : const Color(0xFF1C1917),

        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
              AppColors.primary,
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hỗ trợ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                Text(
                  chatState.isConnected
                      ? 'Đang hoạt động'
                      : 'Mất kết nối',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(
                        0xFF94A3B8)
                        : const Color(
                        0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: Icon(
              chatState.isConnected
                  ? Icons.wifi
                  : Icons.wifi_off,
            ),
            onPressed: () {
              ref
                  .read(chatProvider.notifier)
                  .initChat();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(
              chatState,
              isDark,
            ),
          ),

          ChatInput(
            onSend: _handleSend,
            isSending:
            chatState.isSending,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
      ChatState chatState,
      bool isDark,
      ) {
    if (chatState.isLoading &&
        chatState.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: isDark
                  ? const Color(
                  0xFF334155)
                  : const Color(
                  0xFFE2E8F0),
            ),

            const SizedBox(height: 16),

            Text(
              'Chưa có tin nhắn nào',
              style: TextStyle(
                color: isDark
                    ? const Color(
                    0xFF94A3B8)
                    : const Color(
                    0xFF64748B),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Bắt đầu cuộc trò chuyện với hỗ trợ',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? const Color(
                    0xFF64748B)
                    : const Color(
                    0xFF94A3B8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),
      itemCount:
      chatState.messages.length,
      itemBuilder:
          (context, index) {
        final message =
        chatState.messages[index];

        return ChatBubble(
          message: message,
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../../providers/admin_chat_provider.dart';

class AdminSupportScreen extends StatelessWidget {
  const AdminSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hỗ trợ & Chat'),
          centerTitle: false,
          elevation: 0,
          backgroundColor:
          isDark ? const Color(0xFF1E293B) : Colors.white,
          bottom: TabBar(
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor:
            isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Xử lý Báo cáo'),
              Tab(text: 'Trung tâm Chat'),
            ],
          ),
        ),
        backgroundColor:
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: const TabBarView(
          children: [
            _ReportsTab(),
            _ChatCenterTab(),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Report Center'),
    );
  }
}

class _ChatCenterTab extends ConsumerStatefulWidget {
  const _ChatCenterTab();

  @override
  ConsumerState<_ChatCenterTab> createState() =>
      _ChatCenterTabState();
}

class _ChatCenterTabState
    extends ConsumerState<_ChatCenterTab> {
  final TextEditingController _controller =
  TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;

    final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanUrl = url.startsWith('/') ? url : '/$url';

    return '$cleanBaseUrl$cleanUrl';
  }

  @override
  void initState() {
    super.initState();
    // Socket connect được xử lý ở AdminMainLayout
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    ref
        .read(adminChatProvider.notifier)
        .sendReply(text);

    _controller.clear();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        await ref.read(adminChatProvider.notifier).sendImageReply(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminChatProvider);

    final selectedSession =
        state.selectedSession;

    return Row(
      children: [
        /// LEFT SESSION LIST
        SizedBox(
          width: 320,
          child: Container(
            color: Theme.of(context).cardColor,
            child: ListView.builder(
              itemCount:
              state.sortedSessions.length,
              itemBuilder: (context, index) {
                final session =
                state.sortedSessions[index];

                return ListTile(
                  selected:
                  session.sessionId ==
                      state.selectedSessionId,

                  leading: CircleAvatar(
                    child: Text(
                      session.customerName.isNotEmpty
                          ? session.customerName.substring(0, 1).toUpperCase()
                          : '?',
                    ),
                  ),

                  title: Text(
                    session.customerName,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                  ),

                  subtitle:
                  session.messages.isEmpty
                      ? null
                      : Text(
                    session.messages
                        .last.text,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                  ),

                  trailing:
                  session.unreadCount >
                      0
                      ? CircleAvatar(
                    radius: 12,
                    child: Text(
                      session
                          .unreadCount
                          .toString(),
                      style:
                      const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  )
                      : null,

                  onTap: () {
                    ref
                        .read(
                        adminChatProvider
                            .notifier)
                        .selectSession(
                        session
                            .sessionId);
                  },
                );
              },
            ),
          ),
        ),

        const VerticalDivider(width: 1),

        /// RIGHT CHAT
        Expanded(
          child: selectedSession == null
              ? const Center(
            child: Text(
              'Chọn khách hàng để chat',
            ),
          )
              : Column(
            children: [
              Container(
                width:
                double.infinity,
                padding:
                const EdgeInsets
                    .all(16),
                color:
                Theme.of(context)
                    .cardColor,
                child: Text(
                  'Đang chat với: ${selectedSession.customerName}',
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ),

              const Divider(
                height: 1,
              ),

              Expanded(
                child:
                ListView.builder(
                  padding:
                  const EdgeInsets
                      .all(12),

                  itemCount:
                  selectedSession
                      .messages
                      .length,

                  itemBuilder:
                      (context,
                      index) {
                    final message =
                    selectedSession
                        .messages[
                    index];

                    final isAdmin =
                        message
                            .fromAdmin;
                    final isSystem = message.text == "Customer đã ngắt kết nối";

                    if (isSystem) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    return Align(
                      alignment: isAdmin
                          ? Alignment
                          .centerRight
                          : Alignment
                          .centerLeft,

                      child:
                      Container(
                        margin:
                        const EdgeInsets
                            .symmetric(
                          vertical: 4,
                        ),

                        padding:
                        const EdgeInsets
                            .all(
                            12),

                        constraints:
                        const BoxConstraints(
                          maxWidth:
                          400,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          isAdmin
                              ? Colors
                              .blue
                              : Colors
                              .grey
                              .shade300,

                          borderRadius:
                          BorderRadius.circular(
                              12),
                        ),

                        child: Column(
                          crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: _getFullImageUrl(message.imageUrl),
                                    placeholder: (context, url) => const SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            if (message.text.isNotEmpty)
                              Text(
                                message.text,
                                style:
                                TextStyle(
                                  color:
                                  isAdmin
                                      ? Colors
                                      .white
                                      : Colors
                                      .black,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(
                height: 1,
              ),

              Padding(
                padding:
                const EdgeInsets
                    .all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      onPressed: state.isSending ? null : _pickImage,
                      color: Colors.blue,
                    ),
                    Expanded(
                      child:
                      TextField(
                        controller:
                        _controller,
                        enabled: !state.isSending,
                        decoration:
                        const InputDecoration(
                          hintText:
                          'Nhập phản hồi...',
                          border:
                          OutlineInputBorder(),
                        ),

                        onSubmitted:
                            (_) =>
                            _send(),
                      ),
                    ),

                    const SizedBox(
                        width: 8),

                    IconButton(
                      onPressed:
                      state.isSending ? null : _send,
                      icon: state.isSending 
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.send,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
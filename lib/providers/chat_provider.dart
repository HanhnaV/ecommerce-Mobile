import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/chat_message_model.dart';
import '../data/services/chat_socket_services.dart';
import '../data/services/chat_service.dart';
import 'auth_provider.dart';

final chatSocketServiceProvider =
Provider<ChatSocketService>((ref) => ChatSocketService());

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool isConnecting;
  final String? error;
  final bool isConnected;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isConnecting = false,
    this.error,
    this.isConnected = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isConnecting,
    String? error,
    bool? isConnected,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatSocketService _socketService;
  final ChatService _apiService;
  final Ref _ref;

  ChatNotifier(this._socketService, this._apiService, this._ref)
      : super(const ChatState());

  Future<void> initChat() async {
    if (state.isConnected || state.isConnecting) return;
    state = state.copyWith(isConnecting: true);
    _connectSocket();
  }

  void _connectSocket() {
    _socketService.connect(
      onMessageReceived: (data) {
        final isFromAdmin = data['fromAdmin'] == true;
        final content = data['text'] ?? '';
        final imageUrl = data['imageUrl'] as String?;
        
        // Kiểm tra xem tin nhắn này có phải là phản hồi của chính User vừa gửi không
        // Nếu là USER gửi, và trong list đã có tin nhắn temp có nội dung y hệt thì bỏ qua hoặc xóa temp
        if (!isFromAdmin) {
          final hasTemp = state.messages.any((m) => 
            m.senderType == 'USER' && 
            m.content == content && 
            m.imageUrl == imageUrl &&
            m.id.startsWith('temp-')
          );
          if (hasTemp) {
            // Loại bỏ tin nhắn temp và thay bằng tin nhắn chính thức từ server
            state = state.copyWith(
              messages: [
                ...state.messages.where((m) => !(m.senderType == 'USER' && m.content == content && m.imageUrl == imageUrl && m.id.startsWith('temp-'))),
                ChatMessage(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  conversationId: '',
                  content: content,
                  imageUrl: imageUrl,
                  senderType: 'USER',
                  createdAt: DateTime.now(),
                ),
              ],
            );
            return;
          }
        }

        final message = ChatMessage(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          conversationId: '',
          content: content,
          imageUrl: imageUrl,
          senderType: isFromAdmin ? 'ADMIN' : 'USER',
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
          isConnecting: false,
        );
      },

      onError: (_) {
        state = state.copyWith(
          isConnected: false,
          isConnecting: false,
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

  Future<void> sendImage(XFile file) async {
    if (!_socketService.isConnected) {
      state = state.copyWith(error: 'Socket disconnected');
      return;
    }

    state = state.copyWith(isSending: true);

    try {
      // 1. Upload ảnh lên server để lấy URL
      final imageUrl = await _apiService.uploadChatImage(file.path);

      if (imageUrl.isEmpty) {
        throw Exception('Upload failed: Empty URL returned');
      }

      // 2. Hiển thị tin nhắn tạm thời với ảnh
      final tempMessage = ChatMessage(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: '',
        content: '',
        imageUrl: imageUrl,
        senderType: 'USER',
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, tempMessage],
        isSending: false,
      );

      // 3. Gửi thông tin qua Socket
      _socketService.sendMessage('', imageUrl: imageUrl);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Khong the gui anh: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> disconnectChat() async {
    if (state.isConnected) {
      // Gửi thông báo cho admin trước khi ngắt kết nối
      _socketService.sendMessage("Customer đã ngắt kết nối");
      
      // Đợi một chút để tin nhắn kịp gửi đi
      await Future.delayed(const Duration(milliseconds: 500));
      
      _socketService.disconnect();
      state = state.copyWith(isConnected: false);
    }
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
    final apiService = ref.watch(chatServiceProvider);

    return ChatNotifier(
      socketService,
      apiService,
      ref,
    );
  },
);
class ChatMessage {
  final int id;
  final int conversationId;
  final String content;
  final String senderType;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.senderType,
    required this.createdAt,
    this.isRead = false,
  });

  bool get isUser => senderType == 'USER';
  bool get isAdmin => senderType == 'ADMIN';
  bool get isBot => senderType == 'BOT';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      conversationId: json['conversationId'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      senderType: json['senderType'] as String? ?? 'USER',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'senderType': senderType,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  ChatMessage copyWith({
    int? id,
    int? conversationId,
    String? content,
    String? senderType,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      senderType: senderType ?? this.senderType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class Conversation {
  final int id;
  final String userId;
  final String status;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      userId: json['userId'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      lastMessage: json['lastMessage'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}

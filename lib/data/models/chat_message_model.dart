class ChatMessage {
  final String id;
  final String conversationId;
  final String content;
  final String? imageUrl;
  final String senderType;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    this.imageUrl,
    required this.senderType,
    required this.createdAt,
    this.isRead = false,
  });

  bool get isUser => senderType == 'USER';
  bool get isAdmin => senderType == 'ADMIN';
  bool get isBot => senderType == 'BOT';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      conversationId: json['conversationId']?.toString() ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      senderType: json['senderType'] as String? ?? 'USER',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'senderType': senderType,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? content,
    String? imageUrl,
    String? senderType,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      senderType: senderType ?? this.senderType,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class Conversation {
  final String id;
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
      id: json['id'].toString(),
      userId: json['userId']?.toString() ?? '',
      status: json['status'] as String? ?? 'OPEN',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      lastMessage: json['lastMessage'] as String?,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatbotOption {
  final String buttonLabel;
  final String actionPayload;
  final String? nextNodeId;
  final String? categoryId;

  const ChatbotOption({
    required this.buttonLabel,
    required this.actionPayload,
    this.nextNodeId,
    this.categoryId,
  });

  factory ChatbotOption.fromJson(Map<String, dynamic> json) {
    return ChatbotOption(
      buttonLabel: json['buttonLabel']?.toString() ?? '',
      actionPayload: json['actionPayload']?.toString() ?? '',
      nextNodeId: json['nextNodeId']?.toString(),
      categoryId: json['categoryId']?.toString(),
    );
  }
}

class ChatbotProductCard {
  final String id;
  final String name;
  final double basePrice;
  final String? productUrl;
  final String? thumbnailUrl;

  const ChatbotProductCard({
    required this.id,
    required this.name,
    required this.basePrice,
    this.productUrl,
    this.thumbnailUrl,
  });

  factory ChatbotProductCard.fromJson(Map<String, dynamic> json) {
    return ChatbotProductCard(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      productUrl: json['productUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
    );
  }
}

class ChatbotResponse {
  final String messageText;
  final List<ChatbotOption> options;
  final List<ChatbotProductCard> productCards;
  final bool inputExpected;
  final String? inputHint;
  final bool humanHandoffRequired;
  final String? liveChatSessionId;

  const ChatbotResponse({
    required this.messageText,
    required this.options,
    required this.productCards,
    required this.inputExpected,
    this.inputHint,
    required this.humanHandoffRequired,
    this.liveChatSessionId,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    var optsList = json['options'] as List<dynamic>?;
    List<ChatbotOption> opts = optsList != null
        ? optsList.map((e) => ChatbotOption.fromJson(e as Map<String, dynamic>)).toList()
        : const [];

    var cardsList = json['productCards'] as List<dynamic>?;
    List<ChatbotProductCard> cards = cardsList != null
        ? cardsList.map((e) => ChatbotProductCard.fromJson(e as Map<String, dynamic>)).toList()
        : const [];

    return ChatbotResponse(
      messageText: json['messageText']?.toString() ?? '',
      options: opts,
      productCards: cards,
      inputExpected: json['inputExpected'] as bool? ?? false,
      inputHint: json['inputHint']?.toString(),
      humanHandoffRequired: json['humanHandoffRequired'] as bool? ?? false,
      liveChatSessionId: json['liveChatSessionId']?.toString(),
    );
  }
}

class ChatbotUiMessage {
  final String id;
  final String type; // 'user' or 'bot'
  final String text;
  final List<ChatbotProductCard> productCards;

  const ChatbotUiMessage({
    required this.id,
    required this.type,
    required this.text,
    this.productCards = const [],
  });

  ChatbotUiMessage copyWith({
    String? id,
    String? type,
    String? text,
    List<ChatbotProductCard>? productCards,
  }) {
    return ChatbotUiMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      productCards: productCards ?? this.productCards,
    );
  }
}

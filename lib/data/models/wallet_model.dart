class WalletModel {
  final String walletId;
  final String userId;
  final String currency;
  final double availableBalance;
  final double heldBalance;
  final double totalBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalletModel({
    required this.walletId,
    required this.userId,
    required this.currency,
    required this.availableBalance,
    required this.heldBalance,
    required this.totalBalance,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: (json['walletId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      currency: json['currency'] as String? ?? 'VND',
      availableBalance: _parseDouble(json['availableBalance']),
      heldBalance: _parseDouble(json['heldBalance']),
      totalBalance: _parseDouble(json['totalBalance']),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

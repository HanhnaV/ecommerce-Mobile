class SellerStatistics {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int shippingOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double monthRevenue;
  final int totalProducts;
  final int activeProducts;
  final int outOfStockProducts;
  final int totalCustomers;
  final double averageRating;
  final double walletBalance;

  const SellerStatistics({
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.shippingOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.monthRevenue,
    required this.totalProducts,
    required this.activeProducts,
    required this.outOfStockProducts,
    required this.totalCustomers,
    required this.averageRating,
    required this.walletBalance,
  });

  factory SellerStatistics.fromJson(Map<String, dynamic> json) {
    return SellerStatistics(
      totalOrders: json['totalOrders'] as int? ?? 0,
      pendingOrders: json['pendingOrders'] as int? ?? 0,
      confirmedOrders: json['confirmedOrders'] as int? ?? 0,
      shippingOrders: json['shippingOrders'] as int? ?? 0,
      deliveredOrders: json['deliveredOrders'] as int? ?? 0,
      cancelledOrders: json['cancelledOrders'] as int? ?? 0,
      totalRevenue: _parseDouble(json['totalRevenue']),
      monthRevenue: _parseDouble(json['monthRevenue']),
      totalProducts: json['totalProducts'] as int? ?? 0,
      activeProducts: json['activeProducts'] as int? ?? 0,
      outOfStockProducts: json['outOfStockProducts'] as int? ?? 0,
      totalCustomers: json['totalCustomers'] as int? ?? 0,
      averageRating: _parseDouble(json['averageRating']),
      walletBalance: _parseDouble(json['walletBalance']),
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

class TopProduct {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;
  final int soldCount;
  final int orderCount;

  const TopProduct({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.soldCount,
    required this.orderCount,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: _parseDouble(json['price']),
      imageUrl: json['imageUrl'] as String?,
      soldCount: json['soldCount'] as int? ?? 0,
      orderCount: json['orderCount'] as int? ?? 0,
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

class DashboardSummary {
  final SellerStatistics statistics;
  final List<TopProduct> topProducts;

  const DashboardSummary({
    required this.statistics,
    required this.topProducts,
  });
}

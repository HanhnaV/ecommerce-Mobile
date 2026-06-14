class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String shopId;
  final String shopName;
  final String? imageUrl;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.shopId,
    required this.shopName,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? shopId,
    String? shopName,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class CartState {
  final List<CartItem> items;
  final int totalItems;
  final double totalPrice;

  const CartState({
    this.items = const [],
    this.totalItems = 0,
    this.totalPrice = 0.0,
  });

  CartState copyWith({List<CartItem>? items, int? totalItems, double? totalPrice}) {
    return CartState(
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

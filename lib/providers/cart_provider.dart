import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_model.dart';
import '../data/services/cart_service.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void _recalculate() {
    int totalItems = 0;
    double totalPrice = 0.0;
    for (final item in state.items) {
      totalItems += item.quantity;
      totalPrice += item.price * item.quantity;
    }
    state = state.copyWith(totalItems: totalItems, totalPrice: totalPrice);
  }

  void setFromApi(CartApiResponse apiResponse) {
    final items = apiResponse.items.map((e) => CartItem(
      id: e.id,
      productId: e.productId,
      name: e.productName,
      price: e.unitPrice,
      quantity: e.quantity,
      shopId: e.shopId,
      shopName: e.shopName,
      imageUrl: e.productImageUrl,
    )).toList();
    state = CartState(
      items: items,
      totalItems: apiResponse.totalItems,
      totalPrice: apiResponse.totalPrice,
    );
  }

  void addItem(CartItem item) {
    final existing = state.items.indexWhere((i) => i.productId == item.productId);
    if (existing >= 0) {
      final current = state.items[existing];
      final updated = current.copyWith(quantity: current.quantity + item.quantity);
      final newItems = List<CartItem>.from(state.items);
      newItems[existing] = updated;
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
    _recalculate();
  }

  void removeById(int id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
    _recalculate();
  }

  void removeItem(int productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
    _recalculate();
  }

  void updateQuantityById(int id, int quantity) {
    if (quantity <= 0) {
      removeById(id);
      return;
    }
    final newItems = state.items.map((i) {
      if (i.id == id) {
        return i.copyWith(quantity: quantity);
      }
      return i;
    }).toList();
    state = state.copyWith(items: newItems);
    _recalculate();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final newItems = state.items.map((i) {
      if (i.productId == productId) {
        return i.copyWith(quantity: quantity);
      }
      return i;
    }).toList();
    state = state.copyWith(items: newItems);
    _recalculate();
  }

  void clear() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

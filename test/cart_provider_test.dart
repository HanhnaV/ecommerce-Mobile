import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/providers/cart_provider.dart';
import 'package:ecommerce_mobile/data/models/cart_model.dart';

void main() {
  group('CartNotifier', () {
    test('initial state has empty items', () {
      final notifier = CartNotifier();
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.totalItems, 0);
      expect(notifier.state.totalPrice, 0.0);
    });

    test('addItem() appends new item to list', () {
      final notifier = CartNotifier();
      notifier.addItem(const CartItem(
        id: 0,
        productId: 1,
        name: 'Product 1',
        price: 100.0,
        quantity: 2,
        shopId: 1,
        shopName: 'Shop A',
      ));
      expect(notifier.state.items.length, 1);
      expect(notifier.state.totalItems, 2);
      expect(notifier.state.totalPrice, 200.0);
    });

    test('addItem() increments quantity for existing product', () {
      final notifier = CartNotifier();
      notifier.addItem(const CartItem(
        id: 0,
        productId: 1,
        name: 'Product 1',
        price: 100.0,
        quantity: 2,
        shopId: 1,
        shopName: 'Shop A',
      ));
      notifier.addItem(const CartItem(
        id: 0,
        productId: 1,
        name: 'Product 1',
        price: 100.0,
        quantity: 3,
        shopId: 1,
        shopName: 'Shop A',
      ));
      expect(notifier.state.items.length, 1);
      expect(notifier.state.totalItems, 5);
      expect(notifier.state.totalPrice, 500.0);
    });

    test('removeItem() removes item by productId', () {
      final notifier = CartNotifier();
      notifier.addItem(const CartItem(
        id: 0, productId: 1, name: 'P1', price: 100.0, quantity: 1, shopId: 1, shopName: 'Shop',
      ));
      notifier.addItem(const CartItem(
        id: 0, productId: 2, name: 'P2', price: 200.0, quantity: 1, shopId: 1, shopName: 'Shop',
      ));
      notifier.removeItem(1);
      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.productId, 2);
      expect(notifier.state.totalItems, 1);
    });

    test('updateQuantity() changes item quantity', () {
      final notifier = CartNotifier();
      notifier.addItem(const CartItem(
        id: 0, productId: 1, name: 'P1', price: 100.0, quantity: 1, shopId: 1, shopName: 'Shop',
      ));
      notifier.updateQuantity(1, 5);
      expect(notifier.state.totalItems, 5);
      expect(notifier.state.totalPrice, 500.0);
    });

    test('updateQuantity(0) removes item', () {
      final notifier = CartNotifier();
      notifier.addItem(const CartItem(
        id: 0, productId: 1, name: 'P1', price: 100.0, quantity: 1, shopId: 1, shopName: 'Shop',
      ));
      notifier.updateQuantity(1, 0);
      expect(notifier.state.items, isEmpty);
    });

    test('clear() empties cart', () {
      final notifier = CartNotifier();
      notifier.addItem(const CartItem(
        id: 0, productId: 1, name: 'P1', price: 100.0, quantity: 5, shopId: 1, shopName: 'Shop',
      ));
      notifier.clear();
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.totalItems, 0);
      expect(notifier.state.totalPrice, 0.0);
    });
  });
}

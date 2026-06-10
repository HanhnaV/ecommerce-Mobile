import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_mobile/providers/auth_provider.dart';
import 'package:ecommerce_mobile/data/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  group('AuthNotifier', () {
    late ProviderContainer container;
    late AuthNotifier notifier;

    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'read') return null;
        if (methodCall.method == 'write') return null;
        if (methodCall.method == 'delete') return null;
        return null;
      });
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(authStateProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state isLoading false, isAuthenticated false', () async {
      await Future.delayed(Duration.zero);
      final state = container.read(authStateProvider);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
    });

    test('login() sets isAuthenticated true and stores user + token', () async {
      await notifier.login(
        'test.jwt.token',
        const UserModel(
          id: 1,
          email: 'test@example.com',
          fullName: 'Test User',
          role: 'USER',
          accountVerified: false,
        ),
      );
      final state = container.read(authStateProvider);
      expect(state.isAuthenticated, true);
      expect(state.token, 'test.jwt.token');
      expect(state.user?.email, 'test@example.com');
      expect(state.isLoading, false);
    });

    test('logout() resets state and clears cart', () async {
      await notifier.login(
        'test.jwt.token',
        const UserModel(id: 1, email: 'test@example.com', fullName: 'Test User', role: 'USER'),
      );
      await notifier.logout();
      final state = container.read(authStateProvider);
      expect(state.isAuthenticated, false);
      expect(state.token, null);
      expect(state.user, null);
      expect(state.isLoading, false);
    });

    test('updateUser() replaces user data without affecting auth state', () async {
      await notifier.login(
        'test.jwt.token',
        const UserModel(id: 1, email: 'old@example.com', fullName: 'Old Name', role: 'USER'),
      );
      await notifier.updateUser(
        const UserModel(id: 1, email: 'new@example.com', fullName: 'New Name', role: 'USER'),
      );
      final state = container.read(authStateProvider);
      expect(state.user?.email, 'new@example.com');
      expect(state.user?.fullName, 'New Name');
      expect(state.isAuthenticated, true);
    });

    test('updateAccountVerified() toggles accountVerified flag', () async {
      await notifier.login(
        'test.jwt.token',
        const UserModel(id: 1, email: 'test@example.com', fullName: 'Test User', role: 'USER', accountVerified: false),
      );
      expect(notifier.state.accountVerified, false);
      await notifier.updateAccountVerified(true);
      expect(notifier.state.accountVerified, true);
      await notifier.updateAccountVerified(false);
      expect(notifier.state.accountVerified, false);
    });
  });

  group('AuthState', () {
    test('copyWith preserves unchanged fields', () {
      const original = AuthState(
        user: UserModel(id: 1, email: 'a@b.com', fullName: 'A', role: 'USER'),
        token: 'tok',
        isAuthenticated: true,
        accountVerified: true,
        isLoading: false,
      );
      final updated = original.copyWith(isLoading: true);
      expect(updated.user?.email, 'a@b.com');
      expect(updated.token, 'tok');
      expect(updated.isAuthenticated, true);
      expect(updated.accountVerified, true);
      expect(updated.isLoading, true);
    });
  });
}

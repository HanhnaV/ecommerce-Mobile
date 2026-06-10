import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/models/user_model.dart';
import 'cart_provider.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isAuthenticated;
  final bool accountVerified;
  final bool isLoading;

  const AuthState({
    this.user,
    this.token,
    this.isAuthenticated = false,
    this.accountVerified = false,
    this.isLoading = false,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isAuthenticated,
    bool? accountVerified,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accountVerified: accountVerified ?? this.accountVerified,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  static const _tokenKey = 'access_token';
  static const _userKey = 'auth_user';

  AuthNotifier(this._ref) : super(const AuthState(isLoading: true)) {
    _restoreSession();
  }

  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  Future<void> _restoreSession() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final userJson = await _storage.read(key: _userKey);
      if (token != null && userJson != null) {
        final user = UserModel.fromJson(json.decode(userJson) as Map<String, dynamic>);
        state = AuthState(
          user: user,
          token: token,
          isAuthenticated: true,
          accountVerified: user.accountVerified,
          isLoading: false,
        );
        return;
      }
    } catch (_) {}
    state = const AuthState(isLoading: false);
  }

  Future<void> login(String token, UserModel user) async {
    await _storage.write(key: _tokenKey, value: token);
    final userJson = json.encode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
    state = AuthState(
      user: user,
      token: token,
      isAuthenticated: true,
      accountVerified: user.accountVerified,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    _ref.read(cartProvider.notifier).clear();
    state = const AuthState(isLoading: false);
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final userJson = json.encode(updatedUser.toJson());
    await _storage.write(key: _userKey, value: userJson);
    state = state.copyWith(user: updatedUser);
  }

  Future<void> updateAccountVerified(bool value) async {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(accountVerified: value);
      final userJson = json.encode(updatedUser.toJson());
      await _storage.write(key: _userKey, value: userJson);
      state = state.copyWith(user: updatedUser, accountVerified: value);
    } else {
      state = state.copyWith(accountVerified: value);
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

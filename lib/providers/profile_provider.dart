import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final profileUpdateProvider = StateNotifierProvider<ProfileUpdateNotifier, AsyncValue<UserModel?>>((ref) {
  return ProfileUpdateNotifier(ref.watch(profileServiceProvider));
});

class ProfileUpdateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final ProfileService _service;

  ProfileUpdateNotifier(this._service) : super(const AsyncValue.data(null));

  Future<UserModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    String? avatarPath,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _service.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        avatarPath: avatarPath,
      );
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

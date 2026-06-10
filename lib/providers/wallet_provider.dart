import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/wallet_model.dart';
import '../data/services/wallet_service.dart';

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

final walletProvider = FutureProvider.autoDispose<WalletModel>((ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getMyWallet();
});

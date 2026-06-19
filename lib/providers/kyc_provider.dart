import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/kyc_model.dart';
import '../data/services/kyc_service.dart';

final kycServiceProvider = Provider<KycService>((ref) {
  return KycService();
});

final kycSessionProvider = FutureProvider.autoDispose.family<KycSessionResponse, String>((ref, sessionId) async {
  final service = ref.watch(kycServiceProvider);
  return service.getSession(sessionId);
});

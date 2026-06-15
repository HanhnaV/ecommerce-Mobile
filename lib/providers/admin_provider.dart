import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/admin_request_model.dart';
import '../data/services/admin_service.dart';
import '../data/services/seller_service.dart';

final adminRequestsProvider = FutureProvider.autoDispose<List<AdminRequestModel>>((ref) async {
  final page = await adminService.getRequests(status: 'PENDING', size: 50);
  return page.content;
});

final adminOrdersProvider = FutureProvider.autoDispose<List<SellerOrderDetail>>((ref) async {
  final orders = await adminService.getAllOrders(size: 50);
  return orders;
});

final adminRequestsNotifierProvider = StateNotifierProvider.autoDispose<AdminRequestsNotifier, AsyncValue<List<AdminRequestModel>>>((ref) {
  return AdminRequestsNotifier();
});

final adminApprovedRequestsProvider = FutureProvider.autoDispose<List<AdminRequestModel>>((ref) async {
  final page = await adminService.getRequests(status: 'APPROVED', size: 50);
  return page.content;
});

class AdminRequestsNotifier extends StateNotifier<AsyncValue<List<AdminRequestModel>>> {
  AdminRequestsNotifier() : super(const AsyncValue.loading()) {
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      state = const AsyncValue.loading();
      final page = await adminService.getRequests(status: 'PENDING', size: 50);
      state = AsyncValue.data(page.content);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> approveRequest(String requestId, String responseMessage) async {
    try {
      await adminService.approveRequest(requestId, responseMessage);
      await fetchRequests(); // Refresh list after approving
      return true;
    } catch (e) {
      return false; // Error handled by UI via throw or return false. Here return false for simplicity
    }
  }

  Future<bool> rejectRequest(String requestId, String responseMessage) async {
    try {
      await adminService.rejectRequest(requestId, responseMessage);
      await fetchRequests(); // Refresh list after rejecting
      return true;
    } catch (e) {
      return false;
    }
  }
}

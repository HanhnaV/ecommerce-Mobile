import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dashboard_model.dart';
import '../data/services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final sellerStatisticsProvider = FutureProvider.autoDispose<SellerStatistics>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getSellerStatistics();
});

final topProductsProvider = FutureProvider.autoDispose.family<List<TopProduct>, String>((ref, shopId) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getTopProducts(shopId);
});

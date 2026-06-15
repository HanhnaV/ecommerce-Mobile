import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/verify_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/products/product_list_screen.dart';
import '../../screens/products/product_detail_screen.dart';
import '../../screens/user/cart/cart_screen.dart';
import '../../screens/user/checkout/checkout_screen.dart';
import '../../screens/user/checkout/vnpay_webview_screen.dart';
import '../../screens/user/checkout/payment_result_screen.dart';
import '../../screens/user/profile/profile_screen.dart';
import '../../screens/user/profile/wallet_screen.dart';
import '../../screens/user/profile/kyc_screen.dart';
import '../../screens/user/address/address_list_screen.dart';
import '../../screens/user/address/address_form_screen.dart';
import '../../screens/user/orders/order_list_screen.dart';
import '../../screens/user/orders/order_detail_screen.dart';
import '../../screens/user/orders/submit_review_screen.dart';
import '../../screens/user/seller/seller_registration_screen.dart';
import '../../screens/user/seller/seller_dashboard_screen.dart';
import '../../screens/home/flash_sale_screen.dart';
import '../../screens/user/chat/chat_screen.dart';
import '../../screens/user/report/report_screen.dart';
import '../../screens/admin/admin_main_layout.dart';
import '../../screens/admin/dashboard/admin_dashboard_screen.dart';
import '../../screens/admin/approval/admin_approval_screen.dart';
import '../../screens/admin/orders/admin_orders_screen.dart';
import '../../screens/admin/support/admin_support_screen.dart';
import '../../screens/admin/profile/admin_profile_screen.dart';
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final location = state.uri.path;

      final publicRoutes = ['/login', '/register', '/verify'];
      final isPublicRoute = publicRoutes.contains(location);

      if (!isAuth && !isPublicRoute) return '/login';

      final role = authState.user?.role;
      if (isAuth && (location == '/login' || location == '/register' || location == '/')) {
        if (role == 'ADMIN' && location != '/admin/dashboard') return '/admin/dashboard';
        if (location != '/' && role != 'ADMIN') return '/';
      }

      if (role == 'BUSINESS' && location.startsWith('/admin')) return '/';
      if (role == 'USER' && (location.startsWith('/admin') || location.startsWith('/business') || location.startsWith('/seller/dashboard'))) return '/';

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminMainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/admin/approval', builder: (context, state) => const AdminApprovalScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/admin/orders', builder: (context, state) => const AdminOrdersScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/admin/support', builder: (context, state) => const AdminSupportScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/admin/profile', builder: (context, state) => const AdminProfileScreen())]),
        ],
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          return VerifyScreen(email: email);
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final search = state.uri.queryParameters['search'];
          final categoryId = state.uri.queryParameters['categoryId'];
          return ProductListScreen(
            initialSearch: search,
            initialCategoryId: categoryId,
          );
        },
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final idParam = state.pathParameters['id'];
          final productId = idParam ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final shopId = extra?['shopId']?.toString() ?? '';
          return CheckoutScreen(shopId: shopId);
        },
      ),
      GoRoute(
        path: '/checkout/vnpay',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final paymentUrl = extra?['paymentUrl'] as String? ?? '';
          final orderId = extra?['orderId']?.toString() ?? '';
          return VnpayWebViewScreen(paymentUrl: paymentUrl, orderId: orderId);
        },
      ),
      GoRoute(
        path: '/payment-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          var orderId = extra?['orderId']?.toString() ?? '';
          if (orderId.isEmpty) {
            orderId = state.uri.queryParameters['orderId'] ?? '';
          }

          var params = (extra?['params'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? <String, String>{};
          if (params.isEmpty) {
            params = state.uri.queryParameters;
          }

          var rawQuery = extra?['rawQuery'] as String? ?? '';
          if (rawQuery.isEmpty) {
            rawQuery = state.uri.query;
          }

          return PaymentResultScreen(
            orderId: orderId,
            params: params,
            rawQuery: rawQuery,
          );
        },
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
      GoRoute(path: '/addresses', builder: (context, state) => const AddressListScreen()),
      GoRoute(
        path: '/addresses/add',
        builder: (context, state) => const AddressFormScreen(),
      ),
      GoRoute(
        path: '/addresses/edit',
        builder: (context, state) {
          final extra = state.extra;
          final address = extra != null ? (extra as dynamic) : null;
          return AddressFormScreen(address: address);
        },
      ),
      GoRoute(path: '/kyc', builder: (context, state) => const KycScreen()),
      GoRoute(path: '/orders', builder: (context, state) => const OrderListScreen()),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final idParam = state.pathParameters['id'];
          final orderId = idParam ?? '';
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/submit-review',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SubmitReviewScreen(
            productId: extra?['productId']?.toString() ?? '',
            productName: extra?['productName'] as String? ?? '',
            productImageUrl: extra?['productImageUrl'] as String?,
          );
        },
      ),
      GoRoute(path: '/seller/register', builder: (context, state) => const SellerRegistrationScreen()),
      GoRoute(path: '/seller/dashboard', builder: (context, state) => const SellerDashboardScreen()),
      GoRoute(path: '/flash-sale', builder: (context, state) => const FlashSaleScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(path: '/report', builder: (context, state) => const ReportScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );
});

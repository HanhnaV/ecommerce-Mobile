import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../data/services/order_service.dart';

final _orderService = OrderService();

class VnpayWebViewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final int orderId;

  const VnpayWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
  });

  @override
  ConsumerState<VnpayWebViewScreen> createState() => _VnpayWebViewScreenState();
}

class _VnpayWebViewScreenState extends ConsumerState<VnpayWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_isReturnUrl(url)) {
              _handleReturn(url);
            }
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _error = error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _isReturnUrl(String url) {
    final returnPatterns = ['vnpay_return', 'payment_result', 'localhost:5173/payment'];
    return returnPatterns.any((p) => url.contains(p)) || url.contains('vnp_ResponseCode');
  }

  void _handleReturn(String url) {
    final uri = Uri.parse(url);
    final params = uri.queryParameters;
    final responseCode = params['vnp_ResponseCode'] ?? params['vnp_Response_Id'];

    if (mounted) {
      context.pushReplacement(
        '/payment-result',
        extra: {
          'orderId': widget.orderId,
          'params': Map<String, String>.from(params),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toan VNPay'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE7E5E4),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Loi: $_error', style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}

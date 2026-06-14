import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../data/services/order_service.dart';

class VnpayWebViewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String orderId;

  const VnpayWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
  });

  @override
  ConsumerState<VnpayWebViewScreen> createState() => _VnpayWebViewScreenState();
}

class _VnpayWebViewScreenState extends ConsumerState<VnpayWebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _hasHandledReturn = false;
  late final bool _isSupported;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _isSupported = !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

    if (_isSupported) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              // Intercept the return URL and prevent actual navigation
              if (_isReturnUrl(request.url)) {
                _handleReturn(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageStarted: (url) {
              // Fallback interception in case onNavigationRequest doesn't fire
              if (_isReturnUrl(url) && !_hasHandledReturn) {
                _handleReturn(url);
              }
            },
            onPageFinished: (url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              // Ignore errors for intercepted URLs
              if (_hasHandledReturn) return;
              if (mounted) setState(() => _error = error.description);
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.paymentUrl));
    } else {
      _isLoading = false;
      _startPolling();
    }
  }

  void _startPolling() {
    if (_pollingTimer != null) return;
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final order = await OrderService().getMyOrderById(widget.orderId);
        if (order.status != 'PENDING_PAYMENT') {
          _pollingTimer?.cancel();
          _pollingTimer = null;
          if (mounted) {
            context.pushReplacement(
              '/payment-result',
              extra: {
                'orderId': widget.orderId,
                'params': <String, String>{},
                'rawQuery': '',
              },
            );
          }
        }
      } catch (e) {
        // Ignore network errors during polling
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  bool _isReturnUrl(String url) {
    final returnPatterns = ['vnpay_return', 'payment_result', 'localhost:5173/payment'];
    return returnPatterns.any((p) => url.contains(p)) || url.contains('vnp_ResponseCode');
  }

  void _handleReturn(String url) {
    if (_hasHandledReturn) return;
    _hasHandledReturn = true;

    final uri = Uri.parse(url);
    final params = uri.queryParameters;

    final int indexOfQuery = url.indexOf('?');
    final String rawQuery = indexOfQuery != -1 ? url.substring(indexOfQuery + 1) : '';

    if (mounted) {
      context.pushReplacement(
        '/payment-result',
        extra: {
          'orderId': widget.orderId,
          'params': Map<String, String>.from(params),
          'rawQuery': rawQuery,
        },
      );
    }
  }

  Future<bool> _showExitConfirmation() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huy thanh toan?'),
        content: const Text(
          'Don hang da duoc tao. Neu thoat, ban co the thanh toan lai tu muc Don hang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('O lai'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Thoat', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return shouldLeave == true;
  }

  Widget _buildFallbackView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.language_outlined,
                size: 64,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thanh toan ngoai ung dung',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1C1917),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Trinh duyet trong ung dung (WebView) chi ho tro tren thiet bi di dong (Android/iOS).\n\nVui long mo lien ket thanh toan bang trinh duyet he thong de tiep tuc.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openPaymentUrl,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Mo cong thanh toan VNPay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                context.pushReplacement(
                  '/payment-result',
                  extra: {
                    'orderId': widget.orderId,
                    'params': <String, String>{},
                    'rawQuery': '',
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Xac nhan da thanh toan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPaymentUrl() async {
    final uri = Uri.parse(widget.paymentUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _startPolling();
      } else {
        Fluttertoast.showToast(msg: 'Khong the mo lien ket thanh toan');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Loi khi mo lien ket: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _showExitConfirmation();
        if (shouldLeave && mounted) {
          context.go('/orders/${widget.orderId}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toan VNPay'),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldLeave = await _showExitConfirmation();
              if (shouldLeave && mounted) {
                context.go('/orders/${widget.orderId}');
              }
            },
          ),
        ),
        body: Column(
          children: [
            if (_isLoading && _isSupported)
              LinearProgressIndicator(
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE7E5E4),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
              ),
            if (_error != null && !_hasHandledReturn && _isSupported)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Loi: $_error', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _controller?.loadRequest(Uri.parse(widget.paymentUrl));
                      },
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _isSupported
                  ? WebViewWidget(controller: _controller!)
                  : _buildFallbackView(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

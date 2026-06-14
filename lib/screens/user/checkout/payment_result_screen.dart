import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/services/order_service.dart';
import '../../../providers/theme_provider.dart';

final _orderService = OrderService();

class PaymentResultScreen extends ConsumerStatefulWidget {
  final String orderId;
  final Map<String, String> params;

  const PaymentResultScreen({
    super.key,
    required this.orderId,
    required this.params,
  });

  @override
  ConsumerState<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends ConsumerState<PaymentResultScreen> {
  String _status = 'loading';
  String _message = 'Dang xu ly ket qua thanh toan...';
  String? _transactionId;

  @override
  void initState() {
    super.initState();
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    try {
      await _orderService.verifyVnpayPayment(widget.params);
      final responseCode = widget.params['vnp_ResponseCode'];
      final txnId = widget.params['vnp_TransactionNo'];

      if (responseCode == '00') {
        setState(() {
          _status = 'success';
          _message = 'Thanh toan thanh cong!';
          _transactionId = txnId;
        });
      } else {
        setState(() {
          _status = 'failed';
          _message = _getResponseMessage(responseCode ?? '');
        });
      }
    } catch (e) {
      setState(() {
        _status = 'failed';
        _message = 'Co loi xay ra khi xac thuc thanh toan.';
      });
    }
  }

  String _getResponseMessage(String code) {
    const messages = {
      '07': 'Dinh dang tien thanh toan khong dung.',
      '09': 'The chua dang ky dich vu Internet Banking.',
      '10': 'Xac thuc that bai.',
      '11': 'Dai ly chua xac thuc.',
      '12': 'The nap khong dung.',
      '13': 'Xac thuc mat khau that bai.',
      '24': 'Huy giao dich.',
      '51': 'Tai khoan khong du so du.',
      '65': 'Tai khoan vuot qua han muc.',
      '75': 'Ngan hang dang bao tri.',
      '79': 'Sai mat khau xac thuc.',
      '99': 'Nguoi dung huy giao dich.',
    };
    return messages[code] ?? 'Thanh toan that bai hoac bi huy (ma: $code).';
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
      appBar: AppBar(
        title: const Text('Ket qua thanh toan'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_status == 'loading') ...[
              const CircularProgressIndicator(strokeWidth: 3),
              const SizedBox(height: 24),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1C1917),
                ),
              ),
            ] else if (_status == 'success') ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Thanh toan thanh cong!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1C1917),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Don hang #${widget.orderId} da duoc thanh toan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                ),
              ),
              if (_transactionId != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Ma giao dich: $_transactionId',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
                    ),
                    child: Text('Ve trang chu', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1917))),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Xem don hang'),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel,
                  size: 64,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Thanh toan that bai',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1C1917),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Don hang #${widget.orderId} da duoc tao nhung chua thanh toan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
                    ),
                    child: Text('Ve trang chu', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1917))),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('Quay ve gio hang'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

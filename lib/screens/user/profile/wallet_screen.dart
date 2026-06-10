import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu';
    }
    return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Vi dien tu'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                e.toString().replaceFirst('Exception: ', ''),
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(walletProvider),
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
        data: (wallet) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(walletProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBalanceCard(wallet, isDark),
              const SizedBox(height: 20),
              _buildQuickActions(context, ref, isDark),
              const SizedBox(height: 20),
              _buildInfoCard(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(wallet, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'So du',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_formatCurrency(wallet.totalBalance)} ${wallet.currency}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem('Kha dung', wallet.availableBalance, isDark),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildBalanceItem('Bi khoa', wallet.heldBalance, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatCurrency(amount)}',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            Icons.add,
            'Nap tien',
            const Color(0xFF22C55E),
            isDark,
            () => Fluttertoast.showToast(msg: 'Tinh nang nap tien dang phat trien'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            Icons.arrow_upward,
            'Rut tien',
            Color(0xFF2563EB),
            isDark,
            () => Fluttertoast.showToast(msg: 'Tinh nang rut tien dang phat trien'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            Icons.history,
            'Lich su',
            Color(0xFFF59E0B),
            isDark,
            () => Fluttertoast.showToast(msg: 'Tinh nang lich su giao dich dang phat trien'),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  'Ve Vi dien tu',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoLine('So du kha dung: Tien ban co the rut hoac su dung de thanh toan.', isDark),
            _infoLine('So du bi khoa: Tien trong giao dich cho don hang chua hoan thanh.', isDark),
            _infoLine('Tien se tu dong giai toa khi don hang hoan thanh.', isDark),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

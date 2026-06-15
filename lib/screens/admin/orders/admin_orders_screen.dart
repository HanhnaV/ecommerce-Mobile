import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/admin_provider.dart';
class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng'),
          centerTitle: false,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          bottom: TabBar(
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: const Color(0xFF2563EB),
            tabs: const [
              Tab(text: 'Giám sát đơn hàng'),
              Tab(text: 'Lịch sử giao dịch'),
            ],
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: const TabBarView(
          children: [
            _OrdersMonitorTab(),
            _TransactionHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _OrdersMonitorTab extends ConsumerWidget {
  const _OrdersMonitorTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi: $err')),
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('Chưa có đơn hàng nào trong hệ thống.'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final order = orders[index];
            final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

            return Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.blue),
                ),
                title: Text('Đơn hàng #${order.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Trạng thái: ${order.status}\nTổng tiền: ${currencyFormat.format(order.totalAmount)}'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showOrderDetails(context, order, isDark);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderDetails(BuildContext context, dynamic order, bool isDark) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Chi tiết Đơn hàng #${order.orderCode}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Trạng thái: ${order.status}', style: const TextStyle(fontSize: 16, color: Colors.blue)),
                const Divider(height: 32),
                const Text('Thông tin giao hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Người nhận: ${order.customerName ?? "Không rõ"}'),
                Text('SĐT: ${order.customerPhone ?? "Không rõ"}'),
                Text('Địa chỉ: ${order.shippingAddress ?? "Không rõ"}'),
                const Divider(height: 32),
                const Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (order.items != null)
                  ...order.items.map((item) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.productName),
                      subtitle: Text('Số lượng: ${item.quantity}'),
                      trailing: Text(currencyFormat.format(item.totalPrice)),
                    );
                  }).toList(),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Phí vận chuyển:'),
                    Text(currencyFormat.format(order.shippingFee ?? 0)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng tiền:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(currencyFormat.format(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TransactionHistoryTab extends StatelessWidget {
  const _TransactionHistoryTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Danh sách dòng tiền giao dịch qua VNPay'));
  }
}

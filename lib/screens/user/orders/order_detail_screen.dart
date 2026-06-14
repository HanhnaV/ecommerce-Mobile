import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/order_status.dart';
import '../../../data/services/order_service.dart';
import '../../../providers/theme_provider.dart';
import 'order_list_screen.dart';

final _orderDetailProvider = FutureProvider.family<OrderDetail, String>((ref, orderId) async {
  final service = OrderService();
  return service.getMyOrderById(orderId);
});

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} trieu VND';
    }
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VND';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;
    final orderAsync = ref.watch(_orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Chi tiet don hang'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: orderAsync.when(
        data: (order) => _buildContent(context, ref, order, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                err.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_orderDetailProvider(orderId)),
                child: const Text('Thu lai'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, OrderDetail order, bool isDark) {
    final status = OrderStatus.fromCode(order.status);
    final address = order.address;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(status, isDark),
                const SizedBox(height: 16),
                if (address != null) _buildAddressCard(address, isDark),
                const SizedBox(height: 16),
                _buildShopCard(order, isDark),
                const SizedBox(height: 16),
                _buildItemsCard(context, order, isDark),
                const SizedBox(height: 16),
                _buildPriceCard(order, isDark),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesCard(order.notes!, isDark),
                ],
              ],
            ),
          ),
        ),
        _buildBottomBar(context, ref, order, status, isDark),
      ],
    );
  }

  Widget _buildStatusCard(OrderStatus status, bool isDark) {
    IconData icon;
    switch (status) {
      case OrderStatus.pending:
        icon = Icons.hourglass_top;
        break;
      case OrderStatus.confirmed:
        icon = Icons.check_circle;
        break;
      case OrderStatus.shipping:
        icon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        icon = Icons.cancel;
        break;
      default:
        icon = Icons.info;
    }

    return Card(
      color: status.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: status.color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.displayText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status.color,
                    ),
                  ),
                  if (status == OrderStatus.shipping)
                    Text(
                      'Don hang dang duoc giao den ban',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(AddressInfo address, bool isDark) {
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
                Icon(Icons.location_on, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Dia chi giao hang',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.receiverName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.receiverPhone,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${address.addressLine}, ${address.ward}, ${address.district}, ${address.city}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCard(OrderDetail order, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.store, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.shopName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Ma don: ${order.orderCode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, OrderDetail order, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'San pham (${order.items.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/products/${item.productId}'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.imageUrl != null
                              ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 64,
                          height: 64,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 64,
                          height: 64,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                        ),
                      )
                          : Container(
                        width: 64,
                        height: 64,
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                      ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/products/${item.productId}'),
                          child: Text(
                            item.productName,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(item.totalPrice),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            '${_formatCurrency(item.unitPrice)} x${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (order.status == 'DELIVERED') ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => context.push('/submit-review', extra: {
                          'productId': item.productId,
                          'productName': item.productName,
                          'productImageUrl': item.imageUrl,
                        }),
                        icon: const Icon(Icons.rate_review, size: 16),
                        label: const Text('Danh gia'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(OrderDetail order, bool isDark) {
    final subtotal = order.subtotal;
    final shipping = order.shippingFee;
    final total = order.total;

    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _priceRow('Tien hang', subtotal, isDark),
            const SizedBox(height: 8),
            _priceRow('Phi van chuyen', shipping, isDark),
            Divider(height: 20, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            _priceRow('Tong thanh toan', total, isDark, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double amount, bool isDark, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.primary : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(String notes, bool isDark) {
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
                Icon(Icons.note, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  'Ghi chu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notes,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, OrderDetail order, OrderStatus status, bool isDark) {
    // Hidden because backend cancel API is shop-only
    const canCancel = false;
    final canConfirmReceive = status == OrderStatus.shipping;

    if (!canCancel && !canConfirmReceive) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canCancel)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(context, ref, order.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Huy don'),
              ),
            ),
          if (canCancel && canConfirmReceive) const SizedBox(width: 12),
          if (canConfirmReceive)
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmReceived(context, ref, order.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Da nhan hang'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmReceived(BuildContext context, WidgetRef ref, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan'),
        content: const Text('Ban da nhan duoc hang?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Chua nhan')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Da nhan', style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final service = OrderService();
      await service.markOrderReceived(orderId);
      ref.invalidate(_orderDetailProvider(orderId));
      if (context.mounted) {
        Fluttertoast.showToast(msg: 'Xac nhan thanh cong!');
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: AppColors.error,
        );
      }
    }
  }

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huy don hang'),
        content: const Text('Ban co chan muon huy don hang nay?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Khong')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Huy', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final service = OrderService();
      await service.cancelOrder(orderId);
      ref.invalidate(_orderDetailProvider(orderId));
      ref.invalidate(ordersProvider(null));
      if (context.mounted) {
        Fluttertoast.showToast(msg: 'Da huy don hang');
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: AppColors.error,
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/order_status.dart';
import '../../../data/services/order_service.dart';
import '../../../providers/theme_provider.dart';

final orderServiceProvider = Provider((_) => OrderService());

final ordersProvider = FutureProvider.autoDispose.family<OrderPage, String?>((ref, status) async {
  final service = ref.watch(orderServiceProvider);
  return service.getMyOrders(status: status);
});

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  String? _selectedStatus;

  static const _tabs = [
    (null, 'Tat ca'),
    ('PENDING_PAYMENT', 'Cho thanh toan'),
    ('PENDING', 'Cho xac nhan'),
    ('CONFIRMED', 'Da xac nhan'),
    ('SHIPPING', 'Dang giao'),
    ('DELIVERED', 'Da giao'),
    ('CANCELLED', 'Da huy'),
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;
    final ordersAsync = ref.watch(ordersProvider(_selectedStatus));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Don hang'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedStatus == tab.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        tab.$2,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedStatus = tab.$1),
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      checkmarkColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orderPage) {
                if (orderPage.content.isEmpty) {
                  return _buildEmpty(isDark);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(ordersProvider(_selectedStatus));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderPage.content.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OrderCard(order: orderPage.content[index], isDark: isDark),
                      );
                    },
                  ),
                );
              },
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
                      onPressed: () => ref.invalidate(ordersProvider(_selectedStatus)),
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 64, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(
            'Chua co don hang nao',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Tiep tuc mua sam'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderDetail order;
  final bool isDark;

  const _OrderCard({required this.order, required this.isDark});

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} trieu';
    }
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VND';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final status = OrderStatus.fromCode(order.status);
    final itemCount = order.items.length;

    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        order.shopName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.displayText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: item.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: item.imageUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    width: 48,
                                    height: 48,
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 48,
                                    height: 48,
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'x${item.quantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(item.totalPrice),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (itemCount > 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '+${itemCount - 2} san pham khac',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Tong: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _formatCurrency(order.total),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

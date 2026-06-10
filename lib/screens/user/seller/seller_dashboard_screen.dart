import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/services/seller_service.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/theme_provider.dart';

class SellerDashboardScreen extends ConsumerStatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  ConsumerState<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends ConsumerState<SellerDashboardScreen> {
  SellerShop? _shop;
  bool _loadingShop = true;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    try {
      final shop = await SellerService().getMyShop();
      if (mounted) setState(() { _shop = shop; _loadingShop = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingShop = false);
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(sellerStatisticsProvider);
    if (_shop != null) {
      ref.invalidate(topProductsProvider(_shop!.id));
    }
    await _loadShop();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    final statsAsync = ref.watch(sellerStatisticsProvider);
    final topProductsAsync = _shop != null
        ? ref.watch(topProductsProvider(_shop!.id))
        : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Lam moi',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShopHeader(isDark),
              const SizedBox(height: 20),
              _buildQuickActions(isDark),
              const SizedBox(height: 20),
              _buildSectionTitle('Tong quan', isDark),
              const SizedBox(height: 12),
              statsAsync.when(
                data: (stats) => _buildStatisticsSection(stats, isDark),
                loading: () => _buildLoadingStats(isDark),
                error: (err, _) => _buildErrorCard(
                  err.toString().replaceFirst('Exception: ', ''),
                  isDark,
                  onRetry: () => ref.invalidate(sellerStatisticsProvider),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('San pham ban chay', isDark),
              const SizedBox(height: 12),
              topProductsAsync != null
                  ? topProductsAsync.when(
                      data: (products) => products.isEmpty
                          ? _buildEmptyTopProducts(isDark)
                          : _buildTopProductsList(products, isDark),
                      loading: () => _buildLoadingTopProducts(isDark),
                      error: (err, _) => _buildSmallError(
                        err.toString().replaceFirst('Exception: ', ''),
                        isDark,
                      ),
                    )
                  : _buildSmallError('Dang tai thong tin cua hang...', isDark),
              const SizedBox(height: 24),
              _buildQuickLinks(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader(bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _loadingShop
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    backgroundImage: _shop?.shopAvatarUrl != null
                        ? NetworkImage(_shop!.shopAvatarUrl!) as ImageProvider
                        : null,
                    child: _shop?.shopAvatarUrl == null
                        ? Icon(Icons.store, size: 28, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _shop?.shopName ?? 'Cua hang cua ban',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusBadge(_shop?.status ?? 'PENDING', isDark),
                            if (_shop?.rating != null) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.star, size: 14, color: AppColors.rating),
                              const SizedBox(width: 2),
                              Text(
                                _shop!.rating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.rating,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    onPressed: () {},
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color color;
    String text;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'APPROVED':
        color = AppColors.success;
        text = 'Hoat dong';
        break;
      case 'PENDING':
        color = AppColors.warning;
        text = 'Dang cho';
        break;
      case 'REJECTED':
      case 'BANNED':
        color = AppColors.error;
        text = 'Bi khoa';
        break;
      default:
        color = AppColors.secondary;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.receipt_long,
            label: 'Don hang',
            color: AppColors.info,
            isDark: isDark,
            onTap: () => context.push('/seller/orders'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.inventory_2,
            label: 'San pham',
            color: AppColors.success,
            isDark: isDark,
            onTap: () => context.push('/seller/products'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.account_balance_wallet,
            label: 'Vi',
            color: AppColors.accent,
            isDark: isDark,
            onTap: () => context.push('/wallet'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildStatisticsSection(SellerStatistics stats, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.account_balance_wallet,
                title: 'Tong doanh thu',
                value: _formatCurrency(stats.totalRevenue),
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_month,
                title: 'Doanh thu thang',
                value: _formatCurrency(stats.monthRevenue),
                color: AppColors.info,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.shopping_cart,
                title: 'Tong don hang',
                value: stats.totalOrders.toString(),
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                title: 'Khach hang',
                value: stats.totalCustomers.toString(),
                color: AppColors.accent,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.inventory,
                title: 'San pham',
                subtitle: '${stats.activeProducts} active / ${stats.outOfStockProducts} het hang',
                value: stats.totalProducts.toString(),
                color: AppColors.secondary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                title: 'Danh gia TB',
                value: stats.averageRating > 0 ? stats.averageRating.toStringAsFixed(1) : '-',
                color: AppColors.rating,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildOrderStatusBreakdown(stats, isDark),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusBreakdown(SellerStatistics stats, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tinh trang don hang',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildOrderStatusItem('Cho xu ly', stats.pendingOrders, AppColors.warning, isDark),
                _buildOrderStatusItem('Da xac nhan', stats.confirmedOrders, AppColors.info, isDark),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildOrderStatusItem('Dang giao', stats.shippingOrders, AppColors.shipping, isDark),
                _buildOrderStatusItem('Da giao', stats.deliveredOrders, AppColors.success, isDark),
                _buildOrderStatusItem('Da huy', stats.cancelledOrders, AppColors.error, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusItem(String label, int count, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsList(List<TopProduct> products, bool isDark) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: index < products.length - 1 ? 10 : 0),
            child: Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => context.push('/products/${product.id}'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 90,
                          width: double.infinity,
                          child: product.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: product.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    child: Icon(Icons.image, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8)),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    child: Icon(Icons.image, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8)),
                                  ),
                                )
                              : Container(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                  child: Icon(Icons.image, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8)),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatCurrency(product.price),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${product.soldCount} da ban',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickLinks(bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildLinkTile(Icons.receipt_long, 'Quan ly don hang', Icons.chevron_right, isDark, () => context.push('/seller/orders')),
          Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _buildLinkTile(Icons.inventory_2, 'Quan ly san pham', Icons.chevron_right, isDark, () => context.push('/seller/products')),
          Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _buildLinkTile(Icons.rate_review, 'Tra loi danh gia', Icons.chevron_right, isDark, () {}),
          Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _buildLinkTile(Icons.account_balance_wallet, 'Vi dien tu', Icons.chevron_right, isDark, () => context.push('/wallet')),
        ],
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String title, IconData trailing, bool isDark, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      trailing: Icon(trailing, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
      onTap: onTap,
    );
  }

  Widget _buildLoadingStats(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 100,
            child: Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingTopProducts(bool isDark) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => Container(
          width: 160,
          margin: const EdgeInsets.only(right: 10),
          child: Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTopProducts(bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2, size: 40, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
              const SizedBox(height: 8),
              Text(
                'Chua co san pham nao',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, bool isDark, {VoidCallback? onRetry}) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 40, color: AppColors.error),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Thu lai'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallError(String message, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VND';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K VND';
    }
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VND';
  }
}

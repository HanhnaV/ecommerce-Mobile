import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/services/cart_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/cart_provider.dart';

final _cartService = CartService();

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  CartApiResponse? _cart;
  bool _loading = true;
  String? _error;
  final Map<int, bool> _updatingItems = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      setState(() => _loading = true);
      final data = await _cartService.getCart();
      if (mounted) {
        setState(() => _cart = data);
        ref.read(cartProvider.notifier).setFromApi(data);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleQuantityChange(CartApiItem item, int delta) async {
    final newQty = item.quantity + delta;
    if (newQty < 1) return;
    if (newQty > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('So luong toi da la 10 san pham')),
      );
      return;
    }

    setState(() => _updatingItems[item.id] = true);
    try {
      CartApiResponse data;
      if (delta > 0) {
        data = await _cartService.increaseQuantity(item.id);
      } else {
        data = await _cartService.decreaseQuantity(item.id);
      }
      if (mounted) {
        setState(() => _cart = data);
        ref.read(cartProvider.notifier).setFromApi(data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingItems[item.id] = false);
    }
  }

  Future<void> _handleRemoveItem(CartApiItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa san pham'),
        content: Text('Ban co chac chan muon xoa "${item.productName}" khoi gio hang?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _updatingItems[item.id] = true);
    try {
      final data = await _cartService.removeItem(item.id);
      if (mounted) {
        setState(() => _cart = data);
        ref.read(cartProvider.notifier).setFromApi(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da xoa san pham')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingItems[item.id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
      appBar: AppBar(
        title: const Text('Gio hang'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: isDark ? Colors.red[300] : Colors.red[600])),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadCart, child: const Text('Thu lai')),
          ],
        ),
      );
    }

    final items = _cart?.items ?? [];
    final total = _cart?.totalPrice ?? 0.0;
    final totalItems = _cart?.totalItems ?? 0;

    if (items.isEmpty) {
      return _buildEmptyCart(isDark);
    }

    final grouped = <int, _ShopGroup>{};
    for (final item in items) {
      grouped.putIfAbsent(item.shopId, () => _ShopGroup(shopId: item.shopId, shopName: item.shopName));
      grouped[item.shopId]!.items.add(item);
    }

    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Gio hang cua ban',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1C1917),
            ),
          ),
          Text(
            '($totalItems san pham)',
            style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C)),
          ),
          const SizedBox(height: 16),
          ...grouped.values.map((group) => _buildShopCard(group, isDark)),
          const SizedBox(height: 16),
          _buildSummaryCard(items, total, isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
            ),
            const SizedBox(height: 24),
            Text(
              'Gio hang trong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1C1917),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Co ve nhu ban chua them san pham nao vao gio hang.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tiep tuc mua sam'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCard(_ShopGroup group, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.store, size: 18, color: Color(0xFFD97706)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.shopName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C1917),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...group.items.map((item) => _buildCartItem(item, isDark)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${group.items.length} san pham',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/checkout', extra: {'shopId': group.shopId}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Mua tu Shop nay'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartApiItem item, bool isDark) {
    final isUpdating = _updatingItems[item.id] ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.productImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.productImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4)),
                      errorWidget: (_, __, ___) => Container(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                        child: Icon(Icons.headphones, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
                      ),
                    )
                  : Container(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                      child: Icon(Icons.headphones, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/products/${item.productId}'),
                  child: Text(
                    item.productName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1C1917),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(item.unitPrice),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQtyButton(
                      Icons.remove,
                      item.quantity > 1 ? () => _handleQuantityChange(item, -1) : null,
                      isDark,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: isUpdating
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1C1917),
                              ),
                            ),
                    ),
                    _buildQtyButton(Icons.add, () => _handleQuantityChange(item, 1), isDark),
                    const Spacer(),
                    Text(
                      _formatPrice(item.totalPrice),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1917),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isUpdating ? null : () => _handleRemoveItem(item),
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback? onPressed, bool isDark) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed != null
              ? (isDark ? Colors.white : const Color(0xFF1C1917))
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<CartApiItem> items, double total, bool isDark) {
    final totalItems = items.fold(0, (sum, item) => sum + item.quantity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tong so luong',
                style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C)),
              ),
              Text(
                '$totalItems san pham',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1C1917)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tong tien tam tinh',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917)),
              ),
              Text(
                _formatPrice(total),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '* Phi van chuyen va ma giam gia se duoc tinh o buoc thanh toan.',
            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VND';
  }
}

class _ShopGroup {
  final int shopId;
  final String shopName;
  final List<CartApiItem> items = [];

  _ShopGroup({required this.shopId, required this.shopName});
}

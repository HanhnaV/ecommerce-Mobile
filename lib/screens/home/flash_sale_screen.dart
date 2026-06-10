import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/promotion_service.dart';
import '../../../providers/theme_provider.dart';

final _flashSaleProvider = FutureProvider.autoDispose<FlashSaleData>((ref) async {
  final service = PromotionService();
  return service.getFlashSale();
});

final _dealsProvider = FutureProvider.autoDispose.family<List<DealProduct>, int>((ref, page) async {
  final service = PromotionService();
  return service.getDeals(page: page, size: 20);
});

class FlashSaleScreen extends ConsumerStatefulWidget {
  const FlashSaleScreen({super.key});

  @override
  ConsumerState<FlashSaleScreen> createState() => _FlashSaleScreenState();
}

class _FlashSaleScreenState extends ConsumerState<FlashSaleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Khuyen mai'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          tabs: const [
            Tab(text: 'Flash Sale'),
            Tab(text: 'Deal hot'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FlashSaleTab(isDark: isDark),
          _DealsTab(isDark: isDark),
        ],
      ),
    );
  }
}

class _FlashSaleTab extends ConsumerWidget {
  final bool isDark;

  const _FlashSaleTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashSaleAsync = ref.watch(_flashSaleProvider);

    return flashSaleAsync.when(
      data: (data) {
        if (!data.isActive || data.products.isEmpty) {
          return _buildEmpty(
            Icons.flash_off,
            data.message ?? 'Khong co khuyen mai Flash Sale hien tai.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_flashSaleProvider),
          child: Column(
            children: [
              if (data.endTime != null) _CountdownBanner(endTime: data.endTime!, isDark: isDark),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: data.products.length,
                  itemBuilder: (context, index) {
                    return _FlashSaleCard(product: data.products[index], isDark: isDark);
                  },
                ),
              ),
            ],
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
              onPressed: () => ref.invalidate(_flashSaleProvider),
              child: const Text('Thu lai'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _CountdownBanner extends StatefulWidget {
  final DateTime endTime;
  final bool isDark;

  const _CountdownBanner({required this.endTime, required this.isDark});

  @override
  State<_CountdownBanner> createState() => _CountdownBannerState();
}

class _CountdownBannerState extends State<_CountdownBanner> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateRemaining();
        return _remaining.inSeconds > 0;
      }
      return false;
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    setState(() {
      _remaining = widget.endTime.difference(now);
      if (_remaining.isNegative) _remaining = Duration.zero;
    });
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.discount, AppColors.discount.withValues(alpha: 0.8)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Ket thuc sau:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${_pad(hours)}:${_pad(minutes)}:${_pad(seconds)}',
              style: const TextStyle(
                color: AppColors.discount,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashSaleCard extends StatelessWidget {
  final FlashSaleProduct product;
  final bool isDark;

  const _FlashSaleCard({required this.product, required this.isDark});

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = product.stock > 0 ? product.sold / product.stock : 0.0;

    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/products/${product.productId}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          width: double.infinity,
                          height: 130,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 130,
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 130,
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                          ),
                        )
                      : Container(
                          height: 130,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          child: const Center(child: Icon(Icons.image, color: Color(0xFF94A3B8))),
                        ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.discount,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-${product.discountPercent}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _formatPrice(product.salePrice),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.discount,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatPrice(product.originalPrice),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation(
                          progress > 0.8 ? AppColors.discount : AppColors.success,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Da ban ${product.sold}/${product.stock}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealsTab extends ConsumerStatefulWidget {
  final bool isDark;

  const _DealsTab({required this.isDark});

  @override
  ConsumerState<_DealsTab> createState() => _DealsTabState();
}

class _DealsTabState extends ConsumerState<_DealsTab> {
  int _page = 0;
  final List<DealProduct> _deals = [];
  bool _hasMore = true;
  bool _isLoading = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadDeals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadDeals();
    }
  }

  Future<void> _loadDeals() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final service = PromotionService();
      final newDeals = await service.getDeals(page: _page, size: 20);
      setState(() {
        _deals.addAll(newDeals);
        _hasMore = newDeals.length == 20;
        _page++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (_deals.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer, size: 64, color: widget.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'Dang tai...',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _deals.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _deals.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final deal = _deals[index];
        return Card(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => context.push('/products/${deal.productId}'),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: deal.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: deal.imageUrl!,
                              width: double.infinity,
                              height: 130,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                height: 130,
                                color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 130,
                                color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                              ),
                            )
                          : Container(
                              height: 130,
                              color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                            ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_offer, color: Colors.white, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              '-${deal.discountPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              _formatPrice(deal.dealPrice),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatPrice(deal.originalPrice),
                              style: TextStyle(
                                fontSize: 11,
                                color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            deal.dealType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

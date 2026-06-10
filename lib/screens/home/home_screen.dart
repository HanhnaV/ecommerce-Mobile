import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_service.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../../screens/products/widgets/product_quick_view.dart';

final _productService = ProductService();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ProductModel> _products = [];
  List<ProductModel> _recommendations = [];
  bool _loading = true;
  bool _recLoading = true;
  String? _error;
  int _bannerIndex = 0;

  final _bannerImages = [
    'https://images.unsplash.com/photo-1587523459887-e669248cf666?w=600&h=300&fit=crop',
    'https://images.unsplash.com/photo-1624258919367-5dc28f5dc293?w=600&h=300&fit=crop',
  ];
  final _bannerTitles = ['AirPods Pro: Giam den 40%', 'Mien phi giao hang don tu 500K'];
  final _bannerDescriptions = [
    'Flash sale AirPods Pro. So luong co han.',
    'Ap dung cho AirPods & tai nghe. Khong can ma.',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadRecommendations();
  }

  Future<void> _loadProducts() async {
    try {
      final page = await _productService.getProducts(
        page: 0,
        size: 20,
        sortBy: 'createdAt',
        sortDir: 'desc',
      );
      if (mounted) setState(() => _products = page.content);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final list = await _productService.getRecommendations(limit: 8);
      if (mounted) setState(() => _recommendations = list);
    } catch (e) {
      if (mounted) setState(() => _recommendations = []);
    } finally {
      if (mounted) setState(() => _recLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
      appBar: AppBar(
        title: const Text('AirPod Store'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final cartState = ref.watch(cartProvider);
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (cartState.totalItems > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cartState.totalItems > 99 ? '99+' : cartState.totalItems}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadProducts();
          await _loadRecommendations();
        },
        child: ListView(
          children: [
            _buildBanner(isDark),
            _buildProductsSection(isDark),
            _buildRecommendationsSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'Uu dai AirPods & Tai nghe',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1C1917),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Giam gia AirPods Pro, AirPods Max. So luong co han.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: _bannerImages.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => context.push('/products'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _bannerImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F4),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16, right: 16, bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _bannerTitles[index],
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _bannerDescriptions[index],
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                index == 0 ? 'Mua ngay' : 'Xem san pham',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerImages.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _bannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _bannerIndex == index ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProductsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'AirPods & Tai nghe Apple',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917)),
          ),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_error!, style: TextStyle(color: isDark ? Colors.red[300] : Colors.red[600])),
                TextButton(onPressed: _loadProducts, child: const Text('Thu lai')),
              ],
            ),
          )
        else if (_products.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Chua co san pham nao',
                style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final p = _products[index];
              return GestureDetector(
                onLongPress: () => ProductQuickView.show(context, p),
                child: ProductCard(
                  product: p,
                  onTap: () => context.push('/products/${p.id}'),
                ),
              );
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecommendationsSection(bool isDark) {
    if (_recLoading || _recommendations.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Go y cho ban',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final p = _recommendations[index];
              return SizedBox(
                width: 160,
                child: ProductCard(
                  product: p,
                  onTap: () => context.push('/products/${p.id}'),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../data/services/product_service.dart';
import '../../providers/cart_provider.dart';
import '../../screens/products/widgets/product_quick_view.dart';

final _productService = ProductService();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _loading = true;
  String? _error;
  int _navIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    final mockProducts = [
      const ProductModel(
        id: '1',
        name: 'AirPods Max',
        basePrice: 13500000,
        thumbnailUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/airpods-max-select-silver-202011?wid=500&hei=500&fmt=png-alpha',
      ),
      const ProductModel(
        id: '2',
        name: 'AirPods Pro 2',
        basePrice: 6200000,
        thumbnailUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MQD83?wid=500&hei=500&fmt=png-alpha',
      ),
      const ProductModel(
        id: '3',
        name: 'AirPods 4 ANC',
        basePrice: 4500000,
        thumbnailUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MXP63?wid=500&hei=500&fmt=png-alpha',
      ),
      const ProductModel(
        id: '4',
        name: 'AirPods 4',
        basePrice: 3500000,
        thumbnailUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MXP63?wid=500&hei=500&fmt=png-alpha',
      ),
      const ProductModel(
        id: '5',
        name: 'AirPods 3',
        basePrice: 4200000,
        thumbnailUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MME73?wid=500&hei=500&fmt=png-alpha',
      ),
      const ProductModel(
        id: '6',
        name: 'AirPods 2',
        basePrice: 2800000,
        thumbnailUrl: 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MV7N2?wid=500&hei=500&fmt=png-alpha',
      ),
    ];
    if (mounted) {
      setState(() {
        _products = mockProducts;
        _filteredProducts = mockProducts;
        _loading = false;
        _error = null;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF131313);
    const primaryBlue = Color(0xFF007AFF);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryBlue,
          backgroundColor: const Color(0xFF1C1C1E),
          onRefresh: _loadProducts,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(primaryBlue),
              SliverToBoxAdapter(child: _buildSearchBar(primaryBlue)),
              if (!_showSearch) ...[  
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(child: _buildHeroSection(primaryBlue)),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ] else
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildProductListHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildProductList(primaryBlue),
              if (!_showSearch) ...[  
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
                SliverToBoxAdapter(child: _buildFeatureSection(primaryBlue)),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: bgColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _navIndex,
          selectedItemColor: primaryBlue,
          unselectedItemColor: const Color(0xFF8E8E93),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          onTap: (idx) {
            if (idx == 1) {
              setState(() {
                _showSearch = true;
                _navIndex = 1;
                _searchController.clear();
                _filteredProducts = _products;
              });
            } else {
              setState(() => _navIndex = idx);
              if (idx == 2) context.push('/cart');
              if (idx == 3) context.push('/profile');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Giỏ hàng'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Color primaryBlue) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AirPod Store',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showSearch ? Icons.close : Icons.search,
                    color: _showSearch ? const Color(0xFF007AFF) : Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_showSearch) {
                        _showSearch = false;
                        _searchController.clear();
                        _filteredProducts = _products;
                        _navIndex = 0;
                      } else {
                        _showSearch = true;
                        _navIndex = 1;
                        _searchController.clear();
                        _filteredProducts = _products;
                      }
                    });
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final cartState = ref.watch(cartProvider);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
                          onPressed: () => context.push('/cart'),
                        ),
                        if (cartState.totalItems > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(Color primaryBlue) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _showSearch
          ? Padding(
              key: const ValueKey('search'),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryBlue.withOpacity(0.4)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm tai nghe AirPods...',
                          hintStyle: TextStyle(color: Color(0xFF636366), fontSize: 15),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF636366), size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: _onSearch,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSearch = false;
                        _searchController.clear();
                        _filteredProducts = _products;
                        _navIndex = 0;
                      });
                    },
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Color(0xFF007AFF), fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }

  Widget _buildHeroSection(Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1587523459887-e669248cf666?w=800&q=80'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.2),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Text(
                        'LIMITED TIME',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AirPods Pro\nGiảm đến 40%',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Mua ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sản phẩm nổi bật',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Text(
            'Xem tất cả',
            style: TextStyle(color: const Color(0xFF8E8E93), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(Color primaryBlue) {
    if (_loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF007AFF))),
        ),
      );
    }
    
    if (_error != null) {
      return SliverToBoxAdapter(
        child: Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
      );
    }

    if (_filteredProducts.isEmpty && _showSearch) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.search_off, color: Color(0xFF636366), size: 60),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy "${_searchController.text}"',
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final displayList = _showSearch ? _filteredProducts : _products;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.58,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final p = displayList[index];
            final isBestseller = !_showSearch && index == 0;
            return _buildLuxeProductCard(p, isBestseller, primaryBlue);
          },
          childCount: displayList.length,
        ),
      ),
    );
  }

  Widget _buildLuxeProductCard(ProductModel p, bool isBestseller, Color primaryBlue) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final String imageUrl = p.thumbnailUrl ?? (p.images.isNotEmpty ? p.images.first.imageUrl : 'https://images.unsplash.com/photo-1590658268037-6f1164d2bf5a?w=400');
    
    return GestureDetector(
      onTap: () => context.push('/products/${p.id}'),
      onLongPress: () => ProductQuickView.show(context, p),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.white54),
                      ),
                    ),
                  ),
                  if (isBestseller)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Bestseller', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white54, size: 20),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBestseller)
                        Text(
                          formatCurrency.format(p.basePrice * 1.4),
                          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12, decoration: TextDecoration.lineThrough),
                        ),
                      Text(
                        p.formattedPrice,
                        style: TextStyle(color: primaryBlue, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -20,
              child: Opacity(
                opacity: 0.5,
                child: Image.network(
                  'https://images.unsplash.com/photo-1613040809024-b4ef7ba99bc3?w=400&q=80',
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.spatial_audio_off, color: Colors.white, size: 32),
                  const SizedBox(height: 16),
                  const Text(
                    'Âm thanh Không gian',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trải nghiệm âm thanh vòm 360 độ.',
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Khám phá ngay'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

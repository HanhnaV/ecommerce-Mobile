import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/services/product_service.dart';
import '../../data/services/review_service.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_image_gallery.dart';
import '../../widgets/product_card.dart';

final _productService = ProductService();
final _reviewService = ReviewService();

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductModel? _product;
  bool _loading = true;
  String? _error;
  int _quantity = 1;
  bool _addingToCart = false;
  List<ProductModel> _similarProducts = [];
  bool _similarLoading = true;

  ReviewStats? _reviewStats;
  List<ReviewModel> _reviews = [];
  bool _reviewsLoading = true;
  int _reviewsPage = 0;
  int _reviewsTotalPages = 0;
  int? _filterRating;

  @override
  void initState() {
    super.initState();
    _loadProduct();
    _loadSimilarProducts();
    _loadReviews();
  }

  Future<void> _loadProduct() async {
    try {
      final p = await _productService.getProductById(widget.productId);
      if (mounted) setState(() => _product = p);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSimilarProducts() async {
    try {
      final list = await _productService.getSimilarProducts(widget.productId, limit: 8);
      if (mounted) setState(() => _similarProducts = list);
    } catch (e) {
      if (mounted) setState(() => _similarProducts = []);
    } finally {
      if (mounted) setState(() => _similarLoading = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final results = await Future.wait([
        _reviewService.getProductReviewStats(widget.productId),
        _reviewService.getProductReviews(
          widget.productId,
          page: _reviewsPage,
          size: 5,
          rating: _filterRating,
        ),
      ]);
      if (mounted) {
        setState(() {
          _reviewStats = results[0] as ReviewStats;
          final page = results[1] as ReviewPage;
          _reviews = page.content;
          _reviewsTotalPages = page.totalPages;
        });
      }
    } catch (e) {
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  void _setFilterRating(int? rating) {
    setState(() {
      _filterRating = rating;
      _reviewsPage = 0;
      _reviewsLoading = true;
    });
    _loadReviews();
  }

  void _changeReviewsPage(int delta) {
    final next = _reviewsPage + delta;
    if (next < 0 || next >= _reviewsTotalPages) return;
    setState(() {
      _reviewsPage = next;
      _reviewsLoading = true;
    });
    _loadReviews();
  }

  Future<void> _handleAddToCart() async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      Fluttertoast.showToast(msg: 'Vui long dang nhap de them san pham vao gio hang');
      return;
    }

    if (_product == null) return;

    setState(() => _addingToCart = true);
    try {
      final cartItem = CartItem(
        id: 0,
        productId: _product!.id,
        name: _product!.name,
        price: _product!.basePrice,
        quantity: _quantity,
        shopId: _product!.shopId ?? 0,
        shopName: _product!.shopName ?? '',
        imageUrl: _product!.thumbnailUrl,
      );
      ref.read(cartProvider.notifier).addItem(cartItem);
      Fluttertoast.showToast(
        msg: 'Da them $_quantity ${_product!.name} vao gio hang',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'San pham khong ton tai', style: TextStyle(color: isDark ? Colors.red[300] : Colors.red[600])),
              const SizedBox(height: 12),
              TextButton(onPressed: () => context.pop(), child: const Text('Quay lai')),
            ],
          ),
        ),
      );
    }

    final p = _product!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
      appBar: AppBar(
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImageGallery(images: p.images),
                const SizedBox(height: 16),
                if (p.categoryName != null)
                  Text(
                    p.categoryName!,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C)),
                  ),
                const SizedBox(height: 8),
                Text(
                  p.name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917)),
                ),
                const SizedBox(height: 12),
                Text(
                  p.formattedPrice,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 16),
                _buildFeatures(isDark),
                const SizedBox(height: 20),
                _buildQuantitySelector(isDark),
                const SizedBox(height: 20),
                _buildActionButtons(isDark),
                const SizedBox(height: 24),
                if (p.description != null && p.description!.isNotEmpty) _buildDescription(p, isDark),
                const SizedBox(height: 16),
                _buildProductInfo(p, isDark),
                const SizedBox(height: 24),
                _buildReviewsSection(isDark),
                const SizedBox(height: 24),
                _buildSimilarProducts(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(bool isDark) {
    final features = [
      ('Chinh hang 100%', Icons.verified, isDark ? const Color(0xFF34D399) : const Color(0xFF059669)),
      ('Mien phi van chuyen', Icons.local_shipping_outlined, isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
      ('Bao hanh chinh hang', Icons.shield_outlined, isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
      ('Doi tra 7 ngay', Icons.autorenew, isDark ? const Color(0xFF34D399) : const Color(0xFF059669)),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: features.map((f) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(f.$2, size: 16, color: f.$3),
            const SizedBox(width: 4),
            Text(f.$1, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C))),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector(bool isDark) {
    return Row(
      children: [
        Text('So luong:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C))),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
          ),
          child: Row(
            children: [
              _qtyButton(Icons.remove, () { if (_quantity > 1) setState(() => _quantity--); }, isDark),
              Container(
                width: 48,
                alignment: Alignment.center,
                child: Text('$_quantity', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917))),
              ),
              _qtyButton(Icons.add, () => setState(() { if (_quantity < 99) _quantity++; }), isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onPressed, bool isDark) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: isDark ? Colors.white : const Color(0xFF1C1917)),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _addingToCart ? null : _handleAddToCart,
            icon: _addingToCart
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Icon(Icons.shopping_cart_outlined),
            label: Text(_addingToCart ? 'Dang them...' : 'Them vao gio hang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final authState = ref.read(authStateProvider);
              if (!authState.isAuthenticated) {
                Fluttertoast.showToast(msg: 'Vui long dang nhap de mua hang');
                return;
              }
              if (_product == null) return;
              final cartItem = CartItem(
                id: 0,
                productId: _product!.id,
                name: _product!.name,
                price: _product!.basePrice,
                quantity: _quantity,
                shopId: _product!.shopId ?? 0,
                shopName: _product!.shopName ?? '',
                imageUrl: _product!.thumbnailUrl,
              );
              ref.read(cartProvider.notifier).addItem(cartItem);
              if (_product!.shopId != null) {
                context.push('/checkout', extra: {'shopId': _product!.shopId});
              } else {
                context.push('/cart');
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF2563EB)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Mua ngay'),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ProductModel p, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mo ta san pham', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917))),
          const SizedBox(height: 12),
          Text(p.description!, style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C))),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ProductModel p, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thong tin san pham', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917))),
          const SizedBox(height: 12),
          if (p.sku != null) _infoRow('Ma san pham', p.sku!, isDark),
          if (p.categoryName != null) _infoRow('Danh muc', p.categoryName!, isDark),
          if (p.shopName != null) _infoRow('Cua hang', p.shopName!, isDark, isLink: true),
          _infoRow('Trang thai', p.status == 'PUBLISHED' ? 'Dang ban' : p.status, isDark),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E))),
          if (isLink)
            Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB)))
          else
            Text(value, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1C1917))),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Danh gia san pham', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
          ),
          child: _reviewsLoading && _reviewStats == null
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2)))
              : _reviewStats == null
                  ? Center(child: Text('Chua co danh gia nao', style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E))))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(_reviewStats!.avgRating.toStringAsFixed(1), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (i) => Icon(Icons.star, size: 16, color: i < _reviewStats!.avgRating.round() ? const Color(0xFFFBBF24) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)))),
                            ),
                            const SizedBox(height: 4),
                            Text('${_reviewStats!.totalReviews} danh gia', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E))),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              for (int star in [5, 4, 3, 2, 1])
                                _ratingBar(star, _reviewStats!.getStarCount(star), _reviewStats!.totalReviews, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChip(null, 'Tat ca', isDark),
            for (int star in [5, 4, 3, 2, 1]) _filterChip(star, '$star sao', isDark),
          ],
        ),
        const SizedBox(height: 16),
        if (_reviewsLoading && _reviews.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2)))
        else if (_reviews.isEmpty)
          Center(child: Text('Chua co danh gia nao cho bo loc nay', style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E))))
        else
          ..._reviews.map((r) => _reviewItem(r, isDark)),
        if (_reviewsTotalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _reviewsPage > 0 ? () => _changeReviewsPage(-1) : null,
                  icon: Icon(Icons.chevron_left, color: _reviewsPage > 0 ? (isDark ? Colors.white : const Color(0xFF1C1917)) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4))),
                ),
                Text('Trang ${_reviewsPage + 1} / $_reviewsTotalPages', style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1C1917))),
                IconButton(
                  onPressed: _reviewsPage < _reviewsTotalPages - 1 ? () => _changeReviewsPage(1) : null,
                  icon: Icon(Icons.chevron_right, color: _reviewsPage < _reviewsTotalPages - 1 ? (isDark ? Colors.white : const Color(0xFF1C1917)) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4))),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _ratingBar(int star, int count, int total, bool isDark) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$star', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C))),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: const Color(0xFFFBBF24)),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('$count', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E))),
        ],
      ),
    );
  }

  Widget _filterChip(int? rating, String label, bool isDark) {
    final selected = _filterRating == rating;
    return GestureDetector(
      onTap: () => _setFilterRating(rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4))),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C)))),
      ),
    );
  }

  Widget _reviewItem(ReviewModel r, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  (r.userFullName ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.userFullName ?? 'Nguoi dung', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1C1917))),
                    if (r.createdAt != null)
                      Text(
                        '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
                      ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < r.rating ? const Color(0xFFFBBF24) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)))),
              ),
            ],
          ),
          if (r.comment != null && r.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(r.comment!, style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C))),
          ],
          if (r.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: r.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(r.imageUrls[idx], width: 60, height: 60, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
          if (r.sellerReply != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store, size: 14, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text('Cua hang phan hoi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(r.sellerReply!.reply, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimilarProducts(bool isDark) {
    if (_similarLoading || _similarProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('San pham tuong tu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917))),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _similarProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final p = _similarProducts[index];
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
      ],
    );
  }
}

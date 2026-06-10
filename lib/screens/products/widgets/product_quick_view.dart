import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';

class ProductQuickView extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductQuickView({super.key, required this.product});

  static Future<void> show(BuildContext context, ProductModel product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductQuickView(product: product),
    );
  }

  @override
  ConsumerState<ProductQuickView> createState() => _ProductQuickViewState();
}

class _ProductQuickViewState extends ConsumerState<ProductQuickView> {
  int _quantity = 1;
  bool _addingToCart = false;

  Future<void> _handleAddToCart() async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Vui long dang nhap de them san pham vao gio hang');
      return;
    }

    setState(() => _addingToCart = true);
    try {
      final cartItem = CartItem(
        id: 0,
        productId: widget.product.id,
        name: widget.product.name,
        price: widget.product.basePrice,
        quantity: _quantity,
        shopId: widget.product.shopId ?? 0,
        shopName: widget.product.shopName ?? '',
        imageUrl: widget.product.thumbnailUrl,
      );
      ref.read(cartProvider.notifier).addItem(cartItem);
      if (mounted) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Da them $_quantity san pham vao gio hang',
          backgroundColor: AppColors.success,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _addingToCart = false);
        Fluttertoast.showToast(
          msg: e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;
    final p = widget.product;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: p.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: p.thumbnailUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 100,
                          height: 100,
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                          child: Icon(
                            Icons.headphones,
                            size: 32,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                          ),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                        child: Icon(
                          Icons.headphones,
                          size: 32,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1917),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.formattedPrice,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    if (p.categoryName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        p.categoryName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'So luong:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () { if (_quantity > 1) setState(() => _quantity--); },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: isDark ? Colors.white : const Color(0xFF1C1917),
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1C1917),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _quantity++),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: isDark ? Colors.white : const Color(0xFF1C1917),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addingToCart ? null : _handleAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.6),
              ),
              child: _addingToCart
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Them vao gio hang',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

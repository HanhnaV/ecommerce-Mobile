import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/product_model.dart';

class ProductImageGallery extends StatefulWidget {
  final List<ProductImage> images;

  const ProductImageGallery({super.key, required this.images});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _selectedIndex = 0;

  bool get _hasImages => widget.images.isNotEmpty;
  String get _currentImage =>
      _hasImages ? widget.images[_selectedIndex].imageUrl : '';

  void _goToPrevious() {
    if (!_hasImages) return;
    setState(() {
      _selectedIndex =
          _selectedIndex == 0 ? widget.images.length - 1 : _selectedIndex - 1;
    });
  }

  void _goToNext() {
    if (!_hasImages) return;
    setState(() {
      _selectedIndex = _selectedIndex == widget.images.length - 1
          ? 0
          : _selectedIndex + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_hasImages) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                ),
                const SizedBox(height: 8),
                Text(
                  'Khong co hinh anh',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: CachedNetworkImage(
                  key: ValueKey(_selectedIndex),
                  imageUrl: _currentImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                    ),
                  ),
                ),
              ),
              if (widget.images.length > 1) ...[
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _goToPrevious,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black45 : Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: isDark ? Colors.white : const Color(0xFF1C1917),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _goToNext,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black45 : Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.white : const Color(0xFF1C1917),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black45 : Colors.white70,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedIndex + 1} / ${widget.images.length}',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1C1917),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index].imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 24,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

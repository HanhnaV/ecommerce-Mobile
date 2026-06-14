import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';

class ProductFilterModal extends StatefulWidget {
  final String? selectedCategoryId;
  final int? minPrice;
  final int? maxPrice;
  final List<CategoryModel> categories;
  final Function(String? categoryId, int? minPrice, int? maxPrice) onApply;

  const ProductFilterModal({
    super.key,
    this.selectedCategoryId,
    this.minPrice,
    this.maxPrice,
    required this.categories,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    String? selectedCategoryId,
    int? minPrice,
    int? maxPrice,
    required List<CategoryModel> categories,
    required Function(String? categoryId, int? minPrice, int? maxPrice) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFilterModal(
        selectedCategoryId: selectedCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        categories: categories,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ProductFilterModal> createState() => _ProductFilterModalState();
}

class _ProductFilterModalState extends State<ProductFilterModal> {
  static const _priceRanges = [
    _PriceRangeOption(label: 'Tat ca', min: null, max: null),
    _PriceRangeOption(label: 'Duoi 1 trieu', min: 0, max: 1000000),
    _PriceRangeOption(label: '1 - 3 trieu', min: 1000000, max: 3000000),
    _PriceRangeOption(label: '3 - 5 trieu', min: 3000000, max: 5000000),
    _PriceRangeOption(label: '5 - 10 trieu', min: 5000000, max: 10000000),
    _PriceRangeOption(label: 'Tren 10 trieu', min: 10000000, max: null),
  ];

  late String? _selectedCategoryId;
  late _PriceRangeOption _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _selectedRange = _priceRanges.firstWhere(
      (r) => r.min == widget.minPrice && r.max == widget.maxPrice,
      orElse: () => _priceRanges.first,
    );
  }

  String _formatPrice(int? price) {
    if (price == null) return '';
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loc san pham',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1917),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Danh muc',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1C1917),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _categoryChip(null, 'Tat ca', isDark),
                    ...widget.categories.map((c) => _categoryChip(c.id, c.name, isDark)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Khoang gia',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1C1917),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _priceRanges.map((r) => _priceChip(r, isDark)).toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onApply(null, null, null);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Xoa loc',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C1917),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onApply(_selectedCategoryId, _selectedRange.min, _selectedRange.max);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ap dung'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String? id, String label, bool isDark) {
    final selected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C)),
          ),
        ),
      ),
    );
  }

  Widget _priceChip(_PriceRangeOption r, bool isDark) {
    final selected = _selectedRange == r;
    return GestureDetector(
      onTap: () => setState(() => _selectedRange = r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
          ),
        ),
        child: Text(
          r.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C)),
          ),
        ),
      ),
    );
  }
}

class _PriceRangeOption {
  final String label;
  final int? min;
  final int? max;
  const _PriceRangeOption({required this.label, this.min, this.max});
}

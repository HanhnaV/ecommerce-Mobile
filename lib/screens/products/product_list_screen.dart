import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/product_service.dart';
import '../../data/services/category_service.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/product_card.dart';
import 'widgets/product_filter_modal.dart';
import 'widgets/product_quick_view.dart';

final _productService = ProductService();
final _categoryService = CategoryService();

const _sortOptions = [
  _SortOption(label: 'Moi nhat', sortBy: 'createdAt', sortDir: 'desc'),
  _SortOption(label: 'Cu nhat', sortBy: 'createdAt', sortDir: 'asc'),
  _SortOption(label: 'Gia thap', sortBy: 'basePrice', sortDir: 'asc'),
  _SortOption(label: 'Gia cao', sortBy: 'basePrice', sortDir: 'desc'),
];

class _SortOption {
  final String label;
  final String sortBy;
  final String sortDir;
  const _SortOption({required this.label, required this.sortBy, required this.sortDir});
}

class ProductListScreen extends ConsumerStatefulWidget {
  final String? initialSearch;
  final String? initialCategoryId;

  const ProductListScreen({
    super.key,
    this.initialSearch,
    this.initialCategoryId,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _loading = true;
  bool _catLoading = true;
  String? _error;
  int _totalPages = 0;
  int _totalElements = 0;
  int _currentPage = 0;

  String? _selectedCategoryId;
  int? _minPrice;
  int? _maxPrice;
  _SortOption _selectedSort = _sortOptions[0];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
    }
    _selectedCategoryId = widget.initialCategoryId;
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _categoryService.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _catLoading = false);
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _loading = true);
      final page = await _productService.getProducts(
        page: _currentPage,
        size: 20,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        categoryId: _selectedCategoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortBy: _selectedSort.sortBy,
        sortDir: _selectedSort.sortDir,
      );
      if (mounted) {
        setState(() {
          _products = page.content;
          _totalPages = page.totalPages;
          _totalElements = page.totalElements;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String value) {
    setState(() => _currentPage = 0);
    _loadProducts();
  }

  void _onSortChanged(_SortOption option) {
    setState(() => _selectedSort = option);
    setState(() => _currentPage = 0);
    _loadProducts();
  }

  void _onFilterApplied(String? categoryId, int? minPrice, int? maxPrice) {
    setState(() {
      _selectedCategoryId = categoryId;
      _minPrice = minPrice;
      _maxPrice = maxPrice;
      _currentPage = 0;
    });
    _loadProducts();
  }

  void _showFilterModal() {
    ProductFilterModal.show(
      context: context,
      selectedCategoryId: _selectedCategoryId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      categories: _categories,
      onApply: _onFilterApplied,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = widget.initialCategoryId;
      _minPrice = null;
      _maxPrice = null;
      _selectedSort = _sortOptions[0];
      _searchController.clear();
      _currentPage = 0;
    });
    _loadProducts();
  }

  bool get _hasFilters =>
      _selectedCategoryId != widget.initialCategoryId ||
      _minPrice != null ||
      _maxPrice != null ||
      _searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
      appBar: AppBar(
        title: const Text('Tat ca san pham'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildFilterBar(isDark),
          Expanded(child: _buildBody(isDark)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1917)),
              decoration: InputDecoration(
                hintText: 'Tim kiem san pham...',
                hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
                prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showFilterModal,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hasFilters ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F4)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
              ),
              child: Icon(
                Icons.tune,
                size: 20,
                color: _hasFilters ? Colors.white : (isDark ? const Color(0xFF64748B) : const Color(0xFF78716C)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(
            _totalElements > 0 ? 'Tim thay $_totalElements san pham' : 'Khong co san pham nao',
            style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C)),
          ),
          const Spacer(),
          PopupMenuButton<_SortOption>(
            initialValue: _selectedSort,
            onSelected: _onSortChanged,
            itemBuilder: (context) => _sortOptions.map((opt) {
              return PopupMenuItem<_SortOption>(
                value: opt,
                child: Row(
                  children: [
                    if (_selectedSort.label == opt.label)
                      const Icon(Icons.check, size: 16, color: Color(0xFF2563EB))
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(opt.label),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedSort.label,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1C1917)),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 16, color: isDark ? Colors.white : const Color(0xFF1C1917)),
                ],
              ),
            ),
          ),
        ],
      ),
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
            TextButton(onPressed: _loadProducts, child: const Text('Thu lai')),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
            const SizedBox(height: 16),
            Text(
              'Khong tim thay san pham nao',
              style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C)),
            ),
            if (_hasFilters) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: _clearFilters, child: const Text('Xoa bo loc')),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
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
        ),
        if (_totalPages > 1) _buildPagination(isDark),
      ],
    );
  }

  Widget _buildPagination(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0
                ? () {
                    setState(() => _currentPage--);
                    _loadProducts();
                  }
                : null,
            icon: Icon(Icons.chevron_left, color: _currentPage > 0 ? (isDark ? Colors.white : const Color(0xFF1C1917)) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Trang ${_currentPage + 1} / $_totalPages',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1C1917)),
            ),
          ),
          IconButton(
            onPressed: _currentPage < _totalPages - 1
                ? () {
                    setState(() => _currentPage++);
                    _loadProducts();
                  }
                : null,
            icon: Icon(Icons.chevron_right, color: _currentPage < _totalPages - 1 ? (isDark ? Colors.white : const Color(0xFF1C1917)) : (isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4))),
          ),
        ],
      ),
    );
  }
}

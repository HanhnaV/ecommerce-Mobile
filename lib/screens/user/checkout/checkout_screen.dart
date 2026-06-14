import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/services/cart_service.dart';
import '../../../data/services/order_service.dart';
import '../../../data/services/user_address_service.dart';
import '../../../data/services/shipping_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/cart_provider.dart';

final _cartService = CartService();
final _orderService = OrderService();
final _addressService = UserAddressService();
final _shippingService = ShippingService();

const _FROM_DISTRICT_ID = "1442";
const _FROM_WARD_CODE = '20101';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String shopId;

  const CheckoutScreen({super.key, required this.shopId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _loading = true;
  String? _error;
  List<CartApiItem> _cartItems = [];
  String _shopName = '';
  double _totalPrice = 0;
  double _shippingFee = 0;
  bool _calculatingFee = false;
  bool _shippingFeeFailed = false;

  List<UserAddress> _addresses = [];
  String? _selectedAddressId;
  final _notesController = TextEditingController();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);

      final cartData = await _cartService.getCart();
      final shopItems = cartData.items.where((i) => i.shopId == widget.shopId).toList();

      if (shopItems.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Khong co san pham nao tu Shop nay trong gio hang')),
          );
          context.go('/cart');
        }
        return;
      }

      final addresses = await _addressService.listMyAddresses();

      if (mounted) {
        setState(() {
          _cartItems = shopItems;
          _shopName = shopItems.first.shopName;
          _totalPrice = shopItems.fold(0.0, (sum, i) => sum + i.totalPrice);
          _addresses = addresses;

          final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
          if (defaultAddr != null) _selectedAddressId = (defaultAddr.id).toString();
        });

        if (_selectedAddressId != null) {
          _calculateShippingFee();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _calculateShippingFee() async {
    final selectedAddr = _addresses.where((a) => a.id == _selectedAddressId).firstOrNull;
    if (selectedAddr == null || selectedAddr.districtId == null || selectedAddr.wardCode == null) return;

    setState(() => _calculatingFee = true);
    try {
      final totalWeight = _cartItems.fold(0, (sum, item) => sum + (item.quantity * 500));
      final insurance = _totalPrice > 5000000 ? 5000000 : _totalPrice.toInt();

      final fee = await _shippingService.calculateFee(
        fromDistrictId: _FROM_DISTRICT_ID,
        fromWardCode: _FROM_WARD_CODE,
        toDistrictId: selectedAddr.districtId!,
        toWardCode: selectedAddr.wardCode!,
        weight: totalWeight,
        serviceTypeId: 2,
        insuranceValue: insurance,
      );
      if (mounted) setState(() => _shippingFee = fee.total);
    } catch (e) {
      if (mounted) setState(() {
        _shippingFee = 0;
        _shippingFeeFailed = true;
      });
    } finally {
      if (mounted) setState(() => _calculatingFee = false);
    }
  }

  Future<void> _handleCreateOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long chon dia chi giao hang')),
      );
      return;
    }

    if (_calculatingFee) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dang tinh phi van chuyen, vui long cho...')),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      final order = await _orderService.createOrder(
        shopId: widget.shopId,
        addressId: _selectedAddressId!,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final paymentRes = await _orderService.createVnpayPayment(order.id);

      if (mounted) {
        ref.read(cartProvider.notifier).clear();

        if (paymentRes.paymentUrl.isNotEmpty) {
          context.push('/checkout/vnpay', extra: {
            'paymentUrl': paymentRes.paymentUrl,
            'orderId': order.id,
          });
        } else {
          context.go('/orders');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1C1917)),
          onPressed: () => context.go('/cart'),
        ),
        title: Text('Thanh toan', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1917))),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    final finalTotal = _totalPrice + _shippingFee;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Thanh toan ($_shopName)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1C1917),
                ),
              ),
              const SizedBox(height: 16),

              _buildAddressSection(isDark),
              const SizedBox(height: 16),

              _buildItemsSection(isDark),
              const SizedBox(height: 16),

              _buildNotesSection(isDark),
            ],
          ),
        ),

        _buildBottomBar(finalTotal, isDark),
      ],
    );
  }

  Widget _buildAddressSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  'Dia chi nhan hang',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1C1917),
                  ),
                ),
              ],
            ),
          ),
          if (_addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Ban chua co dia chi nao.',
                style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
              ),
            )
          else
            ...List.generate(_addresses.length, (i) {
              final addr = _addresses[i];
              final isSelected = _selectedAddressId == addr.id;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedAddressId = addr.id);
                  _calculateShippingFee();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: i > 0 ? BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)) : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: addr.id!,
                        groupValue: _selectedAddressId,
                        onChanged: (v) {
                          setState(() => _selectedAddressId = v);
                          _calculateShippingFee();
                        },
                        activeColor: const Color(0xFF2563EB),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  addr.receiverName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1C1917),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  addr.receiverPhone,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                                  ),
                                ),
                                if (addr.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Mac dinh',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${addr.addressLine}, ${addr.ward}, ${addr.district}, ${addr.city}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildItemsSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag, size: 18, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  'San pham',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1C1917),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_cartItems.length, (i) {
            final item = _cartItems[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: i > 0 ? BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)) : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: item.productImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: item.productImageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                                child: const Icon(Icons.headphones, size: 24),
                              ),
                            )
                          : Container(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F4),
                              child: const Icon(Icons.headphones, size: 24),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : const Color(0xFF1C1917),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'x${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatPrice(item.totalPrice),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C1917),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ghi chu don hang',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1C1917),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1917)),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Luu y cho nguoi ban...',
              hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E)),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double finalTotal, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tong tien hang', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C))),
                Text(_formatPrice(_totalPrice), style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1C1917))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Phi van chuyen', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C))),
                _calculatingFee
                    ? const Text('Dang tinh...', style: TextStyle(fontSize: 13, color: Color(0xFF2563EB)))
                    : Text(
                        _shippingFeeFailed ? '---' : (_shippingFee > 0 ? _formatPrice(_shippingFee) : '---'),
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1C1917)),
                      ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tong thanh toan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1C1917))),
                Text(_formatPrice(finalTotal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing || _calculatingFee || _selectedAddressId == null ? null : _handleCreateOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: const Color(0xFF64748B),
                ),
                child: _processing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                      )
                    : const Text('Dat hang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VND';
  }
}

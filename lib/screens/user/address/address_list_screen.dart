import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/user_address_service.dart';
import '../../../providers/theme_provider.dart';

final _addressService = UserAddressService();

class AddressListScreen extends ConsumerStatefulWidget {
  const AddressListScreen({super.key});

  @override
  ConsumerState<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends ConsumerState<AddressListScreen> {
  List<UserAddress> _addresses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _addressService.listMyAddresses();
      if (mounted) setState(() => _addresses = list);
    } catch (e) {
      if (mounted)
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setDefault(UserAddress addr) async {
    if (addr.id == null) return;
    try {
      await _addressService.setDefaultAddress(addr.id!);
      await _loadAddresses();
      if (mounted) Fluttertoast.showToast(msg: 'Da dat dia chi mac dinh');
    } catch (e) {
      if (mounted)
        Fluttertoast.showToast(
            msg: e.toString().replaceFirst('Exception: ', ''),
            backgroundColor: AppColors.error);
    }
  }

  Future<void> _deleteAddress(UserAddress addr) async {
    if (addr.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa dia chi'),
        content: const Text('Ban co chan muon xoa dia chi nay?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _addressService.deleteAddress(addr.id!);
      await _loadAddresses();
      if (mounted) Fluttertoast.showToast(msg: 'Xoa dia chi thanh cong');
    } catch (e) {
      if (mounted)
        Fluttertoast.showToast(
            msg: e.toString().replaceFirst('Exception: ', ''),
            backgroundColor: AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dia chi giao hang'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAddresses,
        child: _buildBody(isDark),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/addresses/add');

          if (result == true) {
            await _loadAddresses();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Them dia chi'),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loadAddresses, child: const Text('Thu lai')),
          ],
        ),
      );
    }
    if (_addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off,
                size: 64,
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            Text('Chua co dia chi nao',
                style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B))),
            const SizedBox(height: 8),
            Text('Them dia chi de nhan hang',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8))),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final addr = _addresses[index];
        return _AddressCard(
          address: addr,
          isDark: isDark,
          onEdit: () async {
            final result = await context.push(
              '/addresses/edit',
              extra: addr,
            );

            print('EDIT RESULT: $result');

            if (result == true) {
              await _loadAddresses();
            }
          },
          onDelete: () => _deleteAddress(addr),
          onSetDefault: () => _setDefault(addr),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  final UserAddress address;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  String get _fullAddress {
    final parts = <String>[
      address.addressLine,
      address.ward,
      address.district,
      address.city
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person,
                      size: 18,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.receiverName,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text('Mac dinh',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Text(address.receiverPhone,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_fullAddress,
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!address.isDefault)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSetDefault,
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Dat mac dinh',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ),
                  if (!address.isDefault) const SizedBox(width: 8),
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B)),
                    tooltip: 'Chinh sua',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    tooltip: 'Xoa',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

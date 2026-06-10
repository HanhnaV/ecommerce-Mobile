import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/user_address_service.dart';
import '../../../data/services/shipping_service.dart';
import '../../../providers/theme_provider.dart';

final _addressService = UserAddressService();
final _shippingService = ShippingService();

class AddressFormScreen extends ConsumerStatefulWidget {
  final UserAddress? address;

  const AddressFormScreen({super.key, this.address});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLineController;

  Province? _selectedProvince;
  District? _selectedDistrict;
  Ward? _selectedWard;

  List<Province> _provinces = [];
  List<District> _districts = [];
  List<Ward> _wards = [];

  bool _loadingProvinces = false;
  bool _loadingDistricts = false;
  bool _loadingWards = false;
  bool _saving = false;
  bool _isDefault = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameController = TextEditingController(text: addr?.receiverName ?? '');
    _phoneController = TextEditingController(text: addr?.receiverPhone ?? '');
    _addressLineController = TextEditingController(text: addr?.addressLine ?? '');
    _isDefault = addr?.isDefault ?? false;
    _loadProvinces();
    if (addr != null) {
      _initExistingAddress(addr);
    }
  }

  Future<void> _initExistingAddress(UserAddress addr) async {
    try {
      final provinces = await _shippingService.getProvinces();
      final province = provinces.firstWhere(
        (p) => p.name.toLowerCase() == addr.city.toLowerCase(),
        orElse: () => const Province(id: 0, name: ''),
      );
      if (province.id != 0 && mounted) {
        setState(() => _selectedProvince = province);
        await _loadDistricts(province.id);

        final district = _districts.firstWhere(
          (d) => d.name.toLowerCase() == addr.district.toLowerCase(),
          orElse: () => const District(id: 0, name: '', provinceId: 0),
        );
        if (district.id != 0 && mounted) {
          setState(() => _selectedDistrict = district);
          await _loadWards(district.id);

          final ward = _wards.firstWhere(
            (w) => w.name.toLowerCase() == addr.ward.toLowerCase(),
            orElse: () => const Ward(code: '', name: '', districtId: 0),
          );
          if (mounted) setState(() => _selectedWard = ward);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    setState(() => _loadingProvinces = true);
    try {
      final list = await _shippingService.getProvinces();
      if (mounted) setState(() => _provinces = list);
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: 'Khong the tai danh sach tinh/thanh', backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _loadingProvinces = false);
    }
  }

  Future<void> _loadDistricts(int provinceId) async {
    setState(() {
      _loadingDistricts = true;
      _selectedDistrict = null;
      _selectedWard = null;
      _wards = [];
    });
    try {
      final list = await _shippingService.getDistricts(provinceId);
      if (mounted) setState(() => _districts = list);
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: 'Khong the tai danh sach quan/huyen', backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _loadingDistricts = false);
    }
  }

  Future<void> _loadWards(int districtId) async {
    setState(() {
      _loadingWards = true;
      _selectedWard = null;
    });
    try {
      final list = await _shippingService.getWards(districtId);
      if (mounted) setState(() => _wards = list);
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: 'Khong the tai danh sach phuong/xa', backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _loadingWards = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProvince == null || _selectedDistrict == null || _selectedWard == null) {
      Fluttertoast.showToast(msg: 'Vui long chon day du tinh/quan/phuong', backgroundColor: AppColors.error);
      return;
    }

    setState(() => _saving = true);
    try {
      final addr = UserAddress(
        id: widget.address?.id,
        receiverName: _nameController.text.trim(),
        receiverPhone: _phoneController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        city: _selectedProvince!.name,
        district: _selectedDistrict!.name,
        ward: _selectedWard!.name,
        districtId: _selectedDistrict!.id,
        wardCode: _selectedWard!.code,
        isDefault: _isDefault,
      );

      if (_isEditing) {
        await _addressService.updateAddress(widget.address!.id!, addr);
        if (_isDefault) {
          await _addressService.setDefaultAddress(widget.address!.id!);
        }
      } else {
        await _addressService.createAddress(addr);
        final created = await _addressService.listMyAddresses();
        final latest = created.firstWhere(
          (a) => a.receiverName == addr.receiverName && a.receiverPhone == addr.receiverPhone,
          orElse: () => addr,
        );
        if (_isDefault && latest.id != null) {
          await _addressService.setDefaultAddress(latest.id!);
        }
      }

      if (mounted) {
        Fluttertoast.showToast(msg: _isEditing ? 'Cap nhat dia chi thanh cong!' : 'Them dia chi thanh cong!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: e.toString().replaceFirst('Exception: ', ''), backgroundColor: AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isEditing ? 'Chinh sua dia chi' : 'Them dia chi moi'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Thong tin nguoi nhan', isDark),
            const SizedBox(height: 12),
            _textField(_nameController, 'Ho va ten nguoi nhan', Icons.person, isDark,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Khong duoc de trong' : null),
            const SizedBox(height: 12),
            _textField(_phoneController, 'So dien thoai', Icons.phone, isDark, keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Khong duoc de trong';
                final phoneRegex = RegExp(r'^(?:\+84|0)(3|5|7|8|9)\d{8}$');
                if (!phoneRegex.hasMatch(v.trim())) return 'So dien thoai khong hop le';
                return null;
              }),
            const SizedBox(height: 24),
            _buildSectionTitle('Dia chi giao hang', isDark),
            const SizedBox(height: 12),
            _textField(_addressLineController, 'Dia chi cu the (so nha, duong)', Icons.home, isDark,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Khong duoc de trong' : null),
            const SizedBox(height: 12),
            _dropdownField<Province>(
              label: 'Tinh / Thanh pho',
              icon: Icons.location_city,
              value: _selectedProvince,
              items: _provinces,
              itemLabel: (p) => p.name,
              onChanged: (p) {
                setState(() {
                  _selectedProvince = p;
                  _districts = [];
                  _wards = [];
                  _selectedDistrict = null;
                  _selectedWard = null;
                });
                if (p != null) _loadDistricts(p.id);
              },
              isLoading: _loadingProvinces,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _dropdownField<District>(
              label: 'Quan / Huyen',
              icon: Icons.location_on,
              value: _selectedDistrict,
              items: _districts,
              itemLabel: (d) => d.name,
              onChanged: (d) {
                setState(() {
                  _selectedDistrict = d;
                  _wards = [];
                  _selectedWard = null;
                });
                if (d != null) _loadWards(d.id);
              },
              isLoading: _loadingDistricts,
              enabled: _selectedProvince != null,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _dropdownField<Ward>(
              label: 'Phuong / Xa',
              icon: Icons.map,
              value: _selectedWard,
              items: _wards,
              itemLabel: (w) => w.name,
              onChanged: (w) => setState(() => _selectedWard = w),
              isLoading: _loadingWards,
              enabled: _selectedDistrict != null,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text('Dat lam dia chi mac dinh', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Luu thay doi' : 'Them dia chi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isDark, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    required bool isLoading,
    required bool isDark,
    bool enabled = true,
  }) {
    if (!enabled) {
      items = [];
      value = null;
    }

    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        suffixIcon: isLoading
            ? const SizedBox(width: 20, height: 20, child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
            : null,
      ),
      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(itemLabel(item), style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black,
        )),
      )).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (v) => v == null ? 'Vui long chon $label' : null,
    );
  }
}

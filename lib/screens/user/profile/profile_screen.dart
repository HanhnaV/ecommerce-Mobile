import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  DateTime? _selectedDate;
  String? _avatarPath;
  XFile? _avatarFile;
  bool _isEditing = false;
  bool _isSaving = false;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController =
        TextEditingController(text: user?.phoneNumber ?? user?.phone ?? '');
    _selectedGender = user?.gender;
    _selectedDate = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chup anh'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chon tu thu vien'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _avatarPath = image.path;
        _avatarFile = image;
        _avatarBytes = bytes;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(profileUpdateProvider.notifier);
      final updatedUser = await notifier.updateProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDate != null
            ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
            : null,
        avatarPath: _avatarPath,
      );

      ref.read(authStateProvider.notifier).updateUser(updatedUser);
      if (mounted) {
        Fluttertoast.showToast(msg: 'Cap nhat ho so thanh cong!');
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
            msg: e.toString().replaceFirst('Exception: ', ''),
            backgroundColor: AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dang xuat'),
        content: const Text('Ban co chan muon dang xuat?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dang xuat',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;
    final user = authState.user;

    final avatarUrl = _avatarPath != null
        ? File(_avatarPath!).uri.toFilePath()
        : user?.avatarUrl;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ho so'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            TextButton(
              onPressed: () {
                setState(() => _isEditing = false);
                _nameController.text = user?.fullName ?? '';
                _phoneController.text = user?.phoneNumber ?? user?.phone ?? '';
                _selectedGender = user?.gender;
                _selectedDate = user?.dateOfBirth;
                _avatarPath = null;
              },
              child: const Text('Huy'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(isDark, avatarUrl),
            const SizedBox(height: 24),
            _buildInfoCard(isDark, user),
            const SizedBox(height: 16),
            _buildActionsCard(isDark, user),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, String? avatarUrl) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _isEditing ? _pickAvatar : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                backgroundImage: _avatarFile != null
                    ? MemoryImage(_avatarBytes!) as ImageProvider
                    : (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl) as ImageProvider
                        : null,
                child: _avatarFile == null && (avatarUrl == null || avatarUrl.isEmpty)
                    ? Icon(Icons.person,
                        size: 50,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF94A3B8))
                    : null,
              ),
            ),
            if (_isEditing)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isEditing) ...[
          SizedBox(
            width: 200,
            child: TextFormField(
              controller: _nameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Ho va ten',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Khong duoc de trong'
                  : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(bool isDark, UserModel? user) {
    if (_isEditing) {
      return Card(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'So dien thoai',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gioi tinh',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Nam')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Nu')),
                  ],
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Ngay sinh',
                      prefixIcon: const Icon(Icons.cake),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Chon ngay sinh',
                      style: TextStyle(
                          color: _selectedDate != null
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B))),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Luu thay doi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoRow(Icons.person, 'Ho va ten', user?.fullName ?? '-', isDark),
            _divider(isDark),
            _infoRow(Icons.email, 'Email', user?.email ?? '-', isDark),
            _divider(isDark),
            _infoRow(Icons.phone, 'So dien thoai',
                user?.phoneNumber ?? user?.phone ?? '-', isDark),
            _divider(isDark),
            _infoRow(
                Icons.wc,
                'Gioi tinh',
                user?.gender == 'MALE'
                    ? 'Nam'
                    : user?.gender == 'FEMALE'
                        ? 'Nu'
                        : '-',
                isDark),
            _divider(isDark),
            _infoRow(
                Icons.cake,
                'Ngay sinh',
                user?.dateOfBirth != null
                    ? '${user!.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}'
                    : '-',
                isDark),
            _divider(isDark),
            _infoRow(
                Icons.verified_user,
                'Trang thai',
                (user?.accountVerified ?? false)
                    ? 'Da xac thuc'
                    : 'Chua xac thuc',
                isDark,
                valueColor: (user?.accountVerified ?? false)
                    ? AppColors.success
                    : AppColors.warning),
            _divider(isDark),
            _infoRow(Icons.shield, 'Vai tro', user?.role ?? '-', isDark),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color:
                  isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: valueColor ??
                            (isDark ? Colors.white : Colors.black))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
        height: 1,
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
  }

  Widget _buildActionsCard(bool isDark, UserModel? user) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _actionTile(Icons.account_balance_wallet, 'Vi dien tu',
              Icons.chevron_right, isDark, () => context.push('/wallet')),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _actionTile(Icons.verified_user, 'Xac minh thanh toan',
              Icons.chevron_right, isDark, () => context.push('/kyc')),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _actionTile(Icons.location_on, 'Dia chi giao hang',
              Icons.chevron_right, isDark, () => context.push('/addresses')),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _actionTile(Icons.receipt_long, 'Don hang', Icons.chevron_right,
              isDark, () => context.push('/orders')),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _actionTile(Icons.flash_on, 'Khuyen mai', Icons.chevron_right, isDark,
              () => context.push('/flash-sale')),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _actionTile(Icons.storefront, 'Dang ky ban hang', Icons.chevron_right,
              isDark, () => context.push('/seller/register')),
          if (user?.role == 'ADMIN') ...[
            Divider(
                height: 1,
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            _actionTile(
                Icons.admin_panel_settings,
                'Admin Dashboard',
                Icons.chevron_right,
                isDark,
                () => context.push('/admin/dashboard')),
          ],
          if (user?.role == 'BUSINESS') ...[
            Divider(
                height: 1,
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            _actionTile(
                Icons.dashboard,
                'Business Dashboard',
                Icons.chevron_right,
                isDark,
                () => context.push('/seller/dashboard')),
          ],
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _actionTile(Icons.chat, 'Tro chuyen ho tro', Icons.chevron_right,
              isDark, () => context.push('/chat')),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _actionTile(Icons.report, 'Bao cao & Ho tro', Icons.chevron_right,
              isDark, () => context.push('/report')),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          _actionTile(Icons.logout, 'Dang xuat', null, isDark, _logout,
              isDestructive: true),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, IconData? trailing,
      bool isDark, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isDestructive
              ? AppColors.error
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
      title: Text(title,
          style: TextStyle(
              color: isDestructive
                  ? AppColors.error
                  : (isDark ? Colors.white : Colors.black))),
      trailing: trailing != null
          ? Icon(trailing,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
          : null,
      onTap: onTap,
    );
  }
}

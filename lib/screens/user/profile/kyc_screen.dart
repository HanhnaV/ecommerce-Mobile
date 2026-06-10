import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/kyc_model.dart';
import '../../../data/services/kyc_service.dart';
import '../../../providers/theme_provider.dart';

final _kycService = KycService();

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  KycModel? _kyc;
  bool _loading = true;
  String? _error;

  String? _idCardNumber;
  String? _frontImagePath;
  String? _backImagePath;
  String? _selfieImagePath;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadKyc();
  }

  Future<void> _loadKyc() async {
    setState(() { _loading = true; _error = null; });
    try {
      final kyc = await _kycService.getMyKyc();
      if (mounted) setState(() => _kyc = kyc);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Chup anh'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Chon tu thu vien'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;
    setState(() {
      switch (type) {
        case 'front':
          _frontImagePath = image.path;
          break;
        case 'back':
          _backImagePath = image.path;
          break;
        case 'selfie':
          _selfieImagePath = image.path;
          break;
      }
    });
  }

  Future<void> _submit() async {
    if (_idCardNumber == null || _idCardNumber!.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Vui long nhap so CCCD/CMND', backgroundColor: AppColors.error);
      return;
    }
    if (_frontImagePath == null || _backImagePath == null || _selfieImagePath == null) {
      Fluttertoast.showToast(msg: 'Vui long tai len day du 3 hinh anh', backgroundColor: AppColors.error);
      return;
    }

    setState(() => _submitting = true);
    try {
      final kyc = await _kycService.submitKyc(
        idCardNumber: _idCardNumber!.trim(),
        frontImagePath: _frontImagePath!,
        backImagePath: _backImagePath!,
        selfieImagePath: _selfieImagePath!,
      );
      if (mounted) {
        setState(() => _kyc = kyc);
        Fluttertoast.showToast(msg: 'Gui yeu cau xac minh thanh cong!');
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: e.toString().replaceFirst('Exception: ', ''), backgroundColor: AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Xac minh thanh toan'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadKyc, child: const Text('Thu lai')),
                    ],
                  ),
                )
              : _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    final kyc = _kyc;

    if (kyc != null && kyc.status != null && !kyc.isRejected) {
      return _buildStatusView(kyc, isDark);
    }

    return _buildFormView(isDark);
  }

  Widget _buildStatusView(KycModel kyc, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusCard(kyc, isDark),
        const SizedBox(height: 20),
        _buildImagesCard(kyc, isDark),
        if (kyc.isRejected) ...[
          const SizedBox(height: 20),
          _buildRejectionCard(kyc, isDark),
        ],
      ],
    );
  }

  Widget _buildStatusCard(KycModel kyc, bool isDark) {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (kyc.statusEnum) {
      case KycStatus.approved:
        icon = Icons.check_circle;
        color = AppColors.success;
        title = 'Da xac minh';
        subtitle = 'Tai khoan cua ban da duoc xac minh thanh cong.';
        break;
      case KycStatus.pending:
        icon = Icons.hourglass_top;
        color = AppColors.warning;
        title = 'Dang cho xet duyet';
        subtitle = 'Yeu cau xac minh cua ban dang duoc xu ly. Vui long cho trong 1-3 ngay lam viec.';
        break;
      case KycStatus.rejected:
        icon = Icons.cancel;
        color = AppColors.error;
        title = 'Bi tu choi';
        subtitle = 'Yeu cau xac minh cua ban bi tu choi.';
        break;
      default:
        icon = Icons.info;
        color = AppColors.info;
        title = 'Chua gui yeu cau';
        subtitle = 'Hoan thanh xac minh de mo khoa cac tinh nang thanh toan.';
    }

    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), textAlign: TextAlign.center),
            if (kyc.submittedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Gui ngay: ${kyc.submittedAt!.day}/${kyc.submittedAt!.month}/${kyc.submittedAt!.year}',
                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagesCard(KycModel kyc, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hinh anh da gui', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildImagePreview(kyc.frontImageUrl, 'Mat truoc CCCD', isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildImagePreview(kyc.backImageUrl, 'Mat sau CCCD', isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildImagePreview(kyc.selfieImageUrl, 'Anh chan dung', isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String? url, String label, bool isDark) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url != null && url.isNotEmpty
              ? Image.network(url, height: 80, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(isDark))
              : _placeholder(isDark),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), textAlign: TextAlign.center, maxLines: 2),
      ],
    );
  }

  Widget _placeholder(bool isDark) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
    );
  }

  Widget _buildRejectionCard(KycModel kyc, bool isDark) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text('Ly do tu choi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kyc.rejectionReason ?? 'Khong co chi tiet',
              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  _kyc = null;
                  _idCardNumber = null;
                  _frontImagePath = null;
                  _backImagePath = null;
                  _selfieImagePath = null;
                }),
                icon: const Icon(Icons.refresh),
                label: const Text('Gui lai yeu cau'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thong tin CCCD/CMND', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _idCardNumber,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'So CCCD/CMND',
                    hintText: 'Nhap 9 hoac 12 so',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    counterText: '',
                  ),
                  onChanged: (v) => _idCardNumber = v,
                ),
                const SizedBox(height: 24),
                Text('Hinh anh CCCD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildImagePicker('front', 'Mat truoc', _frontImagePath, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildImagePicker('back', 'Mat sau', _backImagePath, isDark)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildImagePicker('selfie', 'Anh chan dung (voi mat)', _selfieImagePath, isDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text('Luu y', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                ..._buildNoteItems(isDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Gui yeu cau xac minh'),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNoteItems(bool isDark) {
    final notes = [
      'Anh CCCD phai ro rang, khong bi loa mu',
      'Anh chan dung phai nhin thay mat cua ban',
      'Thong tin tren CCCD phai khop voi hinh anh',
    ];
    return notes.map((n) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          Expanded(child: Text(n, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
        ],
      ),
    )).toList();
  }

  Widget _buildImagePicker(String type, String label, String? path, bool isDark) {
    final hasImage = path != null;
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasImage ? AppColors.success : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: hasImage ? 2 : 1,
          ),
        ),
        child: hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.file(File(path), width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 4, top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 28, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                  const SizedBox(height: 8),
                  Text(label, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                ],
              ),
      ),
    );
  }
}

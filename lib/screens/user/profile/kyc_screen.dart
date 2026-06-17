import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/kyc_provider.dart';
import '../../../providers/theme_provider.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  // Session state
  String _sessionId = '';
  String _sessionStatus = '';

  // Uploaded file paths
  String? _frontPath;
  String? _backPath;
  String? _selfiePath;

  // File bytes for cross-platform upload (avoids dart:io dependency)
  List<int>? _frontBytes;
  List<int>? _backBytes;
  List<int>? _selfieBytes;

  // Preview images (base64 data URLs)
  String? _frontPreview;
  String? _backPreview;
  String? _selfiePreview;

  // Upload status flags
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _selfieUploaded = false;

  // UI state
  int _currentStep = 1; // 1=Front, 2=Back(optional), 3=Selfie, 4=Review
  bool _isStarting = false;
  bool _isUploading = false;
  bool _isComparing = false;
  bool _showCamera = false;

  @override
  void initState() {
    super.initState();
    _autoStartSession();
  }

  Future<void> _autoStartSession() async {
    setState(() => _isStarting = true);
    try {
      final res = await ref.read(kycServiceProvider).startSession();
      setState(() {
        _sessionId = res.sessionId;
        _sessionStatus = res.status;
      });
    } on DioException catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.message ?? 'Không thể tạo phiên KYC.',
          backgroundColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    setState(() {
      switch (type) {
        case 'front':
          _frontPath = image.path;
          _frontBytes = bytes;
          _frontPreview = dataUrl;
          break;
        case 'back':
          _backPath = image.path;
          _backBytes = bytes;
          _backPreview = dataUrl;
          break;
        case 'selfie':
          _selfiePath = image.path;
          _selfieBytes = bytes;
          _selfiePreview = dataUrl;
          break;
      }
    });
  }

  void _removeImage(String type) {
    setState(() {
      switch (type) {
        case 'front':
          _frontPath = null;
          _frontPreview = null;
          _frontUploaded = false;
          break;
        case 'back':
          _backPath = null;
          _backPreview = null;
          _backUploaded = false;
          break;
        case 'selfie':
          _selfiePath = null;
          _selfiePreview = null;
          _selfieUploaded = false;
          break;
      }
    });
  }

  Future<void> _upload(String type) async {
    if (_sessionId.isEmpty) {
      Fluttertoast.showToast(msg: 'Phiên KYC chưa sẵn sàng.', backgroundColor: AppColors.error);
      return;
    }

    List<int>? bytes;
    String docType;
    String label;

    switch (type) {
      case 'front':
        if (_frontBytes == null) return;
        bytes = _frontBytes;
        docType = 'FRONT';
        label = 'mặt trước CCCD';
        break;
      case 'back':
        if (_backBytes == null) return;
        bytes = _backBytes;
        docType = 'BACK';
        label = 'mặt sau CCCD';
        break;
      case 'selfie':
        if (_selfieBytes == null) return;
        bytes = _selfieBytes;
        docType = 'SELFIE';
        label = 'khuôn mặt';
        break;
      default:
        return;
    }

    setState(() => _isUploading = true);
    try {
      await ref.read(kycServiceProvider).uploadWithBytes(
        sessionId: _sessionId,
        type: docType,
        bytes: bytes!,
        title: 'kyc-$type-${DateTime.now().millisecondsSinceEpoch}',
        description: 'Upload $type',
      );

      setState(() {
        switch (type) {
          case 'front':
            _frontUploaded = true;
            _currentStep = 2;
            break;
          case 'back':
            _backUploaded = true;
            _currentStep = 3;
            break;
          case 'selfie':
            _selfieUploaded = true;
            _currentStep = 4;
            break;
        }
      });

      Fluttertoast.showToast(msg: 'Upload ảnh $label thành công!');
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: e.message ?? 'Upload ảnh $label thất bại.',
        backgroundColor: AppColors.error,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _compare() async {
    if (!_frontUploaded || !_selfieUploaded) {
      Fluttertoast.showToast(
        msg: 'Vui lòng hoàn tất upload ảnh trước khi xác minh.',
        backgroundColor: AppColors.error,
      );
      return;
    }

    setState(() => _isComparing = true);
    try {
      final result = await ref.read(kycServiceProvider).compare(_sessionId);

      if (result.isVerified) {
        // Sync verified state back to auth provider
        ref.read(authStateProvider.notifier).updateAccountVerified(true);

        if (mounted) {
          _showVerifiedDialog();
        }
      } else {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Xác minh thất bại. Vui lòng thử lại.',
            backgroundColor: AppColors.error,
          );
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.message ?? 'Xác minh thất bại.',
          backgroundColor: AppColors.error,
        );
      }
    } finally {
      setState(() => _isComparing = false);
    }
  }

  void _showVerifiedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
            ),
            const SizedBox(height: 20),
            const Text(
              'Xác minh thành công!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tài khoản của bạn đã được xác minh.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet(String type) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera, type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery, type);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Xác minh danh tính (KYC)'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
        actions: [
          if (_currentStep > 1)
            TextButton(
              onPressed: () => setState(() {
                if (_currentStep > 1) _currentStep--;
              }),
              child: Text(
                '← Quay lại',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _isStarting
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    return Column(
      children: [
        _buildStepIndicator(isDark),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCurrentStep(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    final steps = [
      {'label': 'Mặt trước', 'icon': Icons.credit_card},
      {'label': 'Mặt sau',  'icon': Icons.credit_card_outlined},
      {'label': 'Khuôn mặt','icon': Icons.face},
      {'label': 'Xem lại',  'icon': Icons.check_circle_outline},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = index + 1;
          final isActive = _currentStep >= step;
          final isDone = _currentStep > step;

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        border: isActive
                            ? Border.all(color: AppColors.primary, width: 0)
                            : Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1), width: 1),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Icon(
                                steps[index]['icon'] as IconData,
                                size: 18,
                                color: isActive ? Colors.white : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? AppColors.primary
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: _currentStep > step
                          ? AppColors.primary
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildUploadStep(
          isDark: isDark,
          title: 'Bước 1: Upload ảnh mặt trước CCCD',
          subtitle: 'Chụp hoặc chọn ảnh mặt trước CMND/CCCD',
          type: 'front',
          preview: _frontPreview,
          isUploaded: _frontUploaded,
          required: true,
        );
      case 2:
        return _buildUploadStep(
          isDark: isDark,
          title: 'Bước 2: Upload ảnh mặt sau CCCD',
          subtitle: 'Có thể bỏ qua bước này',
          type: 'back',
          preview: _backPreview,
          isUploaded: _backUploaded,
          required: false,
          skipAvailable: true,
        );
      case 3:
        return _buildUploadStep(
          isDark: isDark,
          title: 'Bước 3: Chụp ảnh khuôn mặt',
          subtitle: 'Chụp selfie trực tiếp để xác minh',
          type: 'selfie',
          preview: _selfiePreview,
          isUploaded: _selfieUploaded,
          required: true,
        );
      case 4:
        return _buildReviewStep(isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildUploadStep({
    required bool isDark,
    required String title,
    required String subtitle,
    required String type,
    required String? preview,
    required bool isUploaded,
    required bool required,
    bool skipAvailable = false,
  }) {
    final hasFile = preview != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),

                // Preview or upload area
                hasFile
                    ? _buildImagePreview(preview!, isUploaded, type, isDark)
                    : _buildUploadArea(type, isDark),

                const SizedBox(height: 16),

                // Upload button
                if (hasFile && !isUploaded)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : () => _upload(type),
                      icon: _isUploading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload),
                      label: Text(_isUploading ? 'Đang upload...' : 'Upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                // Skip button (step 2 only)
                if (skipAvailable && !isUploaded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep = 3),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Bỏ qua'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        ..._buildNotes(isDark),
      ],
    );
  }

  Widget _buildImagePreview(String dataUrl, bool isUploaded, String type, bool isDark) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(dataUrl.split(',').last),
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        if (isUploaded)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Đã upload',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeImage(type),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(String type, bool isDark) {
    return GestureDetector(
      onTap: () => _showImageSourceSheet(type),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 40,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 8),
            Text(
              'Chạm để chọn ảnh',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bước 4: Xem lại và xác minh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kiểm tra lại các ảnh đã upload trước khi xác minh',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                _buildReviewImage(
                  label: 'Ảnh mặt trước CCCD',
                  preview: _frontPreview,
                  uploaded: _frontUploaded,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildReviewImage(
                  label: 'Ảnh mặt sau CCCD',
                  preview: _backPreview,
                  uploaded: _backUploaded,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildReviewImage(
                  label: 'Ảnh khuôn mặt',
                  preview: _selfiePreview,
                  uploaded: _selfieUploaded,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Warning note
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
                    Text(
                      'Lưu ý',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._buildNotes(isDark),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isComparing || !_frontUploaded || !_selfieUploaded)
                ? null
                : _compare,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isComparing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Xác minh danh tính'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewImage({
    required String label,
    required String? preview,
    required bool uploaded,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              if (preview != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(preview.split(',').last),
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: uploaded
                ? AppColors.success.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                uploaded ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 14,
                color: uploaded
                    ? AppColors.success
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 4),
              Text(
                uploaded ? 'Đã upload' : 'Chưa upload',
                style: TextStyle(
                  fontSize: 12,
                  color: uploaded
                      ? AppColors.success
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNotes(bool isDark) {
    final notes = [
      'Ảnh CCCD phải rõ ràng, không bị lem mờ',
      'Ảnh chân dung phải nhìn thấy mặt của bạn',
      'Thông tin trên CCCD phải khớp với hình ảnh',
    ];
    return notes.map((n) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              n,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }
}

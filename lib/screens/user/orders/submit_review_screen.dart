import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/review_service.dart';
import '../../../data/models/review_model.dart';
import '../../../providers/theme_provider.dart';

class SubmitReviewScreen extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final String? productImageUrl;

  const SubmitReviewScreen({
    super.key,
    required this.productId,
    required this.productName,
    this.productImageUrl,
  });

  @override
  ConsumerState<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends ConsumerState<SubmitReviewScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  final List<String> _selectedImages = [];
  bool _isSubmitting = false;

  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) {
      Fluttertoast.showToast(msg: 'Toi da 5 hinh anh');
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chup anh'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chon tu thu vien'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    final image = await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() => _selectedImages.add(image.path));
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final service = ReviewService();
      await service.submitReview(
        productId: widget.productId,
        rating: _rating,
        comment: _commentController.text.trim().isNotEmpty ? _commentController.text.trim() : null,
        imagePaths: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (mounted) {
        Fluttertoast.showToast(msg: 'Gui danh gia thanh cong!');
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Danh gia san pham'),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1C1917),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.productImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: widget.productImageUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 64,
                                height: 64,
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                              ),
                            )
                          : Container(
                              width: 64,
                              height: 64,
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.productName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                    Text(
                      'Ban danh gia may sao?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(
                            star <= _rating ? Icons.star : Icons.star_border,
                            color: AppColors.rating,
                            size: 36,
                          ),
                          onPressed: () => setState(() => _rating = star),
                        );
                      }),
                    ),
                    Center(
                      child: Text(
                        _getRatingText(_rating),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.rating,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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
                    Text(
                      'Hinh anh (${_selectedImages.length}/5)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._selectedImages.asMap().entries.map((entry) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(entry.value),
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImages.removeAt(entry.key)),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (_selectedImages.length < 5)
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                      ],
                    ),
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
                    Text(
                      'Nhan xet cua ban',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Chia se trai nghiem cua ban ve san pham...',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      ),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Gui danh gia'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Rat kem';
      case 2:
        return 'Kem';
      case 3:
        return 'Trung binh';
      case 4:
        return 'Tot';
      case 5:
        return 'Rat tot';
      default:
        return '';
    }
  }
}

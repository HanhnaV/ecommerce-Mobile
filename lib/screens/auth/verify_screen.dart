import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_service_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/auth_layout.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  void _handleChange(int index, String value) {
    if (value.isEmpty) return;

    if (value.length > 1) {
      final chars = value.replaceAll(RegExp(r'\D'), '').split('').take(6).toList();
      for (int i = 0; i < chars.length && index + i < 6; i++) {
        _controllers[index + i].text = chars[i];
      }
      final lastIndex = (index + chars.length - 1).clamp(0, 5);
      _focusNodes[lastIndex].requestFocus();
    } else if (RegExp(r'^\d$').hasMatch(value)) {
      _controllers[index].text = value;
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _checkAutoSubmit();
      }
    } else {
      _controllers[index].clear();
    }
    setState(() {});
  }

  void _handleKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].text = '';
        _focusNodes[index - 1].requestFocus();
        setState(() {});
      }
    }
  }

  void _checkAutoSubmit() {
    if (_otpValue.length == 6 && !_isLoading) {
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    if (_otpValue.length != 6) {
      Fluttertoast.showToast(
        msg: 'Vui long nhap du 6 so OTP',
        backgroundColor: AppColors.warning,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(authServiceProvider);
      await service.verify(email: widget.email, otp: _otpValue);

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Xac thuc thanh cong! Vui long dang nhap.',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      _clearOtp();
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0 || _isResending) return;

    if (widget.email.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Khong co email de gui lai ma. Vui long dang ky truoc.',
        backgroundColor: AppColors.warning,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isResending = true);

    try {
      final service = ref.read(authServiceProvider);
      await service.resendOtp(email: widget.email);

      if (!mounted) return;

      _clearOtp();
      Fluttertoast.showToast(
        msg: 'Da gui lai ma OTP! Kiem tra email cua ban.',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
      setState(() => _resendCooldown = 60);
      _startCooldown();
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startCooldown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendCooldown <= 0) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return AuthLayout(
      title: 'Xac thuc tai khoan',
      subtitle: widget.email.isNotEmpty
          ? 'Nhap ma OTP 6 so da gui toi\n${widget.email}'
          : 'Nhap ma OTP 6 so da gui toi email cua ban',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Da co tai khoan? ',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Text(
              'Dang nhap',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 48,
                height: 56,
                child: KeyboardListener(
                  focusNode: _focusNodes[index],
                  onKeyEvent: (event) => _handleKeyDown(index, event),
                  child: TextFormField(
                    controller: _controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    readOnly: _isLoading,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1C1917),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                          : const Color(0xFFF5F5F4).withValues(alpha: 0.8),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _handleChange(index, value),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          'Ma OTP se tu dong xac thuc khi nhap day 6 so',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _isLoading ? null : _handleVerify,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Xac thuc',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Khong nhan duoc ma? ',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: _resendCooldown == 0 && !_isResending ? _handleResend : null,
              child: _isResending
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Text(
                      _resendCooldown > 0 ? 'Gui lai ($_resendCooldown)' : 'Gui lai',
                      style: TextStyle(
                        color: _resendCooldown > 0
                            ? (isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E))
                            : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

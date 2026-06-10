import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_service_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui long nhap ten dang nhap';
    if (value.trim().length < 3) return 'It nhat 3 ky tu';
    if (value.trim().length > 50) return 'Toi da 50 ky tu';
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value.trim())) {
      return 'Chi chua chu cai, so, gap duoi va gap ngang';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui long nhap so dien thoai';
    if (!RegExp(r'^(84|0[3|5|7|8|9])+(\d{8})$').hasMatch(value.trim())) {
      return 'So dien thoai khong hop le (VN)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui long nhap email';
    if (!RegExp(r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$', caseSensitive: false)
        .hasMatch(value.trim())) {
      return 'Email khong hop le';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui long nhap mat khau';
    if (value.length < 8) return 'It nhat 8 ky tu';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'It nhat 1 chu hoa';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'It nhat 1 chu thuong';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'It nhat 1 chu so';
    return null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(authServiceProvider);
      final result = await service.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Dang ky thanh cong! Vui long xac thuc tai khoan.',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );

      context.go('/verify', extra: {'email': result.email});
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: AppColors.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tao tai khoan',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1C1917),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tham gia AirPod Store va bat dau mua sam',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155).withValues(alpha: 0.5)
                            : const Color(0xFFE7E5E4).withValues(alpha: 0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _usernameController,
                          label: 'Ten dang nhap',
                          hint: 'username',
                          icon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: _validateUsername,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _phoneController,
                          label: 'So dien thoai',
                          hint: '0912345678',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'you@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Mat khau',
                          hint: 'It nhat 8 ky tu, 1 hoa, 1 thuong, 1 so',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _confirmController,
                          label: 'Xac nhan mat khau',
                          hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleRegister(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui long xac nhan mat khau';
                            }
                            if (value != _passwordController.text) {
                              return 'Mat khau khong khop';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isLoading ? null : _handleRegister,
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
                                  'Tao tai khoan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

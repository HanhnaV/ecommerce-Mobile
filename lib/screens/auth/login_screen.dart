import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_service_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final service = ref.read(authServiceProvider);
      final result = await service.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      await ref.read(authStateProvider.notifier).login(result.token, result.user);
      ref.read(cartProvider.notifier).clear();

      Fluttertoast.showToast(
        msg: 'Chao mung tro lai, ${result.user.fullName}!',
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );

      if (mounted) context.go('/');
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

    return Form(
      key: _formKey,
      child: AuthLayout(
        title: 'Dang nhap tai khoan',
        subtitle: 'Nhap ten dang nhap de tiep tuc',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chua co tai khoan? ',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/register'),
            child: Text(
              'Dang ky',
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
        AuthTextField(
          controller: _usernameController,
          label: 'Ten dang nhap',
          hint: 'username',
          icon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui long nhap ten dang nhap';
            }
            if (value.trim().length < 3) {
              return 'It nhat 3 ky tu';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        AuthTextField(
          controller: _passwordController,
          label: 'Mat khau',
          hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui long nhap mat khau';
            }
            if (value.length < 6) {
              return 'It nhat 6 ky tu';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: forgot password (P7+)
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Quen mat khau?',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
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
                  'Dang nhap',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    ),
    );
  }
}

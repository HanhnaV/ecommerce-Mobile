import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.errorText,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF44403C),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          autofocus: autofocus,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1C1917),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFFA8A29E),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A).withOpacity(0.5)
                : const Color(0xFFF5F5F4).withOpacity(0.8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE7E5E4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

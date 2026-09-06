import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  final String? Function(String?)? validator;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  final int maxLines;
  final int? maxLength;

  final List<TextInputFormatter>? inputFormatters;

  final bool obscureText;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
  });

  static const Color navyBlue = Color(0xFF172C4E);

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF182331)
        : Colors.white;

    final textColor = isDark
        ? Colors.white
        : const Color(0xFF172C4E);

    final secondaryTextColor = isDark
        ? Colors.white70
        : const Color(0xFF687386);

    final borderColor = isDark
        ? Colors.white12
        : const Color(0xFFE2E6EC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          validator: validator,

          style: TextStyle(
            fontSize: 16,
            color: textColor,
          ),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),

            prefixIcon: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11.r),
                  color: navyBlue.withOpacity(0.07),
                ),
                child: Icon(
                  icon,
                  color: navyBlue,
                  size: 22.w,
                ),
              ),
            ),

            filled: true,
            fillColor: backgroundColor,

            counterText: '',

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),

            errorStyle: const TextStyle(
              fontSize: 11,
              color: Colors.red,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: navyBlue,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
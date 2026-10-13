import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_go_app/utils/text_style.dart';

import '../../utils/colors.dart';

class AppTextField extends StatelessWidget {
  // ── الأساسيات ──
  final String? title;
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;

  final String? Function(String?)? validator;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  final int maxLines;
  final int? maxLength;

  final List<TextInputFormatter>? inputFormatters;

  final bool obscureText;
  final bool enabled;

  // ── Prefix / Suffix ──
  final String? prefixText; // نص بادئة (مثل رمز العملة) إذا ما في icon
  final String? suffixText; // نص لاحقة (kg, SAR...)
  final Widget? suffix; // Widget مخصص، وإذا انعطى بيتقدّم على suffixText

  // ── إضافات جاية من AddProductTextField ──
  final bool readOnly;
  final bool autofocus;
  final bool autocorrect;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final TextCapitalization textCapitalization;
  final bool isEditMode;
  final String? htmlContent;

  const AppTextField({
    super.key,
    this.title,
    this.hint,
    this.controller,
    this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.prefixText,
    this.suffixText,
    this.suffix,
    this.readOnly = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.isEditMode = false,
    this.htmlContent,
  });

  static const Color navyBlue = Color(0xFF172C4E);

  bool _has(String? s) => s != null && s.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF18263F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF172C4E);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF687386);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6EC);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    // suffix: الـ Widget المخصص أولاً، وإلا suffixText
    Widget? suffixWidget = suffix;
    if (suffixWidget == null && _has(suffixText)) {
      suffixWidget = Padding(
        padding: const EdgeInsets.only(left: 8, right: 12),
        child: Center(
          widthFactor: 1,
          child: Text(
            suffixText!,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_has(title)) ...[
          Text(title!, style: pSemiBold14),
          const SizedBox(height: 8),
        ],

        // ── وضع عرض HTML ──
        if (isEditMode && _has(htmlContent))
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Html(
              data: htmlContent,
              style: {
                "body": Style(
                  fontSize: FontSize(14.sp),
                  color: textColor,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "p": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
              },
            ),
          )
        else
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            readOnly: readOnly,
            autofocus: autofocus,
            autocorrect: autocorrect,
            onTap: onTap,
            onChanged: onChanged,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            cursorColor: navyBlue,
            style: TextStyle(fontSize: 16.sp, color: textColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: secondaryTextColor,
              ),
              prefixIcon: icon != null
                  ? Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11.r),
                    color: navyBlue.withValues(alpha: 0.07),
                  ),
                  child: Icon(icon, color: isDark ? Colors.white : AppColor.themeNavyBlueColor, size: 22.w),
                ),
              )
                  : null,

              prefixText: (icon == null && _has(prefixText)) ? prefixText : null,
              prefixStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),

              suffixIcon: suffixWidget,

              filled: true,
              fillColor: backgroundColor,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              errorStyle: const TextStyle(fontSize: 11, color: Colors.red),

              border: border(borderColor),
              enabledBorder: border(borderColor),
              disabledBorder: border(borderColor),
              focusedBorder: border(navyBlue, 1.5),
              errorBorder: border(Colors.red),
              focusedErrorBorder: border(Colors.red, 1.5),
            ),
          ),
      ],
    );
  }
}
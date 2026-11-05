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

  /// The accessible name, for the sites that render their visible label at the
  /// call site instead of passing [title] -- `_requiredLabel` in
  /// add_new_product_screen.dart is a RichText with a red asterisk that [title]
  /// cannot express. Falls back to [title]; when both are absent no annotation
  /// is added at all, so the sites that pass neither are untouched.
  final String? semanticLabel;
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
    this.semanticLabel,
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

  /// P2.5-D-02. Kept, because it is still the correct LIGHT-mode value (13.94:1 on white) and
  /// because removing a public static is a breaking change for anything referencing it.
  /// What changed is that it is no longer used unconditionally -- see [_focusColor].
  static const Color navyBlue = Color(0xFF172C4E);

  /// The caret and the focus ring, solved against the surface they are actually painted on.
  ///
  /// MEASURED: navy on the dark theme's own field surface (`DarkThemeColor.cSurface`, #213252)
  /// is **1.09:1**. A caret and a focus indicator are non-text UI components, so WCAG 1.4.11
  /// asks 3:1, and focus visibility is WCAG 2.4.7 -- a ring nobody can see is the same as no
  /// ring. In dark mode a merchant could not tell which field had focus or where the cursor was.
  ///
  /// NO NEW COLOUR IS INTRODUCED. Both values already exist in this app's own themes:
  /// `LightThemeColor.cPrimary` is the same navy (13.94:1 on white, unchanged) and
  /// `DarkThemeColor.cPrimary` is #10AFC0 (4.82:1 on the dark field). The app's brand is an
  /// open question reserved to the owner; this reads what the theme already says rather than
  /// deciding it. Guarded by test/a11y/field_focus_contrast_test.dart.
  static Color _focusColor(bool isDark) =>
      isDark ? DarkThemeColor.cPrimary : LightThemeColor.cPrimary;

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
        // P2-07 RTL: the suffix sits inside the field, so its breathing room
        // has to follow the text direction -- 8 before it, 12 after it.
        padding: const EdgeInsetsDirectional.only(start: 8, end: 12),
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
          // Names the field with its own visible label. `Semantics` defaults to
          // `container: false`, so this MERGES into the field's node rather
          // than adding a sibling -- which is what keeps the TEXTFIELD role,
          // the OBSCURED flag, the value and the validator's error intact.
          //
          // Deliberately no `textField: true`: RenderEditable already sets it,
          // two nodes carrying the same flag conflict, and the conflict forces
          // the field to form its own node -- measured, the label then never
          // arrives and a phantom edit box appears beside it.
          Semantics(
            label: _has(semanticLabel)
                ? semanticLabel
                : (_has(title) ? title : null),
            child: TextFormField(
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
            cursorColor: _focusColor(isDark),
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
              focusedBorder: border(_focusColor(isDark), 1.5),
              errorBorder: border(Colors.red),
              focusedErrorBorder: border(Colors.red, 1.5),
            ),
          ),
          ),
      ],
    );
  }
}
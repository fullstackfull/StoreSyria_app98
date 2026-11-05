// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';

Widget commonDropdownButtonWidget<T>({
  T? value,
  String? labelText,
  Widget? widget,
  String hint = '',
  List<T>? list,
  String Function(T item)? itemLabel,
  ValueChanged<T?>? onChanged,
  FormFieldValidator<T>? validator,
}) {
  return Builder(builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldBg = isDark ? const Color(0xFF18263F) : AppColor.cWhite;
    final borderColor = isDark ? const Color(0xFF2E4266) : AppColor.cBorder;
    final textColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;
    final labelColor = isDark ? Colors.grey.shade400 : AppColor.cDarkGreyFont;
    /* P2.5-A-06. THE LIGHT BRANCH WAS `AppColor.cHintFont`, WHICH IS #FFFFFF -- white hint text
       on the white field set one line above. 1.00:1. A merchant filling in the product, shipping
       or tax form could not read what the control was asking for.

       cHintFont is the mutable-global trap in miniature: colors.dart:33 assigns it white once and
       NEITHER AppLightTheme.lightThemeColor() NOR AppDarkTheme.darkColor() reassigns it, so it
       stays white in both themes while every field around it swaps. A grep across lib/ returns
       exactly two lines -- the declaration and this one use.

       LightThemeColor.cFont (#66728C, 4.83:1 on white) is this app's own secondary-text colour,
       so the hint now matches every other muted line instead of being its own value.

       THE DARK BRANCH IS DELIBERATELY UNTOUCHED. Colors.grey.shade500 on #18263F measures
       5.65:1 and already passes; changing it would be a restyle rather than a repair, and this
       file's own idiom is `isDark ? <literal> : <token>` (see labelColor above). */
    final hintColor = isDark ? Colors.grey.shade500 : LightThemeColor.cFont;
    final accentColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;

    // إذا ما انبعت دالة عرض، استخدم toString() (نفس السلوك القديم لـ List<String>)
    String labelOf(T item) => itemLabel != null ? itemLabel(item) : item.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText == ''
            ? verticalSpace(0)
            : Text(
          labelText!,
          style: pMedium12.copyWith(color: labelColor),
        ),
        verticalSpace(8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: list!.map((data) {
            return DropdownMenuItem<T>(
              value: data,
              child: Text(
                labelOf(data),
                style: pMedium14.copyWith(color: textColor),
              ),
            );
          }).toList(),
          dropdownColor: fieldBg,
          icon: Padding(
            // P2-07 RTL: the chevron's inset follows the direction, so it is not
            // flush against the field edge in Arabic and gapped in English.
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: assetSvdImageWidget(
              image: DefaultImages.dropDownIcn,
              colorFilter: ColorFilter.mode(
                accentColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          style: pMedium14.copyWith(
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: pMedium12.copyWith(color: hintColor),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: widget == null
                ? null
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: widget,
            ),
            prefixIconConstraints: widget == null
                ? null
                : BoxConstraints(maxWidth: 60, maxHeight: 60),
            filled: true,
            fillColor: fieldBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(0xFFE5484D)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accentColor, width: 1.4),
            ),
          ),
        ),
      ],
    );
  });
}
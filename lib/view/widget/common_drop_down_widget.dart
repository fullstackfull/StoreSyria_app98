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
    final fieldBg = isDark ? const Color(0xFF1E2530) : AppColor.cWhite;
    final borderColor = isDark ? const Color(0xFF2E3542) : AppColor.cBorder;
    final textColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;
    final labelColor = isDark ? Colors.grey.shade400 : AppColor.cDarkGreyFont;
    final hintColor = isDark ? Colors.grey.shade500 : AppColor.cHintFont;
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
            padding: const EdgeInsets.only(right: 4),
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
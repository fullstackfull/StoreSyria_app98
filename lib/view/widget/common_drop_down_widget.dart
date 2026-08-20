// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';

Widget commonDropdownButtonWidget(
    {String? value,
      String? labelText,
      Widget? widget,
      String hint = '',
      List? list,
      ValueChanged? onChanged,
      FormFieldValidator? validator}) {
  return Builder(builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldBg = isDark ? const Color(0xFF1E2530) : AppColor.cWhite;
    final borderColor = isDark ? const Color(0xFF2E3542) : AppColor.cBorder;
    final textColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;
    final labelColor = isDark ? Colors.grey.shade400 : AppColor.cDarkGreyFont;
    final hintColor = isDark ? Colors.grey.shade500 : AppColor.cHintFont;
    final accentColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;

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
        DropdownButtonFormField(
          value: value,
          items: list!.map((data) {
            return DropdownMenuItem(
              value: data,
              child: Text(
                data,
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
          onChanged: onChanged!,
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
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Color(0xFFE5484D),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: accentColor,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  });
}

Widget commonHintDropdownWidget(
    {String? value,
      String? labelText,
      Widget? widget,
      String hint = '',
      List? list,
      ValueChanged? onChanged,
      FormFieldValidator? validator}) {
  return Builder(builder: (context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldBg = isDark ? const Color(0xFF1E2530) : AppColor.cWhite;
    final borderColor = isDark ? const Color(0xFF2E3542) : AppColor.cBorder;
    final textColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;
    final labelColor = isDark ? Colors.grey.shade400 : AppColor.cDarkGreyFont;
    final hintColor = isDark ? Colors.grey.shade500 : AppColor.cDarkGreyFont;
    final accentColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText == ''
            ? verticalSpace(0)
            : Text(
          labelText!,
          style: pMedium12.copyWith(
            color: labelColor,
          ),
        ),
        verticalSpace(8),
        SizedBox(
          height: 48,
          child: DropdownButtonFormField(
            // value: value,
            items: list!.map((data) {
              return DropdownMenuItem(
                value: data,
                child: Text(
                  data,
                  style: pMedium12.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
            dropdownColor: fieldBg,
            icon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: assetSvdImageWidget(
                  image: DefaultImages.dropDownIcn,
                  colorFilter: ColorFilter.mode(
                      accentColor, BlendMode.srcIn)),
            ),
            onChanged: onChanged!,
            validator: validator,
            isExpanded: true,
            style: pMedium12.copyWith(
              color: textColor,
            ),
            borderRadius: BorderRadius.circular(16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: pMedium12.copyWith(color: hintColor),
              isDense: true,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: borderColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: borderColor,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Color(0xFFE5484D),
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: accentColor,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  });
}
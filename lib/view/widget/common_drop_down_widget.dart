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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      labelText == ''
          ? verticalSpace(0)
          : Text(
              labelText!,
              style: pMedium12,
            ),
      verticalSpace(15),
      DropdownButtonFormField(
        value: value,
        items: list!.map((data) {
          return DropdownMenuItem(
            value: data,
            child: Text(
              data,
              style: pMedium14.copyWith(),
            ),
          );
        }).toList(),
        dropdownColor: AppColor.themeGreenColor,
        icon: assetSvdImageWidget(image: DefaultImages.dropDownIcn),
        onChanged: onChanged!,
        validator: validator,
        style: pMedium14.copyWith(
          color: AppColor.cWhiteFont,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: pMedium12.copyWith(color: AppColor.cHintFont),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: widget,
          ),
          prefixIconConstraints: BoxConstraints(maxWidth: 80, maxHeight: 80),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: AppColor.cBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: AppColor.cBorder,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: AppColor.cBorder,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: AppColor.cBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    ],
  );
}

Widget commonHintDropdownWidget(
    {String? value,
    String? labelText,
    Widget? widget,
    String hint = '',
    List? list,
    ValueChanged? onChanged,
    FormFieldValidator? validator}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      labelText == ''
          ? verticalSpace(0)
          : Text(
              labelText!,
              style: pMedium12.copyWith(
                color: AppColor.cDarkGreyFont,
              ),
            ),
      verticalSpace(10),
      SizedBox(
        height: 50,
        child: DropdownButtonFormField(
          // value: value,
          items: list!.map((data) {
            return DropdownMenuItem(
              value: data,
              child: Text(
                data,
                style: pMedium12,
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
          dropdownColor: AppColor.themeGreenColor,
          icon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: assetSvdImageWidget(
                image: DefaultImages.dropDownIcn,
                colorFilter:
                    ColorFilter.mode(AppColor.cLabel, BlendMode.srcIn)),
          ),
          onChanged: onChanged!,
          validator: validator,
          style: pMedium12.copyWith(
            color: AppColor.cWhiteFont,
          ),
          borderRadius: BorderRadius.circular(15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: widget,
            ),
            prefixIconConstraints: BoxConstraints(maxWidth: 80, maxHeight: 80),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColor.cBorder,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColor.cBorder,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColor.cBorder,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColor.cBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: AppColor.cBorder,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

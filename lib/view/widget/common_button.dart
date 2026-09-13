// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

class CommonButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? fontSize;
  final bool isLoading; // هذا المتغير هو المفتاح
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;

  CommonButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.textColor,
    this.fontSize,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AnimatedOpacity(
      opacity: isLoading ? 0.7 : 1.0, // تخفيف الشفافية قليلاً أثناء التحميل
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        // تعطيل الضغط تماماً إذا كان يحمل
        onTap: isLoading ? null : onPressed,
        child: Container(
          width: width ?? Get.width,
          height: height ?? 42,
          decoration: BoxDecoration(
            color: btnColor ?? AppColor.themeNavyBlueColor,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: bColor ?? AppColor.cTransparent),
          ),
          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
          child: Center(
            child: isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(textColor ?? AppColor.cWhite),
              ),
            )
                : Text(
              title!,
              style: pBold14.copyWith(
                  color: textColor ?? AppColor.cWhite,
                  fontSize: fontSize ?? 14
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
class CommonIconButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? radius;
  final String? iconData;
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;

  CommonIconButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.iconData,
    this.radius,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? Get.width,
        // height: height ?? Get.height * 0.07,
        height: height ?? 43,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.themeNavyBlueColor,
            borderRadius: BorderRadius.circular(radius ?? 35),
            border: Border.all(color: bColor ?? AppColor.cTransparent, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            assetSvdImageWidget(
              image: iconData!,
            ),
            horizontalSpace(10),
            Text(
              title!,
              style: pBold12.copyWith(color: textColor ?? AppColor.cWhite),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SmallCommonIconButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? radius;
  final String? iconData;
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;
  final Color? circleColor;

  SmallCommonIconButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.iconData,
    this.radius,
    this.textColor,
    this.circleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // width: width ?? 180,
        height: height ?? 35,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.themeNavyBlueColor,
            borderRadius: BorderRadius.circular(radius ?? 35),
            border: Border.all(color: bColor ?? AppColor.cTransparent, width: 1)),
        padding: EdgeInsets.only(top: 3, bottom: 3, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(color: circleColor ?? AppColor.cWhite, shape: BoxShape.circle),
              padding: EdgeInsets.all(3),
              child: assetSvdImageWidget(
                image: iconData!,
              ),
            ),
            horizontalSpace(10),
            Text(
              title!,
              style: pMedium12.copyWith(color: textColor ?? AppColor.cWhiteFont),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CommonBorderButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? radius;
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;

  CommonBorderButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.radius,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? Get.width,
        // height: height ?? Get.height * 0.07,
        height: height ?? 43,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.cWhite,
            borderRadius: BorderRadius.circular(radius ?? 10),
            border: Border.all(color: bColor ?? AppColor.themeGreenColor, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title!,
              style: pBold14.copyWith(color: textColor ?? AppColor.cText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CommonIconBorderButton extends StatelessWidget {
  final String? title;
  final double? height;
  final double? width;
  final double? radius;
  final String? iconData;
  final Function()? onPressed;
  final Color? bColor;
  final Color? btnColor;
  final Color? textColor;

  CommonIconBorderButton({
    Key? key,
    this.title,
    this.height,
    this.width,
    this.onPressed,
    this.bColor,
    this.btnColor,
    this.iconData,
    this.radius,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? Get.width,
        // height: height ?? Get.height * 0.07,
        height: height ?? 43,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.cWhite,
            borderRadius: BorderRadius.circular(radius ?? 10),
            border: Border.all(color: bColor ?? AppColor.themeGreenColor, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title!,
              style: pBold14.copyWith(color: textColor ?? AppColor.cText),
              textAlign: TextAlign.center,
            ),
            horizontalSpace(10),
            assetSvdImageWidget(
              image: iconData!,
            )
          ],
        ),
      ),
    );
  }
}

class CommonSocialButton extends StatelessWidget {
  final String? title;
  final String? icon;
  final double? height;
  final double? width;
  final double? radius;
  final Color? btnColor;
  final Color? circleColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? borderColor;
  final Function()? onPressed;

  CommonSocialButton(
      {Key? key,
      this.title,
      this.icon,
      this.height,
      this.width,
      this.onPressed,
      this.btnColor,
      this.radius,
      this.borderColor,
      this.iconColor,
      this.textColor,
      this.circleColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height ?? 45,
        width: width ?? 272,
        decoration: BoxDecoration(
            color: btnColor ?? AppColor.themeGreenColor,
            borderRadius: BorderRadius.circular(radius ?? 64),
            border: Border.all(color: borderColor ?? AppColor.cTransparent)),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    color: circleColor ?? AppColor.themeNavyBlueColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.cBorder, width: 1)),
                padding: const EdgeInsets.all(3),
                child: Center(
                  child: assetSvdImageWidget(
                    image: icon!,
                  ),
                )),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title!,
                  style: pMedium10.copyWith(color: textColor ?? AppColor.cFont),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(width: 0, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

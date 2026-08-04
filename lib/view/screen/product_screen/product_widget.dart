// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart'; // تأكد من تحديث الأنماط هنا لتستخدم .sp إذا أمكن
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:store_go_app/utils/helper.dart';

Widget allProductWidget({
  int? index,
  Function()? deleteFun,
  Function()? viewFun,
  Function()? changeFun,
  required String image,
  required String title,
  required double initialRating,
  required String subTitle,
  required String amount,
}) {
  final isDark = Get.isDarkMode;
  final cardBg = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5);
  final primaryText = isDark ? Colors.white : AppColor.cText;
  final secondaryText = isDark ? Colors.grey.shade400 : AppColor.cFont;
  final accentColor = AppColor.themeNavyBlueColor;

  return Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Slidable(
      key: ValueKey(index),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          slidableActionWidget(
              onTap: viewFun,
              image: DefaultImages.eyeIcn,
              title: "view".tr),
          slidableActionWidget(
              onTap: changeFun,
              image: DefaultImages.changeIcn,
              title: "change".tr,
              color: accentColor),
          slidableActionWidget(
              onTap: deleteFun,
              image: DefaultImages.deleteIcn,
              title: "delete".tr,
              color: AppColor.cRedText),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor)),
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          child: Row(
          children: [
        Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 55.w,
                  width: 44.w,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: getImageUrl(image),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => SizedBox(),
                      errorWidget: (context, url, error) => Icon(Icons.production_quantity_limits, size: 45),
                      ),
                    ),
                  ),
        horizontalSpace(10.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: secondaryText,
                  fontWeight: FontWeight.normal,
                ),
              ),


              verticalSpace(3.h),


              Text(
                subTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),


              verticalSpace(3.h),


              richText(
                "price_label".tr,
                amount,
                secondaryText,
                primaryText,
              ),

            ],
          ),
        ),
                Align(
                  alignment: Alignment.centerRight,
                  child: RatingBar.builder(
                    initialRating: initialRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 15.sp,
                    unratedColor: secondaryText,
                    itemBuilder: (context, _) => Icon(
                      Icons.star_rate_rounded,
                      color: AppColor.cGreenFont,
                    ),
                    onRatingUpdate: (_) {},
                  ),
                ),
              ],
            ),
          ],
        ),
        )]),
    )));
}

Widget richText(String label, String value, Color labelColor, Color valueColor) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(text: "$label ", style: TextStyle(fontSize: 12.sp, color: labelColor)),
        TextSpan(text: value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    ),
  );
}

DottedBorder addAttachmentWidget(String name) {
  return DottedBorder(
    options: RoundedRectDottedBorderOptions(
      dashPattern: [3, 3],
      radius: Radius.circular(25.r),
      color: AppColor.cGreenFont,
    ),
    child: Padding(
      padding: EdgeInsets.all(15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          assetSvdImageWidget(image: DefaultImages.uploadIcn),
          horizontalSpace(10.w),
          Text(
            name,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}

class AddProductTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final bool? autofocus;
  final FocusNode? focusNode;
  final bool? obscureText;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final bool? autocorrect;
  final FormFieldValidator<String>? validator;
  final bool? readOnly;
  final String? labelText;
  final String? hintText;
  final String? prefix;
  final Widget? suffix;
  final String? obscuringCharacter;
  final int? maxLines;

  const AddProductTextField({
    Key? key,
    this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.onChanged,
    this.obscuringCharacter,
    this.onTap,
    this.validator,
    this.labelText,
    this.hintText,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.maxLines,
  }) : super(key: key);

  @override
  State<AddProductTextField> createState() => _AddProductTextFieldState();
}

class _AddProductTextFieldState extends State<AddProductTextField> {
  final TextAlign textAlign = TextAlign.start;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    // تفضيل المستخدم: عدم طباعة ID المستخدم أو معلومات حساسة
    // debugPrint("Focus: ${_focus.hasFocus.toString()}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5);
    final hintColor = isDark ? Colors.grey.shade500 : AppColor.cFont;
    final textColor = isDark ? Colors.white : AppColor.cText;
    final accentColor = AppColor.themeNavyBlueColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelText != null && widget.labelText!.isNotEmpty)
            Text(
              widget.labelText!,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: isDark ? Colors.grey.shade300 : AppColor.cDarkGreyFont),
            ),
          if (widget.labelText != null && widget.labelText!.isNotEmpty) verticalSpace(15.h),

          TextFormField(
            controller: widget.controller,
            cursorColor: accentColor,
            autofocus: widget.autofocus ?? false,
            focusNode: _focus,
            maxLines: widget.maxLines ?? 1,
            readOnly: widget.readOnly ?? false,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            obscureText: widget.obscureText ?? false,
            obscuringCharacter: widget.obscuringCharacter ?? '•',
            keyboardType: widget.keyboardType,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textColor),
            decoration: InputDecoration(
              fillColor: bgColor,
              filled: true,
              hintText: widget.hintText,
              hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
              errorStyle: TextStyle(fontSize: 12.sp, color: AppColor.cRedText),
              suffixIcon: widget.suffix,
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: borderColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColor.cRedText),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
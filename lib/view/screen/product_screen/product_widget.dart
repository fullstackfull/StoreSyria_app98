// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/images.dart';
import '../../widget/icon_and_image.dart';

Widget allProductsListItemWidget({
  required BuildContext context,
  required String imageUrl,
  required String categoryName,
  required String productName,
  required String price,
  String? salePrice,
  required String stock,
  String? stockStatus,
  double? rating,
  bool? hasVariant,
  VoidCallback? onTap,
  VoidCallback? viewFun,
  VoidCallback? deleteFun,
  VoidCallback? changeFun,
  bool showChangeAction = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final cardColor = isDark
      ? const Color(0xFF1E1E1E)
      : Colors.white;

  final textColor = isDark
      ? Colors.white
      : const Color(0xFF1F1F1F);

  final subTextColor = isDark
      ? const Color(0xFF9CA3AF)
      : const Color(0xFF6B7280);

  final accentColor = AppColor.themeGreenColor;
  final dangerColor = Color(0xFFEF4444);

  final variant = hasVariant == true;

  final isValidImageUrl = imageUrl.trim().isNotEmpty &&
      (imageUrl.startsWith('http') ||
          imageUrl.startsWith('assets'));

  final isInStock = stockStatus == 'in_stock';

  final originalPrice = double.tryParse(price) ?? 0;
  final discountedPrice = double.tryParse(salePrice ?? '') ?? 0;

  final hasDiscount = !variant &&
      salePrice != null &&
      salePrice!.isNotEmpty &&
      originalPrice > 0 &&
      discountedPrice > 0 &&
      discountedPrice != originalPrice;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(.08)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= IMAGE =================

            AspectRatio(
              aspectRatio: 1.05,
              child: Stack(
                fit: StackFit.expand,
                children: [

                  isValidImageUrl
                      ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: isDark
                          ? Colors.white.withOpacity(.05)
                          : const Color(0xFFF3F4F6),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark
                          ? Colors.white.withOpacity(.05)
                          : const Color(0xFFF3F4F6),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: subTextColor,
                        size: 24.sp,
                      ),
                    ),
                  )
                      : Container(
                    color: isDark
                        ? Colors.white.withOpacity(.05)
                        : const Color(0xFFF3F4F6),
                    child: Icon(
                      Icons.image_outlined,
                      color: subTextColor,
                      size: 28.sp,
                    ),
                  ),

                  // ================= OUT OF STOCK =================

                  if (!isInStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(.30),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.75),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: dangerColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  'out_of_stock'.tr,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ================= DISCOUNT =================

                  if (hasDiscount)
                    Positioned(
                      top: 7.h,
                      left: 7.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: dangerColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '-${((originalPrice - discountedPrice) /
                              originalPrice *
                              100)
                              .round()}%',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // ================= MENU =================

                  if (viewFun != null ||
                      (showChangeAction && changeFun != null) ||
                      deleteFun != null)
                    Positioned(
                      top: 7.h,
                      right: 7.w,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        tooltip: '',
                        offset: Offset(0, 34.h),
                        icon: Container(
                          width: 29.w,
                          height: 29.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 16.sp,
                            color: textColor,
                          ),
                        ),
                        elevation: 4,
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        onSelected: (value) {
                          if (value == 'view') {
                            viewFun?.call();
                          } else if (value == 'change') {
                            changeFun?.call();
                          } else if (value == 'delete') {
                            deleteFun?.call();
                          }
                        },
                        itemBuilder: (_) => [
                          if (viewFun != null)
                            PopupMenuItem(
                              value: 'view',
                              height: 38.h,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.visibility_outlined,
                                    size: 16.sp,
                                    color: subTextColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'view'.tr,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (showChangeAction && changeFun != null)
                            PopupMenuItem(
                              value: 'change',
                              height: 38.h,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 16.sp,
                                    color: accentColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'change'.tr,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (deleteFun != null)
                            PopupMenuItem(
                              value: 'delete',
                              height: 38.h,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16.sp,
                                    color: dangerColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'delete'.tr,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: dangerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ================= CONTENT =================

            Padding(
              padding: EdgeInsets.fromLTRB(
                10.w,
                7.h,
                10.w,
                8.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // CATEGORY

                  if (categoryName.trim().isNotEmpty)
                    Text(
                      categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),

                  // PRODUCT NAME

                  SizedBox(height: 2.h),

                  Text(
                    productName.trim().isNotEmpty
                        ? productName
                        : 'no_product_name'.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  // ================= RATING + VARIANT =================

                  Row(
                    children: [

                      Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: Colors.amber,
                      ),

                      SizedBox(width: 3.w),

                      Text(
                        (rating ?? 0).toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),

                      if (variant) ...[
                        SizedBox(width: 7.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(.10),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            'has_variant'.tr,
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 5.h),

                  // ================= STOCK =================

                  Row(
                    children: [

                      Icon(
                        Icons.inventory_2_outlined,
                        size: 13.sp,
                        color: isInStock
                            ? accentColor
                            : dangerColor,
                      ),

                      SizedBox(width: 4.w),

                      Expanded(
                        child: Text(
                          '${'stock'.tr}: $stock',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isInStock
                              ? accentColor.withOpacity(.10)
                              : dangerColor.withOpacity(.10),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          isInStock
                              ? 'in_stock'.tr
                              : 'out_of_stock'.tr,
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: isInStock
                                ? accentColor
                                : dangerColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ================= PRICE =================

                  if (!variant && originalPrice > 0) ...[
                    SizedBox(height: 5.h),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        Text(
                          '\$${hasDiscount ? discountedPrice.toStringAsFixed(2) : originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),

                        if (hasDiscount) ...[
                          SizedBox(width: 5.w),
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: subTextColor,
                              decoration:
                              TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// باقي الكود (AddProductTextField و addAttachmentWidget) يبقى كما هو دون تغيير
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
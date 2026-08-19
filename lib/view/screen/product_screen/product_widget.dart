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
  required String productId,
  required String productName,
  required String price,
  required int status,
  required bool trackStock,
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

  // ==================================================
  // COLORS
  // ==================================================

  final cardColor = isDark
      ? const Color(0xFF1E1E1E)
      : Colors.white;

  final textColor = isDark
      ? Colors.white
      : const Color(0xFF1F1F1F);

  final subTextColor = isDark
      ? const Color(0xFF9CA3AF)
      : const Color(0xFF6B7280);

  final borderColor = isDark
      ? Colors.white.withOpacity(.08)
      : const Color(0xFFE5E7EB);

  final imageBackground = isDark
      ? Colors.white.withOpacity(.05)
      : const Color(0xFFF3F4F6);

  final accentColor = AppColor.themeGreenColor;

  const dangerColor = Color(0xFFEF4444);
  const warningColor = Colors.orange;

  // ==================================================
  // PRODUCT LOGIC
  // ==================================================

  final variant = hasVariant == true;

  final isHidden = status == 0;

  final stockValue = stockStatus ?? '';

  final isInStock = stockValue == 'in_stock';

  final isBackorder = stockValue == 'on_backorder';

  final isOutOfStock =
      stockValue == 'out_of_stock' ||
          stockValue == '0';

  // ==================================================
  // PRICE LOGIC
  // ==================================================

  final finalPrice = double.tryParse(price) ?? 0;

  final sale = double.tryParse(salePrice ?? '') ?? 0;

  final hasDiscount =
      !variant &&
          sale > 0 &&
          finalPrice > 0 &&
          sale != finalPrice;

  final displayPrice =
  hasDiscount ? sale : finalPrice;

  // ==================================================
  // IMAGE
  // ==================================================

  final isValidImageUrl =
      imageUrl.trim().isNotEmpty &&
          (
              imageUrl.startsWith('http') ||
                  imageUrl.startsWith('assets')
          );

  // ==================================================
  // STOCK COLOR
  // ==================================================

  Color stockColor() {
    if (variant || !trackStock) {
      return subTextColor;
    }

    if (isInStock) {
      return accentColor;
    }

    if (isBackorder) {
      return warningColor;
    }

    return dangerColor;
  }

  Color statusColor() {
    if (variant) {
      return accentColor;
    }

    if (isInStock) {
      return accentColor;
    }

    if (isBackorder) {
      return warningColor;
    }

    return dangerColor;
  }

  Color statusBackgroundColor() {
    if (variant) {
      return accentColor.withOpacity(.10);
    }

    if (isInStock) {
      return accentColor.withOpacity(.10);
    }

    if (isBackorder) {
      return warningColor.withOpacity(.10);
    }

    return dangerColor.withOpacity(.10);
  }

  // ==================================================
  // MENU
  // ==================================================

  final hasMenu =
      viewFun != null ||
          (showChangeAction && changeFun != null) ||
          deleteFun != null;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(.025),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==================================================
            // IMAGE
            // ==================================================

            AspectRatio(
              aspectRatio: 1.18,
              child: Stack(
                fit: StackFit.expand,
                children: [

                  // ==================================================
                  // PRODUCT IMAGE
                  // ==================================================

                  Hero(
                    tag: 'product_image_$productId',
                    child: isValidImageUrl
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) {
                        return Container(
                          color: imageBackground,
                          child: Center(
                            child: SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: accentColor,
                              ),
                            ),
                          ),
                        );
                      },
                      errorWidget: (_, __, ___) {
                        return Container(
                          color: imageBackground,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: subTextColor,
                            size: 24.sp,
                          ),
                        );
                      },
                    )
                        : Container(
                      color: imageBackground,
                      child: Icon(
                        Icons.image_outlined,
                        color: subTextColor,
                        size: 24.sp,
                      ),
                    ),
                  ),

                  // ==================================================
                  // HIDDEN BADGE
                  // ==================================================

                  if (isHidden)
                    Positioned(
                      top: 7.h,
                      left: 7.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.72),
                          borderRadius:
                          BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Icon(
                              Icons.visibility_off_outlined,
                              size: 11.sp,
                              color: Colors.white,
                            ),

                            SizedBox(width: 4.w),

                            Text(
                              'hidden'.tr,
                              style: TextStyle(
                                fontSize: 7.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ==================================================
                  // OUT OF STOCK OVERLAY
                  // ==================================================

                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(.25),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.72),
                              borderRadius:
                              BorderRadius.circular(15.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Container(
                                  width: 5.w,
                                  height: 5.w,
                                  decoration:
                                  const BoxDecoration(
                                    color: dangerColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                SizedBox(width: 4.w),

                                Text(
                                  'out_of_stock'.tr,
                                  style: TextStyle(
                                    fontSize: 8.sp,
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

                  // ==================================================
                  // MENU
                  // ==================================================

                  if (hasMenu)
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        tooltip: '',
                        offset: Offset(0, 30.h),

                        icon: Container(
                          width: 26.w,
                          height: 26.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.black.withOpacity(.15),
                                blurRadius: 4,
                                offset:
                                const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 15.sp,
                            color: Colors.black,
                          ),
                        ),

                        elevation: 3,

                        color: cardColor,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(9.r),
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
                            PopupMenuItem<String>(
                              value: 'view',
                              height: 36.h,
                              child: Row(
                                children: [

                                  Icon(
                                    Icons.visibility_outlined,
                                    size: 15.sp,
                                    color: subTextColor,
                                  ),

                                  SizedBox(width: 7.w),

                                  Text(
                                    'view'.tr,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (showChangeAction &&
                              changeFun != null)
                            PopupMenuItem<String>(
                              value: 'change',
                              height: 36.h,
                              child: Row(
                                children: [

                                  Icon(
                                    Icons.edit_outlined,
                                    size: 15.sp,
                                    color: accentColor,
                                  ),

                                  SizedBox(width: 7.w),

                                  Text(
                                    'change'.tr,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (deleteFun != null)
                            PopupMenuItem<String>(
                              value: 'delete',
                              height: 36.h,
                              child: Row(
                                children: [

                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 15.sp,
                                    color: dangerColor,
                                  ),

                                  SizedBox(width: 7.w),

                                  Text(
                                    'delete'.tr,
                                    style: TextStyle(
                                      fontSize: 11.sp,
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

            // ==================================================
            // CONTENT
            // ==================================================

            Padding(
              padding: EdgeInsets.fromLTRB(
                9.w,
                7.h,
                9.w,
                8.h,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // ==================================================
                  // CATEGORY
                  // ==================================================

                  if (categoryName.trim().isNotEmpty)
                    Text(
                      categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),

                  SizedBox(height: 2.h),

                  // ==================================================
                  // PRODUCT NAME
                  // ==================================================

                  Text(
                    productName.trim().isNotEmpty
                        ? productName
                        : 'no_product_name'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  // ==================================================
                  // RATING + VARIANT
                  // ==================================================

                  Row(
                    children: [

                      Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: Colors.amber,
                      ),

                      SizedBox(width: 2.w),

                      Text(
                        (rating ?? 0).toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),


                  SizedBox(height: 6.h),

                  // ==================================================
                  // STOCK
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [

                            Icon(
                              Icons.inventory_2_outlined,
                              size: 12.sp,
                              color: stockColor(),
                            ),

                            SizedBox(width: 4.w),

                            Expanded(
                              child: Text(
                                variant
                                    ? '${'stock'.tr}: -'
                                    : !trackStock
                                    ? '${'stock'.tr}: -'
                                    : '${'stock'.tr}: $stock',
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  fontWeight:
                                  FontWeight.w500,
                                  color: subTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 5.w),

                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                            statusBackgroundColor(),
                            borderRadius:
                            BorderRadius.circular(5.r),
                          ),
                          child: Text(
                                isInStock
                                ? 'in_stock'.tr
                                : isBackorder
                                ? 'on_backorder'.tr
                                : 'out_of_stock'.tr,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight:
                              FontWeight.w700,
                              color: statusColor(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ==================================================
                  // NOT TRACKED
                  // ==================================================

                  if (!trackStock) ...[
                    SizedBox(height: 5.h),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                        subTextColor.withOpacity(.08),
                        borderRadius:
                        BorderRadius.circular(5.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Icon(
                              trackStock
                                  ? Icons.track_changes_rounded
                                  : Icons.do_not_disturb_on_outlined,
                            size: 11.sp,
                            color: subTextColor,
                          ),

                          SizedBox(width: 4.w),

                          Text(
                            trackStock ?
                            'tracked'.tr :
                            'not_tracked'.tr,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight:
                              FontWeight.w600,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ==================================================
                  // PRICE
                  // ==================================================

                  if (!variant && displayPrice > 0) ...[
                    SizedBox(height: 7.h),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [

                        Text(
                          '${displayPrice.toStringAsFixed(2)}\$',
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight:
                            FontWeight.w800,
                            color: textColor,
                          ),
                        ),

                        if (hasDiscount) ...[
                          SizedBox(width: 6.w),

                          Flexible(
                            child: Text(
                              '${finalPrice.toStringAsFixed(2)}\$',
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight:
                                FontWeight.w500,
                                color: subTextColor,
                                decoration:
                                TextDecoration
                                    .lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // ==================================================
                  // VARIANT MESSAGE
                  // ==================================================

                  if (variant) ...[
                    SizedBox(height: 5.h),

                    Text(
                      'multiple_variants'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
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
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ),
  );
}

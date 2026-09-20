import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import '../../../utils/images.dart';
import '../../new_widgets/network_image_widget.dart';
import '../../new_widgets/pop_up_menu.dart';
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


  final variant = hasVariant == true;

  final isHidden = status == 0;

  final stockValue = stockStatus ?? '';

  final isInStock = stockValue == 'in_stock';

  final isBackorder = stockValue == 'on_backorder';

  final isOutOfStock =
      stockValue == 'out_of_stock' || stockValue == '0';

  final finalPrice = double.tryParse(price) ?? 0;
  final displayPrice = finalPrice;


  final isValidImageUrl =
      imageUrl.trim().isNotEmpty &&
          (
              imageUrl.startsWith('http') ||
                  imageUrl.startsWith('assets')
          );

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
          // border: Border.all(color: AppColor.themeNavyBlueColor.withOpacity(0.3)),
          color: cardColor,
          borderRadius: BorderRadius.circular(10.r),
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
            AspectRatio(
              aspectRatio: 1.18,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_image_$productId',
                    child: isValidImageUrl
                        ? productNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      backgroundColor: imageBackground,
                      iconColor: subTextColor,
                      loadingColor: accentColor,
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

                  if (viewFun != null ||
                      (showChangeAction && changeFun != null) ||
                      deleteFun != null)
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: AppPopupMenu(
                        color: Colors.white,
                        viewFun: viewFun,
                        changeFun: showChangeAction
                            ? changeFun
                            : null,
                        deleteFun: deleteFun,
                      ),
                    ),
                ],
              ),
            ),

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
                  if (categoryName.trim().isNotEmpty)
                    Text(
                      categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),

                  SizedBox(height: 2.h),

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
                  if (!variant && displayPrice > 0) ...[
                    SizedBox(height: 7.h),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [

                        Text(
                          '${displayPrice.toStringAsFixed(2)}',
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
                      ],
                    ),
                  ],

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

  final bool isEditMode;
  final String? htmlContent;

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
    this.isEditMode = false,
    this.htmlContent,
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

    // Colors
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
          // Label
          if (widget.labelText != null && widget.labelText!.isNotEmpty)
            Text(
              widget.labelText!,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade300 : AppColor.cDarkGreyFont
              ),
            ),

          if (widget.labelText != null && widget.labelText!.isNotEmpty)
            verticalSpace(15.h),

          if (widget.isEditMode && widget.htmlContent != null && widget.htmlContent!.isNotEmpty)

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: borderColor),
              ),
              child: Html(
                data: widget.htmlContent,
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

          // Manual FormField wrapper: we render the error text ourselves
          // (instead of relying on TextFormField's built-in errorText),
          // using the exact same horizontal inset as the field's own
          // content padding. This guarantees the error message lines up
          // perfectly under the input text instead of looking shifted.
            FormField<String>(
              initialValue: widget.controller?.text,
              validator: widget.validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              builder: (FormFieldState<String> field) {
                final hasError = field.hasError;
                final activeBorderColor = hasError ? AppColor.cRedText : borderColor;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: widget.controller,
                      cursorColor: accentColor,
                      autofocus: widget.autofocus ?? false,
                      focusNode: _focus,
                      maxLines: widget.maxLines ?? 1,
                      readOnly: widget.readOnly ?? false,
                      onChanged: (value) {
                        field.didChange(value);
                        widget.onChanged?.call(value);
                      },
                      onTap: widget.onTap,
                      obscureText: widget.obscureText ?? false,
                      obscuringCharacter: widget.obscuringCharacter ?? '•',
                      keyboardType: widget.keyboardType,
                      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
                      textInputAction: widget.textInputAction,
                      autocorrect: widget.autocorrect ?? true,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textColor),
                      decoration: InputDecoration(
                        fillColor: bgColor,
                        filled: true,
                        hintText: widget.hintText, // يظهر الهينت هنا
                        hintStyle: TextStyle(fontSize: 14.sp, color: hintColor),
                        suffixIcon: widget.suffix,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: activeBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: activeBorderColor),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: hasError ? AppColor.cRedText : accentColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (hasError)
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: 20.w, top: 6.h),
                        child: Text(
                          field.errorText ?? '',
                          style: TextStyle(fontSize: 12.sp, color: AppColor.cRedText, height: 1.3),
                        ),
                      ),
                  ],
                );
              },
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
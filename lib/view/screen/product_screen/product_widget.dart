import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import '../../../utils/helper.dart';
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

  final cardColor = isDark ? const Color(0xFF1B1C20) : Colors.white;
  final textColor = isDark ? Colors.white : const Color(0xFF111827);
  final subTextColor =
  isDark ? const Color(0xFF9297A1) : const Color(0xFF8A8F98);
  final imageBg = isDark ? const Color(0xFF25272C) : const Color(0xFFF6F7F9);
  final dividerColor =
  isDark ? Colors.white.withOpacity(.07) : const Color(0xFFEEF0F3);

  final accentColor = AppColor.themeGreenColor;
  const dangerColor = Color(0xFFEF4444);
  const warningColor = Color(0xFFF59E0B);

  final variant = hasVariant == true;
  final isHidden = status == 0;

  final stockValue = stockStatus ?? '';
  final isInStock = stockValue == 'in_stock';
  final isBackorder = stockValue == 'on_backorder';
  final isOutOfStock = stockValue == 'out_of_stock' || stockValue == '0';

  final displayPrice = parsePriceSafe(price);

  final isValidImageUrl = imageUrl.trim().isNotEmpty &&
      (imageUrl.startsWith('http') || imageUrl.startsWith('assets'));

  final Color statusColor = (variant || isInStock)
      ? accentColor
      : isBackorder
      ? warningColor
      : dangerColor;

  final String statusText = isInStock
      ? 'in_stock'.tr
      : isBackorder
      ? 'on_backorder'.tr
      : 'out_of_stock'.tr;

  final String stockText =
  (variant || !trackStock) ? '${'stock'.tr}: -' : '${'stock'.tr}: $stock';

  // نص لا يُقطع: يصغّر تلقائياً إذا ضاق المكان
  Widget fitText(
      String text,
      TextStyle style, {
        Alignment alignment = Alignment.centerLeft,
      }) {
    return Align(
      alignment: alignment,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(text, maxLines: 1, softWrap: false, style: style),
      ),
    );
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: const Color(0xFF111827).withOpacity(.06),
              blurRadius: 22,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================== IMAGE =====================
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: imageBg),

                      Opacity(
                        opacity: isOutOfStock ? .45 : 1,
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Hero(
                            tag: 'product_image_$productId',
                            child: isValidImageUrl
                                ? productNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              backgroundColor: Colors.transparent,
                              iconColor: subTextColor,
                              loadingColor: accentColor,
                            )
                                : Icon(Icons.image_outlined,
                                color: subTextColor, size: 28.sp),
                          ),
                        ),
                      ),

                      // ===== OUT OF STOCK (center of image) =====
                      if (isOutOfStock)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.78),
                                      borderRadius:
                                      BorderRadius.circular(30.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(.18),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6.w,
                                          height: 6.w,
                                          decoration: const BoxDecoration(
                                            color: dangerColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 7.w),
                                        Text(
                                          'out_of_stock'.tr,
                                          maxLines: 1,
                                          softWrap: false,
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
                          ),
                        ),

                      // hidden (top-left)
                      if (isHidden)
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: _overlayChip(
                            label: 'hidden'.tr,
                            icon: Icons.visibility_off_outlined,
                          ),
                        ),

                      // menu (top-right)
                      if (viewFun != null ||
                          (showChangeAction && changeFun != null) ||
                          deleteFun != null)
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: AppPopupMenu(
                            color: Colors.white,
                            viewFun: viewFun,
                            changeFun: showChangeAction ? changeFun : null,
                            deleteFun: deleteFun,
                          ),
                        ),

                      // rating (bottom-left)
                      Positioned(
                        left: 8.w,
                        bottom: 8.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.95),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 13.sp, color: Colors.amber),
                              SizedBox(width: 3.w),
                              Text(
                                (rating ?? 0).toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ===================== CONTENT =====================
            Padding(
              padding: EdgeInsets.fromLTRB(13.w, 11.h, 13.w, 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) category
                  if (categoryName.trim().isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: fitText(
                        categoryName.trim().toUpperCase(),
                        TextStyle(
                          fontSize: 9.sp,
                          letterSpacing: .9,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // 2) name
                  SizedBox(
                    width: double.infinity,
                    child: fitText(
                      productName.trim().isNotEmpty
                          ? productName
                          : 'no_product_name'.tr,
                      TextStyle(
                        fontSize: 14.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.2,
                        color: textColor,
                      ),
                    ),
                  ),

                  SizedBox(height: 9.h),
                  Divider(height: 1, color: dividerColor),
                  SizedBox(height: 9.h),

                  // 3) price | status pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: fitText(
                          variant
                              ? 'multiple_variants'.tr
                              : (displayPrice > 0 ? price : '—'),
                          TextStyle(
                            fontSize: variant ? 10.5.sp : 15.sp,
                            fontWeight:
                            variant ? FontWeight.w500 : FontWeight.w800,
                            letterSpacing: variant ? 0 : -.3,
                            color: variant ? subTextColor : textColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(.10),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              statusText,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // 4) stock qty | not tracked
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 13.sp, color: subTextColor),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: fitText(
                          stockText,
                          TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ),
                      if (!trackStock) ...[
                        SizedBox(width: 4.w),
                        Flexible(
                          child: fitText(
                            'not_tracked'.tr,
                            TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: subTextColor.withOpacity(.8),
                            ),
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _overlayChip({
  required String label,
  IconData? icon,
  Color? dotColor,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.72),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 12.sp, color: Colors.white),
        if (dotColor != null)
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
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
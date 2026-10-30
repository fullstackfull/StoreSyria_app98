import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import '../../../utils/helper.dart';
import '../../../utils/images.dart';
import '../../../utils/text_style.dart';
import '../../new_widgets/network_image_widget.dart';
import '../../new_widgets/pop_up_menu.dart';
import '../../widget/icon_and_image.dart';
import 'package:store_go_app/core/stock/stock_state.dart';

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
  int? outOfStockThreshold,
  double? rating,
  bool? hasVariant,
  VoidCallback? onTap,
  VoidCallback? viewFun,
  VoidCallback? deleteFun,
  VoidCallback? changeFun,
  bool showChangeAction = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final cardColor = isDark ? const Color(0xFF18263F) : Colors.white;
  final textColor = isDark ? Colors.white : const Color(0xFF111827);
  final subTextColor =
  isDark ? const Color(0xFFA9B8D0) : const Color(0xFF8A8F98);
  final imageBg = isDark ? const Color(0xFF213252) : const Color(0xFFF6F7F9);
  final dividerColor =
  isDark ? Colors.white.withValues(alpha: .07) : const Color(0xFFEEF0F3);

  final accentColor = AppColor.themeGreenColor;
  const dangerColor = Color(0xFFEF4444);
  const warningColor = Color(0xFFF59E0B);

  final variant = hasVariant == true;
  final isHidden = status == 0;

  // P2-07-10. ONE RULE, SHARED WITH THE WEB. This read `stock_status` unconditionally; the web
  // ignores that column for a TRACKED product and derives the badge from the live quantity. The
  // column is never recomputed when stock drains, so the app was calling sold-out products
  // "In stock" while the web called them "Out of stock". See resolveStockState().
  final stockState = resolveStockState(
    hasVariant: variant,
    trackStock: trackStock,
    productStock: int.tryParse(stock),
    stockStatus: stockStatus,
    outOfStockThreshold: outOfStockThreshold,
  );

  final isInStock = stockState == StockState.inStock;
  final isBackorder = stockState == StockState.onBackorder;
  final isOutOfStock = stockState == StockState.outOfStock;

  final displayPrice = parsePriceSafe(price);

  final isValidImageUrl = imageUrl.trim().isNotEmpty &&
      (imageUrl.startsWith('http') || imageUrl.startsWith('assets'));

  final Color statusColor = (stockState == StockState.inVariant || isInStock)
      ? accentColor
      : isBackorder
      ? warningColor
      : dangerColor;

  final String statusText = isInStock
      ? 'in_stock'.tr
      : isBackorder
      ? 'on_backorder'.tr
      : 'out_of_stock'.tr;

  final String stockText = (stockState == StockState.inVariant || !trackStock)
      ? '${'stock'.tr}: -'
      : '${'stock'.tr}: $stock';

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
              color: const Color(0xFF111827).withValues(alpha: .06),
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
                                      color: Colors.black.withValues(alpha: .78),
                                      borderRadius:
                                      BorderRadius.circular(30.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: .18),
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

                      // hidden (top-start)
                      if (isHidden)
                        PositionedDirectional(
                          top: 8.h,
                          start: 8.w,
                          child: _overlayChip(
                            label: 'hidden'.tr,
                            icon: Icons.visibility_off_outlined,
                          ),
                        ),

                      // menu (top-end)
                      if (viewFun != null ||
                          (showChangeAction && changeFun != null) ||
                          deleteFun != null)
                        PositionedDirectional(
                          top: 4.h,
                          end: 4.w,
                          child: AppPopupMenu(
                            color: Colors.white,
                            viewFun: viewFun,
                            changeFun: showChangeAction ? changeFun : null,
                            deleteFun: deleteFun,
                          ),
                        ),

                      // rating (bottom-start)
                      PositionedDirectional(
                        start: 8.w,
                        bottom: 8.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .95),
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
                            color: statusColor.withValues(alpha: .10),
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
                              color: subTextColor.withValues(alpha: .8),
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
      color: Colors.black.withValues(alpha: .72),
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

class AddProductTextField extends StatelessWidget {
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
  final String? prefix; // نص بادئة (مثل رمز العملة) إذا ما في icon
  final IconData? icon; // أيقونة البادئة بنفس تصميم AppTextField
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
    this.icon,
    this.suffix,
    this.focusNode,
    this.maxLines,
    this.isEditMode = false,
    this.htmlContent,
  }) : super(key: key);

  static const Color navyBlue = Color(0xFF172C4E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? const Color(0xFF18263F) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF172C4E);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF687386);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6EC);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final hasLabel = widget_isNotEmpty(labelText);
    final showHtml = isEditMode && widget_isNotEmpty(htmlContent);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLabel) ...[
            Text(labelText!, style: pSemiBold14),
            const SizedBox(height: 8),
          ],

          if (showHtml)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Html(
                data: htmlContent,
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
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus ?? false,
              readOnly: readOnly ?? false,
              onTap: onTap,
              onChanged: onChanged,
              validator: validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization ?? TextCapitalization.none,
              autocorrect: autocorrect ?? true,
              obscureText: obscureText ?? false,
              obscuringCharacter: obscuringCharacter ?? '•',
              maxLines: (obscureText ?? false) ? 1 : (maxLines ?? 1),
              cursorColor: navyBlue,
              style: TextStyle(fontSize: 16, color: textColor),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 13, color: secondaryTextColor),

                prefixIcon: icon != null
                    ? Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11.r),
                      color: navyBlue.withValues(alpha: 0.07),
                    ),
                    child: Icon(icon, color: navyBlue, size: 22.w),
                  ),
                )
                    : null,

                // نص بادئة إذا ما في أيقونة
                prefixText: (icon == null && widget_isNotEmpty(prefix)) ? prefix : null,
                prefixStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryTextColor,
                ),

                suffixIcon: suffix,

                filled: true,
                fillColor: backgroundColor,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                errorStyle: const TextStyle(fontSize: 11, color: Colors.red),

                border: border(borderColor),
                enabledBorder: border(borderColor),
                disabledBorder: border(borderColor),
                focusedBorder: border(navyBlue, 1.5),
                errorBorder: border(Colors.red),
                focusedErrorBorder: border(Colors.red, 1.5),
              ),
            ),
        ],
      ),
    );
  }

  static bool widget_isNotEmpty(String? s) => s != null && s.isNotEmpty;
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
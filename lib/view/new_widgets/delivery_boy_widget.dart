import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/delivery_boy_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';

Widget deliveryBoyWidget({
  required BuildContext context,
  DeliveryBoyData? deliveryBoy,
  VoidCallback? onTap,
  VoidCallback? changeFun,
  String? changeText2,
  VoidCallback? changeFun2,
  VoidCallback? deleteFun,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final cardColor = isDark ? DarkThemeColor.cCardBackground : Colors.white;

  final textColor = isDark ? DarkThemeColor.cText : const Color(0xFF0F1A2E);

  final subTextColor = isDark
      ? DarkThemeColor.cSecondaryText
      : const Color(0xFF777777);

  final name = deliveryBoy?.name?.replaceAll('"', '').trim() ?? '';

  final email = deliveryBoy?.email?.replaceAll('"', '').trim() ?? '';

  final contact = deliveryBoy?.contact?.replaceAll('"', '').trim() ?? '';

  final commissionPercentage =
      deliveryBoy?.commissionPercentage?.replaceAll('"', '').trim() ?? '0';

  final bool isCommissionEnabled = deliveryBoy?.isCommissionEnabled == 1;

  final createdAt = deliveryBoy?.createdAt?.replaceAll('"', '').trim() ?? '';

  final displayName = name.isNotEmpty ? name : 'no_delivery_boy_name'.tr;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 8.h),
      decoration: BoxDecoration(
        color: cardColor,
        // P2.5-FLUTTER-FRAMING. IN LIGHT MODE THIS CARD IS WHITE ON A WHITE PAGE.
        //
        // `LightThemeColor.cBackGround` is `0xffFFFFFF` (colors.dart:72) and this card's fill is
        // `Colors.white`, so the only thing separating the card from the page was a shadow at
        // alpha .035 — MEASURED off the capture at 1.08:1, which is no edge at all.
        //
        // THIS IS THE READING `docs/design/GOLDEN-BASELINE-FRAMING.md` MADE FIRST AND THEN
        // RETRACTED, and the retraction was right about dark and wrong about light. In dark the
        // two tokens really are different (`cCardBackground` #18263F on `cBackGround` #0F1A2E),
        // though only 1.15:1 — enough over a large area. In light they are the same colour. The
        // defect was invisible until the card stopped covering the whole page, which is why it
        // surfaced with the framing repair rather than before it.
        //
        // A hairline in the app's OWN token, light only: `cBorder` is 1.43:1 on white. Dark keeps
        // its fill difference and gets no border, because an outline there fights a surface that
        // is already reading.
        border: isDark
            ? null
            : Border.all(color: LightThemeColor.cBorder, width: 1),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .10 : .035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
        // P2.5-FLUTTER-FRAMING. `MainAxisSize.min`, and it is not tidying.
        //
        // A `Column` defaults to `MainAxisSize.max` — "be as tall as the incoming maxHeight". The
        // `Container` above it has a width and no height, so it sizes to this child; given any
        // BOUNDED box the card therefore stretched to fill it. MEASURED: 800.0px in an 800px
        // box against 120.0px in a scrolling list.
        //
        // IT LOOKED RIGHT IN THE APP FOR A REASON THAT IS NOT THIS WIDGET'S DOING. The card is
        // rendered inside a scrolling list (customer_screen.dart:282-287), where the main axis is
        // UNBOUNDED, so `MainAxisSize.max` has nothing to expand into. The card was content-height
        // by accident of its surroundings, and would stretch in a sheet, a grid cell or a
        // fixed-height box.
        //
        // WHERE IT WAS NOT RIGHT: the golden baselines. 98% of every captured image was this
        // card's own fill, the scaffold background was absent from the light capture altogether,
        // and a height regression was invisible because the comparison could not see a difference
        // in a dimension the harness had pinned to the viewport.
        // docs/design/GOLDEN-BASELINE-FRAMING.md attributed that to `goldenHost()`'s tight
        // constraints and proposed `Align` alone. That change was applied and the baselines
        // regenerated and THE MEASUREMENT DID NOT MOVE — loose constraints are no help while the
        // Column still chooses the maximum. Both halves are needed.
        //
        // NOTHING A MERCHANT SEES CHANGES: card_intrinsic_height_test.dart asserts the bounded and
        // the list measurement now agree, so the height here is the height the app has always
        // drawn.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              AppPopupMenu(
                changeFun2: changeFun2,
                changeText2: changeText2,
                changeFun: changeFun,
                deleteFun: deleteFun,
                changeText: 'change'.tr,
                deleteText: 'delete'.tr,
              ),
            ],
          ),
          // SAME TREATMENT AS THE CUSTOMER CARD BESIDE THIS ONE: no row is drawn for a
          // value the delivery man does not have, and the Latin runs are laid out LTR
          // so an Arabic page does not reorder an address or a phone number.
          if (email.isNotEmpty) ...[
            _deliveryBoyInfoRow(
              context: context,
              icon: Icons.email_outlined,
              text: email,
              textColor: subTextColor,
              iconColor: AppColor.themeNavyBlueColor,
            ),
            SizedBox(height: 5.h),
          ],

          if (contact.isNotEmpty) ...[
            _deliveryBoyInfoRow(
              context: context,
              icon: Icons.phone_outlined,
              text: contact,
              textColor: subTextColor,
              iconColor: AppColor.themeNavyBlueColor,
            ),
            SizedBox(height: 5.h),
          ],

          if (commissionPercentage.isNotEmpty) ...[
            SizedBox(height: 5.h),
            Row(
              children: [
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: AppColor.themeNavyBlueColor.withValues(alpha: .07),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.percent_outlined,
                    size: 15.sp,
                    color: AppColor.themeNavyBlueColor,
                  ),
                ),

                SizedBox(width: 8.w),

                Text(
                  '${'commission:'.tr} $commissionPercentage%',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),

                const Spacer(),

                statusPill(
                  label: isCommissionEnabled ? 'enabled'.tr : 'disabled'.tr,
                  isActive: isCommissionEnabled,
                ),
              ],
            ),
          ],

          if (createdAt.isNotEmpty) ...[
            SizedBox(height: 5.h),
            _deliveryBoyInfoRow(
              context: context,
              icon: Icons.calendar_today_outlined,
              text: dateFormatted(
                date: createdAt,
                formatType: formatForDateTime(FormatType.date),
              ),
              textColor: subTextColor,
              iconColor: AppColor.themeNavyBlueColor,
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _deliveryBoyInfoRow({
  required BuildContext context,
  required IconData icon,
  required String text,
  required Color textColor,
  required Color iconColor,
  TextDirection? textDirection,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: .07),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15.sp, color: iconColor),
      ),
      SizedBox(width: 8.w),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: textDirection,
          // `start`, not `end` -- the icon leads the row, so the text belongs beside it
          // in both directions.
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    ],
  );
}

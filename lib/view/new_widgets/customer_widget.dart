import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/customer_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';

Widget customerWidget({
  required BuildContext context,
  CustomerData? customer,
  VoidCallback? onTap,
  VoidCallback? viewFun,
  VoidCallback? changeFun,
  VoidCallback? deleteFun,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final cardColor = isDark ? DarkThemeColor.cCardBackground : Colors.white;

  final textColor = isDark ? DarkThemeColor.cText : const Color(0xFF0F1A2E);

  final subTextColor = isDark
      ? DarkThemeColor.cSecondaryText
      : const Color(0xFF777777);

  final name = customer?.customerInfo?.name?.replaceAll('"', '').trim() ?? '';

  final mobile =
      customer?.customerInfo?.mobile?.replaceAll('"', '').trim() ?? '';

  final orders = customer?.orders ?? 0;

  final city = customer?.city?.replaceAll('"', '').trim() ?? '';

  // THE CUSTOMER'S E-MAIL WAS NEVER ON THIS CARD. The row below carried
  // `Icons.email_outlined` and rendered `city` beside it -- an e-mail icon
  // labelling a place name -- while `CustomerData.email` (customer_model.dart:70,
  // read from the response root at :102) went unread. The merchant web card shows
  // identity first, name then e-mail (customer/grid.blade.php:159), and the
  // delivery-man card in this same folder already pairs the e-mail icon with the
  // e-mail (delivery_boy_widget.dart:92-93). This card was the odd one out.
  //
  // `customer_info` carries ONLY name and mobile (customer_model.dart:130-142); the
  // API puts `email` beside that object, not inside it
  // (Api/DashboardController.php:6128-6132).
  final email = customer?.email?.replaceAll('"', '').trim() ?? '';

  final bool isActive = customer?.status == 1;

  final statusLabel = customer?.statusText?.isNotEmpty == true
      ? customer!.statusText!
      : isActive
      ? 'active'.tr
      : 'inactive'.tr;

  final displayName = name.isNotEmpty ? name : 'no_customer_name'.tr;

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
        // box against 141.0px in a scrolling list.
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  statusPill(label: statusLabel, isActive: isActive),
                  AppPopupMenu(
                    viewFun: viewFun,
                    changeFun: changeFun,
                    deleteFun: deleteFun,
                    viewText: 'view'.tr,
                    changeText: 'change'.tr,
                    deleteText: 'delete'.tr,
                  ),
                ],
              ),
            ],
          ),
          // NO ROW IS DRAWN FOR A VALUE THE CUSTOMER DOES NOT HAVE. Both of the rows
          // above used to render a literal '--' when their field was empty, which is a
          // row that costs a line of the card and tells the merchant nothing. The
          // orders count is the one row that is always meaningful, because zero orders
          // is a real and useful answer.
          if (email.isNotEmpty) ...[
            _customerInfoRow(
              context: context,
              icon: Icons.email_outlined,
              // LTR EVEN IN ARABIC. An address is a Latin run with '@' and '.' in it;
              // laid out RTL the parts reorder and it reads as a different address.
              // The web card answers this with `dir="ltr"` on the same field
              // (customer/grid.blade.php:159); this is that, in Flutter.
              text: email,
              textColor: subTextColor,
              iconColor: AppColor.themeNavyBlueColor,
            ),
            SizedBox(height: 5.h),
          ],

          if (city.isNotEmpty) ...[
            _customerInfoRow(
              context: context,
              // A PLACE ICON FOR A PLACE. `CustomerData.city` is read from
              // `json['state_name']` (customer_model.dart:111), so this row has always
              // been a location -- it was simply wearing the e-mail icon.
              icon: Icons.location_on_outlined,
              text: city,
              textColor: subTextColor,
              iconColor: AppColor.themeNavyBlueColor,
            ),
            SizedBox(height: 5.h),
          ],

          _customerInfoRow(
            context: context,
            icon: Icons.shopping_bag_outlined,
            text: '${'orders'.tr} ${orders.toString()}',
            textColor: subTextColor,
            iconColor: AppColor.themeNavyBlueColor,
          ),

          if (mobile.isNotEmpty) ...[
            SizedBox(height: 5.h),
            _customerInfoRow(
              context: context,
              icon: Icons.phone_outlined,
              // A phone number is a Latin digit run for the same reason as the e-mail.
              text: mobile,
              textColor: subTextColor,
              iconColor: AppColor.themeNavyBlueColor,
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _customerInfoRow({
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
          // `start`, NOT `end`. The row puts its icon first and the text beside it, so
          // the text belongs against the icon in BOTH directions; `TextAlign.end` sent
          // it to the far edge of whatever width the Flexible happened to take.
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

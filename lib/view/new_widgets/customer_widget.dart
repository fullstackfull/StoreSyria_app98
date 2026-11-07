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
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .10 : .035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
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

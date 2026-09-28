import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/delivery_boy_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';

import '../widget/common_snak_bar_widget.dart';

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

  final cardColor =
  isDark ? DarkThemeColor.cCardBackground : Colors.white;

  final textColor =
  isDark ? DarkThemeColor.cText : const Color(0xFF171717);

  final subTextColor =
  isDark ? DarkThemeColor.cSecondaryText : const Color(0xFF777777);

  final name =
      deliveryBoy?.name?.replaceAll('"', '').trim() ?? '';

  final email =
      deliveryBoy?.email?.replaceAll('"', '').trim() ?? '';

  final contact =
      deliveryBoy?.contact?.replaceAll('"', '').trim() ?? '';

  final commissionPercentage =
      deliveryBoy?.commissionPercentage?.replaceAll('"', '').trim() ?? '0';

  final bool isCommissionEnabled = deliveryBoy?.isCommissionEnabled == 1;

  final createdAt = deliveryBoy?.createdAt?.replaceAll('"', '').trim() ?? '';

  final displayName =
  name.isNotEmpty ? name : 'no_delivery_boy_name'.tr;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.fromLTRB(
        18.w,
        6.h,
        18.w,
        8.h,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? .10 : .035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
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
          ),
          _deliveryBoyInfoRow(
            context: context,
            icon: Icons.email_outlined,
            text: email.isNotEmpty ? email : '--',
            textColor: subTextColor,
            iconColor: AppColor.themeNavyBlueColor,
          ),

          SizedBox(height: 5.h),

          _deliveryBoyInfoRow(
            context: context,
            icon: Icons.phone_outlined,
            text: contact.isNotEmpty ? contact : '--',
            textColor: subTextColor,
            iconColor: AppColor.themeNavyBlueColor,
          ),

          if (commissionPercentage.isNotEmpty) ...[
            SizedBox(height: 5.h),
            Row(
              children: [
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: AppColor.themeNavyBlueColor.withOpacity(.07),
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
                  label: isCommissionEnabled
                      ? 'enabled'.tr
                      : 'disabled'.tr,
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
                  date:createdAt,
                  formatType: formatForDateTime(
                    FormatType.date,
                  )),
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
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(.07),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 15.sp,
          color: iconColor,
        ),
      ),
      SizedBox(width: 8.w),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
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

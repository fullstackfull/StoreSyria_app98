import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';

/// The order list's status filter.
///
/// P2-07-12. `orders.delivered_status` holds NINE values, and this offered seven of them. The two
/// it left out are not fulfilment states: 7 is Partially Paid (a payment state) and 8 is Pre Order
/// (an order type), both sharing the column. The web's own filter offers all nine and says why a
/// hand-typed list is the wrong shape (`order/partials/filters.blade.php:12-14`):
///
///   "Typing a list by hand is how a filter ends up offering 0-6 and quietly hiding those orders
///    from the one screen a merchant uses to find them."
///
/// It was not merely hidden here — the API refused it too (`in:0,1,2,3,4,5,6`, so a request for
/// either answered 422), while F29 had already taught the API to RENDER both names. So a merchant
/// could see a partially-paid order in the list and had no way to ask for one.
///
/// THE TWO ARE LABELLED AS WHAT THEY ARE, which is the honesty the web's filter spends an optgroup
/// on: a leading dot marks them as recorded in the same field without being a delivery stage, so
/// the row does not imply a fulfilment step that does not exist.
///
/// The index-to-status mapping is the caller's (`selectedStatus - 1`, index 0 meaning "all"), so
/// these two appended entries become statuses 7 and 8 without touching it.
Widget orderStatusTabsWidget({
  required BuildContext context,
  required int selectedIndex,
  required ValueChanged<int> onChanged,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = AppColor.themeNavyBlueColor;
  final normalTextColor = isDark ? DarkThemeColor.cText : AppColor.cText;

  Widget tab({
    required int index,
    required String label,
  }) {
    final active = selectedIndex == index;

    return GestureDetector(
      onTap: () => onChanged(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : normalTextColor,
          ),
        ),
      ),
    );
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        tab(
          index: 0,
          label: "all_orders".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 1,
          label: "pending".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 2,
          label: "delivered".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 3,
          label: "cancelled".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 4,
          label: "return".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 5,
          label: "confirmed".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 6,
          label: "picked_up".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 7,
          label: "shipped".tr,
        ),
        SizedBox(width: 14.w),
        tab(
          index: 8,
          label: "• ${"partially_paid".tr}",
        ),
        SizedBox(width: 14.w),
        tab(
          index: 9,
          label: "• ${"pre_order".tr}",
        ),
      ],
    ),
  );
}
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';


/// -----------------------------------------------------------------
/// 2) تابات الحالة: "All Orders 120" / "3 New" / "0 Preparing"
/// -----------------------------------------------------------------
Widget orderStatusTabsWidget({
  required BuildContext context,
  required int allCount,
  required int newCount,
  required int preparingCount,
  required String allLabel,
  required String newLabel,
  required String preparingLabel,
  required int selectedIndex,
  required ValueChanged<int> onChanged,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final accent = AppColor.themeNavyBlueColor;
  final normalTextColor = isDark ? DarkThemeColor.cText : AppColor.cText;

  Widget pill({required bool active}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: active ? accent : Colors.transparent,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$allCount",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : normalTextColor,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            allLabel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : normalTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget plainTab({required String count, required String label, required bool active}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: active ? accent : normalTextColor,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: active ? accent : normalTextColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  return Row(
    children: [
      GestureDetector(onTap: () => onChanged(0), child: pill(active: selectedIndex == 0)),
      SizedBox(width: 18.w),
      GestureDetector(
        onTap: () => onChanged(1),
        child: plainTab(count: "$newCount", label: newLabel, active: selectedIndex == 1),
      ),
      SizedBox(width: 18.w),
      GestureDetector(
        onTap: () => onChanged(2),
        child: plainTab(count: "$preparingCount", label: preparingLabel, active: selectedIndex == 2),
      ),
    ],
  );
}

/// -----------------------------------------------------------------
/// 3) صف البحث: خانة البحث + دائرة (Hot/Sort) + زر فلتر
/// -----------------------------------------------------------------


/// -----------------------------------------------------------------
/// 4) بانر "استرجع سلاتك المتروكة"
/// -----------------------------------------------------------------

/// -----------------------------------------------------------------
/// 5) عنوان قسم مع فلتر جانبي، مثال: "Top orders" + "Last 30 days"
/// -----------------------------------------------------------------
Widget sectionHeaderWithFilterWidget({
  required BuildContext context,
  required String title,
  required String filterLabel,
  VoidCallback? onFilterTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final titleColor = isDark ? Colors.white : Colors.black;
  final accent = AppColor.themeNavyBlueColor;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: titleColor),
      ),
      GestureDetector(
        onTap: onFilterTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: accent.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 14.sp, color: accent),
              SizedBox(width: 6.w),
              Text(
                filterLabel,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: accent),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// -----------------------------------------------------------------
/// 6) بادج صغير قابل لإعادة الاستخدام: New / Preparing / Paid ...
/// نوعين: primary (لون التطبيق الأساسي) و success (لون النجاح/الدفع)
/// -----------------------------------------------------------------
enum OrderBadgeType { primary, success, danger }

Widget orderStatusBadgeWidget({
  required String label,
  OrderBadgeType type = OrderBadgeType.primary,
  IconData? icon,
}) {
  Color color;
  switch (type) {
    case OrderBadgeType.success:
      color = AppColor.themeGreenColor;
      break;
    case OrderBadgeType.danger:
      color = AppColor.cRedText;
      break;
    case OrderBadgeType.primary:
      color = AppColor.themeNavyBlueColor;
      break;
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
        ],
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    ),
  );
}

/// -----------------------------------------------------------------
/// 7) كرت "أفضل الطلبات" (Top orders) - يستخدم بسلايدر أفقي
/// -----------------------------------------------------------------
Widget topOrderCardWidget({
  required BuildContext context,
  required String orderId,
  required String date,
  required String maskedName,
  required String price,
  bool isHot = false,
  String? primaryBadgeLabel,
  String? secondaryBadgeLabel,
  VoidCallback? onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final subTextColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 260.w,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    orderId,
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: textColor),
                  ),
                  if (isHot) ...[
                    SizedBox(width: 4.w),
                    Text("🔥", style: TextStyle(fontSize: 15.sp)),
                  ],
                ],
              ),
              Text(
                date,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: subTextColor),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: AppColor.themeGreenColor),
                  SizedBox(width: 6.w),
                  Text(
                    maskedName,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: subTextColor),
                  ),
                ],
              ),
              Text(
                price,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: textColor),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (primaryBadgeLabel != null)
                orderStatusBadgeWidget(label: primaryBadgeLabel, type: OrderBadgeType.primary),
              if (primaryBadgeLabel != null && secondaryBadgeLabel != null) SizedBox(width: 8.w),
              if (secondaryBadgeLabel != null)
                orderStatusBadgeWidget(
                  label: secondaryBadgeLabel,
                  type: OrderBadgeType.success,
                  icon: Icons.verified_outlined,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// -----------------------------------------------------------------
/// 8) كرت طلب داخل قائمة "All Orders" - نسخة مطوّرة من recentOrdersWidget
/// نفس منطق الكولباكات الأصلية (view/delete/share/download) موجودة
/// كقائمة خيارات (three-dot menu) حتى ما نخسر أي وظيفة قديمة
/// -----------------------------------------------------------------
Widget allOrdersListItemWidget({
  required BuildContext context,
  required String orderId,
  required String date,
  required String maskedName,
  required String price,
  String? primaryBadgeLabel,
  String? secondaryBadgeLabel,
  VoidCallback? onTap,
  VoidCallback? viewFun,
  VoidCallback? shareFun,
  VoidCallback? downloadFun,
  VoidCallback? deleteFun,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final subTextColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: textColor),
              ),
              Row(
                children: [
                  Text(
                    date,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: subTextColor),
                  ),
                  if (viewFun != null || shareFun != null || downloadFun != null || deleteFun != null)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 18.sp, color: subTextColor),
                      onSelected: (value) {
                        if (value == 'view') viewFun?.call();
                        if (value == 'share') shareFun?.call();
                        if (value == 'download') downloadFun?.call();
                        if (value == 'delete') deleteFun?.call();
                      },
                      itemBuilder: (context) => [
                        if (viewFun != null) PopupMenuItem(value: 'view', child: Text('view'.tr)),
                        if (shareFun != null) PopupMenuItem(value: 'share', child: Text('share'.tr)),
                        if (downloadFun != null) PopupMenuItem(value: 'download', child: Text('download'.tr)),
                        if (deleteFun != null) PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
                      ],
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 16.sp, color: AppColor.themeGreenColor),
                  SizedBox(width: 6.w),
                  Text(
                    maskedName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              Text(
                price,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: textColor),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (primaryBadgeLabel != null)
                orderStatusBadgeWidget(label: primaryBadgeLabel, type: OrderBadgeType.primary),
              if (primaryBadgeLabel != null && secondaryBadgeLabel != null) SizedBox(width: 8.w),
              if (secondaryBadgeLabel != null)
                orderStatusBadgeWidget(
                  label: secondaryBadgeLabel,
                  type: OrderBadgeType.success,
                  icon: Icons.verified_outlined,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
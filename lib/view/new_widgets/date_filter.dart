import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';

Future<DateTimeRange?> showDateRangeBottomSheet({
  required BuildContext context,
  DateTimeRange? initialRange,
  VoidCallback? onReset,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor =
  isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor =
  isDark ? DarkThemeColor.cText : AppColor.cText;
  final accent = AppColor.themeNavyBlueColor;

  return await showModalBottomSheet<DateTimeRange>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      DateTime tempStart =
          initialRange?.start ??
              DateTime.now().subtract(const Duration(days: 30));

      DateTime tempEnd =
          initialRange?.end ?? DateTime.now();

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 24.h,
              bottom:
              MediaQuery.of(context).viewPadding.bottom + 20.h,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  'date_filter.select_range'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'date_filter.from'.tr,
                        date: tempStart,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempStart,
                            firstDate: DateTime(2020),
                            lastDate: tempEnd,
                          );

                          if (picked != null) {
                            setState(() {
                              tempStart = picked;
                            });
                          }
                        },
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: _DatePickerField(
                        label: 'date_filter.to'.tr,
                        date: tempEnd,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempEnd,
                            firstDate: tempStart,
                            lastDate: DateTime.now(),
                          );

                          if (picked != null) {
                            setState(() {
                              tempEnd = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Reset
                if (initialRange != null)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onReset?.call();
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: 18.sp,
                        color: AppColor.cRedText,
                      ),
                      label: Text(
                        'reset'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.cRedText,
                        ),
                      ),
                    ),
                  ),

                if (initialRange != null)
                  SizedBox(height: 8.h),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                          ),
                          side: BorderSide(
                            color: accent.withOpacity(0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'common.cancel'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            ctx,
                            DateTimeRange(
                              start: tempStart,
                              end: tempEnd,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'common.apply'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
    final subTextColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;
    final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14.sp,
                  color: AppColor.themeNavyBlueColor,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    dateFormatted(
                      date: date.toString(),
                      formatType: formatForDateTime(FormatType.date),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget sectionHeaderWithFilterWidget({
  required BuildContext context,
  required String title,
  required bool isFilter,
  required int num,
  required String filterLabel,
  VoidCallback? onFilterTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final titleColor = isDark ? Colors.white : Colors.black;
  final accent = AppColor.themeNavyBlueColor;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          children: [
            Text(
              num.toString(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.themeNavyBlueColor,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: titleColor),
            ),
          ],
        ),
      ),
      SizedBox(width: 8.w),
      isFilter ?
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
              Flexible(
                child: Text(
                  filterLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: accent),
                ),
              ),
            ],
          ),
        ),
      ) : SizedBox(),
    ],
  );
}
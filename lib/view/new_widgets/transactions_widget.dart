import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/model/wallet_model.dart';
import '../../utils/helper.dart';

const Color success = Color(0xFF16A34A);
const Color danger = Color(0xFFEF4444);
const Color warning = Color(0xFFF59E0B);


Widget transactionCard({
  required WalletTransaction tx,
  required String currency,
  required bool isDark,
}) {

  final Color amountColor = tx.isCredit ? success : danger;
  final IconData icon = _iconForType(tx.type, tx.isCredit);
  final Color cardColor =
  isDark ? const Color(0xFF1B1C20) : Colors.white;
  final Color borderColor = isDark
      ? Colors.white.withOpacity(.07)
      : const Color(0xFFE8EAEE);
  final Color primaryText =
  isDark ? Colors.white : const Color(0xFF15171A);
  final Color secondaryText =
  isDark ? const Color(0xFF9297A1) : const Color(0xFF777D87);

  return Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16.r),
      // border: Border.all(color: AppColor.themeNavyBlueColor.withOpacity(0.3)),
      boxShadow: isDark
          ? null
          : [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          offset: const Offset(0, 3),
          blurRadius: 10,
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: amountColor.withOpacity(isDark ? 0.15 : 0.10),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: amountColor, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${tx.id}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _formatType(tx.type),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                tx.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, color: secondaryText),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tx.isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 12.sp,
                  color: amountColor,
                ),
                SizedBox(width: 3.w),
                Text(
                  tx.isCredit ? 'credit'.tr : 'debit'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              dateFormatted(
                  date: tx.createdAt,
                  formatType: formatForDateTime(
                    FormatType.dateTime2,
                  )),
              style: TextStyle(fontSize: 10.5.sp, color: secondaryText),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${tx.isCredit ? '+' : '-'} ${tx.amount}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  currency,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: amountColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            _statusBadge(status: tx.status, isDark: isDark),
          ],
        ),
      ],
    ),
  );
}

Widget _statusBadge({required String status, required bool isDark}) {
  final bool isCompleted = status == 'completed';
  final Color color = isCompleted ? success : warning;

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: color.withOpacity(isDark ? 0.18 : 0.10),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      isCompleted ? 'completed'.tr : status,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

IconData _iconForType(String type, bool isCredit) {
  switch (type) {
    case 'manual_deposit':
      return Icons.add_box_outlined;
    case 'order_paid':
      return Icons.shopping_bag_outlined;
    case 'order_payment_reversed':
      return Icons.undo_rounded;
    case 'manual_withdrawal':
      return Icons.indeterminate_check_box_outlined;
    default:
      return isCredit
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded;
  }
}

String _formatType(String type) {
  return type
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
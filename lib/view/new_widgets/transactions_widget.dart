import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/model/wallet_model.dart';
import '../../utils/colors.dart';
import '../../utils/helper.dart';
import '../../utils/text_style.dart';

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
  // P2.5-FLUTTER-FRAMING. IN LIGHT MODE THIS CARD IS WHITE ON A WHITE PAGE.
  // `LightThemeColor.cBackGround` is `0xffFFFFFF` (colors.dart:72) and this fill is
  // `Colors.white`, so the only separation was a shadow at alpha .03. Same reading, same remedy
  // and the same token as the customer and delivery-man cards: a hairline in light, nothing in
  // dark, where `0xFF18263F` already differs from the page.
  final Color cardColor =
  isDark ? const Color(0xFF18263F) : Colors.white;
  final Color primaryText =
  isDark ? Colors.white : const Color(0xFF0F1A2E);
  final Color secondaryText =
  isDark ? const Color(0xFFA9B8D0) : const Color(0xFF777D87);

  return Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: cardColor,
      border: isDark ? null : Border.all(color: LightThemeColor.cBorder, width: 1),
      borderRadius: BorderRadius.circular(16.r),
      // border: Border.all(color: AppColor.themeNavyBlueColor.withValues(alpha: 0.3)),
      boxShadow: isDark
          ? null
          : [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
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
            color: amountColor.withValues(alpha: isDark ? 0.15 : 0.10),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: amountColor, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          // P2.5-FLUTTER-FRAMING. The same defect the two list cards had, in a different shape.
          // The root here is a `Row`, so this `Column` is sized on the Row's cross axis and a
          // `Column` with no `mainAxisSize` is `MainAxisSize.max` -- it fills whatever bounded
          // height arrives. MEASURED: 800.0px in an 800px box against 128.0px in a scrolling
          // list, which is the context /finance really renders it in.
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                _typeLabel(tx.type),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                tx.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, color: secondaryText),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        // P2.5-FLUTTER-FRAMING. THE SECOND ONE, and it is why fixing the first changed nothing.
        // MEASURED after the first fix: the card was still 800px in a bounded box and the Row
        // itself 770px, because THIS trailing amount column was still `MainAxisSize.max` and the
        // Row sizes its cross axis to its tallest child. A card can have more than one Column
        // and the stretch only needs one of them.
        Column(
          mainAxisSize: MainAxisSize.min,
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
            RichText(
              text: TextSpan(
                // THE ROOT SPAN MUST CARRY THE FAMILY. `RichText` does not inherit
                // `DefaultTextStyle`, so without this both child spans below resolved
                // `fontFamily: null` — measured as `[null, null]` — and the transaction amount,
                // the largest number on the row, rendered in the platform font beside Tajawal.
                style: const TextStyle(fontFamily: appFontFamily),
                children: [
                  TextSpan(
                    text: '${tx.isCredit ? '+' : '-'} ${tx.amount}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
                  ),
                  TextSpan(
                    text: ' ${tx.currencyCode}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
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
      color: color.withValues(alpha: isDark ? 0.18 : 0.10),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      // GAP-271. This was `isCompleted ? 'completed'.tr : status`, so the host enum's other two
      // values -- `pending` and `cancelled`, both of which already had copy in both maps --
      // printed the raw lowercase server string beside a translated `مكتمل` on the same list.
      // The colour still branches on `isCompleted` above: re-tinting the pill is GAP-271's other
      // half and is carried with GAP-269 as one palette decision, deliberately not taken here.
      _statusLabel(status),
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

/// GAP-270. THE TYPE NOW GOES THROUGH THE SAME `.tr` THE REST OF THIS CARD ALREADY USES.
///
/// `_formatType` alone had no `.tr` anywhere in its chain, so `manual_withdrawal` printed
/// `Manual Withdrawal` in Latin script on an otherwise fully Arabic card. Found by looking at the
/// rendered image; no assertion in the suite read that string.
///
/// WHY A BARE `type.tr` WOULD BE A REGRESSION RATHER THAN A FIX. GetX returns THE KEY when a
/// translation is absent (get-4.7.3 `internacionalization.dart:96-111` falls through to
/// `return this`), so an unmapped type would print the raw `some_new_type` to the merchant --
/// strictly worse than the humanised English it replaced. The nine types the server really writes
/// all have copy in both maps (censused from the eleven `StoreWalletTransaction::create` sites in
/// the Laravel repository), and anything else degrades to `_formatType` as before. That fallback
/// is load-bearing today: `sampleTransaction()` carries `type: 'order'`, which no write site
/// produces.
String _typeLabel(String type) {
  if (type.isEmpty) {
    return '';
  }

  final String translated = type.tr;

  return translated == type ? _formatType(type) : translated;
}

/// GAP-271. The host enum is `['pending','completed','cancelled']`; all three have copy in both
/// maps. Same fallback reasoning as [_typeLabel]: a status the enum does not name prints as it
/// arrived rather than as a key.
String _statusLabel(String status) {
  if (status.isEmpty) {
    return '';
  }

  return status.tr;
}

String _formatType(String type) {
  return type
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
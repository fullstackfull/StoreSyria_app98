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

// GAP-271 / GAP-272. THE HUES ABOVE STAY; THEY ARE TINTS AND ICONS, NOT TEXT.
//
// Each of the three was spent twice -- as a tint and as its own opaque label -- which is the
// defect this codebase has now repaired in `status_pill.dart`, in `order_status_badge.dart` and
// in the product stock pill. Measured on this card's own hosts:
//
//     element                        light #FFFFFF    dark #18263F
//     success  Credit / + amount          3.30:1          4.59:1
//     danger   Debit  / - amount          3.76:1       ** 4.02:1 **   <- dark does NOT pass
//     pill label on its own tint     2.96 / 1.99:1    3.62 / 5.10:1
//
// GAP-272's own row warns that "dark passes throughout" was a figure taken on one surface, and it
// was right to: `danger` on the dark card is 4.02:1, and the amount is 15 sp w800 -- 11.25 pt,
// below the large-text threshold -- so SC 1.4.3 asks 4.5:1 of it.
//
// The replacements are the design system's per-theme semantic foregrounds, already transcribed
// into this app at `common_snak_bar_widget.dart:127-145` from `public/css/store-syria-ds.css`.
// Nothing new is introduced.
//
//     light  success #165E34  danger #8C1D17  warning #5D3F04
//     dark   success #7FD6A0  danger #F3A9A4  warning #F0C674
//
// BOTH SIDES OF EACH PAIR MOVE, including the two that already passed (`success` on the dark
// card, `warning` on the dark pill). Credit and debit are ONE signal a merchant tells apart at a
// glance, and so are completed and pending; leaving half of a pair on the saturated hue and half
// on the design system would make the distinction carry two colour systems at once. Every figure
// improves: 7.82 / 9.12 / 8.67 / 7.94 for the amounts, 7.02 / 8.92 / 6.83 / 6.80 for the pills.
//
// THE 42 dp TYPE TILE KEEPS `success`/`danger` for its fill AND its icon, at 2.96-3.75:1. SC
// 1.4.11 asks 3:1 of a graphic that carries meaning, and light success is a 1 % miss -- but the
// icon duplicates the type, which is printed as text immediately beside it, so it is not an
// essential graphical object. Recorded rather than used to justify repainting the card's accent.
const Color _successFgLight = Color(0xFF165E34); // --ss-green-800
const Color _successFgDark = Color(0xFF7FD6A0);
const Color _dangerFgLight = Color(0xFF8C1D17); // --ss-red-800
const Color _dangerFgDark = Color(0xFFF3A9A4);
const Color _warningFgLight = Color(0xFF5D3F04); // --ss-amber-900
const Color _warningFgDark = Color(0xFFF0C674);


Widget transactionCard({
  required WalletTransaction tx,
  required String currency,
  required bool isDark,
}) {

  final Color amountColor = tx.isCredit ? success : danger;

  // The LABEL and the AMOUNT, which are text; `amountColor` above stays the tint and the icons.
  final Color amountTextColor = tx.isCredit
      ? (isDark ? _successFgDark : _successFgLight)
      : (isDark ? _dangerFgDark : _dangerFgLight);

  final IconData icon = _iconForType(tx.type, tx.isCredit);
  // P2.5-FLUTTER-FRAMING, AND ITS CORRECTION. The light reading stands: this fill is
  // `Colors.white` and the golden harness's page is `LightThemeColor.cBackGround` `0xffFFFFFF`,
  // separated only by a shadow at alpha .03.
  //
  // **THE DARK HALF OF THAT NOTE WAS WRONG, and it said the opposite of the truth.** It read
  // "nothing in dark, where `0xFF18263F` already differs from the page" -- which is true of the
  // HARNESS page (`DarkThemeColor.cBackGround` `#0F1A2E`, 1.15:1) and false of the page this card
  // ships on. `transactionCard` has exactly one call site, `wallet_screen.dart:169`, and that
  // screen's Scaffold is `backgroundColor: AppColor.cLight` (`:69`) -- a static the themes
  // REASSIGN: light to `LightThemeColor.cLight` `#F2F6FA`, dark to
  // **`DarkThemeColor.cCardBackground` `#18263F`**, which is this card's own fill.
  //
  //     host                     light            dark
  //     golden harness page      #FFFFFF 1.00:1   #0F1A2E 1.15:1
  //     wallet_screen.dart:69    #F2F6FA 1.09:1   #18263F ** 1.00:1 **
  //
  // So on /finance in dark the card had no fill difference, no border and no shadow: no boundary
  // of any kind. The half that was given the hairline was the better one. Both halves have an
  // edge now -- `LightThemeColor.cBorder` in light (1.32:1 on that page) and
  // `DarkThemeColor.cBorder` in dark (1.50:1), each the app's own token.
  //
  // Found by asking which host, after the coupon card taught the same lesson one commit earlier:
  // a component baseline cannot tell you what the component really sits on. NOT CHANGED here, and
  // it is the underlying cause: a Scaffold painting `AppColor.cLight`, whose dark value is the
  // CARD background, is a page wearing a card's colour -- and that static is used by other
  // screens, so moving it is a design decision rather than this widget's repair.
  final Color cardColor =
  isDark ? const Color(0xFF18263F) : Colors.white;
  final Color primaryText =
  isDark ? Colors.white : const Color(0xFF0F1A2E);
  // GAP-272. `#777D87` measured 4.14:1 on the white card at 12 sp, which SC 1.4.3 fails -- the
  // type line, the description and the date all use it. `LightThemeColor.cFont` is the app's own
  // token and reads 4.83:1: a modest darkening rather than the jump to the design system's
  // `--ss-grey-700` (8.73:1), which would repaint the card's whole secondary layer. Dark is
  // untouched at 7.53:1.
  final Color secondaryText =
  isDark ? const Color(0xFFA9B8D0) : LightThemeColor.cFont;

  return Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: cardColor,
      border: Border.all(
          color: isDark ? DarkThemeColor.cBorder : LightThemeColor.cBorder, width: 1),
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
                _translatedOr(tx.type),
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
                  // Part of the label, so it takes the label's colour rather than the tile's.
                  color: amountTextColor,
                ),
                SizedBox(width: 3.w),
                Text(
                  tx.isCredit ? 'credit'.tr : 'debit'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: amountTextColor,
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
                      color: amountTextColor,
                    ),
                  ),
                  TextSpan(
                    text: ' ${tx.currencyCode}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: amountTextColor,
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

  // The TINT keeps the saturated hue; only the LABEL moves. See the note beside the constants.
  final Color tint = isCompleted ? success : warning;
  final Color label = isCompleted
      ? (isDark ? _successFgDark : _successFgLight)
      : (isDark ? _warningFgDark : _warningFgLight);

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: tint.withValues(alpha: isDark ? 0.18 : 0.10),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      // GAP-271. THIS WAS `isCompleted ? 'completed'.tr : status`, so a value that is not
      // `completed` reached the merchant as the RAW SERVER TOKEN. The host column is
      // `enum('status', ['pending','completed','cancelled'])`, so TWO OF THE THREE reachable
      // values bypassed translation -- both Arabic captures show the Arabic for completed above a
      // lowercase `pending`. All three keys already carry copy in both maps, so none is written.
      _translatedOr(status),
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: label,
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

/// GAP-270. WHAT THIS USED TO BE, AND WHY IT WAS A DEFECT RATHER THAN A STYLE.
///
/// The old `_formatType()` split the wire value on `_`, capitalised each word and rejoined --
/// with **no `.tr` anywhere in it** -- so an Arabic merchant on /finance read `Order` and
/// `Manual Withdrawal` in Latin script. Both Arabic captures show it.
///
/// NOT THE PLURAL MECHANISM. `lib/utils/plural.dart` selects a CLDR category by COUNT; these are
/// type and status NAMES with no number and nothing to agree with. Using it would be fitting the
/// shape of the problem rather than its content. The right mechanism is a key per value, and
/// every key this needs -- `manual_deposit`, `order_paid`, `order_payment_reversed`,
/// `manual_withdrawal`, `pending`, `completed`, `cancelled` -- ALREADY EXISTS in both maps, with
/// the four type values byte-identical to what the title-casing produced. So the English screen
/// does not move by a character, which is the governing rule
/// `test/translations/converted_labels_render_arabic_test.dart` records.
///
/// THE FALLBACK IS LOAD-BEARING. GetX returns THE KEY ITSELF on a miss, so a bare `value.tr`
/// would print a raw identifier the moment the host adds a type or a status -- strictly worse
/// than the English it replaced. `sampleTransaction()`'s type is `order`, which has no key, so
/// that branch is exercised by a fixture rather than left to hope.
String _translatedOr(String value) {
  final translated = value.tr;

  return translated == value ? _titleCase(value) : translated;
}

/// What the old formatter did, kept as the fallback for a value with no copy.
String _titleCase(String value) {
  return value
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
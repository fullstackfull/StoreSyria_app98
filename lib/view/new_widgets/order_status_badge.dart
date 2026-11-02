import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum StatusBadgeType {
  order,
  payment,
}

class StatusBadgeConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;

  const StatusBadgeConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
  });
}

class StatusBadgeHelper {
  // =========================================================
  // ORDER STATUS CONFIG
  // =========================================================

  /// CONTRAST-CHECKED, every pair, by `test/widgets/order_status_label_test.dart`.
  ///
  /// These are hardcoded colour pairs rather than theme tokens, so nothing
  /// else was ever going to check them -- and MEASURED, three of the original
  /// seven were below WCAG AA for small text:
  ///
  ///     status 0  Pending     #EF6C00 on #FFF3E0  2.81:1
  ///     status 5  Picked Up   #00838F on #E0F7FA  4.06:1
  ///     status 6  Shipped     #F9A825 on #FFF8E1  1.85:1
  ///
  /// Status 6 at 1.85:1 was effectively unreadable: a pale amber word on a
  /// pale amber chip. THE HUE IS KEPT AND ONLY THE TEXT DARKENS -- the tinted
  /// backgrounds are what make a status column scannable and they are
  /// unchanged, so the badges look like themselves, just legible. The new
  /// values are the darkest step that clears 4.5:1 with margin (5.75, 6.60 and
  /// 5.86 respectively) rather than the first one that scrapes past it.
  static StatusBadgeConfig getOrderConfig(int status) {
    switch (status) {
      case 0:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFFFF3E0),
          textColor: Color(0xFFA63F00),   // was #EF6C00 -- 2.81:1
          borderColor: Color(0xFFFFCC80),
          icon: Icons.access_time_rounded,
        );

      case 1:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFE8F5E9),
          textColor: Color(0xFF2E7D32),
          borderColor: Color(0xFFC8E6C9),
          icon: Icons.check_circle_outline,
        );

      case 2:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFFFEBEE),
          textColor: Color(0xFFC62828),
          borderColor: Color(0xFFFFCDD2),
          icon: Icons.cancel_outlined,
        );

      case 3:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFF3E5F5),
          textColor: Color(0xFF7B1FA2),
          borderColor: Color(0xFFE1BEE7),
          icon: Icons.undo,
        );

      case 4:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFE3F2FD),
          textColor: Color(0xFF1565C0),
          borderColor: Color(0xFFBBDEFB),
          icon: Icons.verified_outlined,
        );

      case 5:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFE0F7FA),
          textColor: Color(0xFF006064),   // was #00838F -- 4.06:1
          borderColor: Color(0xFFB2EBF2),
          icon: Icons.inventory_2_outlined,
        );

      case 6:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFFFF8E1),
          textColor: Color(0xFF8F5200),   // was #F9A825 -- 1.85:1, unreadable
          borderColor: Color(0xFFFFE082),
          icon: Icons.local_shipping_outlined,
        );

      /*
       * 7 AND 8 ARE NOT FULFILMENT STATES, and their colours say so.
       *
       * 7 is Partially Paid -- a PAYMENT state -- and 8 is Pre Order, an order
       * TYPE. Both live in the same integer column as the seven above (host
       * ledger F0). They were falling through to the grey default, which is
       * also what a corrupt value gets, so a real Pre Order looked like an
       * error. Indigo and brown: deliberately outside the warm-to-green
       * progression the fulfilment states use, so they do not read as a stage
       * of delivery.
       */
      case 7:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFE8EAF6),
          textColor: Color(0xFF283593),   // 8.68:1
          borderColor: Color(0xFFC5CAE9),
          icon: Icons.payments_outlined,
        );

      case 8:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFEFEBE9),
          textColor: Color(0xFF4E342E),   // 9.56:1
          borderColor: Color(0xFFD7CCC8),
          icon: Icons.event_available_outlined,
        );

      default:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFF5F5F5),
          textColor: Color(0xFF616161),
          borderColor: Color(0xFFE0E0E0),
          icon: Icons.info_outline,
        );
    }
  }

  // =========================================================
  // ORDER STATUS LABEL
  // =========================================================

  /// NINE VALUES, NOT SEVEN. `orders.delivered_status` carries 0..8, and the
  /// two this used to miss are the awkward ones: **7 is Partially Paid, a
  /// PAYMENT state, and 8 is Pre Order, an order TYPE** -- both recorded in
  /// the same integer column as the seven fulfilment states. That is a schema
  /// problem (host ledger F0) and splitting the column is Phase 04; naming
  /// them is not, and saying "unknown" about a value the database knows is
  /// worse than saying nothing.
  ///
  /// `'cancelled'`, NOT `'cancel'`. Both keys exist in en.dart and ar.dart and
  /// they mean different things: `'cancelled'` is "Cancelled" / "ملغى", the
  /// state of an order, and `'cancel'` is "Cancel" / "إلغاء", the word on a
  /// button. This asked for the button.
  static String getOrderLabel(int status) {
    switch (status) {
      case 0:
        return 'pending'.tr;
      case 1:
        return 'delivered'.tr;
      case 2:
        return 'cancelled'.tr;
      case 3:
        return 'return'.tr;
      case 4:
        return 'confirmed'.tr;
      case 5:
        return 'picked_up'.tr;
      case 6:
        return 'shipped'.tr;
      case 7:
        return 'partially_paid'.tr;
      case 8:
        return 'pre_order'.tr;
      default:
        // `'unknown'` HAS NO KEY in either translation file, and GetX returns
        // the key when a lookup misses -- so this branch used to render the
        // literal lowercase word `unknown` in both languages.
        return 'status_unrecognised'.tr;
    }
  }

  // =========================================================
  // ORDER STATUS -- THE SERVER'S OWN SPELLING
  // =========================================================

  /// The host's English spelling of a status.
  ///
  /// THIS IS NOT AN "API NAME", despite what the heading said for a long time:
  /// nothing sends it anywhere. Its one caller writes the result into
  /// `model.orderStatusText`, a DISPLAY field -- so after a merchant changed a
  /// status, the order detail screen's status line flipped from the Arabic the
  /// server had sent to a hardcoded English word. Two of the three call sites
  /// discard the value entirely.
  ///
  /// The display call site now uses [getOrderLabel] instead. This is kept for
  /// anything that genuinely needs the server's spelling, extended to 7 and 8
  /// so it no longer answers "Unknown" either.
  static String getOrderName(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Delivered';
      case 2:
        return 'Cancel';
      case 3:
        return 'Return';
      case 4:
        return 'Confirmed';
      case 5:
        return 'Picked Up';
      case 6:
        return 'Shipped';
      case 7:
        return 'Partially Paid';
      case 8:
        return 'Pre Order';
      default:
        return 'Unknown';
    }
  }

  // =========================================================
  // ORDER STATUS DESCRIPTION
  // =========================================================

  /// TRANSLATED, not hardcoded Arabic.
  ///
  /// Every one of these was an Arabic string literal with no `.tr` at all, in
  /// a bilingual app -- so an English-locale merchant read the status
  /// descriptions in Arabic on the status sheet. The reverse of the host's own
  /// "has variant" defect, found the same week.
  static String getOrderDescription(int status) {
    switch (status) {
      case 0:
        return 'order_desc_pending'.tr;
      case 1:
        return 'order_desc_delivered'.tr;
      case 2:
        return 'order_desc_cancelled'.tr;
      case 3:
        return 'order_desc_return'.tr;
      case 4:
        return 'order_desc_confirmed'.tr;
      case 5:
        return 'order_desc_picked_up'.tr;
      case 6:
        return 'order_desc_shipped'.tr;
      case 7:
        return 'order_desc_partially_paid'.tr;
      case 8:
        return 'order_desc_pre_order'.tr;
      default:
        return 'order_desc_unrecognised'.tr;
    }
  }

  // =========================================================
  // PAYMENT CONFIG
  // =========================================================

  static StatusBadgeConfig getPaymentConfig(
      String? paymentStatus,
      ) {
    final isPaid =
        (paymentStatus ?? 'Unpaid').toLowerCase().trim() == 'paid';

    if (isPaid) {
      return const StatusBadgeConfig(
        backgroundColor: Color(0xFFE8F5E9),
        textColor: Color(0xFF2E7D32),
        borderColor: Color(0xFFC8E6C9),
        icon: Icons.check_circle_outline,
      );
    }

    return const StatusBadgeConfig(
      backgroundColor: Color(0xFFFFEBEE),
      textColor: Color(0xFFC62828),
      borderColor: Color(0xFFFFCDD2),
      icon: Icons.cancel_outlined,
    );
  }

  // =========================================================
  // PAYMENT LABEL
  // =========================================================

  static String getPaymentLabel(String? paymentStatus) {
    final isPaid =
        (paymentStatus ?? 'Unpaid').toLowerCase().trim() == 'paid';

    return isPaid ? 'paid'.tr : 'unpaid'.tr;
  }
}

// =============================================================
// COMMON STATUS BADGE
// =============================================================

class CommonStatusBadge extends StatelessWidget {
  final StatusBadgeType type;

  final int? orderStatus;
  final String? paymentStatus;

  final String? customLabel;
  final String? paymentMethod;

  final VoidCallback? onTap;

  final bool showArrow;

  final bool isCard;

  const CommonStatusBadge({
    super.key,
    required this.type,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.customLabel,
    this.onTap,
    this.showArrow = false,
    this.isCard = false,
  });

  StatusBadgeConfig _getConfig() {
    if (type == StatusBadgeType.payment) {
      return StatusBadgeHelper.getPaymentConfig(
        paymentStatus,
      );
    }

    return StatusBadgeHelper.getOrderConfig(
      orderStatus ?? 0,
    );
  }

  String _getLabel() {
    if (customLabel != null &&
        customLabel!.trim().isNotEmpty) {
      return customLabel!;
    }

    if (type == StatusBadgeType.payment) {
      final isPaid =
          (paymentStatus ?? 'Unpaid').toLowerCase().trim() == 'paid';

      if (isPaid) {
        if (paymentMethod != null &&
            paymentMethod!.trim().isNotEmpty) {
          return 'paid_by2'.trParams({
            'method': paymentMethod!.trim(),
          });
        }

        return 'paid'.tr;
      }

      return 'unpaid'.tr;
    }

    return StatusBadgeHelper.getOrderLabel(
      orderStatus ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final label = _getLabel();

    // =========================
    // SIZE - نفس التصميم القديم
    // =========================

    final double horizontalPadding =
    isCard ? 7.w : 10.w;

    final double verticalPadding =
    isCard ? 4.h : 6.h;

    final double borderRadius =
    isCard ? 8.r : 10.r;

    final double iconSize =
    isCard ? 12.sp : 15.sp;

    final double textSize =
    isCard ? 10.sp : 12.sp;

    final double arrowSize =
    isCard ? 13.sp : 16.sp;

    final double iconTextSpacing =
    isCard ? 3.w : 5.w;

    final badge = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius:
        BorderRadius.circular(borderRadius),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: iconSize,
            color: config.textColor,
          ),

          SizedBox(
            width: iconTextSpacing,
          ),

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w600,
                color: config.textColor,
              ),
            ),
          ),

          if (showArrow) ...[
            SizedBox(
              width: isCard ? 2.w : 4.w,
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: arrowSize,
              color: config.textColor,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return badge;
    }

    return GestureDetector(
      onTap: onTap,
      child: badge,
    );
  }
}
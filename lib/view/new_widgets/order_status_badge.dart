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

  static StatusBadgeConfig getOrderConfig(int status) {
    switch (status) {
      case 0:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFFFF3E0),
          textColor: Color(0xFFEF6C00),
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
          textColor: Color(0xFF00838F),
          borderColor: Color(0xFFB2EBF2),
          icon: Icons.inventory_2_outlined,
        );

      case 6:
        return const StatusBadgeConfig(
          backgroundColor: Color(0xFFFFF8E1),
          textColor: Color(0xFFF9A825),
          borderColor: Color(0xFFFFE082),
          icon: Icons.local_shipping_outlined,
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

  static String getOrderLabel(int status) {
    switch (status) {
      case 0:
        return 'pending'.tr;
      case 1:
        return 'delivered'.tr;
      case 2:
        return 'cancel'.tr;
      case 3:
        return 'return'.tr;
      case 4:
        return 'confirmed'.tr;
      case 5:
        return 'picked_up'.tr;
      case 6:
        return 'shipped'.tr;
      default:
        return 'unknown'.tr;
    }
  }

  // =========================================================
  // ORDER STATUS API NAME
  // =========================================================

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
      default:
        return 'Unknown';
    }
  }

  // =========================================================
  // ORDER STATUS DESCRIPTION
  // =========================================================

  static String getOrderDescription(int status) {
    switch (status) {
      case 0:
        return 'الطلب قيد الانتظار';
      case 1:
        return 'تم التوصيل بنجاح';
      case 2:
        return 'تم إلغاء الطلب';
      case 3:
        return 'طلب إرجاع';
      case 4:
        return 'تم تأكيد الطلب';
      case 5:
        return 'تم الاستلام من المتجر';
      case 6:
        return 'تم الشحن';
      default:
        return '';
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
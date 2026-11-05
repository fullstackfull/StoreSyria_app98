import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// THE FILL HUES ARE UNCHANGED. The tinted background is what makes a status
// column scannable, which is the decision already recorded for the sibling
// badge language at order_status_badge.dart:40-44: "THE HUE IS KEPT AND ONLY
// THE TEXT DARKENS". Replacing these with the web design system's opaque
// pastels measures 1.03:1 against this app's navy dark card and turns the
// inactive chip darker than the card it sits on -- the web can carry them
// because its dark card is a neutral #262b33, and this one is a navy at a
// different luminance.
const _tintActive = Color(0xFF00B894);
const _tintInactive = Color(0xFFFF5C5C);

// The FOREGROUNDS do transplant from the web design system, and they are the
// whole repair: the label and the dot used to be painted in the same saturated
// hue as their own 9% tint, measuring 2.33:1 and 2.74:1 on a white host.
const _fgActiveLight = Color(0xFF165E34); // --ss-green-800
const _fgInactiveLight = Color(0xFF8C1D17); // --ss-red-800
const _fgActiveDark = Color(0xFF7FD6A0); // dark --ss-success-fg
const _fgInactiveDark = Color(0xFFF3A9A4); // dark --ss-danger-fg

Widget statusPill({
  required String label,
  required bool isActive,
}) {
  // Builder, not an `isDark` parameter and not Get.isDarkMode. A parameter
  // would be a breaking change to a shared widget used at five call sites, and
  // the owner's decision asks for backward-compatible repairs;
  // `Get.isDarkMode` reads the wrong thing under a plain MaterialApp (which is
  // what test/rtl/customer_card_direction_test.dart pumps) and ignores a local
  // Theme override. Builder takes the ambient Theme from the real element tree,
  // so the signature and all five call sites stay byte-identical.
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      final tint = isActive ? _tintActive : _tintInactive;
      final fg = isActive
          ? (isDark ? _fgActiveDark : _fgActiveLight)
          : (isDark ? _fgInactiveDark : _fgInactiveLight);

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 5.h,
        ),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The dot IS the foreground, mirroring the web's
            // `.ss-badge__dot { background: currentColor }`. It is the only
            // non-text carrier of the same information, so 1.4.11 applies.
            Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),

            SizedBox(width: 4.w),

            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      );
    },
  );
}
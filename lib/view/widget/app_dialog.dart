import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:lottie/lottie.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> showCustomDialog({
    required BuildContext context,
    String? title,
    required String message,
    bool showConfirmLoading = true,
    String? confirmText,
    String? cancelText,
    bool popOnConfirm = true,
    required Future<void> Function() onConfirm,
    VoidCallback? onCancel,
    IconData? icon,
    Color? iconColor,
    String? lottieAsset,
    Color? confirmColor,
    bool barrierDismissible = true,
  }) {
    bool isLoading = false;

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: .45),
      transitionDuration: const Duration(milliseconds: 200),

      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return const SizedBox.shrink();
      },

      transitionBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return StatefulBuilder(
          builder: (context, setState) {
            final isDark =
                Theme.of(context).brightness == Brightness.dark;

            final bgColor = isDark
                ? const Color(0xFF20222A)
                : const Color(0xFFF7F7F9);

            final titleColor = isDark
                ? Colors.white
                : const Color(0xFF14161B);

            final descriptionColor = isDark
                ? const Color(0xFFA7ABB5)
                : const Color(0xFF6B7280);

            final confirmButtonColor =
                confirmColor ?? AppColor.cRedText;

            final accentColor =
                iconColor ?? confirmButtonColor;

            final cancelBorderColor = isDark
                ? Colors.white.withValues(alpha: .14)
                : const Color(0xFFE3E5EA);

            final dialogBorderColor =
            accentColor.withValues(alpha:
              isDark ? .55 : .45,
            );

            final hasLottie =
                lottieAsset != null &&
                    lottieAsset.trim().isNotEmpty;

            final hasIcon =
                icon != null && !hasLottie;

            return FadeTransition(
              opacity: curvedAnimation,

              child: ScaleTransition(
                scale: Tween<double>(
                  begin: .92,
                  end: 1.0,
                ).animate(curvedAnimation),

                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,

                  insetPadding: EdgeInsets.symmetric(
                    horizontal: 55.w,
                  ),

                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius:
                      BorderRadius.circular(20.r),

                      border: Border.all(
                        color: dialogBorderColor,
                        width: 1.2,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:
                            isDark ? .3 : .06,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20.w,
                        20.h,
                        20.w,
                        16.h,
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                        CrossAxisAlignment.center,

                        children: [

                          // =====================================
                          // LOTTIE
                          // =====================================

                          if (hasLottie)
                            SizedBox(
                              width: 70.w,
                              height: 70.w,
                              child: Lottie.asset(
                                lottieAsset,
                                fit: BoxFit.contain,
                              ),
                            )

                          // =====================================
                          // ICON
                          // =====================================

                          else if (hasIcon)
                            Container(
                              width: 48.w,
                              height: 48.w,

                              alignment: Alignment.center,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentColor
                                        .withValues(alpha:
                                        isDark
                                            ? .28
                                            : .16),
                                    accentColor
                                        .withValues(alpha:
                                        isDark
                                            ? .14
                                            : .07),
                                  ],
                                ),
                              ),

                              child: Icon(
                                icon,
                                size: 21.sp,
                                color: accentColor,
                              ),
                            ),

                          // =====================================
                          // SPACE AFTER IMAGE / ICON
                          // =====================================

                          if (hasLottie || hasIcon)
                            SizedBox(height: 12.h),

                          // =====================================
                          // TITLE
                          // =====================================

                          Text(
                            title ?? 'delete'.tr,
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                              letterSpacing: -.2,
                            ),
                          ),

                          SizedBox(height: 5.h),

                          // =====================================
                          // MESSAGE
                          // =====================================

                          Text(
                            message.tr,
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.4,
                              color: descriptionColor,
                              fontWeight:
                              FontWeight.w400,
                            ),
                          ),

                          SizedBox(height: 18.h),

                          // =====================================
                          // BUTTONS
                          // =====================================

                          Row(
                            children: [

                              // CANCEL
                              Expanded(
                                child: AppButton(
                                  text: cancelText ??
                                      'cancel'.tr,

                                  height: 40.h,

                                  radius: 30,

                                  outlined: true,

                                  textColor: titleColor,

                                  borderSide:
                                  BorderSide(
                                    color:
                                    cancelBorderColor,
                                    width: 1.2,
                                  ),

                                  onPressed: isLoading
                                      ? null
                                      : () {
                                    Navigator.pop(
                                      context,
                                      false,
                                    );

                                    onCancel?.call();
                                  },
                                ),
                              ),

                              SizedBox(width: 10.w),

                              // CONFIRM
                              Expanded(
                                child: AppButton(
                                  text: confirmText ??
                                      'delete'.tr,

                                  height: 40.h,

                                  radius: 30,

                                  backgroundColor:
                                  confirmButtonColor,

                                  isLoading: isLoading && showConfirmLoading,

                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                    setState(() {
                                      isLoading =
                                      true;
                                    });

                                    try {
                                      await onConfirm();

                                      if (popOnConfirm && context.mounted) {
                                        Navigator.pop(
                                          context,
                                          true,
                                        );
                                      }
                                    } catch (e) {
                                      if (context
                                          .mounted) {
                                        setState(() {
                                          isLoading =
                                          false;
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final String? image;
  final bool isIcon;
  final bool tintIcon;
  final bool isLoading;
  final bool outlined;
  final double radius;
  final double? width;
  final double? height;
  final BorderSide? borderSide;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.image,
    this.isIcon = false,
    this.tintIcon = true,
    this.isLoading = false,
    this.outlined = false,
    this.radius = 14,
    this.width,
    this.height,
    this.borderSide,
  });

  /// The ink a filled button's label is drawn in, chosen so that it can be READ on the fill.
  ///
  /// ────────────────────────────────────────────────────────────────────────────────────────────
  /// WHY THIS IS NOT JUST `Colors.white`, WHICH IS WHAT IT WAS
  /// ────────────────────────────────────────────────────────────────────────────────────────────
  ///
  /// A filled `AppButton` used to draw its label white whatever the fill. On the navy primary that
  /// is 14.43:1 and right. On a RED it is not, and red is what every destructive confirmation in
  /// this application uses: twelve `AppDialog.showCustomDialog` call sites pass one of four reds
  /// as `confirmColor`, and white fails SC 1.4.3 on three of them —
  ///
  ///     AppColor.cRedText  #dc0303  light   5.18:1  ok
  ///     AppColor.cRedText  #FF6B6B  dark    2.78:1  FAIL   <- 7 call sites, dark mode
  ///     Colors.red         #F44336          3.68:1  FAIL   <- 4 call sites
  ///     danger             #EF4444          3.76:1  FAIL   <- 1 call site
  ///
  /// — so the label on "delete this customer", "delete this order", "delete this product" was
  /// under the minimum in at least one theme at every one of those sites. MEASURED FROM A
  /// RENDERED CAPTURE, not from the token: the confirm button was photographed in all four
  /// combinations and its pixels sampled, white `#FFFFFF` on `#EF4444`, 3.76:1.
  ///
  /// The label is 14.sp at `FontWeight.w600`, which is nowhere near WCAG's large-text threshold
  /// (18.66px AND bold, or 24px), so 4.5:1 is the bar and not 3:1.
  ///
  /// ────────────────────────────────────────────────────────────────────────────────────────────
  /// THE RULE, AND WHY IT CANNOT MAKE ANYTHING WORSE
  /// ────────────────────────────────────────────────────────────────────────────────────────────
  ///
  /// Take whichever of white and the app's near-black ink contrasts BETTER with the fill. A
  /// button whose white label already passes keeps it — white wins on every dark fill in this
  /// app, the navy primary included — so the only labels that change are ones that were failing.
  /// The design system reaches the same answer from the other side: `--ss-on-danger` is `#ffffff`
  /// in a light scope and `#3b0d0a` in a dark one, because its danger fill inverts between them.
  ///
  /// `#14161B` is this file's own `titleColor` for light mode, not a new value.
  ///
  /// An explicit `textColor:` from the caller still wins: this only decides the DEFAULT.
  ///
  /// Pinned by `test/a11y/dialog_confirm_label_contrast_test.dart`, which measures every colour
  /// the twelve call sites actually pass and fails if a thirteenth introduces an unmeasured one.
  static Color labelFor(Color background) {
    const Color ink = Color(0xFF14161B);

    return _contrast(Colors.white, background) >= _contrast(ink, background)
        ? Colors.white
        : ink;
  }

  /// WCAG 2.1 relative luminance, and the ratio built from it. Written out rather than taken from
  /// `ThemeData.estimateBrightnessForColor`, which switches on a 0.15 luminance threshold and so
  /// answers "is this dark?" — a different question from "can the label be read?", and one that
  /// gives the wrong answer for exactly the mid-tone reds above.
  static double _luminance(Color c) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  }

  static double _contrast(Color a, Color b) {
    final double la = _luminance(a) + 0.05;
    final double lb = _luminance(b) + 0.05;

    return la > lb ? la / lb : lb / la;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color btnBackground = outlined
        ? Colors.transparent
        : (backgroundColor ?? AppColor.themeNavyBlueColor);

    final Color btnTextColor = textColor ??
        (outlined
            ? (isDark ? Colors.white : AppColor.cText)
            : labelFor(btnBackground));

    final BorderSide side = borderSide ??
        BorderSide(
          color: isDark
              ? Colors.white24
              : AppColor.cBorder,
        );

    return SizedBox(
      width: width,
      height: height ?? 48.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: btnBackground,
          foregroundColor: btnTextColor,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          side: outlined ? side : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.r),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 10.h,
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor:
            AlwaysStoppedAnimation(btnTextColor),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isIcon && image != null) ...[
              Image.asset(
                image!,
                width: 20.w,
                height: 20.h,
                color: tintIcon ? btnTextColor : null,
              ),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: btnTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
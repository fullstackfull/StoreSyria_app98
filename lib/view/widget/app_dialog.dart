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
      barrierColor: Colors.black.withOpacity(.45),
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
                ? Colors.white.withOpacity(.14)
                : const Color(0xFFE3E5EA);

            final dialogBorderColor =
            accentColor.withOpacity(
              isDark ? .55 : .45,
            );

            final hasLottie =
                lottieAsset != null &&
                    lottieAsset!.trim().isNotEmpty;

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
                          color: Colors.black.withOpacity(
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
                                        .withOpacity(
                                        isDark
                                            ? .28
                                            : .16),
                                    accentColor
                                        .withOpacity(
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color btnBackground = outlined
        ? Colors.transparent
        : (backgroundColor ?? AppColor.themeNavyBlueColor);

    final Color btnTextColor = textColor ??
        (outlined
            ? (isDark ? Colors.white : AppColor.cText)
            : Colors.white);

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
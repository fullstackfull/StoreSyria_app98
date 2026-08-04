import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> showCustomDialog({
    required BuildContext context,
    String? title,
    String? message,
    bool showConfirmLoading = true,
    String? confirmText,
    String? cancelText,
    required Future<void> Function() onConfirm,
    VoidCallback? onCancel,
    IconData icon = Icons.info_outline_rounded,
    Color? iconColor,
    Color? confirmColor,
    bool barrierDismissible = true,
  }) {
    bool isLoading = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            final bgColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
            final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
            final subTextColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;
            final primaryBtnColor = confirmColor ?? AppColor.themeNavyBlueColor;
            final cancelBtnColor = isDark ? DarkThemeColor.cBorder : AppColor.cButton;
            final accentIconColor = iconColor ?? AppColor.themeGreenColor;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              backgroundColor: bgColor,
              insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: accentIconColor.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: accentIconColor,
                        size: 32.r,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      title ?? 'delete'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      message ?? 'deleteConfirm'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: subTextColor,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: confirmText ?? 'delete'.tr,
                            backgroundColor: primaryBtnColor,
                            textColor: Colors.white,
                            isLoading: showConfirmLoading ? isLoading : false,
                            onPressed: isLoading
                                ? null
                                : () async {
                              if (!dialogContext.mounted) return;
                              setState(() => isLoading = true);
                              try {
                                await onConfirm();
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext, true);
                                }
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: AppButton(
                            text: cancelText ?? 'cancel'.tr,
                            backgroundColor: cancelBtnColor,
                            textColor: textColor,
                            onPressed: isLoading
                                ? null
                                : () {
                              Navigator.pop(dialogContext, false);
                              onCancel?.call();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
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
            vertical: 12.h,
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
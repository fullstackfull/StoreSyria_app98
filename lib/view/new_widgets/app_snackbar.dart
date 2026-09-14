import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum AppSnackBarType {
  success,
  error,
  info,
  warning,
}

class AppSnackBar {
  AppSnackBar._();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color successColor = Color(0xFF16A34A);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color infoColor = Color(0xFF2563EB);
  static const Color warningColor = Color(0xFFD97706);

  // ============================================================
  // PUBLIC METHODS
  // ============================================================

  static void success({
    required String title,
    String message = '',
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(
        type: AppSnackBarType.success,
        title: title,
        message: message,
        duration: duration,
      );

  static void error({
    required String title,
    String message = '',
    Duration duration = const Duration(seconds: 4),
  }) =>
      _show(
        type: AppSnackBarType.error,
        title: title,
        message: message,
        duration: duration,
      );

  static void info({
    required String title,
    String message = '',
    Duration duration = const Duration(seconds: 3),
  }) =>
      _show(
        type: AppSnackBarType.info,
        title: title,
        message: message,
        duration: duration,
      );

  static void warning({
    required String title,
    String message = '',
    Duration duration = const Duration(seconds: 4),
  }) =>
      _show(
        type: AppSnackBarType.warning,
        title: title,
        message: message,
        duration: duration,
      );

  static void _show({
    required AppSnackBarType type,
    required String title,
    required String message,
    required Duration duration,
  }) {
    final config = _getConfig(type);

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,

      overlayBlur: 0.0,
      barBlur: 0.0,
      backgroundColor: Colors.transparent,
      overlayColor: Colors.transparent,

      margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      padding: EdgeInsets.zero,
      borderRadius: 0,
      isDismissible: true,
      duration: duration,
      animationDuration: const Duration(milliseconds: 220),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,

      messageText: _SnackBarContent(
        title: title,
        message: message,
        icon: config.icon,
        color: config.color,
        onClose: () => Get.closeCurrentSnackbar(),
      ),
    );
  }

  // ============================================================
  // CONFIG HELPER
  // ============================================================

  static _SnackBarConfig _getConfig(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return const _SnackBarConfig(
          color: successColor,
          icon: Icons.check_circle_rounded,
        );
      case AppSnackBarType.error:
        return const _SnackBarConfig(
          color: errorColor,
          icon: Icons.error_rounded,
        );
      case AppSnackBarType.info:
        return const _SnackBarConfig(
          color: infoColor,
          icon: Icons.info_rounded,
        );
      case AppSnackBarType.warning:
        return const _SnackBarConfig(
          color: warningColor,
          icon: Icons.warning_rounded,
        );
    }
  }
}

// ============================================================
// INTERNAL CONFIG MODEL
// ============================================================

class _SnackBarConfig {
  final Color color;
  final IconData icon;

  const _SnackBarConfig({
    required this.color,
    required this.icon,
  });
}

// ============================================================
// CUSTOM SNACKBAR CONTENT WIDGET (slim / minimal)
// ============================================================

class _SnackBarContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onClose;

  const _SnackBarContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color titleColor =
    isDark ? Colors.white : const Color(0xFF0F172A);
    final Color msgColor =
    isDark ? Colors.white60 : const Color(0xFF94A3B8);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 48.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // شريط لون رفيع بدل الدائرة الكبيرة
              Container(
                width: 3.5.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 9.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon, size: 16.sp, color: color),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                                height: 1.2,
                              ),
                            ),
                            if (message.trim().isNotEmpty) ...[
                              SizedBox(height: 1.h),
                              Text(
                                message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  color: msgColor,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: onClose,
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14.sp,
                            color: msgColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
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

  static const Color navyBlue = Color(0xFF172C4E);

  static const Color successColor = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFEAF7EF);

  static const Color errorColor = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFCEBEA);

  static const Color infoColor = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFEAF1FD);

  static const Color warningColor = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFCF3E7);

  // ============================================================
  // SUCCESS
  // ============================================================

  static void success({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      type: AppSnackBarType.success,
      title: title,
      message: message,
      duration: duration,
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  static void error({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      type: AppSnackBarType.error,
      title: title,
      message: message,
      duration: duration,
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  static void info({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      type: AppSnackBarType.info,
      title: title,
      message: message,
      duration: duration,
    );
  }

  // ============================================================
  // WARNING
  // ============================================================

  static void warning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      type: AppSnackBarType.warning,
      title: title,
      message: message,
      duration: duration,
    );
  }

  // ============================================================
  // SHOW
  // ============================================================

  static void show({
    required AppSnackBarType type,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);

    Get.closeCurrentSnackbar();

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: EdgeInsets.zero,
      borderRadius: 14,
      backgroundColor: Colors.transparent,
      boxShadows: const [],
      isDismissible: true,
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,

      // مهم حتى نستخدم Widget الخاص بنا
      messageText: _SnackBarContent(
        title: title,
        message: message,
        icon: config.icon,
        color: config.color,
        bgColor: config.bgColor,
        onClose: Get.closeCurrentSnackbar,
      ),
    );
  }

  // ============================================================
  // CONFIG
  // ============================================================

  static _SnackBarConfig _getConfig(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return const _SnackBarConfig(
          color: successColor,
          bgColor: successBg,
          icon: Icons.check_circle_rounded,
        );

      case AppSnackBarType.error:
        return const _SnackBarConfig(
          color: errorColor,
          bgColor: errorBg,
          icon: Icons.cancel_rounded,
        );

      case AppSnackBarType.info:
        return const _SnackBarConfig(
          color: infoColor,
          bgColor: infoBg,
          icon: Icons.info_rounded,
        );

      case AppSnackBarType.warning:
        return const _SnackBarConfig(
          color: warningColor,
          bgColor: warningBg,
          icon: Icons.warning_rounded,
        );
    }
  }
}

// ============================================================
// CONFIG
// ============================================================

class _SnackBarConfig {
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _SnackBarConfig({
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}

// ============================================================
// CONTENT
// ============================================================

class _SnackBarContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onClose;

  const _SnackBarContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDark
        ? const Color(0xFF182331)
        : Colors.white;

    final Color titleColor = isDark
        ? Colors.white
        : const Color(0xFF172C4E);

    final Color messageColor = isDark
        ? Colors.white70
        : const Color(0xFF687386);

    final Color iconBg = isDark ? color.withAlpha(38) : bgColor;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 68,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),

          // ======================================================
          // ICON
          // ======================================================

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          // ======================================================
          // TEXT
          // ======================================================

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                      color: messageColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // CLOSE
          // ======================================================

          Padding(
            padding: const EdgeInsets.only(right: 6, left: 2),
            child: IconButton(
              onPressed: onClose,
              splashRadius: 18,
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: isDark
                    ? Colors.white54
                    : const Color(0xFF98A1AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
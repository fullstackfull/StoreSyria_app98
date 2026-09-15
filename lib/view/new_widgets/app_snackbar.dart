import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackBar {
  static void success({
    required String title,
    required String message,
  }) {
    _show(
      title: title,
      message: message,
      icon: Icons.check_rounded,
      color: const Color(0xFF22A06B),
    );
  }

  static void error({
    required String title,
    required String message,
  }) {
    _show(
      title: title,
      message: message,
      icon: Icons.close_rounded,
      color: const Color(0xFFD64545),
    );
  }

  static void warning({
    required String title,
    required String message,
  }) {
    _show(
      title: title,
      message: message,
      icon: Icons.priority_high_rounded,
      color: const Color(0xFFD99A16),
    );
  }

  static void info({
    required String title,
    required String message,
  }) {
    _show(
      title: title,
      message: message,
      icon: Icons.info_outline_rounded,
      color: const Color(0xFF3478C8),
    );
  }

  static void _show({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    Get.closeCurrentSnackbar();

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      barBlur: 1,
      backgroundColor: Colors.transparent,
      boxShadows: const [],
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      borderRadius: 0,
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      titleText: const SizedBox.shrink(),
      messageText: _SnackBarContent(
        title: title,
        message: message,
        icon: icon,
        color: color,
      ),
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _SnackBarContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 72,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              children: [
// خط الحالة
                Container(
                  width: 4,
                  color: color,
                ),

                const SizedBox(width: 14),

// الأيقونة
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

// النص
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF202124),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6B6F76),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

// زر الإغلاق
                IconButton(
                  onPressed: Get.closeCurrentSnackbar,
                  splashRadius: 20,
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF9A9DA3),
                  ),
                ),

                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

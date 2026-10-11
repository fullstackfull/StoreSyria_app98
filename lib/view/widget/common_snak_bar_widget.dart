import 'dart:async';
import 'dart:ui'; // تأكد من استيراد هذه المكتبة إذا كنت تريد إضافة الغباشة لاحقاً

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================================
// PUBLIC TYPE
// ============================================================

enum AppSnackBarType {
 success,
 error,
 warning,
 info,
}

// ============================================================
// INTERNAL TYPE
// ============================================================

enum _SnackType {
 success,
 error,
 warning,
 info,
}

// ============================================================
// COMMON TOAST
// ============================================================

void commonToast(
    String msg, {
     AppSnackBarType type = AppSnackBarType.success,
    }) {
 switch (type) {
  case AppSnackBarType.success:
   AppSnackBar.success(title: msg);
   break;

  case AppSnackBarType.error:
   AppSnackBar.error(title: msg);
   break;

  case AppSnackBarType.warning:
   AppSnackBar.warning(title: msg);
   break;

  case AppSnackBarType.info:
   AppSnackBar.info(title: msg);
   break;
 }
}

// ============================================================
// STYLE
// ============================================================

class _SnackStyle {
 final IconData icon;
 final Color color;

 const _SnackStyle({
  required this.icon,
  required this.color,
 });
}

const Map<_SnackType, _SnackStyle> _styles = {
 _SnackType.success: _SnackStyle(
  icon: Icons.check_circle_rounded,
  color: Color(0xFF16A34A),
 ),
 _SnackType.error: _SnackStyle(
  icon: Icons.error_rounded,
  color: Color(0xFFDC2626),
 ),
 _SnackType.warning: _SnackStyle(
  icon: Icons.warning_rounded,
  color: Color(0xFFD97706),
 ),
 _SnackType.info: _SnackStyle(
  icon: Icons.info_rounded,
  color: Color(0xFF1C53C7),
 ),
};

// ============================================================
// PUBLIC API
// ============================================================

class AppSnackBar {
 AppSnackBar._();

 static void success({
  required String title,
  String message = '',
  Duration duration = const Duration(seconds: 3),
 }) {
  _show(
   type: _SnackType.success,
   title: title,
   message: message,
   duration: duration,
  );
 }

 static void error({
  required String title,
  String message = '',
  Duration duration = const Duration(seconds: 3),
 }) {
  _show(
   type: _SnackType.error,
   title: title,
   message: message,
   duration: duration,
  );
 }

 static void warning({
  required String title,
  String message = '',
  Duration duration = const Duration(seconds: 3),
 }) {
  _show(
   type: _SnackType.warning,
   title: title,
   message: message,
   duration: duration,
  );
 }

 static void info({
  required String title,
  String message = '',
  Duration duration = const Duration(seconds: 3),
 }) {
  _show(
   type: _SnackType.info,
   title: title,
   message: message,
   duration: duration,
  );
 }

 static void _show({
  required _SnackType type,
  required String title,
  required String message,
  required Duration duration,
 }) {
  _AppSnackBarController.show(
   type: type,
   title: title,
   message: message,
   duration: duration,
  );
 }
}

// ============================================================
// CONTROLLER
// ============================================================

class _AppSnackBarController {
 static OverlayEntry? _entry;
 static Timer? _timer;

 static void show({
  required _SnackType type,
  required String title,
  required String message,
  required Duration duration,
 }) {
  final context = Get.overlayContext;

  if (context == null) return;

  _remove();

  final overlay = Overlay.of(
   context,
   rootOverlay: true,
  );

  _entry = OverlayEntry(
   builder: (_) {
    return _SimpleSnackBar(
     type: type,
     title: title,
     message: message,
     onClose: _remove,
    );
   },
  );

  overlay.insert(_entry!);

  _timer = Timer(
   duration,
   _remove,
  );
 }

 static void _remove() {
  _timer?.cancel();
  _timer = null;

  final entry = _entry;

  _entry = null;

  entry?.remove();
 }
}

// ============================================================
// SNACKBAR
// ============================================================

class _SimpleSnackBar extends StatefulWidget {
 final _SnackType type;
 final String title;
 final String message;
 final VoidCallback onClose;

 const _SimpleSnackBar({
  required this.type,
  required this.title,
  required this.message,
  required this.onClose,
 });

 @override
 State<_SimpleSnackBar> createState() {
  return _SimpleSnackBarState();
 }
}

// ============================================================
// STATE
// ============================================================

class _SimpleSnackBarState extends State<_SimpleSnackBar>
    with SingleTickerProviderStateMixin {
 late final AnimationController _animationController;

 late final Animation<Offset> _slideAnimation;

 late final Animation<double> _fadeAnimation;

 @override
 void initState() {
  super.initState();

  _animationController = AnimationController(
   vsync: this,
   duration: const Duration(
    milliseconds: 250,
   ),
  );

  _slideAnimation = Tween<Offset>(
   begin: const Offset(0, -0.8),
   end: Offset.zero,
  ).animate(
   CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOutCubic,
   ),
  );

  _fadeAnimation = CurvedAnimation(
   parent: _animationController,
   curve: Curves.easeOut,
  );

  _animationController.forward();
 }

 @override
 void dispose() {
  _animationController.dispose();
  super.dispose();
 }

 @override
 Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final style = _styles[widget.type]!;

  final backgroundColor = isDark ? const Color(0xFF18263F) : Colors.white;

  final titleColor = isDark ? Colors.white : const Color(0xFF0F1A2E);

  final messageColor = isDark ? const Color(0xFFA9B8D0) : const Color(0xFF6B7280);

  return Positioned(
   top: MediaQuery.of(context).padding.top + 12,
   left: 16,
   right: 16,
   child: SafeArea(
    bottom: false,
    child: SlideTransition(
     position: _slideAnimation,
     child: FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
       color: Colors.transparent,
       child: Container(
        padding: const EdgeInsets.symmetric(
         horizontal: 12,
         vertical: 10,
        ),
        decoration: BoxDecoration(
         color: backgroundColor,
         borderRadius: BorderRadius.circular(14),
         // ==================================================
         // تعديل الحواف لتكون بلون النوع (Type Color)
         // ==================================================
         border: Border.all(
          color: style.color.withOpacity(isDark ? 0.6 : 0.3),
          width: 1.2,
         ),
         boxShadow: [
          BoxShadow(
           color: style.color.withOpacity(isDark ? 0.18 : 0.10),
           blurRadius: 18,
           offset: const Offset(0, 6),
          ),
         ],
        ),
        child: Row(
         children: [
          // ==================================================
          // ICON
          // ==================================================

          Container(
           width: 34,
           height: 34,
           decoration: BoxDecoration(
            color: style.color.withOpacity(.10),
            shape: BoxShape.circle,
           ),
           child: Icon(
            style.icon,
            color: style.color,
            size: 20,
           ),
          ),

          const SizedBox(width: 10),

          // ==================================================
          // TEXT
          // ==================================================

          Expanded(
           child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
               fontSize: 13.5,
               fontWeight: FontWeight.w700,
               color: titleColor,
               height: 1.2,
              ),
             ),

             if (widget.message.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
               widget.message,
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
               style: TextStyle(
                fontSize: 11.5,
                color: messageColor,
                height: 1.3,
               ),
              ),
             ],
            ],
           ),
          ),

          const SizedBox(width: 6),

          // ==================================================
          // CLOSE
          // ==================================================

          InkWell(
           onTap: widget.onClose,
           borderRadius: BorderRadius.circular(20),
           child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
             Icons.close_rounded,
             size: 18,
             color: isDark
                 ? const Color(0xFFA9B8D0)
                 : const Color(0xFF9CA3AF),
            ),
           ),
          ),
         ],
        ),
       ),
      ),
     ),
    ),
   ),
  );
 }
}
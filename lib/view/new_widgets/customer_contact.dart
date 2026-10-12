import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:store_go_app/utils/colors.dart';
import 'app_snackbar.dart';

class CustomerContactActions extends StatelessWidget {
  final String? phone;
  final String? email;
  final bool isDark;

  const CustomerContactActions({
    super.key,
    this.phone,
    this.email,
    required this.isDark,
  });

  static const Color _whatsappGreen = Color(0xFF1FA855);

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Future<void> _launch(Uri uri) async {
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!ok) {
        AppSnackBar.info(
          title: 'error',
          message: 'could_not_open',
        );
      }
    } catch (_) {
      AppSnackBar.info(
        title: 'error',
        message: 'could_not_open',
      );
    }
  }

  void _callCustomer() {
    if (!_hasValue(phone)) return;

    _launch(
      Uri(
        scheme: 'tel',
        path: phone!.trim(),
      ),
    );
  }

  void _whatsappCustomer() {
    if (!_hasValue(phone)) return;

    final cleaned = phone!.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    _launch(
      Uri.parse('https://wa.me/$cleaned'),
    );
  }

  void _emailCustomer() {
    if (!_hasValue(email)) return;

    _launch(
      Uri(
        scheme: 'mailto',
        path: email!.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = _hasValue(phone);
    final hasEmail = _hasValue(email);

    if (!hasPhone && !hasEmail) {
      return const SizedBox.shrink();
    }

    final labelColor = isDark ? Colors.white : const Color(0xFF172C4E);

    final actions = <Widget>[
      if (hasPhone)
        _action(
          icon: Icons.call_rounded,
          label: 'call'.tr,
          accent: AppColor.themeGreenColor,
          labelColor: labelColor,
          onTap: _callCustomer,
        ),
      if (hasPhone)
        _action(
          icon: Icons.chat_rounded,
          label: 'whatsapp'.tr,
          accent: _whatsappGreen,
          labelColor: labelColor,
          onTap: _whatsappCustomer,
        ),
      if (hasEmail)
        _action(
          icon: Icons.mail_rounded,
          label: 'email2'.tr,
          accent: AppColor.themeNavyBlueColor,
          labelColor: labelColor,
          onTap: _emailCustomer,
        ),
    ];

    // فراغ ثابت بين الأزرار
    final children = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      if (i > 0) children.add(SizedBox(width: 8.w));
      children.add(Expanded(child: actions[i]));
    }

    return Row(children: children);
  }

  Widget _action({
    required IconData icon,
    required String label,
    required Color accent,
    required Color labelColor,
    required VoidCallback onTap,
  }) {
    // الكحلي غامق كتير على الخلفية الداكنة، فنفتّحه شوي
    final isNavy = accent == AppColor.themeNavyBlueColor;
    final tone = isDark && isNavy ? const Color(0xFF8FB0E0) : accent;

    // زر كبسولة أفقي: أيقونة ونص جنب بعض بلون الإجراء
    return Material(
      color: tone.withValues(alpha: isDark ? 0.14 : 0.10),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: tone.withValues(alpha: 0.18),
        highlightColor: tone.withValues(alpha: 0.08),
        child: SizedBox(
          height: 42.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18.sp, color: tone),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? tone : Color.lerp(tone, labelColor, 0.25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

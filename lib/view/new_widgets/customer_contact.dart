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

    final cardColor = isDark
        ? DarkThemeColor.cCardBackground
        : Colors.white;

    final borderColor = isDark
        ? DarkThemeColor.cBorder
        : const Color(0xFFE8EAF0);

    final textColor = isDark
        ? Colors.white
        : AppColor.cText;

    final iconBackground = isDark
        ? Colors.white.withOpacity(.06)
        : const Color(0xFFF5F6F8);

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? .08 : .035,
            ),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (hasPhone)
            Expanded(
              child: _action(
                icon: Icons.call_outlined,
                label: 'call'.tr,
                textColor: textColor,
                iconBackground: iconBackground,
                onTap: _callCustomer,
              ),
            ),

          if (hasPhone && (hasEmail))
            Container(
              width: 1.w,
              height: 38.h,
              color: borderColor,
            ),

          if (hasPhone)
            Expanded(
              child: _action(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'whatsapp'.tr,
                textColor: textColor,
                iconBackground: iconBackground,
                onTap: _whatsappCustomer,
              ),
            ),

          if (hasPhone && hasEmail)
            Container(
              width: 1.w,
              height: 38.h,
              color: borderColor,
            ),

          if (hasEmail)
            Expanded(
              child: _action(
                icon: Icons.mail_outline_rounded,
                label: 'email2'.tr,
                textColor: textColor,
                iconBackground: iconBackground,
                onTap: _emailCustomer,
              ),
            ),
        ],
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required Color textColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.h,
            horizontal: 4.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: AppColor.themeNavyBlueColor,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
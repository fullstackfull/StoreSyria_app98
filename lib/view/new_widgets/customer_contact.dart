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

    return Row(
      children: [
        if (hasPhone)
          Expanded(
            child: _contactAction(
              icon: Icons.call_outlined,
              label: 'call'.tr,
              onTap: _callCustomer,
            ),
          ),

        if (hasPhone)
          SizedBox(width: 10.w),

        if (hasPhone)
          Expanded(
            child: _contactAction(
              icon: Icons.chat_outlined,
              label: 'whatsapp'.tr,
              onTap: _whatsappCustomer,
            ),
          ),

        if (hasEmail) ...[
          if (hasPhone)
            SizedBox(width: 10.w),

          Expanded(
            child: _contactAction(
              icon: Icons.mail_outline_rounded,
              label: 'email2'.tr,
              onTap: _emailCustomer,
            ),
          ),
        ],
      ],
    );
  }

  Widget _contactAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(.15)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white
                    : AppColor.themeNavyBlueColor,
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              icon,
              size: 14.sp,
              color: AppColor.themeNavyBlueColor,
            ),
          ],
        ),
      ),
    );
  }
}
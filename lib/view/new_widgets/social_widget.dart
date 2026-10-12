import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/controller/setting_controller/store_setting_controller.dart';
import '../../utils/colors.dart';
import '../../utils/validator.dart';
import '../widget/icon_and_image.dart';

class SocialMediaSection extends StatelessWidget {
  final StoreSettingController controller;

  const SocialMediaSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme
            .of(context)
            .brightness == Brightness.dark;

    final Color cardColor =
    isDark ? const Color(0xFF18263F) : Colors.white;

    final Color titleColor =
    isDark ? Colors.white : const Color(0xFF172C4E);

    final Color iconBackground = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFF172C4E).withValues(alpha: 0.06);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE5E8ED),
        ),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.share_outlined,
                  color: AppColor.themeNavyBlueColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Social Media',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          SocialMediaField(
            title: 'Facebook',
            hint: 'Facebook link',
            controller: controller.facebookController,
            iconWidget: assetImageWidget(
              image: 'assets/icon/facebook.png',
              width: 24.w,
              height: 24.w,
            ),
            keyboardType: TextInputType.url,
            validator: (value) =>
                Validator.validateOptionalUrl(value!),
          ),

          SizedBox(height: 14.h),

          SocialMediaField(
            title: 'Twitter / X',
            hint: 'Twitter / X link',
            controller: controller.twitterController,
            iconWidget: assetImageWidget(
              image: 'assets/icon/twitter.png',
              width: 24.w,
              height: 24.w,
            ),
            keyboardType: TextInputType.url,
            validator: (value) =>
                Validator.validateOptionalUrl(value!),
          ),

          SizedBox(height: 14.h),

          SocialMediaField(
            title: 'Instagram',
            hint: 'Instagram link',
            controller: controller.instagramController,
            iconWidget: assetImageWidget(
              image: 'assets/icon/instagram.png',
              width: 24.w,
              height: 24.w,
            ),
            keyboardType: TextInputType.url,
            validator: (value) =>
                Validator.validateOptionalUrl(value!),
          ),

          SizedBox(height: 14.h),

          SocialMediaField(
            title: 'WhatsApp',
            hint: 'WhatsApp link',
            controller: controller.whatsappController,
            iconWidget: assetImageWidget(
              image: 'assets/icon/whatsapp.png',
              width: 24.w,
              height: 24.w,
            ),
            keyboardType: TextInputType.url,
            validator: (value) =>
                Validator.validateOptionalUrl(value!),
          ),

          SizedBox(height: 14.h),

          SocialMediaField(
            title: 'Telegram',
            hint: 'Telegram link',
            controller: controller.telegramController,
            iconWidget: assetImageWidget(
              image: 'assets/icon/telegram.png',
              width: 24.w,
              height: 24.w,
            ),
            keyboardType: TextInputType.url,
            validator: (value) =>
                Validator.validateOptionalUrl(value!),
          ),

        ],
      ),
    );
  }
}

class SocialMediaField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final Widget iconWidget;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const SocialMediaField({
    Key? key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.iconWidget,
    this.keyboardType = TextInputType.text,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white70
                : const Color(0xFF687386),
          ),
        ),

        SizedBox(height: 8.h),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),

            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
              ),
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: iconWidget,
              ),
            ),

            prefixIconConstraints: BoxConstraints(
              minWidth: 52.w,
              minHeight: 24.w,
            ),

            filled: true,

            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF7F8FA),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E6EC),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E6EC),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColor.themeNavyBlueColor,
                width: 1.3,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/images.dart';
import '../widget/icon_and_image.dart';

Widget MyPlanCard({
  required BuildContext context,
  required bool isDark,
  required dynamic plan,
  required int storeId,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      border: Border.all(color: AppColor.themeNavyBlueColor.withValues(alpha: 0.3)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColor.themeNavyBlueColor,
          AppColor.themeNavyBlueColor,
          AppColor.themeGreenColor,
        ],
      ),
      borderRadius: BorderRadius.circular(22.r),
      boxShadow: [
        BoxShadow(
          color: AppColor.themeNavyBlueColor.withValues(alpha: 0.3),
          offset: const Offset(0, 8),
          blurRadius: 20,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            assetSvdImageWidget(
                image: DefaultImages.myPlanImg,
                width: 30.w,
                height: 30.h
            ),
            Text(
              " ${plan.name}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              plan.priceDisplay,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
              ),
            ),

            const Spacer(),

            if (plan.planStatus.isExpired)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'expired'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'active'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        Divider(color: Colors.grey.shade400,indent: 4.w,endIndent: 4.w),
        SizedBox(height: 10.h),
        Row(
          children: [
            Icon(
              Icons.event_outlined,
              color: Colors.white.withValues(alpha: .8),
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '${'expire_date'.tr}: '
                  '${plan.planStatus.planExpireDate}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .9),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        if (plan.planStatus.isExpired) ...[
          SizedBox(height: 10.h),
          Text(
            plan.planStatus.expireMessage,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .75),
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    ),
  );
}

Widget sectionTitle({
  required String title,
  required bool isDark,
}) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 17.sp,
      fontWeight: FontWeight.w700,
      color: isDark
          ? Colors.white
          : const Color(0xFF15171A),
    ),
  );
}

Widget usageCard({
  required String title,
  required int used,
  required int max,
  required int remaining,
  required double percentage,
  required IconData icon,
  required bool isDark,
}) {
  final Color cardColor =
  isDark ? const Color(0xFF18263F) : Colors.white;

  final Color textColor =
  isDark ? Colors.white : const Color(0xFF0F1A2E);

  final Color secondaryColor =
  isDark ? const Color(0xFFA9B8D0) : const Color(0xFF777D87);

  final double progress =
  (percentage / 100).clamp(0.0, 1.0);

  return Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16.r),
      // border: Border.all(
      //   color: isDark
      //       ? Colors.white.withValues(alpha: .06)
      //       : AppColor.cBorder,
      // ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColor.themeNavyBlueColor
                    .withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: AppColor.themeNavyBlueColor,
                size: 21.sp,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Text(
              '$used / $max',
              style: TextStyle(
                color: textColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        SizedBox(height: 13.h),

        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7.h,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: .08)
                : const Color(0xFFEDEFF2),
            valueColor: AlwaysStoppedAnimation<Color>(
                percentage < 50
                    ? Colors.green.shade300
                    : percentage < 90
                    ? Colors.orange.shade300
                    : Colors.red.shade300
            ),
          ),
        ),

        SizedBox(height: 8.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 11.sp,
              ),
            ),
            Text(
              '$remaining ${'remaining'.tr}',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget detailsCard({
  required bool isDark,
  required List<Widget> children,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: 16.w,
      vertical: 4.h,
    ),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF18263F) : Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      // border: Border.all(
      //   color: isDark
      //       ? Colors.white.withValues(alpha: .06)
      //       : const Color(0xFFE8EAEE),
      // ),
    ),
    child: Column(
      children: children,
    ),
  );
}

Widget detailRow({
  required String title,
  required String value,
  required IconData icon,
  required bool isDark,
  Color? valueColor,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 14.h),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppColor.themeNavyBlueColor,
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? const Color(0xFFA9B8D0)
                  : AppColor.themeNavyBlueColor,
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ??
                (isDark
                    ? Colors.white
                    : const Color(0xFF15171A)),
          ),
        ),
      ],
    ),
  );
}

Widget divider(bool isDark) {
  return Divider(
    height: 1,
    color: isDark
        ? Colors.white.withValues(alpha: .06)
        : const Color(0xFFE8EAEE),
  );
}

Widget featuresCard({
  required bool isDark,
  required dynamic plan,
}) {
  final features = [
    _FeatureItem(
      title: 'custom_domain'.tr,
      enabled: plan.features.customDomain,
      icon: Icons.language_outlined,
    ),
    _FeatureItem(
      title: 'sub_domain'.tr,
      enabled: plan.features.subDomain,
      icon: Icons.public_outlined,
    ),
    _FeatureItem(
      title: 'chatgpt'.tr,
      enabled: plan.features.chatgpt,
      icon: Icons.auto_awesome_outlined,
    ),
    _FeatureItem(
      title: 'pwa'.tr,
      enabled: plan.features.pwa,
      icon: Icons.phone_android_outlined,
    ),
    _FeatureItem(
      title: 'shipping_method'.tr,
      enabled: plan.features.shippingMethod,
      icon: Icons.local_shipping_outlined,
    ),
    _FeatureItem(
      title: 'enable_tax'.tr,
      enabled: plan.features.enableTax,
      icon: Icons.percent_outlined,
    ),
  ];

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF18263F) : Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      // border: Border.all(
      //   color: isDark
      //       ? Colors.white.withValues(alpha: .06)
      //       : const Color(0xFFE8EAEE),
      // ),
    ),
    child: Column(
      children: [
        ...features.map(
              (feature) => Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              children: [
                Icon(
                  feature.icon,
                  size: 20.sp,
                  color: feature.enabled
                      ? AppColor.themeNavyBlueColor
                      : const Color(0xFF9CA3AF),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    feature.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? Colors.white
                          : AppColor.themeNavyBlueColor,
                    ),
                  ),
                ),

                Icon(
                  feature.enabled
                      ? Icons.check_circle
                      : Icons.cancel_outlined,
                  size: 19.sp,
                  color: feature.enabled
                      ? Colors.green.shade300
                      : const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Row(
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 20.sp,
                color: AppColor.themeNavyBlueColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'storage'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF15171A),
                  ),
                ),
              ),
              Text(
                plan.features.storageLimit,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF15171A),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


class _FeatureItem {
  final String title;
  final bool enabled;
  final IconData icon;

  const _FeatureItem({
    required this.title,
    required this.enabled,
    required this.icon,
  });
}
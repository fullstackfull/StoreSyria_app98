import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import '../widget/common_space_divider_widget.dart';
import '../widget/icon_and_image.dart';

Widget settingCard({
  required String icon,
  required String title,
  String? subtitle,
  required bool isDark,
  required Function() function,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: function,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.cBackGround,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.18)
                  : AppColor.cBlack.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
          border: Border.all(
            color: isDark
                ? AppColor.cFont.withOpacity(0.05)
                : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColor.themeNavyBlueColor.withOpacity(0.12)
                        : AppColor.themeNavyBlueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: assetSvdImageWidget(
                      image: icon,
                      width: 27.w,
                      height: 27.h,
                      colorFilter: ColorFilter.mode(
                        isDark
                            ? AppColor.themeGreenColor.withOpacity(0.3)
                            : AppColor.themeNavyBlueColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColor.cFont.withOpacity(
                    isDark ? 0.4 : 0.5,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Card Title
            Text(
              title,
              style: pSemiBold16.copyWith(
                color: AppColor.themeNavyBlueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 5),

              // Card Subtitle
              Text(
                subtitle!,
                style: pMedium12.copyWith(
                  color: isDark
                      ? AppColor.cFont.withOpacity(0.55)
                      : AppColor.cFont.withOpacity(0.55),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget settingWidget({
  required String icon,
  required String title,
  required bool isDark,
  required Function() function,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: function,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColor.themeNavyBlueColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: assetSvdImageWidget(
                  image: icon,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
            ),

            horizontalSpace(14),

            Expanded(
              child: Text(
                title,
                style: pSemiBold16.copyWith(
                  color: AppColor.themeNavyBlueColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColor.cFont.withOpacity(0.35),
            ),
          ],
        ),
      ),
    ),
  );
}
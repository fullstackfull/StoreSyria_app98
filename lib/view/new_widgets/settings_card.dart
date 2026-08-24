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
                  : Colors.teal.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],

          border: Border.all(
            color: isDark
                ? AppColor.cFont.withOpacity(0.05)
                : Colors.transparent,
          ),
        ),

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.teal.withOpacity(0.12)
                        : Colors.teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: assetSvdImageWidget(
                      image: icon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isDark
                            ? Colors.tealAccent.shade100
                            : Colors.teal,
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

            Text(
              title,
              style: pMedium14.copyWith(
                color: AppColor.cFont,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: pRegular10.copyWith(
                  color: isDark
                      ? AppColor.cFont.withOpacity(0.55)
                      : Colors.grey,
                  fontSize: 9.sp,
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
                color: Colors.teal.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: assetSvdImageWidget(
                  image: icon,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.teal,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            horizontalSpace(14),

            Expanded(
              child: Text(
                title,
                style: pRegular14.copyWith(
                  color: AppColor.cFont,
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

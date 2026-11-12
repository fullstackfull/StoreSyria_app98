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
          color: isDark ? DarkThemeColor.cCardBackground : AppColor.cBackGround,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.18)
                  : AppColor.cBlack.withValues(alpha: 0.2),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
          border: Border.all(
            color: isDark
                ? AppColor.cFont.withValues(alpha: 0.05)
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
                        ? AppColor.themeNavyBlueColor.withValues(alpha: 0.12)
                        : AppColor.themeNavyBlueColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: assetSvdImageWidget(
                      image: icon,
                      width: 27.w,
                      height: 27.h,
                      colorFilter: ColorFilter.mode(
                        // The dark branch drew the icon at alpha 0.3 on its tinted circle --
                        // 1.89:1 -- while the light branch already used full opacity at 5.72:1,
                        // so the two themes disagreed about whether this was an illustration or
                        // an indicator. At full opacity dark measures 5.94:1 and they agree.
                        isDark
                            ? AppColor.themeGreenColor
                            : AppColor.themeNavyBlueColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  // The chevron is the signal that the card is a navigation target, so it is
                  // held to the 3:1 non-text threshold. At 0.4/0.5 it measured 2.38:1 in dark and
                  // 1.99:1 in light -- nothing on the card said it led anywhere. 0.8 gives
                  // 5.37:1 and 3.28:1 while still reading lighter than the subtitle beside it.
                  color: AppColor.cFont.withValues(alpha: 0.8),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (subtitle != null && subtitle.isNotEmpty) ...[
              const SizedBox(height: 5),

              // Card Subtitle
              Text(
                subtitle,
                style: pMedium12.copyWith(
                  // P2.5-FLUTTER-MORE-CARD. FULL OPACITY, AND NO BRANCH.
                  //
                  // This was `isDark ? ...alpha: 0.55 : ...alpha: 0.55` -- the same expression on
                  // both sides, which is not a choice but a value tuned once and copied, and it
                  // hid that one number was serving two very different backgrounds. Measured on
                  // the rendered card: **3.30:1 in dark and 2.15:1 in light**, against a 4.5:1
                  // threshold, for the only sentence that tells a merchant what each card does.
                  //
                  // `AppColor.cFont` is ALREADY the designed secondary tone -- `cSecondaryText`
                  // (#A9B8D0) in dark, `LightThemeColor.cFont` (#66728C) in light -- and clears
                  // the threshold on its own card at full opacity: 7.53:1 and 4.83:1. The alpha
                  // on top of it was the whole defect.
                  color: AppColor.cFont,
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
                color: AppColor.themeNavyBlueColor.withValues(alpha: 0.06),
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
              color: AppColor.cFont.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    ),
  );
}
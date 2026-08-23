import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import '../widget/icon_and_image.dart';

Widget settingCard({
  required String icon,
  required String title,
  String? subtitle,
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
              color: AppColor.cShadow.withOpacity(0.35),
              offset: const Offset(0, 5),
              blurRadius: 14,
              spreadRadius: 0,
            ),
          ],
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
                    color: AppColor.cLabel.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: assetSvdImageWidget(
                      image: icon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        AppColor.cLabel,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColor.cFont.withOpacity(0.5),
                ),
              ],
            ),

            const Spacer(),

            Text(
              title,
              style: pMedium14,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: pRegular10.copyWith(
                  color: Colors.grey,
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
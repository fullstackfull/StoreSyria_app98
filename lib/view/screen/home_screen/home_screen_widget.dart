// ignore_for_file: prefer_const_constructors, avoid_print, must_be_immutable, prefer_const_constructors_in_immutables, avoid_function_literals_in_foreach_calls
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store_go_app/core/model/dashboard_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/profile_screen/profile_screen.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/view/screen/notification_screen/notification_screen.dart';

Widget buildAppTitleRow(String date) {
  final NotificationController notificationController = Get.find<NotificationController>();
  final isDark = Get.isDarkMode;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Text(
          "Dashboard".tr,
          style: pBold24.copyWith(
            fontSize: 24.sp,
            height: 1.2,
            color: isDark ? Colors.white : AppColor.themeNavyBlueColor,
          ),
        ),
      ),
      Obx(() => GestureDetector(
        onTap: () {
          Get.to(() => NotificationScreen(isBack: true));
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.cShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 24.sp,
                color: isDark ? Colors.white : AppColor.themeNavyBlueColor,
              ),
            ),
            if (notificationController.unreadCount.value > 0)
              PositionedDirectional(
                end: -4,
                top: -4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppColor.cRed,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? DarkThemeColor.cBackGround : AppColor.cLight,
                      width: 2,
                    ),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20.w,
                    minHeight: 20.w,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    notificationController.unreadCount.value > 99
                        ? '99+'
                        : notificationController.unreadCount.value.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      )),
    ],
  );
}

Widget buildProfileTitle({String? profileImage, String? name, String? task, Function(dynamic)? onValue}) {
  return GestureDetector(
    onTap: () {
      Get.to(() => ProfileScreen(
        name: name!,
        profileImg: profileImage!,
      ))!
          .then(onValue!);
    },
    child: Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppColor.themeNavyBlueColor,
            AppColor.blueColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.themeNavyBlueColor.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          PositionedDirectional(
            end: -30,
            top: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          PositionedDirectional(
            end: 60,
            bottom: -50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.themeGreenColor.withOpacity(0.18),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            child: Row(
              children: [
                Hero(
                  tag: "123",
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColor.themeGreenColor,
                          Colors.white.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.themeNavyBlueColor,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColor.themeGreenColor,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: getImageUrl(profileImage),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                            errorWidget: (context, url, error) {
                              return Image.network(
                                DefaultImages.profileImg,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                horizontalSpace(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome back".tr,
                        style: pRegular12.copyWith(color: Colors.white.withOpacity(0.75)),
                      ),
                      verticalSpace(4),
                      Text(
                        "$name",
                        style: pBold18.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                horizontalSpace(8),
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget qrCodeWidget({String? qrString, String? title}) {
  final isDark = Get.isDarkMode;
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
      border: Border.all(color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(22.r),
      boxShadow: [
        BoxShadow(
          color: AppColor.cShadow,
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    padding: EdgeInsets.all(14.w),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColor.themeGreenColor.withOpacity(0.35), width: 1.5),
          ),
          child: CustomPaint(
            size: Size.square(64),
            painter: QrPainter(
              data: qrString!,
              version: QrVersions.auto,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColor.themeNavyBlueColor,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColor.themeNavyBlueColor,
              ),
              gapless: true,
            ),
          ),
        ),
        horizontalSpace(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  assetSvdImageWidget(
                    image: DefaultImages.qrCodeIcn,
                    height: 14,
                    colorFilter: ColorFilter.mode(AppColor.themeGreenColor, BlendMode.srcIn),
                  ),
                  horizontalSpace(6),
                  Text(
                    "QR Code".tr,
                    style: pMedium12.copyWith(color: isDark ? Colors.white60 : AppColor.cDarkGreyFont),
                  ),
                ],
              ),
              verticalSpace(4),
              Text(
                (title == null || title.isEmpty) ? "My Store".tr : title,
                style: pSemiBold16.copyWith(color: isDark ? Colors.white : AppColor.cLabel),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              verticalSpace(10),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: qrString ?? ""));
                  print('copied');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.themeNavyBlueColor,
                        AppColor.blueColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      assetSvdImageWidget(
                        image: DefaultImages.copyIcn,
                        height: 12,
                        colorFilter: ColorFilter.mode(AppColor.cWhite, BlendMode.srcIn),
                      ),
                      horizontalSpace(8),
                      Text(
                        'Copy Me Quickly'.tr,
                        style: pMedium10.copyWith(color: AppColor.cWhite),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget totalProductWidget({
  String? image,
  String? title,
  String? subTitle,
  String? total,
  Color? accentColor,
}) {
  final isDark = Get.isDarkMode;
  final Color accent = accentColor ?? AppColor.themeGreenColor;
  return Container(
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: AppColor.cShadow,
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Stack(
      children: [
        PositionedDirectional(
          end: -18,
          top: -18,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.08),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: assetSvdImageWidget(
                  image: image,
                  height: 18,
                  colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                ),
              ),
              verticalSpace(14),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  total!,
                  style: pBold24.copyWith(
                    fontSize: 22,
                    height: 1.1,
                    color: isDark ? Colors.white : AppColor.cLabel,
                  ),
                ),
              ),
              verticalSpace(4),
              Text(
                "${title!} ${subTitle!}",
                style: pSemiBold12.copyWith(color: isDark ? Colors.white70 : AppColor.cDarkGreyFont),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              verticalSpace(8),
              Container(
                height: 3,
                width: 26.w,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ChartData {
  ChartData(this.x, this.desktop, this.mobile);

  final String x;
  final num desktop;
  final num mobile;
}

Widget slidableActionWidget({Function()? onTap, String? image, String? title, Color? color}) {
  return Expanded(
    flex: 1,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color ?? AppColor.themeGreenColor, borderRadius: BorderRadius.horizontal(right: Radius.circular(16))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            assetSvdImageWidget(
              image: image,
            ),
            verticalSpace(8),
            Text(
              title!,
              style: pRegular14.copyWith(color: AppColor.cWhite),
            ),
          ],
        ),
      ),
    ),
  );
}
onShare({required String link}) {
  Share.share(link, subject: 'Store Syria', sharePositionOrigin: Rect.largest);
}
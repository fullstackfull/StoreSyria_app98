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
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Dashboard".tr,
        style: pBold24.copyWith(
          color: isDark ? Colors.white : AppColor.themeNavyBlueColor,
        ),
      ),
      Obx(() => Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => NotificationScreen(isBack: true));
            },
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.cShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 22.sp,
                color: isDark ? Colors.white : AppColor.themeNavyBlueColor,
              ),
            ),
          ),
          if (notificationController.unreadCount.value > 0)
            Positioned(
              right: -3,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 18.w,
                  minHeight: 18.h,
                ),
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
      ))
    ],
  );
}

Widget buildProfileTitle({String? profileImage, String? name, String? task, Function(dynamic)? onValue}) {
  final isDark = Get.isDarkMode;
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.themeNavyBlueColor,
            AppColor.themeNavyBlueColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.themeNavyBlueColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
           Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: AppColor.themeGreenColor,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: getImageUrl(profileImage),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                    errorWidget: (context, url, error) {
                      return Image.network(
                        DefaultImages.profileImg,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.white,
                          );
                        },
                      );
                    },
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
                  style: pRegular12.copyWith(color: Colors.white.withOpacity(0.7)),
                ),
                verticalSpace(3),
                Text(
                  "$name!",
                  style: pBold16.copyWith(fontSize: 19, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

Widget qrCodeWidget({String? qrString, String? title}) {
  final isDark = Get.isDarkMode;
  return Container(
    height: 76,
    width: double.infinity,
    decoration: BoxDecoration(
      color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
      border: Border.all(color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.6)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColor.cShadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            assetSvdImageWidget(image: DefaultImages.qrCodeIcn),
            horizontalSpace(9),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "QR Code".tr,
                  style: pRegular12.copyWith(color: isDark ? Colors.white70 : AppColor.cDarkGreyFont),
                ),
                Text(
                  title ?? "My Store".tr,
                  style: pSemiBold16.copyWith(color: isDark ? Colors.white : AppColor.cLabel),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: qrString!));
            print('copied');
          },
          child: Container(
            width: 108,
            height: 26,
            decoration: BoxDecoration(
              color: AppColor.themeNavyBlueColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                assetSvdImageWidget(
                  image: DefaultImages.copyIcn,
                  colorFilter: ColorFilter.mode(AppColor.cWhite, BlendMode.srcIn),
                ),
                horizontalSpace(8),
                Text(
                  'Copy Me Quickly'.tr,
                  style: pRegular8.copyWith(color: AppColor.cWhite),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        CustomPaint(
          size: Size.square(60),
          painter: QrPainter(
            data: qrString!,
            version: QrVersions.auto,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: isDark ? Colors.white : AppColor.cBlackFont,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: isDark ? Colors.white : AppColor.cBlackFont,
            ),
            gapless: true,
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
}) {
  final isDark = Get.isDarkMode;
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: AppColor.cShadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColor.themeGreenColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: assetSvdImageWidget(
            image: image,
            height: 18,
            colorFilter: ColorFilter.mode(AppColor.themeGreenColor, BlendMode.srcIn),
          ),
        ),
        verticalSpace(10),
        Text(
          total!,
          style: pSemiBold18.copyWith(fontSize: 22, color: isDark ? Colors.white : AppColor.cLabel),
        ),
        verticalSpace(2),
        Text(
          "${title!} ${subTitle!}",
          style: pRegular12.copyWith(color: isDark ? Colors.white70 : AppColor.cDarkGreyFont),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class OrderGraph extends StatefulWidget {
  final List<Orderchart> list;

  OrderGraph({super.key, required this.list});

  @override
  State<OrderGraph> createState() => _OrderGraphState();
}

class _OrderGraphState extends State<OrderGraph> {
  List<SalesData> orders = [];

  @override
  void initState() {
    super.initState();
    if (Prefs.getBool(AppConstant.isDemoMode) == true) {
      orders = [
        SalesData('19-jul', 13),
        SalesData('20-jul', 35),
        SalesData('21-jul', 34),
        SalesData('22-jul', 27),
        SalesData('23-jul', 40),
        SalesData('24-jul', 37),
        SalesData('25-jul', 42),
      ];
    } else {
      widget.list.forEach((element) {
        orders.add(SalesData(element.date.toString(), double.parse(element.order.toString())));
      });
    }
  }

  // List<SalesData> canceledOrders = [
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? DarkThemeColor.cCardBackground : AppColor.cWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Get.isDarkMode ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColor.cShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColor.themeGreenColor,
                  radius: 6,
                ),
                horizontalSpace(10),
                Text(
                  "Orders".tr,
                  style: pMedium8.copyWith(color: Get.isDarkMode ? Colors.white70 : AppColor.cLabel),
                ),
                horizontalSpace(20),
                // CircleAvatar(
                //   backgroundColor: AppColor.cRedText,
                //   radius: 6,
                // ),
                // horizontalSpace(10),
                // Text(
                //   "Canceled Orders",
                //   style: pMedium8,
                // ),
              ],
            ),
          ),
          Expanded(
            child: SfCartesianChart(
              enableAxisAnimation: true,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                borderWidth: 0,
                autoScrollingMode: AutoScrollingMode.start,
                autoScrollingDelta: 10,
                maximumLabels: 100,
                majorGridLines: MajorGridLines(color: AppColor.cBorder),
                axisLine: AxisLine(width: 0, color: AppColor.cTransparent),
                interval: 1,
                majorTickLines: MajorTickLines(width: 0),
              ),
              primaryYAxis: NumericAxis(borderWidth: 0, interval: 1, majorGridLines: MajorGridLines(color: AppColor.cTransparent), axisLine: AxisLine(width: 0, color: AppColor.cTransparent), majorTickLines: MajorTickLines(width: 0)),
              legend: Legend(isVisible: false),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: AppColor.cBackGround,
                activationMode: ActivationMode.singleTap,
                canShowMarker: true,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  var order = /*seriesIndex == 1 ? canceledOrders[pointIndex].sales :*/ orders[pointIndex].sales;
                  return Container(
                    // width: 119,
                    // height: 54,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.cBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                       children: [
                        Text(
                          /* seriesIndex == 1 ? "Canceled Orders" :*/
                          "Orders".tr,
                          style: pSemiBold12.copyWith(color: AppColor.cDarkGreyFont),
                        ),
                        verticalSpace(8),
                        Text(
                          "\$$order",
                          style: pSemiBold12.copyWith(
                            color: seriesIndex == 1 ? AppColor.cRedText : AppColor.cGreenFont,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              zoomPanBehavior: ZoomPanBehavior(
                enablePanning: true,
              ),
              series: <CartesianSeries<SalesData, String>>[
                SplineSeries<SalesData, String>(
                  dataSource: orders,
                  xValueMapper: (SalesData sales, _) => sales.year,
                  yValueMapper: (SalesData sales, _) => sales.sales,
                  name: 'Orders'.tr,
                  color: AppColor.themeGreenColor,
                  width: 5,
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                ),
                // SplineSeries<SalesData, String>(
                //   dataSource: canceledOrders,
                //   xValueMapper: (SalesData sales, _) => sales.year,
                //   yValueMapper: (SalesData sales, _) => sales.sales,
                //   color: AppColor.cRedText,
                //   name: 'Canceled Orders',
                //   width: 5,
                //   // Enable data label
                //   dataLabelSettings: DataLabelSettings(isVisible: false),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
// class VisitorChart extends StatefulWidget {
//   final List<Visitorchart> visitorChart;
//
//   const VisitorChart({Key? key, required this.visitorChart}) : super(key: key);
//
//   @override
//   State<VisitorChart> createState() => _VisitorChartState();
// }
//
// class _VisitorChartState extends State<VisitorChart> {
//   List<ChartData>? chartData;
//
//   @override
//   void initState() {
//     chartData = <ChartData>[];
//     if (Prefs.getBool(AppConstant.isDemoMode) == true) {
//       chartData = [
//         ChartData('19-jul', 5, 8),
//         ChartData('20-jul', 10, 15),
//         ChartData('21-jul', 12, 17),
//         ChartData('22-jul', 14, 19),
//         ChartData('23-jul', 12, 17),
//         ChartData('24-jul', 15, 10),
//         ChartData('25-jul', 8, 5),
//       ];
//     } else {
//       widget.visitorChart.forEach((data) {
//         chartData!.add(ChartData(data.date!, data.uniquePageview!, data.pageview!));
//       });
//     }
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 250,
//       decoration: BoxDecoration(
//         color: Get.isDarkMode ? DarkThemeColor.cCardBackground : AppColor.cWhite,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: Get.isDarkMode ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.cShadow,
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(15),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: AppColor.themeGreenColor,
//                   radius: 6,
//                 ),
//                 horizontalSpace(10),
//                 Text(
//                   "Total page view",
//                   style: pMedium8,
//                 ),
//                 horizontalSpace(15),
//                 CircleAvatar(
//                   backgroundColor: AppColor.themeNavyBlueColor,
//                   radius: 6,
//                 ),
//                 horizontalSpace(10),
//                 Text(
//                   "Unique page view",
//                   style: pMedium8,
//                 ),
//               ],
//             ),
//           ),
//           Expanded(child: _buildStackedBarChart()),
//         ],
//       ),
//     );
//   }
//
//   SfCartesianChart _buildStackedBarChart() {
//     return SfCartesianChart(
//       enableAxisAnimation: true,
//       plotAreaBorderWidth: 0,
//       legend: Legend(isVisible: false),
//       zoomPanBehavior: ZoomPanBehavior(
//         enablePanning: true,
//       ),
//       primaryXAxis: CategoryAxis(
//         borderWidth: 0,
//         autoScrollingMode: AutoScrollingMode.start,
//         autoScrollingDelta: 7,
//         maximumLabels: 100,
//         majorGridLines: MajorGridLines(color: AppColor.cBorder),
//         axisLine: AxisLine(width: 0, color: AppColor.cTransparent),
//         interval: 1,
//         majorTickLines: MajorTickLines(width: 0),
//         axisBorderType: AxisBorderType.withoutTopAndBottom,
//       ),
//       primaryYAxis: NumericAxis(borderWidth: 0, majorGridLines: MajorGridLines(color: AppColor.cTransparent), axisLine: AxisLine(width: 0, color: AppColor.cTransparent), majorTickLines: MajorTickLines(width: 0)),
//       tooltipBehavior: TooltipBehavior(
//         enable: true,
//         color: AppColor.cBackGround,
//         activationMode: ActivationMode.singleTap,
//         canShowMarker: true,
//         shouldAlwaysShow: false,
//         borderColor: AppColor.cBorder,
//         borderWidth: 5,
//         builder: (data, point, series, pointIndex, seriesIndex) {
//           print(data);
//           print(point);
//           print(series);
//           print(pointIndex);
//           print(seriesIndex);
//           var title = seriesIndex == 0 ? "Total Page View" : "Unique Page View";
//           var platform = seriesIndex == 0 ? chartData![pointIndex].desktop : chartData![pointIndex].mobile;
//           return Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: AppColor.cBorder),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   title,
//                   style: pBold12.copyWith(color: AppColor.cDarkGreyFont),
//                 ),
//                 verticalSpace(8),
//                 Text(
//                   platform.toString(),
//                   style: pBold16.copyWith(color: seriesIndex == 0 ? AppColor.cGreenFont : AppColor.cLabel),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       series: _getStackedBarSeries(),
//     );
//   }
//
//   List<CartesianSeries<ChartData, String>> _getStackedBarSeries() {
//     return <CartesianSeries<ChartData, String>>[
//       StackedColumnSeries<ChartData, String>(
//         dataSource: chartData!,
//         xValueMapper: (ChartData sales, _) => sales.x,
//         yValueMapper: (ChartData sales, _) => sales.desktop,
//         color: AppColor.themeGreenColor,
//         name: 'Desktop platform',
//         width: 0.5,
//         dataLabelSettings: DataLabelSettings(
//           isVisible: true,
//           textStyle: pMedium10.copyWith(
//             color: AppColor.cWhite,
//           ),
//         ),
//       ),
//       StackedColumnSeries<ChartData, String>(
//         dataSource: chartData!,
//         xValueMapper: (ChartData sales, _) => sales.x,
//         yValueMapper: (ChartData sales, _) => sales.mobile,
//         color: AppColor.themeNavyBlueColor,
//         name: 'Mobile platform',
//         borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
//         width: 0.5,
//         dataLabelSettings: DataLabelSettings(
//           isVisible: true,
//           textStyle: pMedium10.copyWith(color: AppColor.cWhite),
//           borderRadius: 12,
//         ),
//       ),
//     ];
//   }
//
//   @override
//   void dispose() {
//     chartData!.clear();
//     super.dispose();
//   }
// }

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
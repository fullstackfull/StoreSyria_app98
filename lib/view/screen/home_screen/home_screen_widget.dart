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
import 'package:store_go_app/view/screen/home_screen/drawer_screen.dart';
import 'package:store_go_app/view/screen/profile_screen/profile_screen.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/view/screen/notification_screen/notification_screen.dart';

Widget buildAppTitleRow(Function() menuFun, String date) {
  final NotificationController notificationController = Get.put(NotificationController());
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          GestureDetector(
            onTap: menuFun,
            child: assetSvdImageWidget(image: DefaultImages.menuIcn, height: 18, colorFilter: ColorFilter.mode(AppColor.cLabel, BlendMode.srcIn)),
          ),
          horizontalSpace(16),
          Text(
            "Dashboard",
            style: pMedium16,
          ),
        ],
      ),
      Obx(() => Stack(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => NotificationScreen(isBack: true));
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColor.cBottomNavyBlueColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 24.sp,
                color: AppColor.cWhite,
              ),
            ),
          ),
          if (notificationController.unreadCount.value > 0)
            Positioned(
              right: 0,
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
  return Row(
    children: [
      GestureDetector(
        onTap: () {
          Get.to(() => ProfileScreen(
                    name: name!,
                    profileImg: profileImage!,
                  ))!
              .then(onValue!);
        },
        child: CircleAvatar(
          radius: 34,
          backgroundColor: AppColor.themeGreenColor,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: getImageUrl(profileImage),
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              errorWidget: (context, url, error) => Image.network(
                DefaultImages.profileImg,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      horizontalSpace(8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hello, $name!",
              style: pBold16.copyWith(fontSize: 20),
            ),
            // Text.rich(
            //   TextSpan(
            //     text: 'You have ',
            //     style: pRegular18.copyWith(
            //       color: AppColor.cGreenFont,
            //     ),
            //     children: <TextSpan>[
            //       TextSpan(
            //         text: '$task Tasks For Today',
            //         style: pRegular18.copyWith(
            //           color: AppColor.cGreenFont,
            //           decoration: TextDecoration.underline,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    ],
  );
}

Widget titleShowMoreWidget({String? title, String? btnName, Function()? onPresses}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title!,
        style: pRegular10.copyWith(fontSize: 20),
      ),
      SmallCommonIconButton(
        onPressed: onPresses,
        iconData: DefaultImages.graphIcn,
        title: btnName,
        textColor: AppColor.cWhiteFont,
      )
    ],
  );
}

Widget qrCodeWidget({String? qrString, String? title}) {
  return Container(
    height: 70,
    width: Get.width,
    decoration: BoxDecoration(border: Border.all(color: AppColor.cBorder), borderRadius: BorderRadius.circular(10)),
    padding: EdgeInsets.all(10),
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
                  "QR Code",
                  style: pRegular12,
                ),
                Text(
                  title ?? "My Store",
                  style: pSemiBold16,
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
            width: 101,
            height: 22,
            decoration: BoxDecoration(
              color: AppColor.themeNavyBlueColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                assetSvdImageWidget(
                  image: DefaultImages.copyIcn,
                ),
                horizontalSpace(10),
                Text(
                  'Copy Me Quickly',
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
              color: AppColor.cBlackFont,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColor.cBlackFont,
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
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Container(
      height: 70,
      width: Get.width,
      decoration: BoxDecoration(border: Border.all(color: AppColor.cBorder), borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              assetSvdImageWidget(image: image),
              horizontalSpace(9),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: pRegular12,
                  ),
                  Text(
                    subTitle!,
                    style: pSemiBold16,
                  ),
                ],
              ),
            ],
          ),
          Text(
            total!,
            style: pSemiBold18,
          ),
        ],
      ),
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
    // TODO: implement initState
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColor.cBorder)),
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
                  "Orders",
                  style: pMedium8,
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
                          "Orders",
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
                  name: 'Orders',
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

Widget topProductWidget({
  required String image,
  required String title,
  required String subTitle,
  required String amount,
  required String digit,
  required String qty,
  int? index,
  Function()? deleteFun,
  Function()? viewFun,
  Function()? changeFun,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, bottom: 13),
    child: Slidable(
      key: ValueKey(index),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          slidableActionWidget(onTap: viewFun, image: DefaultImages.eyeIcn, title: "View"),
          slidableActionWidget(onTap: changeFun, image: DefaultImages.changeIcn, title: "Change", color: AppColor.themeNavyBlueColor),
          slidableActionWidget(onTap: deleteFun, image: DefaultImages.deleteIcn, title: "Delete", color: AppColor.cRedText),
        ],
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        fit: StackFit.loose,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(color: AppColor.cBackGround, borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColor.cBorder)),
            padding: const EdgeInsets.only(left: 20, right: 8, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 55,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColor.cBackGround,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: getImageUrl(image),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) => Image.network(
                            DefaultImages.productImg,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    horizontalSpace(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: pRegular12.copyWith(color: AppColor.cDarkGreyFont),
                        ),
                        verticalSpace(3),
                        SizedBox(
                          width: Get.width / 1.8,
                          child: Text(
                            subTitle,
                            style: pSemiBold16,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        verticalSpace(3),
                        Row(
                          children: [
                            richText("Quantity:", qty),
                            horizontalSpace(10),
                            richText("Price: ", amount),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft - Alignment(.05, 0),
            child: twoXWidget(digit),
          ),
        ],
      ),
    ),
  );
}

Widget circleImageWidget(String image) {
  return CircleAvatar(
    radius: 15,
    backgroundColor: AppColor.themeGreenColor,
    child: assetSvdImageWidget(image: image),
  );
}

richText(String title, String total) => Text.rich(
      TextSpan(
        text: '$title ',
        style: pRegular12.copyWith(color: AppColor.cDarkGreyFont),
        children: <TextSpan>[
          TextSpan(
            text: total,
            style: pMedium12,
          ),
        ],
      ),
    );

twoXWidget(String string) {
  return Container(
    height: 24,
    width: 24,
    decoration: BoxDecoration(color: AppColor.themeGreenColor, shape: BoxShape.circle),
    child: Center(
      child: Text(
        string,
        style: pSemiBold14,
      ),
    ),
  );
}

Widget recentOrdersWidget({
  String? status,
  String? orderId,
  String? name,
  String? date,
  String? usd,
  int? index,
  Function()? viewFun,
  Function()? deleteFun,
  Function()? downloadFun,
  Function()? shareFun
}) {
  final isDark = Get.isDarkMode;

  // ألوان مخصصة للبطاقة
  final cardBg = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5);
  final titleColor = isDark ? Colors.white : AppColor.themeNavyBlueColor;
  final subTextColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Slidable(
      key: ValueKey(index ?? 0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          slidableActionWidget(onTap: viewFun, image: DefaultImages.eyeIcn, title: "view".tr),
          slidableActionWidget(onTap: deleteFun, image: DefaultImages.deleteIcn, title: "delete".tr, color: AppColor.cRedText),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصف العلوي: رقم الطلب والحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${orderId ?? ''}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                statusButton(status),
              ],
            ),

            verticalSpace(7.h),

            // الصف الأوسط: الاسم والتاريخ
            Row(
              children: [
                Icon(Icons.person_outline, size: 14.sp, color: subTextColor),
                horizontalSpace(6.w),
                Expanded(
                  child: Text(
                    name ?? '',
                    style: TextStyle(fontSize: 12.sp, color: subTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                horizontalSpace(10.w),
                Icon(Icons.calendar_today_outlined, size: 12.sp, color: subTextColor),
                horizontalSpace(4.w),
                Text(
                  date ?? '',
                  style: TextStyle(fontSize: 11.sp, color: subTextColor),
                ),
              ],
            ),

            verticalSpace(5.h),

            // خط فاصل خفيف
            Divider(height: 1.h, color: borderColor, thickness: 1),

            verticalSpace(5.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: TextStyle(fontSize: 12.sp, color: subTextColor),
                ),
                Text(
                  "\$${usd ?? '0.00'}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.themeGreenColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
Container statusButton(String? status) {
  return Container(
    padding: EdgeInsets.only(left: 10.h, right: 10.h, top: 7.h, bottom: 7.h),
    decoration: BoxDecoration(
      color: AppColor.cLightGreen,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        assetSvdImageWidget(image: DefaultImages.doneIcn),
        horizontalSpace(10),
        Text(
          status!,
          style: pBold12.copyWith(color: AppColor.cGreenFont, fontSize: 10),
        ),
      ],
    ),
  );
}

class VisitorChart extends StatefulWidget {
  final List<Visitorchart> visitorChart;

  const VisitorChart({Key? key, required this.visitorChart}) : super(key: key);

  @override
  State<VisitorChart> createState() => _VisitorChartState();
}

class _VisitorChartState extends State<VisitorChart> {
  List<ChartData>? chartData;

  @override
  void initState() {
    chartData = <ChartData>[];
    if (Prefs.getBool(AppConstant.isDemoMode) == true) {
      chartData = [
        ChartData('19-jul', 5, 8),
        ChartData('20-jul', 10, 15),
        ChartData('21-jul', 12, 17),
        ChartData('22-jul', 14, 19),
        ChartData('23-jul', 12, 17),
        ChartData('24-jul', 15, 10),
        ChartData('25-jul', 8, 5),
      ];
    } else {
      widget.visitorChart.forEach((data) {
        chartData!.add(ChartData(data.date!, data.uniquePageview!, data.pageview!));
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColor.cBorder)),
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
                  "Total page view",
                  style: pMedium8,
                ),
                horizontalSpace(15),
                CircleAvatar(
                  backgroundColor: AppColor.themeNavyBlueColor,
                  radius: 6,
                ),
                horizontalSpace(10),
                Text(
                  "Unique page view",
                  style: pMedium8,
                ),
              ],
            ),
          ),
          Expanded(child: _buildStackedBarChart()),
        ],
      ),
    );
  }

  SfCartesianChart _buildStackedBarChart() {
    return SfCartesianChart(
      enableAxisAnimation: true,
      plotAreaBorderWidth: 0,
      legend: Legend(isVisible: false),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
      ),
      primaryXAxis: CategoryAxis(
        borderWidth: 0,
        autoScrollingMode: AutoScrollingMode.start,
        autoScrollingDelta: 7,
        maximumLabels: 100,
        majorGridLines: MajorGridLines(color: AppColor.cBorder),
        axisLine: AxisLine(width: 0, color: AppColor.cTransparent),
        interval: 1,
        majorTickLines: MajorTickLines(width: 0),
        axisBorderType: AxisBorderType.withoutTopAndBottom,
      ),
      primaryYAxis: NumericAxis(borderWidth: 0, majorGridLines: MajorGridLines(color: AppColor.cTransparent), axisLine: AxisLine(width: 0, color: AppColor.cTransparent), majorTickLines: MajorTickLines(width: 0)),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: AppColor.cBackGround,
        activationMode: ActivationMode.singleTap,
        canShowMarker: true,
        shouldAlwaysShow: false,
        borderColor: AppColor.cBorder,
        borderWidth: 5,
        builder: (data, point, series, pointIndex, seriesIndex) {
          print(data);
          print(point);
          print(series);
          print(pointIndex);
          print(seriesIndex);
          var title = seriesIndex == 0 ? "Total Page View" : "Unique Page View";
          var platform = seriesIndex == 0 ? chartData![pointIndex].desktop : chartData![pointIndex].mobile;
          return Container(
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
                  title,
                  style: pBold12.copyWith(color: AppColor.cDarkGreyFont),
                ),
                verticalSpace(8),
                Text(
                  platform.toString(),
                  style: pBold16.copyWith(color: seriesIndex == 0 ? AppColor.cGreenFont : AppColor.cLabel),
                ),
              ],
            ),
          );
        },
      ),
      series: _getStackedBarSeries(),
    );
  }

  List<CartesianSeries<ChartData, String>> _getStackedBarSeries() {
    return <CartesianSeries<ChartData, String>>[
      StackedColumnSeries<ChartData, String>(
        dataSource: chartData!,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.desktop,
        color: AppColor.themeGreenColor,
        name: 'Desktop platform',
        width: 0.5,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          textStyle: pMedium10.copyWith(
            color: AppColor.cWhite,
          ),
        ),
      ),
      StackedColumnSeries<ChartData, String>(
        dataSource: chartData!,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.mobile,
        color: AppColor.themeNavyBlueColor,
        name: 'Mobile platform',
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        width: 0.5,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          textStyle: pMedium10.copyWith(color: AppColor.cWhite),
          borderRadius: 12,
        ),
      ),
    ];
  }

  @override
  void dispose() {
    chartData!.clear();
    super.dispose();
  }
}

class ChartData {
  ChartData(this.x, this.desktop, this.mobile);

  final String x;
  final num desktop;
  final num mobile;
}

Widget productCouponWidget({
  int? index,
  Function()? deleteFun,
  Function()? viewFun,
  Function()? changeFun,
  String? code,
  String? name,
  String? discount,
  String? date,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Slidable(
      key: ValueKey(index),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          slidableActionWidget(onTap: viewFun, image: DefaultImages.eyeIcn, title: "View"),
          slidableActionWidget(onTap: changeFun, image: DefaultImages.changeIcn, title: "Change", color: AppColor.themeNavyBlueColor),
          slidableActionWidget(onTap: deleteFun, image: DefaultImages.deleteIcn, title: "Delete", color: AppColor.cRedText),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.cBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statusButton(code),
              verticalSpace(10),
              Text(
                "Name:",
                style: pRegular10,
              ),
              Text(
                name!,
                style: pBold18,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              date == '' ? SizedBox() : Text("Exp Date: $date", style: pRegular12),
              verticalSpace(date == '' ? 0 : 8),
              Text(
                "Discount:",
                style: pRegular10.copyWith(color: AppColor.cDarkGreyFont),
              ),
              Text(
                discount!,
                style: pBold18,
              ),
            ],
          )
        ]),
      ),
    ),
  );
}

Widget slidableActionWidget({Function()? onTap, String? image, String? title, Color? color}) {
  return Expanded(
    flex: 1,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color ?? AppColor.themeGreenColor, borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
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

void showPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return DrawerScreen();
    },
  );
}

Widget drawerWidget({bool? isSelected, String? title, String? icon}) {
  return Card(
    shadowColor: AppColor.cFont,
    elevation: 12.41,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(color: isSelected == true ? AppColor.themeGreenColor : AppColor.cBackGround, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          assetSvdImageWidget(
            image: icon,
            colorFilter: ColorFilter.mode(
              isSelected == true ? AppColor.cWhite : AppColor.cLabel,
              BlendMode.srcIn,
            ),
          ),
          verticalSpace(10),
          Text(
            title!,
            style: pSemiBold10.copyWith(
              color: isSelected == true ? AppColor.cWhite : AppColor.cLabel,
            ),
          ),
        ],
      ),
    ),
  );
}

onShare({required String link}) {
  Share.share(link, subject: 'Store Syria', sharePositionOrigin: Rect.largest);
}

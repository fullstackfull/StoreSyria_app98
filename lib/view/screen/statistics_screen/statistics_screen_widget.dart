// ignore_for_file: must_be_immutable, prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';

Widget topUrlWidget({
  required String title,
  required String subTitle,
  required String total,
  required String digit,
  required Function() shareFun,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, bottom: 13),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pRegular12.copyWith(color: AppColor.cDarkGreyFont),
                  ),
                  verticalSpace(3),
                  SizedBox(
                    width: 200,
                    child: Text(
                      subTitle,
                      style: pSemiBold10,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  verticalSpace(3),
                  Row(
                    children: [
                      richText("Unique Clicks: ", total),
                    ],
                  )
                ],
              ),
              GestureDetector(
                onTap: shareFun,
                child: circleImageWidget(DefaultImages.shareIcn),
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
  );
}

class StatisticsVisitorGraph extends StatefulWidget {
  final List<VisitorChartData> visitorChart;

  const StatisticsVisitorGraph({Key? key, required this.visitorChart}) : super(key: key);

  @override
  State<StatisticsVisitorGraph> createState() => _StatisticsVisitorGraphState();
}

class _StatisticsVisitorGraphState extends State<StatisticsVisitorGraph> {
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
                  backgroundColor: AppColor.themeNavyBlueColor,
                  radius: 6,
                ),
                horizontalSpace(10),
                Text(
                  "Total page view",
                  style: pMedium8,
                ),
                horizontalSpace(15),
                CircleAvatar(
                  backgroundColor: AppColor.themeGreenColor,
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
          var title = seriesIndex == 1 ? "Total Page View" : "Unique Page View";
          var platform = seriesIndex == 1 ? chartData![pointIndex].mobile : chartData![pointIndex].desktop;
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
        name: 'Page View',
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
        name: 'Unique page View',
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
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

class PlatformBarChart extends StatefulWidget {
  final List<PlatformData> list;

  const PlatformBarChart({super.key, required this.list});

  @override
  State<PlatformBarChart> createState() => _PlatformBarChartState();
}

class _PlatformBarChartState extends State<PlatformBarChart> {
  List<BarChartData>? chartData;

  @override
  void initState() {
    chartData = <BarChartData>[];
    if (Prefs.getBool(AppConstant.isDemoMode) == true) {
      chartData = [
        BarChartData('Windows', 5, Colors.pink),
        BarChartData('OS X', 10, Colors.purple),
        BarChartData('Linux', 12, Colors.amber),
        BarChartData('iOS', 14, Colors.brown),
        BarChartData('AndroidOS', 12, Colors.indigo),
        BarChartData('Other', 15, Colors.lime),
      ];
    } else  {
      widget.list.forEach((data) {
        chartData!.add(BarChartData(data.platform!, data.data!, HexColor(data.colour!)));
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
            child: Wrap(direction: Axis.horizontal, alignment: WrapAlignment.start, spacing: 15, runSpacing: 8, children: platFormData()),
          ),
          Expanded(
            child: SfCartesianChart(
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
                  var title = chartData![pointIndex].x;
                  var platform = chartData![pointIndex].desktop;
                  Color color = chartData![pointIndex].color;
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
                          style: pBold16.copyWith(color: color),
                        ),
                      ],
                    ),
                  );
                },
              ),
              series: <CartesianSeries<BarChartData, String>>[
                StackedColumnSeries<BarChartData, String>(
                  dataSource: chartData!,
                  width: 0.5,
                  xValueMapper: (BarChartData sales, _) => sales.x,
                  yValueMapper: (BarChartData sales, _) => sales.desktop,
                  pointColorMapper: (BarChartData sales, _) => sales.color,
                  color: AppColor.themeGreenColor,
                  name: 'Page View',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: pMedium10.copyWith(
                      color: AppColor.cWhite,
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

  List<Widget> platFormData() {
    List<Widget> data = [];
    for (int i = 0; i < chartData!.length; i++) {
      data.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: chartData![i].color,
            radius: 6,
          ),
          horizontalSpace(10),
          Text(
            chartData![i].x,
            style: pMedium8,
          ),
        ],
      ));
    }
    return data;
  }
}

class BarChartData {
  BarChartData(this.x, this.desktop, this.color);

  final String x;
  final num desktop;
  final Color color;
}

class BrowsersGraph extends StatefulWidget {
  final List<BrowserData>? browser;
  final List<DeviceData>? device;
  final bool isDevice;

  BrowsersGraph({Key? key, this.browser, this.device, required this.isDevice}) : super(key: key);

  @override
  State<BrowsersGraph> createState() => _BrowsersGraphState();
}

class _BrowsersGraphState extends State<BrowsersGraph> {
   List<_ChartData> chartData = <_ChartData>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isDevice == true) {
      if (Prefs.getBool(AppConstant.isDemoMode) == true) {
        chartData = [
          _ChartData('WebKit', 350, Colors.pink),
          _ChartData('Samsung', 100, Colors.purple),
          _ChartData('Nexus', 120, Colors.amber),
          _ChartData('iPhone', 140, Colors.brown),
          _ChartData('Other', 120, Colors.indigo),
        ];
      } else  {
        widget.device!.forEach((element) {
          chartData.add(_ChartData(element.device!, element.data!, HexColor(element.colour!)));
        });
      }
    } else {
      if (Prefs.getBool(AppConstant.isDemoMode) == true) {
        chartData = [
          _ChartData('Safari', 200, Colors.amber),
          _ChartData('Mozilla', 320, Colors.orange),
          _ChartData('Firefox', 420, Colors.green),
          _ChartData('Edge', 540, Colors.lightBlue),
          _ChartData('Chrome', 700, Colors.indigo),
        ];
      } else {
        widget.browser!.forEach((element) {
          chartData.add(_ChartData(element.browser!, element.data!, HexColor(element.colour!)));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColor.cBorder)),
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 25),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: widget.isDevice == true
                ? SfCircularChart(
                    series: <CircularSeries>[
                      PieSeries<_ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (_ChartData data, _) => data.x,
                          yValueMapper: (_ChartData data, _) => data.y,
                          pointColorMapper: (_ChartData data, _) => data.color,
                          explode: true,
                          explodeIndex: 1,
                          // dataLabelMapper: (_ChartData data, _) => data.x,
                          pointRenderMode: PointRenderMode.segment,
                          dataLabelSettings: DataLabelSettings(
                              builder: (data, point, series, pointIndex, seriesIndex) {
                                return Text(
                                  chartData[pointIndex].y.toString(),
                                  style: pMedium10,
                                );
                              },
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              labelAlignment: ChartDataLabelAlignment.outer))
                    ],
                  )
                : SfCircularChart(
                    series: <CircularSeries<_ChartData, String>>[
                      RadialBarSeries<_ChartData, String>(
                        maximumValue: 1000,
                        radius: '100%',
                        gap: '2%',
                        strokeWidth: 0.8,
                        dataSource: chartData,
                        trackColor: AppColor.cBorder,
                        cornerStyle: CornerStyle.bothCurve,
                        xValueMapper: (_ChartData data, _) => data.x,
                        yValueMapper: (_ChartData data, _) => data.y,
                        pointColorMapper: (_ChartData data, _) => data.color,
                      ),
                    ],
                  ),
          ),
          Column(
            children: platFormData(),
          ),
        ],
      ),
    );
  }

  List<Widget> platFormData() {
    List<Widget> data = [];
    for (int i = 0; i < chartData.length; i++) {
      data.add(browserGraphDetail(title: chartData[i].x, total: chartData[i].y.toString(), color: chartData[i].color));
    }
    return data;
  }

  Widget browserGraphDetail({required String title, required String total, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColor.cBorder)),
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: color),
                horizontalSpace(9),
                Text(
                  title,
                  style: pMedium10.copyWith(color: color),
                ),
              ],
            ),
            Text(
              total,
              style: pMedium12.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String x;
  final int y;
  final Color color;

  _ChartData(this.x, this.y, this.color);
}

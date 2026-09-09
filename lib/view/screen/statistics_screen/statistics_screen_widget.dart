import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const StatisticsCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cBackGround,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColor.cBorder.withOpacity(.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColor.themeNavyBlueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              horizontalSpace(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pBold14.copyWith(
                        color: AppColor.cDarkGreyFont,
                      ),
                    ),
                    if (subtitle != null) ...[
                      verticalSpace(3),
                      Text(
                        subtitle!,
                        style: pRegular10.copyWith(
                          color: AppColor.cDarkGreyFont.withOpacity(.65),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(16),
          child,
        ],
      ),
    );
  }
}

Widget topUrlWidget({
  required String title,
  required String subTitle,
  required String total,
  required String digit,
  required Function() shareFun,
}) {
  return Container(
    margin: const EdgeInsets.only(
      left: 8,
      right: 8,
      bottom: 14,
    ),
    decoration: BoxDecoration(
      color: AppColor.cBackGround,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColor.cBorder.withOpacity(.7),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.035),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColor.themeNavyBlueColor.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.link_rounded,
              color: AppColor.themeNavyBlueColor,
              size: 21,
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: pRegular12.copyWith(
                    color: AppColor.cDarkGreyFont.withOpacity(.65),
                  ),
                ),
                verticalSpace(4),
                Text(
                  subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pSemiBold12.copyWith(
                    color: AppColor.cDarkGreyFont,
                  ),
                ),
              ],
            ),
          ),
          horizontalSpace(10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColor.themeGreenColor.withOpacity(.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              total,
              style: pBold12.copyWith(
                color: AppColor.themeGreenColor,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


class StatisticsVisitorGraph extends StatefulWidget {
  final List<VisitorChartData> visitorChart;

  const StatisticsVisitorGraph({
    Key? key,
    required this.visitorChart,
  }) : super(key: key);

  @override
  State<StatisticsVisitorGraph> createState() =>
      _StatisticsVisitorGraphState();
}

class _StatisticsVisitorGraphState
    extends State<StatisticsVisitorGraph> {

  List<ChartData> chartData = [];

  @override
  void initState() {
    super.initState();

    _loadChartData();
  }

  void _loadChartData() {
    chartData = [];

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
      final data = widget.visitorChart;

      final start = data.length > 7 ? data.length - 7 : 0;

      chartData = data.sublist(start).map((data) {
        return ChartData(
          data.date ?? '',
          data.uniquePageview ?? 0,
          data.pageview ?? 0,
        );
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColor.cBorder,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  AppColor.themeNavyBlueColor,
                  radius: 6,
                ),
                horizontalSpace(10),
                Text(
                  "Total page view".tr,
                  style: pMedium8,
                ),

                horizontalSpace(15),

                CircleAvatar(
                  backgroundColor:
                  AppColor.themeGreenColor,
                  radius: 6,
                ),
                horizontalSpace(10),
                Text(
                  "Unique page view".tr,
                  style: pMedium8,
                ),
              ],
            ),
          ),

          Expanded(
            child: _buildStackedBarChart(),
          ),
        ],
      ),
    );
  }

  SfCartesianChart _buildStackedBarChart() {
    return SfCartesianChart(
      enableAxisAnimation: true,

      plotAreaBorderWidth: 0,

      legend: Legend(
        isVisible: false,
      ),

      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
      ),

      primaryXAxis: CategoryAxis(
        borderWidth: 0,
        autoScrollingMode:
        AutoScrollingMode.start,
        autoScrollingDelta: 7,
        maximumLabels: 100,

        majorGridLines: MajorGridLines(
          color: AppColor.cBorder,
        ),

        axisLine: AxisLine(
          width: 0,
          color: AppColor.cTransparent,
        ),

        interval: 1,

        majorTickLines: MajorTickLines(
          width: 0,
        ),

        axisBorderType:
        AxisBorderType.withoutTopAndBottom,
      ),

      primaryYAxis: NumericAxis(
        borderWidth: 0,

        majorGridLines: MajorGridLines(
          color: AppColor.cTransparent,
        ),

        axisLine: AxisLine(
          width: 0,
          color: AppColor.cTransparent,
        ),

        majorTickLines: MajorTickLines(
          width: 0,
        ),
      ),

      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: AppColor.cBackGround,
        activationMode:
        ActivationMode.singleTap,
        canShowMarker: true,
        shouldAlwaysShow: false,

        borderColor: AppColor.cBorder,
        borderWidth: 1,

        builder: (
            data,
            point,
            series,
            pointIndex,
            seriesIndex,
            ) {
          final bool isUnique =
              seriesIndex == 0;

          final String title = isUnique
              ? "Unique Page View".tr
              : "Total Page View".tr;

          final num value = isUnique
              ? chartData[pointIndex].desktop
              : chartData[pointIndex].mobile;

          return Container(
            decoration: BoxDecoration(
              color: AppColor.cBackGround,
              border: Border.all(
                color: AppColor.cBorder,
              ),
              borderRadius:
              BorderRadius.circular(8),
            ),

            padding:
            const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: pBold12.copyWith(
                    color:
                    AppColor.cDarkGreyFont,
                  ),
                ),

                verticalSpace(8),

                Text(
                  value.toString(),
                  style: pBold16.copyWith(
                    color: isUnique
                        ? AppColor
                        .themeGreenColor
                        : AppColor
                        .themeNavyBlueColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),

      series: _getStackedBarSeries(),
    );
  }

  List<CartesianSeries<ChartData, String>>
  _getStackedBarSeries() {
    return [
      StackedColumnSeries<ChartData, String>(
        dataSource: chartData,

        xValueMapper:
            (ChartData data, _) => data.x,

        yValueMapper:
            (ChartData data, _) => data.desktop,

        color:
        AppColor.themeGreenColor,

        name: 'Unique Page View'.tr,

        animationDuration: 900,

        dataLabelSettings:
        DataLabelSettings(
          isVisible: true,

          textStyle:
          pMedium10.copyWith(
            color: AppColor.cWhite,
          ),
        ),
      ),

      StackedColumnSeries<ChartData, String>(
        dataSource: chartData,

        xValueMapper:
            (ChartData data, _) => data.x,

        yValueMapper:
            (ChartData data, _) => data.mobile,

        color:
        AppColor.themeNavyBlueColor,

        name: 'Total Page View'.tr,

        animationDuration: 1100,

        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(8),
        ),

        dataLabelSettings:
        DataLabelSettings(
          isVisible: true,

          textStyle:
          pMedium10.copyWith(
            color: AppColor.cWhite,
          ),

          borderRadius: 12,
        ),
      ),
    ];
  }
}

/// ------------------------------------------------------------
/// PLATFORM BAR CHART
/// ------------------------------------------------------------

class PlatformBarChart extends StatefulWidget {
  final List<PlatformData> list;

  const PlatformBarChart({
    super.key,
    required this.list,
  });

  @override
  State<PlatformBarChart> createState() =>
      _PlatformBarChartState();
}

class _PlatformBarChartState
    extends State<PlatformBarChart> {
  List<BarChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    chartData = [];

    if (Prefs.getBool(AppConstant.isDemoMode) == true) {
      chartData = [
        BarChartData('Windows', 5, Colors.pink),
        BarChartData('OS X', 10, Colors.purple),
        BarChartData('Linux', 12, Colors.amber),
        BarChartData('iOS', 14, Colors.brown),
        BarChartData('AndroidOS', 12, Colors.indigo),
        BarChartData('Other', 15, Colors.lime),
      ];
    } else {
      for (final data in widget.list) {
        chartData.add(
          BarChartData(
            data.platform ?? '',
            data.data ?? 0,
            HexColor(data.colour ?? '#000000'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatisticsCard(
      title: 'Platforms'.tr,
      subtitle: 'Visitors by operating system'.tr,
      child: Column(
        children: [
          _buildPlatformLegend(),
          verticalSpace(10),
          SizedBox(
            height: 205,
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 9,
      children: chartData.map((data) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: data.color,
                shape: BoxShape.circle,
              ),
            ),
            horizontalSpace(6),
            Text(
              data.x,
              style: pMedium8.copyWith(
                color: AppColor.cDarkGreyFont,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChart() {
    return SfCartesianChart(
      enableAxisAnimation: true,
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.only(
        left: 0,
        right: 5,
        top: 10,
      ),
      primaryXAxis: CategoryAxis(
        interval: 1,
        borderWidth: 0,
        majorTickLines: const MajorTickLines(width: 0),
        majorGridLines: MajorGridLines(
          color: AppColor.cBorder.withOpacity(.4),
        ),
        axisLine: AxisLine(
          width: 0,
          color: AppColor.cTransparent,
        ),
        labelStyle: pMedium8.copyWith(
          color: AppColor.cDarkGreyFont.withOpacity(.65),
        ),
      ),
      primaryYAxis: NumericAxis(
        borderWidth: 0,
        majorTickLines: const MajorTickLines(width: 0),
        majorGridLines: MajorGridLines(
          color: AppColor.cBorder.withOpacity(.35),
        ),
        axisLine: AxisLine(
          width: 0,
          color: AppColor.cTransparent,
        ),
        labelStyle: pMedium8.copyWith(
          color: AppColor.cDarkGreyFont.withOpacity(.55),
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        color: AppColor.cBackGround,
        borderColor: AppColor.cBorder,
        borderWidth: 1,
        builder: (
            data,
            point,
            series,
            pointIndex,
            seriesIndex,
            ) {
          final item = chartData[pointIndex];

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColor.cBackGround,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColor.cBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.x,
                  style: pMedium10.copyWith(
                    color: AppColor.cDarkGreyFont,
                  ),
                ),
                verticalSpace(5),
                Text(
                  item.desktop.toString(),
                  style: pBold16.copyWith(
                    color: item.color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      series: [
        ColumnSeries<BarChartData, String>(
          dataSource: chartData,
          width: .55,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
          xValueMapper: (data, _) => data.x,
          yValueMapper: (data, _) => data.desktop,
          pointColorMapper: (data, _) => data.color,
          name: 'Page View'.tr,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: pMedium10.copyWith(
              color: AppColor.cWhite,
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// BROWSER / DEVICE GRAPH
/// ------------------------------------------------------------

class BrowsersGraph extends StatefulWidget {
  final List<BrowserData>? browser;
  final List<DeviceData>? device;
  final bool isDevice;

  const BrowsersGraph({
    Key? key,
    this.browser,
    this.device,
    required this.isDevice,
  }) : super(key: key);

  @override
  State<BrowsersGraph> createState() =>
      _BrowsersGraphState();
}

class _BrowsersGraphState extends State<BrowsersGraph> {
  List<_ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.isDevice) {
      if (Prefs.getBool(AppConstant.isDemoMode) == true) {
        chartData = [
          _ChartData('WebKit', 350, Colors.pink),
          _ChartData('Samsung', 100, Colors.purple),
          _ChartData('Nexus', 120, Colors.amber),
          _ChartData('iPhone', 140, Colors.brown),
          _ChartData('Other', 120, Colors.indigo),
        ];
      } else {
        chartData = (widget.device ?? []).map((element) {
          return _ChartData(
            element.device ?? '',
            element.data ?? 0,
            HexColor(element.colour ?? '#000000'),
          );
        }).toList();
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
        chartData = (widget.browser ?? []).map((element) {
          return _ChartData(
            element.browser ?? '',
            element.data ?? 0,
            HexColor(element.colour ?? '#000000'),
          );
        }).toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatisticsCard(
      title: widget.isDevice
          ? 'Devices'.tr
          : 'Browsers'.tr,
      subtitle: widget.isDevice
          ? 'Visitors by device'.tr
          : 'Visitors by browser'.tr,
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: widget.isDevice
                ? _buildPieChart()
                : _buildRadialChart(),
          ),
          verticalSpace(10),
          _buildDetails(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      margin: EdgeInsets.zero,
      series: [
        PieSeries<_ChartData, String>(
          dataSource: chartData,
          xValueMapper: (data, _) => data.x,
          yValueMapper: (data, _) => data.y,
          pointColorMapper: (data, _) => data.color,
          explode: true,
          explodeIndex: 0,
          explodeOffset: '8%',
          radius: '90%',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: pMedium10.copyWith(
              color: AppColor.cDarkGreyFont,
            ),
            connectorLineSettings:
            const ConnectorLineSettings(
              length: '12%',
              type: ConnectorType.curve,
            ),
            builder: (
                data,
                point,
                series,
                pointIndex,
                seriesIndex,
                ) {
              return Text(
                chartData[pointIndex].y.toString(),
                style: pSemiBold8.copyWith(
                  color: chartData[pointIndex].color,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRadialChart() {
    return SfCircularChart(
      margin: EdgeInsets.zero,
      series: [
        RadialBarSeries<_ChartData, String>(
          dataSource: chartData,
          maximumValue: 1000,
          radius: '90%',
          innerRadius: '30%',
          gap: '5%',
          strokeWidth: 0,
          trackColor: AppColor.cBorder.withOpacity(.35),
          cornerStyle: CornerStyle.bothCurve,
          xValueMapper: (data, _) => data.x,
          yValueMapper: (data, _) => data.y,
          pointColorMapper: (data, _) => data.color,
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: chartData.map((data) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: data.color.withOpacity(.055),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: data.color.withOpacity(.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
              ),
              horizontalSpace(9),
              Expanded(
                child: Text(
                  data.x,
                  style: pMedium10.copyWith(
                    color: data.color,
                  ),
                ),
              ),
              Text(
                data.y.toString(),
                style: pBold12.copyWith(
                  color: data.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// ------------------------------------------------------------
/// MODELS
/// ------------------------------------------------------------

class BarChartData {
  BarChartData(
      this.x,
      this.desktop,
      this.color,
      );

  final String x;
  final num desktop;
  final Color color;
}

class _ChartData {
  final String x;
  final int y;
  final Color color;

  _ChartData(
      this.x,
      this.y,
      this.color,
      );
}
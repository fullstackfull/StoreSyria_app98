import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../utils/colors.dart';

class StatisticsTheme {
  // LIGHT
  static const lightBackground = Color(0xFFF6F7F9);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardStrong = Color(0xFFF9FAFB);
  static const lightBorder = Color(0xFFE5E7EB);
  static const lightBorderStrong = Color(0xFFD1D5DB);
  static const lightText = Color(0xFF111827);
  static const lightSecondary = Color(0xFF6B7280);
  static const lightMuted = Color(0xFF9CA3AF);

  // DARK
  static const darkBackground = Color(0xFF0B1120);
  static const darkCard = Color(0xFF111827);
  static const darkCardStrong = Color(0xFF172033);
  static const darkBorder = Color(0xFF1F2937);
  static const darkBorderStrong = Color(0xFF374151);
  static const darkText = Color(0xFFF9FAFB);
  static const darkSecondary = Color(0xFF9CA3AF);
  static const darkMuted = Color(0xFF6B7280);

  // DASHBOARD ACCENTS
  static Color primary = AppColor.blueColor;
  static const secondary = Color(0xFF3BF6A8);
  static const warning = Color(0x99EDF50B);
  static const danger = Color(0xFFD00A67);
}

class Glass {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) =>
      isDark(context) ? StatisticsTheme.darkCard : StatisticsTheme.lightCard;

  static Color surfaceStrong(BuildContext context) => isDark(context)
      ? StatisticsTheme.darkCardStrong
      : StatisticsTheme.lightCardStrong;

  static Color border(BuildContext context) => isDark(context)
      ? StatisticsTheme.darkBorder
      : StatisticsTheme.lightBorder;

  static Color borderStrong(BuildContext context) => isDark(context)
      ? StatisticsTheme.darkBorderStrong
      : StatisticsTheme.lightBorder;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? StatisticsTheme.darkText : StatisticsTheme.lightText;

  static Color textSecondary(BuildContext context) => isDark(context)
      ? StatisticsTheme.darkSecondary
      : StatisticsTheme.lightSecondary;

  static Color textMuted(BuildContext context) => isDark(context)
      ? StatisticsTheme.darkMuted
      : StatisticsTheme.lightMuted;

  static Color chartGrid(BuildContext context) => isDark(context)
      ? Colors.white.withOpacity(.07)
      : const Color(0xFFE5E7EB);

  static Color chartBackground(BuildContext context) =>
      isDark(context) ? StatisticsTheme.darkCard : StatisticsTheme.lightCard;

  static Color tooltipBackground(BuildContext context) =>
      isDark(context) ? const Color(0xFF1F2937) : Colors.white;
}

// ============================================================
// CLEAN PANEL
// ============================================================

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? tint;
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 20,
    this.blur = 0,
    this.tint,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Glass.isDark(context);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? Glass.surface(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? Glass.border(context)),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? .16 : .035),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
      ),
      child: child,
    );

    if (blur <= 0) return content;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );
  }
}

// ============================================================
// CLEAN CARD
// ============================================================

class GlassCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.icon,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: padding,
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: StatisticsTheme.primary.withOpacity(.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: StatisticsTheme.primary),
                ),
                horizontalSpace(10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pBold14.copyWith(
                        color: Glass.textPrimary(context),
                      ),
                    ),
                    if (subtitle != null) ...[
                      verticalSpace(3),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pRegular10.copyWith(
                          color: Glass.textSecondary(context),
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

// ============================================================
// BACKDROP
// ============================================================

class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Glass.isDark(context);

    return ColoredBox(
      color: isDark
          ? StatisticsTheme.darkBackground
          : StatisticsTheme.lightBackground,
    );
  }
}

// ============================================================
// HERO CARD
// ============================================================

class StatisticsHeroCard extends StatelessWidget {
  final String periodLabel;
  final int totalPageViews;
  final int totalUniqueViews;
  final int topLinksCount;

  const StatisticsHeroCard({
    super.key,
    required this.periodLabel,
    required this.totalPageViews,
    required this.totalUniqueViews,
    required this.topLinksCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Glass.isDark(context);

    return GlassPanel(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      tint: isDark ? StatisticsTheme.darkCard : StatisticsTheme.lightCard,
      borderColor: isDark
          ? StatisticsTheme.darkBorderStrong
          : StatisticsTheme.lightBorder,
      shadows: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? .20 : .045),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: StatisticsTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        horizontalSpace(7),
                        Text(
                          'Overview'.tr,
                          style: pSemiBold14.copyWith(
                            color: Glass.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(5),
                    Text(
                      periodLabel,
                      style: pRegular10.copyWith(
                        color: Glass.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: StatisticsTheme.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: StatisticsTheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          verticalSpace(20),
          Text(
            'Total page views'.tr,
            style: pRegular10.copyWith(color: Glass.textSecondary(context)),
          ),
          verticalSpace(4),
          AnimatedCounterText(
            value: totalPageViews,
            style: pBold30.copyWith(color: Glass.textPrimary(context)),
          ),
          verticalSpace(18),
          Row(
            children: [
              Expanded(
                child: _heroMiniStat(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  label: 'Unique visitors'.tr,
                  value: totalUniqueViews,
                ),
              ),
              horizontalSpace(10),
              Expanded(
                child: _heroMiniStat(
                  context: context,
                  icon: Icons.link_rounded,
                  label: 'Top links'.tr,
                  value: topLinksCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMiniStat({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Glass.surfaceStrong(context),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Glass.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: StatisticsTheme.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: StatisticsTheme.primary, size: 15),
          ),
          horizontalSpace(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCounterText(
                  value: value,
                  style: pBold16.copyWith(color: Glass.textPrimary(context)),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pRegular8.copyWith(color: Glass.textMuted(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ANIMATED COUNTER
// ============================================================

class AnimatedCounterText extends StatelessWidget {
  final int value;
  final TextStyle style;
  final Duration duration;

  const AnimatedCounterText({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(value.round().toString(), style: style);
      },
    );
  }
}

// ============================================================
// TOP URL CHART
// ============================================================

class TopUrlChart extends StatelessWidget {
  final List<TopUrl> list;
  final Animation<double> animation;

  const TopUrlChart({super.key, required this.list, required this.animation});

  @override
  Widget build(BuildContext context) {
    final visible = list.length > 7 ? list.sublist(0, 7) : list;

    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    final chartData = List<_TopUrlChartData>.generate(
      visible.length,
          (index) {
        final item = visible[index];
        return _TopUrlChartData('#${index + 1}', item.totalClick ?? 0);
      },
      growable: false,
    );

    return Container(
      height: 205,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      decoration: BoxDecoration(
        color: Glass.surfaceStrong(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Glass.border(context)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _TopUrlLinePainter(
                    data: chartData,
                    animation: animation,
                    lineColor: StatisticsTheme.primary,
                    fillColor: StatisticsTheme.primary.withOpacity(.10),
                  ),
                ),
              ),
            ),
          ),
          SfCartesianChart(
            plotAreaBorderWidth: 0,
            enableAxisAnimation: false,
            margin: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            legend: const Legend(isVisible: false),
            primaryXAxis: CategoryAxis(
              interval: 1,
              borderWidth: 0,
              majorGridLines: const MajorGridLines(width: 0),
              majorTickLines: const MajorTickLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: pMedium8.copyWith(color: Glass.textMuted(context)),
            ),
            primaryYAxis: NumericAxis(
              borderWidth: 0,
              majorGridLines: MajorGridLines(color: Glass.chartGrid(context)),
              majorTickLines: const MajorTickLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: pMedium8.copyWith(color: Glass.textMuted(context)),
            ),
            tooltipBehavior: TooltipBehavior(enable: false),
            series: <CartesianSeries<_TopUrlChartData, String>>[
              SplineSeries<_TopUrlChartData, String>(
                dataSource: chartData,
                xValueMapper: (data, _) => data.x,
                yValueMapper: (data, _) => data.y,
                color: Colors.transparent,
                width: 0,
                animationDuration: 0,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  width: 7,
                  height: 7,
                  color: Colors.transparent,
                ),
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.top,
                  textStyle: pSemiBold8.copyWith(
                    color: StatisticsTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopUrlChartData {
  final String x;
  final double y;

  const _TopUrlChartData(this.x, this.y);
}

// ============================================================
// COMPATIBILITY CARD
// ============================================================

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
    return GlassCard(title: title, subtitle: subtitle, padding: padding, child: child);
  }
}

// ============================================================
// TOP URL ITEM
// ============================================================

// Widget topUrlWidget({
//   required BuildContext context,
//   required String title,
//   required String subTitle,
//   required String total,
//   required String digit,
//   required Function() shareFun,
// }) {
//   final rankColors = [
//     const Color(0xFFD4A72C),
//     const Color(0xFF9CA3AF),
//     const Color(0xFFB7794B),
//   ];
//
//   final rankIndex = int.tryParse(digit) ?? 99;
//   final rankColor = rankIndex >= 1 && rankIndex <= 3
//       ? rankColors[rankIndex - 1]
//       : Glass.textSecondary(context);
//
//   return Container(
//     margin: const EdgeInsets.only(bottom: 9),
//     decoration: BoxDecoration(
//       color: Glass.surface(context),
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: Glass.border(context)),
//     ),
//     child: Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(14),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: shareFun,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
//           child: Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: rankColor.withOpacity(.10),
//                   borderRadius: BorderRadius.circular(9),
//                   border: Border.all(color: rankColor.withOpacity(.25)),
//                 ),
//                 child: Text('#$digit', style: pBold12.copyWith(color: rankColor)),
//               ),
//               horizontalSpace(11),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.link_rounded, size: 11, color: Glass.textMuted(context)),
//                         horizontalSpace(4),
//                         Expanded(
//                           child: Text(
//                             title,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: pRegular10.copyWith(color: Glass.textMuted(context)),
//                           ),
//                         ),
//                       ],
//                     ),
//                     verticalSpace(3),
//                     Text(
//                       subTitle,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: pSemiBold12.copyWith(color: Glass.textPrimary(context)),
//                     ),
//                   ],
//                 ),
//               ),
//               horizontalSpace(8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: StatisticsTheme.primary.withOpacity(.10),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(total, style: pBold12.copyWith(color: StatisticsTheme.primary)),
//               ),
//               horizontalSpace(6),
//               Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(8),
//                   onTap: shareFun,
//                   child: Container(
//                     width: 31,
//                     height: 31,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: Glass.surfaceStrong(context),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Glass.border(context)),
//                     ),
//                     child: Icon(Icons.ios_share_rounded, size: 15, color: StatisticsTheme.primary),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// ============================================================
// CLEAN VISITOR CHART
// ============================================================

class GlassVisitorChart extends StatelessWidget {
  final List<VisitorChartData> visitorChart;
  final Animation<double> animation;
  final Animation<double> lineOpacity;

  const GlassVisitorChart({
    super.key,
    required this.visitorChart,
    required this.animation,
    required this.lineOpacity,
  });

  List<ChartData> _loadChartData() {
    final data = visitorChart;
    final start = data.length > 7 ? data.length - 7 : 0;

    return data.sublist(start).map((e) {
      return ChartData(e.date ?? '', e.uniquePageview ?? 0, e.pageview ?? 0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _loadChartData();

    return GlassCard(
      title: 'Visitors'.tr,
      subtitle: 'Page views over the selected period'.tr,
      icon: Icons.show_chart_rounded,
      child: SizedBox(
        height: 220,
        child: chartData.isEmpty
            ? Center(
          child: Text(
            'No data'.tr,
            style: pRegular10.copyWith(color: Glass.textMuted(context)),
          ),
        )
            : Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // طبقة ثابتة: شبكة + أرقام + تواريخ - بترسم مرة وحدة بس
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _VisitorStaticPainter(data: chartData),
                  ),
                ),
              ),
              // طبقة متحركة: الخط + التظليل بس، ملفوفة بـ fade
              Positioned.fill(
                child: FadeTransition(
                  opacity: lineOpacity,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _VisitorLinePainter(
                        data: chartData,
                        animation: animation,
                        lineColor: StatisticsTheme.primary,
                        fillColor: StatisticsTheme.primary.withOpacity(.10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PLATFORM CHART
// ============================================================

class PlatformBarChart extends StatefulWidget {
  final List<PlatformData> list;

  const PlatformBarChart({
    super.key,
    required this.list,
  });

  @override
  State<PlatformBarChart> createState() => _PlatformBarChartState();
}

class _PlatformBarChartState extends State<PlatformBarChart>
    with SingleTickerProviderStateMixin {
  List<BarChartData> chartData = [];

  late final AnimationController _platformController;

  @override
  void initState() {
    super.initState();

    _loadData();

    _platformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didUpdateWidget(covariant PlatformBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.list != widget.list) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _platformController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (widget.list.isEmpty) {
      chartData = [
        BarChartData(
          'Windows',
          5,
          const Color(0xFF64748B),
        ),
        BarChartData(
          'OS X',
          10,
          const Color(0xFF3B82F6),
        ),
        BarChartData(
          'Linux',
          12,
          const Color(0xFF22C55E),
        ),
        BarChartData(
          'iOS',
          14,
          const Color(0xFF8B5CF6),
        ),
        BarChartData(
          'AndroidOS',
          12,
          const Color(0xFFF59E0B),
        ),
        BarChartData(
          'Other',
          15,
          const Color(0xFF94A3B8),
        ),
      ];
    } else {
      chartData = widget.list.map((data) {
        return BarChartData(
          data.platform ?? '',
          data.data ?? 0,
          HexColor(data.colour ?? '#64748B'),
        );
      }).toList();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _startAnimation() {
    if (_platformController.status ==
        AnimationStatus.dismissed) {
      _platformController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Container(
        height: 205,
        alignment: Alignment.center,
        child: Text(
          'No data',
          style: pMedium12.copyWith(
            color: Glass.textMuted(context),
          ),
        ),
      );
    }

    return VisibilityDetector(
      key: const Key('platform-bar-chart'),
      onVisibilityChanged: (info) {
        // يبدأ فقط لما يصير جزء واضح من الشارت ظاهر.
        if (info.visibleFraction > 0.15) {
          _startAnimation();
        }
      },
      child: Column(
        children: [
          _buildLegend(context),
          const SizedBox(height: 10),
          _buildChart(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: chartData.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              item.x,
              style: pMedium8.copyWith(
                color: Glass.textMuted(context),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Container(
      height: 205,
      padding: const EdgeInsets.fromLTRB(
        8,
        12,
        8,
        0,
      ),
      decoration: BoxDecoration(
        color: Glass.surfaceStrong(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Glass.border(context),
        ),
      ),
      child: Stack(
        children: [
          // المحاور والـlabels ثابتة.
          IgnorePointer(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              enableAxisAnimation: false,
              margin: const EdgeInsets.fromLTRB(
                4,
                8,
                4,
                4,
              ),
              legend: const Legend(
                isVisible: false,
              ),
              primaryXAxis: CategoryAxis(
                interval: 1,
                borderWidth: 0,
                majorGridLines: const MajorGridLines(
                  width: 0,
                ),
                majorTickLines: const MajorTickLines(
                  width: 0,
                ),
                axisLine: const AxisLine(
                  width: 0,
                ),
                labelStyle: pMedium8.copyWith(
                  color: Glass.textMuted(context),
                ),
              ),
              primaryYAxis: NumericAxis(
                borderWidth: 0,
                minimum: 0,
                maximum: _getMaxValue(),
                majorGridLines: MajorGridLines(
                  color: Glass.chartGrid(context),
                ),
                majorTickLines: const MajorTickLines(
                  width: 0,
                ),
                axisLine: const AxisLine(
                  width: 0,
                ),
                labelStyle: pMedium8.copyWith(
                  color: Glass.textMuted(context),
                ),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: false,
              ),
              series: const [],
            ),
          ),

          // الأعمدة المتحركة.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _platformController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _PlatformBarPainter(
                    data: chartData,
                    progress: _platformController.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxValue() {
    if (chartData.isEmpty) {
      return 10;
    }

    double max = 0;

    for (final item in chartData) {
      max = math.max(
        max,
        item.desktop.toDouble(),
      );
    }

    return max <= 0 ? 10 : max * 1.25;
  }
}

class _PlatformBarPainter extends CustomPainter {
  final List<BarChartData> data;
  final double progress;

  const _PlatformBarPainter({
    required this.data,
    required this.progress,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    if (data.isEmpty) return;

    const double left = 42;
    const double right = 14;
    const double top = 18;
    const double bottom = 34;

    final double chartWidth =
        size.width - left - right;

    final double chartHeight =
        size.height - top - bottom;

    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    double maxValue = 0;

    for (final item in data) {
      maxValue = math.max(
        maxValue,
        item.desktop.toDouble(),
      );
    }

    if (maxValue <= 0) return;

    maxValue *= 1.25;

    final double slotWidth =
        chartWidth / data.length;

    // الحركة من 0 إلى الارتفاع الحقيقي.
    final double animation =
    Curves.easeOutCubic.transform(progress);

    for (int index = 0; index < data.length; index++) {
      final item = data[index];

      final double value =
      item.desktop.toDouble();

      final double fullHeight =
          (value / maxValue) * chartHeight;

      // يبدأ من الصفر ويطلع للأعلى.
      final double barHeight =
          fullHeight * animation;

      final double centerX =
          left +
              (slotWidth * index) +
              (slotWidth / 2);

      final double barWidth =
          slotWidth * 0.55;

      final double barLeft =
          centerX - (barWidth / 2);

      final double barRight =
          centerX + (barWidth / 2);

      final double barBottom =
          top + chartHeight;

      final double barTop =
          barBottom - barHeight;

      final Rect rect = Rect.fromLTRB(
        barLeft,
        barTop,
        barRight,
        barBottom,
      );

      final RRect roundedRect =
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(7),
        topRight: const Radius.circular(7),
      );

      final Paint paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.drawRRect(
        roundedRect,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _PlatformBarPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress ||
        oldDelegate.data != data;
  }
}// ============================================================
// BROWSER / DEVICE
// ============================================================

class BrowsersGraph extends StatefulWidget {
  final List<BrowserData>? browser;
  final List<DeviceData>? device;
  final bool isDevice;

  const BrowsersGraph({Key? key, this.browser, this.device, required this.isDevice}) : super(key: key);

  @override
  State<BrowsersGraph> createState() => _BrowsersGraphState();
}

class _BrowsersGraphState extends State<BrowsersGraph> {
  List<_ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant BrowsersGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.browser != widget.browser ||
        oldWidget.device != widget.device ||
        oldWidget.isDevice != widget.isDevice) {
      _loadData();
    }
  }

  void _loadData() {
    final palette = <Color>[
    AppColor.blueColor,
    Color(0xFF3BF6A8),
    Color(0x99F5F10B),
    Color(0xFFD00A67),
    ];

    if (widget.isDevice) {
      if (Prefs.getBool(AppConstant.isDemoMode) == true) {
        chartData = [
          _ChartData('WebKit', 350, palette[0]),
          _ChartData('Samsung', 100, palette[1]),
          _ChartData('Nexus', 120, palette[2]),
          _ChartData('iPhone', 140, palette[3]),
          _ChartData('Other', 120, palette[4]),
        ];
      } else {
        chartData = (widget.device ?? []).asMap().entries.map((entry) {
          final element = entry.value;
          return _ChartData(element.device ?? '', element.data ?? 0, palette[entry.key % palette.length]);
        }).toList();
      }
    } else {
      if (Prefs.getBool(AppConstant.isDemoMode) == true) {
        chartData = [
          _ChartData('Safari', 200, palette[0]),
          _ChartData('Mozilla', 320, palette[1]),
          _ChartData('Firefox', 420, palette[2]),
          _ChartData('Edge', 540, palette[3]),
          _ChartData('Chrome', 700, palette[4]),
        ];
      } else {
        chartData = (widget.browser ?? []).asMap().entries.map((entry) {
          final element = entry.value;
          return _ChartData(element.browser ?? '', element.data ?? 0, palette[entry.key % palette.length]);
        }).toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: widget.isDevice ? 'Devices'.tr : 'Browsers'.tr,
      subtitle: widget.isDevice ? 'Visitors by device'.tr : 'Visitors by browser'.tr,
      icon: widget.isDevice ? Icons.phone_iphone_rounded : Icons.public_rounded,
      child: chartData.isEmpty
          ? SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No data'.tr,
            style: pRegular10.copyWith(color: Glass.textMuted(context)),
          ),
        ),
      )
          : Column(
        children: [
          SizedBox(
            height: 210,
            child: widget.isDevice ? _buildPieChart(context) : _buildRadialChart(context),
          ),
          verticalSpace(10),
          _buildDetails(context),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
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
          explodeOffset: '6%',
          radius: '88%',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: pSemiBold8.copyWith(color: Glass.textSecondary(context)),
            connectorLineSettings: const ConnectorLineSettings(length: '10%', type: ConnectorType.curve),
            builder: (data, point, series, pointIndex, seriesIndex) {
              return Text(
                chartData[pointIndex].y.toString(),
                style: pSemiBold8.copyWith(color: chartData[pointIndex].color),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRadialChart(BuildContext context) {
    final maxValue = chartData.fold<num>(0, (max, item) => item.y > max ? item.y : max);

    return SfCircularChart(
      margin: EdgeInsets.zero,
      series: [
        RadialBarSeries<_ChartData, String>(
          dataSource: chartData,
          maximumValue: maxValue <= 0 ? 100 : maxValue.toDouble(),
          radius: '90%',
          innerRadius: '32%',
          gap: '5%',
          strokeWidth: 0,
          trackColor: Glass.isDark(context) ? Colors.white.withOpacity(.06) : const Color(0xFFE5E7EB),
          cornerStyle: CornerStyle.bothCurve,
          xValueMapper: (data, _) => data.x,
          yValueMapper: (data, _) => data.y,
          pointColorMapper: (data, _) => data.color,
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      children: chartData.map((data) {
        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Glass.surfaceStrong(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Glass.border(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: data.color, shape: BoxShape.circle),
              ),
              horizontalSpace(9),
              Expanded(
                child: Text(data.x, style: pMedium10.copyWith(color: Glass.textSecondary(context))),
              ),
              Text(data.y.toString(), style: pBold12.copyWith(color: Glass.textPrimary(context))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// MODELS
// ============================================================

class BarChartData {
  BarChartData(this.x, this.desktop, this.color);

  final String x;
  final num desktop;
  final Color color;
}

class _ChartData {
  final String x;
  final int y;
  final Color color;

  _ChartData(this.x, this.y, this.color);
}

// ============================================================
// TOP URL PAINTER (بدون تغيير)
// ============================================================

class _TopUrlLinePainter extends CustomPainter {
  final List<_TopUrlChartData> data;
  final Animation<double> animation;
  final Color lineColor;
  final Color fillColor;

  PathMetric? _metric;
  Size? _lastSize;

  _TopUrlLinePainter({
    required this.data,
    required this.animation,
    required this.lineColor,
    required this.fillColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) {
      return;
    }

    _ensurePath(size);

    final metric = _metric;

    if (metric == null || metric.length <= 0) {
      return;
    }

    final progress = Curves.easeIn.transform(
      animation.value.clamp(0.0, 1.0),
    );
    if (progress <= 0) {
      return;
    }

    final visibleLength = metric.length * progress;
    final visiblePath = metric.extractPath(0, visibleLength);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(visiblePath, linePaint);

    _drawArea(
      canvas: canvas,
      size: size,
      metric: metric,
      visiblePath: visiblePath,
      visibleLength: visibleLength,
    );
  }

  void _ensurePath(Size size) {
    if (_metric != null && _lastSize == size) {
      return;
    }

    _lastSize = size;
    _metric = null;

    const left = 42.0;
    const right = 14.0;
    const top = 18.0;
    const bottom = 28.0;

    final width = size.width - left - right;
    final height = size.height - top - bottom;

    if (width <= 0 || height <= 0) {
      return;
    }

    double minY = data.first.y;
    double maxY = data.first.y;

    for (final item in data) {
      if (item.y < minY) {
        minY = item.y;
      }
      if (item.y > maxY) {
        maxY = item.y;
      }
    }

    final range = maxY - minY;

    double x(int index) {
      return left + (width * index / (data.length - 1));
    }

    double y(double value) {
      if (range == 0) {
        return top + height / 2;
      }
      final normalized = (value - minY) / range;
      return top + height - (normalized * height);
    }

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final currentX = x(i);
      final currentY = y(data[i].y);

      if (i == 0) {
        path.moveTo(currentX, currentY);
        continue;
      }

      final previousX = x(i - 1);
      final previousY = y(data[i - 1].y);
      final controlX = (previousX + currentX) / 2;

      path.cubicTo(controlX, previousY, controlX, currentY, currentX, currentY);
    }

    final metrics = path.computeMetrics().toList(growable: false);

    if (metrics.isEmpty) {
      return;
    }

    _metric = metrics.first;
  }

  void _drawArea({
    required Canvas canvas,
    required Size size,
    required PathMetric metric,
    required Path visiblePath,
    required double visibleLength,
  }) {
    const left = 42.0;
    const top = 18.0;
    const bottom = 28.0;

    final height = size.height - top - bottom;

    final tangent = metric.getTangentForOffset(visibleLength.clamp(0.0, metric.length));

    if (tangent == null) {
      return;
    }

    final areaPath = Path()
      ..addPath(visiblePath, Offset.zero)
      ..lineTo(tangent.position.dx, top + height)
      ..lineTo(left, top + height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, top, size.width, height));

    canvas.drawPath(areaPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _TopUrlLinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.animation != animation ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

// ============================================================
// طبقة ثابتة: شبكة + Y labels + date labels + value labels
// بترسم مرة وحدة بس، ما إلها علاقة بالأنيميشن إطلاقًا
// ============================================================
class _VisitorStaticPainter extends CustomPainter {
  final List<ChartData> data;

  static const double left = 42;
  static const double right = 14;
  static const double top = 18;
  static const double bottom = 34;

  _VisitorStaticPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    double maxY = 0;
    for (final item in data) {
      final value = (item.desktop + item.mobile).toDouble();
      if (value > maxY) maxY = value;
    }
    if (maxY <= 0) maxY = 1;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    const divisions = 4;
    for (int i = 0; i <= divisions; i++) {
      final gridY = top + chartHeight * i / divisions;
      canvas.drawLine(Offset(left, gridY), Offset(size.width - right, gridY), gridPaint);
    }

    final yTextStyle = pMedium8.copyWith(color: const Color(0xFF9CA3AF));
    for (int i = 0; i <= divisions; i++) {
      final value = maxY - (maxY * i / divisions);
      final painter = TextPainter(
        text: TextSpan(text: _formatNumber(value), style: yTextStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelY = top + chartHeight * i / divisions;
      painter.paint(canvas, Offset(left - painter.width - 8, labelY - painter.height / 2));
    }

    double x(int index) =>
        data.length == 1 ? left + chartWidth / 2 : left + chartWidth * index / (data.length - 1);
    double y(double value) => top + chartHeight - (value / maxY).clamp(0.0, 1.0) * chartHeight;

    for (int i = 0; i < data.length; i++) {
      final value = (data[i].desktop + data[i].mobile).toDouble();
      final point = Offset(x(i), y(value));
      final painter = TextPainter(
        text: TextSpan(text: _formatNumber(value), style: pSemiBold8.copyWith(color: StatisticsTheme.primary)),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(point.dx - painter.width / 2, point.dy - painter.height - 7));
    }

    final dateStyle = pMedium8.copyWith(color: const Color(0xFF9CA3AF));
    for (int i = 0; i < data.length; i++) {
      if (data.length > 8 && i % 2 != 0 && i != data.length - 1) continue;
      final painter = TextPainter(
        text: TextSpan(text: data[i].x, style: dateStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final px = x(i);
      painter.paint(canvas, Offset(px - painter.width / 2, size.height - bottom + 8));
    }
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      final formatted =
      value % 1000 == 0 ? (value / 1000).toStringAsFixed(0) : (value / 1000).toStringAsFixed(1);
      return '${formatted}k';
    }
    return value.round().toString();
  }

  @override
  bool shouldRepaint(covariant _VisitorStaticPainter oldDelegate) => oldDelegate.data != data;
}

class _VisitorLinePainter extends CustomPainter {
  final List<ChartData> data;
  final Animation<double> animation;
  final Color lineColor;
  final Color fillColor;

  _VisitorLinePainter({
    required this.data,
    required this.animation,
    required this.lineColor,
    required this.fillColor,
  }) : super(repaint: animation);

  static const double left = 42;
  static const double right = 14;
  static const double top = 18;
  static const double bottom = 34;

  Path? _linePath;
  PathMetric? _metric;
  Size? _lastSize;

  void _ensurePath(Size size) {
    if (_linePath != null && _lastSize == size) {
      return;
    }

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    if (chartWidth <= 0 || chartHeight <= 0 || data.isEmpty) {
      _linePath = null;
      _metric = null;
      return;
    }

    // نفس القيمة المستخدمة في _VisitorStaticPainter
    final values = data
        .map((e) => (e.desktop + e.mobile).toDouble())
        .toList();

    // نفس مقياس الـ Y الموجود في الرسم الثابت
    double maxY = 0;

    for (final value in values) {
      if (value > maxY) {
        maxY = value;
      }
    }

    if (maxY <= 0) {
      maxY = 1;
    }

    double x(int index) {
      if (data.length == 1) {
        return left + chartWidth / 2;
      }

      return left +
          chartWidth * index / (data.length - 1);
    }

    double y(double value) {
      final normalized =
      (value / maxY).clamp(0.0, 1.0);

      return top +
          chartHeight -
          normalized * chartHeight;
    }

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final currentX = x(i);
      final currentY = y(values[i]);

      if (i == 0) {
        path.moveTo(currentX, currentY);
        continue;
      }

      final previousX = x(i - 1);
      final previousY = y(values[i - 1]);

      // منحنى ناعم بين النقطتين
      final controlX = (previousX + currentX) / 2;

      path.cubicTo(
        controlX,
        previousY,
        controlX,
        currentY,
        currentX,
        currentY,
      );
    }

    _linePath = path;
    _lastSize = size;

    final metrics = path.computeMetrics().toList(growable: false);

    _metric = metrics.isEmpty ? null : metrics.first;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _ensurePath(size);

    final metric = _metric;

    if (metric == null || metric.length <= 0) {
      return;
    }

    // 0 → 1
    final progress = Curves.easeInOutCubic.transform(
      animation.value.clamp(0.0, 1.0),
    );

    if (progress <= 0) {
      return;
    }

    // طول الجزء الذي سيتم رسمه
    final visibleLength = metric.length * progress;

    // أهم سطر:
    // يرسم الـ Path فعليًا من اليسار لليمين
    final visiblePath = metric.extractPath(
      0,
      visibleLength,
    );

    // =========================================================
    // AREA / GRADIENT
    // =========================================================

    final tangent = metric.getTangentForOffset(
      visibleLength.clamp(0.0, metric.length),
    );

    if (tangent != null) {
      final areaPath = Path()
        ..addPath(visiblePath, Offset.zero)
        ..lineTo(
          tangent.position.dx,
          size.height - bottom,
        )
        ..lineTo(
          left,
          size.height - bottom,
        )
        ..close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fillColor,
            fillColor.withOpacity(0),
          ],
        ).createShader(
          Rect.fromLTWH(
            0,
            top,
            size.width,
            size.height - top - bottom,
          ),
        );

      canvas.drawPath(
        areaPath,
        areaPaint,
      );
    }

    // =========================================================
    // LINE
    // =========================================================

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      visiblePath,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _VisitorLinePainter oldDelegate,
      ) {
    return oldDelegate.data != data ||
        oldDelegate.animation != animation ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}
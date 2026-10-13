import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../utils/colors.dart';

// ============================================================
// THEME
// One set of tokens for the whole statistics screen. Surfaces and
// text match the rest of the app (order details, notes, ...), so the
// screen no longer has its own blue-black dark theme.
// ============================================================

class StatisticsTheme {
  // LIGHT
  static const lightBackground = Color(0xFFF7F8FA);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardStrong = Color(0xFFF7F8FA);
  static const lightBorder = Color(0xFFE8EAF0);
  static const lightSecondary = Color(0xFF7B8190);
  static const lightMuted = Color(0xFF9CA3AF);
  static const lightGrid = Color(0xFFEDEFF3);

  // DARK (same values as DarkThemeColor)
  static const darkBackground = Color(0xFF0F1A2E);
  static const darkCard = Color(0xFF18263F);
  static const darkCardStrong = Color(0xFF232833);
  static const darkBorder = Color(0xFF2E4266);
  static const darkSecondary = Color(0xFFA0A0A0);
  static const darkMuted = Color(0xFF7B8190);
  static const darkGrid = Color(0xFF2A2F3B);

  // Brand primary, stepped lighter for dark mode so lines/bars keep
  // >= 3:1 contrast on the dark card.
  static const primaryLight = Color(0xFF2C57A2); // AppColor.blueColor
  static const primaryDark = Color(0xFF10AFC0);

  // Categorical order for browsers / devices. Validated for colour-blind
  // separation and contrast against the card in each mode. Keep the order:
  // it is what makes neighbours distinguishable.
  static const categoricalLight = <Color>[
    Color(0xFF2C57A2), // blue
    Color(0xFFEB6834), // orange
    Color(0xFF1BAF7A), // aqua
    Color(0xFFEDA100), // yellow
    Color(0xFFE87BA4), // magenta
  ];
  static const categoricalDark = <Color>[
    Color(0xFF10AFC0),
    Color(0xFFD95926),
    Color(0xFF199E70),
    Color(0xFFC98500),
    Color(0xFFD55181),
  ];

  // Everything past the 5th item is folded into "Other" with this gray.
  static const otherLight = Color(0xFFB4B9C4);
  static const otherDark = Color(0xFF5C6270);
}

class Glass {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) => isDark(context)
      ? StatisticsTheme.darkBackground
      : StatisticsTheme.lightBackground;

  static Color surface(BuildContext context) =>
      isDark(context) ? StatisticsTheme.darkCard : StatisticsTheme.lightCard;

  static Color surfaceStrong(BuildContext context) => isDark(context)
      ? StatisticsTheme.darkCardStrong
      : StatisticsTheme.lightCardStrong;

  static Color border(BuildContext context) =>
      isDark(context) ? StatisticsTheme.darkBorder : StatisticsTheme.lightBorder;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : AppColor.cText;

  static Color textSecondary(BuildContext context) => isDark(context)
      ? StatisticsTheme.darkSecondary
      : StatisticsTheme.lightSecondary;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? StatisticsTheme.darkMuted : StatisticsTheme.lightMuted;

  static Color chartGrid(BuildContext context) =>
      isDark(context) ? StatisticsTheme.darkGrid : StatisticsTheme.lightGrid;

  static Color primary(BuildContext context) => isDark(context)
      ? StatisticsTheme.primaryDark
      : StatisticsTheme.primaryLight;

  static List<Color> categorical(BuildContext context) => isDark(context)
      ? StatisticsTheme.categoricalDark
      : StatisticsTheme.categoricalLight;

  static Color other(BuildContext context) =>
      isDark(context) ? StatisticsTheme.otherDark : StatisticsTheme.otherLight;
}

// ============================================================
// PANEL
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
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.blur = 0,
    this.tint,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Glass.isDark(context);

    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? Glass.surface(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? Glass.border(context)),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? .18 : .04),
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
// CARD (title + optional icon + child)
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
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final primary = Glass.primary(context);

    return GlassPanel(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                _IconBadge(icon: icon!, color: primary, size: 34),
                horizontalSpace(10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pBold14.copyWith(color: Glass.textPrimary(context)),
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

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconBadge({required this.icon, required this.color, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: Glass.isDark(context) ? .18 : .10),
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Icon(icon, size: size * .5, color: color),
    );
  }
}

/// The inset box every chart sits in, so all charts share one frame.
class _ChartFrame extends StatelessWidget {
  final double height;
  final Widget child;

  const _ChartFrame({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Glass.surfaceStrong(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Glass.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final double height;

  const _EmptyChart({this.height = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          'No data'.tr,
          style: pRegular12.copyWith(color: Glass.textMuted(context)),
        ),
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
    return ColoredBox(color: Glass.background(context));
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
    final primary = Glass.primary(context);

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview'.tr,
                      style: pBold14.copyWith(color: Glass.textPrimary(context)),
                    ),
                    verticalSpace(4),
                    Text(
                      periodLabel,
                      style: pRegular10.copyWith(
                        color: Glass.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              _IconBadge(icon: Icons.bar_chart_rounded, color: primary, size: 38),
            ],
          ),
          verticalSpace(18),
          Text(
            'Total page views'.tr,
            style: pRegular12.copyWith(color: Glass.textSecondary(context)),
          ),
          verticalSpace(4),
          AnimatedCounterText(
            value: totalPageViews,
            style: pBold30.copyWith(color: Glass.textPrimary(context)),
          ),
          verticalSpace(16),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Glass.border(context)),
      ),
      child: Row(
        children: [
          _IconBadge(icon: icon, color: Glass.primary(context), size: 30),
          horizontalSpace(9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCounterText(
                  value: value,
                  style: pBold16.copyWith(color: Glass.textPrimary(context)),
                ),
                verticalSpace(2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pRegular10.copyWith(color: Glass.textSecondary(context)),
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
        return Text(_formatCount(value), style: style);
      },
    );
  }
}

String _formatCount(num value) {
  if (value >= 1000000) {
    final v = value / 1000000;
    return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}M';
  }
  if (value >= 10000) {
    final v = value / 1000;
    return '${v.toStringAsFixed(v >= 100 ? 0 : 1)}k';
  }
  return value.round().toString();
}

// ============================================================
// TOP URLS
// A ranked list reads better as horizontal bars than as a line:
// each row shows the link, a bar sized by clicks, and the count.
// ============================================================

class TopUrlChart extends StatelessWidget {
  final List<TopUrl> list;

  /// Kept for backwards compatibility; bars animate once on their own.
  final Animation<double>? animation;

  const TopUrlChart({super.key, required this.list, this.animation});

  @override
  Widget build(BuildContext context) {
    final visible = list.length > 7 ? list.sublist(0, 7) : list;
    if (visible.isEmpty) return const _EmptyChart();

    final maxClicks = visible.fold<double>(
      0,
          (m, e) => math.max(m, e.totalClick ?? 0),
    );
    final primary = Glass.primary(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Column(
          children: [
            for (int i = 0; i < visible.length; i++) ...[
              if (i > 0) verticalSpace(12),
              _topUrlRow(
                context: context,
                rank: i + 1,
                url: _shortUrl(visible[i].url ?? ''),
                clicks: visible[i].totalClick ?? 0,
                fraction: maxClicks <= 0
                    ? 0
                    : ((visible[i].totalClick ?? 0) / maxClicks) * t,
                color: primary,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _topUrlRow({
    required BuildContext context,
    required int rank,
    required String url,
    required double clicks,
    required double fraction,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '#$rank',
                style: pSemiBold12.copyWith(color: Glass.textSecondary(context)),
              ),
            ),
            Expanded(
              child: Text(
                url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
                style: pMedium12.copyWith(color: Glass.textPrimary(context)),
              ),
            ),
            horizontalSpace(8),
            Text(
              _formatCount(clicks),
              style: pBold12.copyWith(color: Glass.textPrimary(context)),
            ),
          ],
        ),
        verticalSpace(6),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Glass.chartGrid(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 6,
                    width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _shortUrl(String url) {
    return url
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'^www\.'), '');
  }
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
    return GlassCard(
      title: title,
      subtitle: subtitle,
      padding: padding,
      child: child,
    );
  }
}

// ============================================================
// SHARED AXIS LAYOUT
// Visitors (line) and platforms (bars) use the same paddings, grid,
// label sizes and colours, so the two charts look like one family.
// ============================================================

class _AxisLayout {
  static const double left = 40;
  static const double right = 14;
  static const double top = 22;
  static const double bottom = 30;
  static const int divisions = 4;

  /// Rounds the max up to a clean number so grid labels are 0, 25, 50...
  static double niceMax(double maxValue) {
    if (maxValue <= 0) return 4;
    final raw = maxValue * 1.1;
    final magnitude =
    math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    for (final step in [1.0, 2.0, 2.5, 5.0, 10.0]) {
      final candidate = step * magnitude;
      if (candidate >= raw) return candidate;
    }
    return 10 * magnitude;
  }
}

class _AxisPainter extends CustomPainter {
  final List<String> xLabels;
  final double maxY;
  final Color gridColor;
  final Color labelColor;

  /// true = labels sit under each bar slot; false = under each point.
  final bool slotted;

  _AxisPainter({
    required this.xLabels,
    required this.maxY,
    required this.gridColor,
    required this.labelColor,
    required this.slotted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const l = _AxisLayout.left;
    const r = _AxisLayout.right;
    const t = _AxisLayout.top;
    const b = _AxisLayout.bottom;
    const divisions = _AxisLayout.divisions;

    final chartWidth = size.width - l - r;
    final chartHeight = size.height - t - b;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final labelStyle = pRegular10.copyWith(color: labelColor);

    for (int i = 0; i <= divisions; i++) {
      final y = t + chartHeight * i / divisions;
      canvas.drawLine(Offset(l, y), Offset(size.width - r, y), gridPaint);

      final value = maxY - (maxY * i / divisions);
      final tp = TextPainter(
        text: TextSpan(text: _formatCount(value), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(l - tp.width - 8, y - tp.height / 2));
    }

    if (xLabels.isEmpty) return;
    final n = xLabels.length;
    // Thin out labels so they never collide.
    final every = n > 8 ? 2 : 1;

    for (int i = 0; i < n; i++) {
      if (i % every != 0 && i != n - 1) continue;
      final cx = slotted
          ? l + chartWidth * (i + .5) / n
          : (n == 1 ? l + chartWidth / 2 : l + chartWidth * i / (n - 1));
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: slotted ? chartWidth / n : 64);
      tp.paint(canvas, Offset(cx - tp.width / 2, size.height - b + 9));
    }
  }

  @override
  bool shouldRepaint(covariant _AxisPainter old) =>
      old.maxY != maxY ||
          old.gridColor != gridColor ||
          old.labelColor != labelColor ||
          old.slotted != slotted ||
          !_listEquals(old.xLabels, xLabels);
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// ============================================================
// VISITOR CHART
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
      // Page views only. The old chart added unique + page views together,
      // which counted every unique visit twice.
      return ChartData(_shortDate(e.date ?? ''), e.pageview ?? 0, 0);
    }).toList();
  }

  // "2026-09-30" -> "09/30"; anything else is kept as is.
  String _shortDate(String date) {
    final m = RegExp(r'^\d{4}-(\d{2})-(\d{2})').firstMatch(date);
    return m == null ? date : '${m.group(1)}/${m.group(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _loadChartData();
    final primary = Glass.primary(context);

    double maxValue = 0;
    for (final item in chartData) {
      maxValue = math.max(maxValue, (item.desktop + item.mobile).toDouble());
    }
    final maxY = _AxisLayout.niceMax(maxValue);

    return GlassCard(
      title: 'Visitors'.tr,
      subtitle: 'Page views over the selected period'.tr,
      icon: Icons.show_chart_rounded,
      child: chartData.isEmpty
          ? const _EmptyChart(height: 220)
          : _ChartFrame(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _AxisPainter(
                    xLabels: chartData.map((e) => e.x).toList(),
                    maxY: maxY,
                    gridColor: Glass.chartGrid(context),
                    labelColor: Glass.textMuted(context),
                    slotted: false,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: FadeTransition(
                opacity: lineOpacity,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _VisitorLinePainter(
                      data: chartData,
                      maxY: maxY,
                      animation: animation,
                      lineColor: primary,
                      fillColor: primary.withValues(alpha:
                          Glass.isDark(context) ? .22 : .12),
                      surfaceColor: Glass.surfaceStrong(context),
                      labelColor: Glass.textPrimary(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitorLinePainter extends CustomPainter {
  final List<ChartData> data;
  final double maxY;
  final Animation<double> animation;
  final Color lineColor;
  final Color fillColor;
  final Color surfaceColor;
  final Color labelColor;

  _VisitorLinePainter({
    required this.data,
    required this.maxY,
    required this.animation,
    required this.lineColor,
    required this.fillColor,
    required this.surfaceColor,
    required this.labelColor,
  }) : super(repaint: animation);

  List<Offset> _points = const [];
  PathMetric? _metric;
  Size? _lastSize;

  void _ensurePath(Size size) {
    if (_lastSize == size && _points.isNotEmpty) return;
    _lastSize = size;
    _metric = null;
    _points = const [];

    const l = _AxisLayout.left;
    const r = _AxisLayout.right;
    const t = _AxisLayout.top;
    const b = _AxisLayout.bottom;

    final chartWidth = size.width - l - r;
    final chartHeight = size.height - t - b;
    if (chartWidth <= 0 || chartHeight <= 0 || data.isEmpty) return;

    double x(int i) => data.length == 1
        ? l + chartWidth / 2
        : l + chartWidth * i / (data.length - 1);
    double y(num v) =>
        t + chartHeight - (v / maxY).clamp(0.0, 1.0) * chartHeight;

    _points = [
      for (int i = 0; i < data.length; i++)
        Offset(x(i), y(data[i].desktop + data[i].mobile)),
    ];

    final path = Path()..moveTo(_points.first.dx, _points.first.dy);
    for (int i = 1; i < _points.length; i++) {
      final p0 = _points[i - 1];
      final p1 = _points[i];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final metrics = path.computeMetrics().toList(growable: false);
    _metric = metrics.isEmpty ? null : metrics.first;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _ensurePath(size);
    if (_points.isEmpty) return;

    final progress = Curves.easeInOutCubic.transform(
      animation.value.clamp(0.0, 1.0),
    );
    if (progress <= 0) return;

    final baseline = size.height - _AxisLayout.bottom;
    final metric = _metric;

    if (metric != null && metric.length > 0) {
      final visibleLength = metric.length * progress;
      final visiblePath = metric.extractPath(0, visibleLength);
      final tangent = metric.getTangentForOffset(visibleLength);

      if (tangent != null) {
        final area = Path()
          ..addPath(visiblePath, Offset.zero)
          ..lineTo(tangent.position.dx, baseline)
          ..lineTo(_points.first.dx, baseline)
          ..close();

        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [fillColor, fillColor.withValues(alpha: 0)],
            ).createShader(
              Rect.fromLTRB(0, _AxisLayout.top, size.width, baseline),
            ),
        );
      }

      canvas.drawPath(
        visiblePath,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Markers for the points the line has reached.
    final reachedX = _points.first.dx +
        (_points.last.dx - _points.first.dx) * progress;
    final ring = Paint()..color = surfaceColor;
    final dot = Paint()..color = lineColor;
    for (final p in _points) {
      if (p.dx > reachedX + .5) break;
      canvas.drawCircle(p, 5, ring);
      canvas.drawCircle(p, 3.5, dot);
    }

    // Only label the peak and the latest day, not every point.
    if (progress >= 1) {
      int peak = 0;
      for (int i = 1; i < _points.length; i++) {
        if (_points[i].dy < _points[peak].dy) peak = i;
      }
      final last = _points.length - 1;
      for (final i in {peak, last}) {
        final value = data[i].desktop + data[i].mobile;
        final tp = TextPainter(
          text: TextSpan(
            text: _formatCount(value),
            style: pSemiBold10.copyWith(color: labelColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final dx = (_points[i].dx - tp.width / 2)
            .clamp(0.0, size.width - tp.width);
        tp.paint(canvas, Offset(dx, _points[i].dy - tp.height - 8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VisitorLinePainter old) =>
      old.data != data ||
          old.maxY != maxY ||
          old.animation != animation ||
          old.lineColor != lineColor ||
          old.fillColor != fillColor ||
          old.surfaceColor != surfaceColor ||
          old.labelColor != labelColor;
}

// ============================================================
// PLATFORM CHART
// One measure across platforms, so every bar uses the brand colour.
// The platform name under each bar is the identity; no legend needed.
// ============================================================

class PlatformBarChart extends StatefulWidget {
  final List<PlatformData> list;

  const PlatformBarChart({super.key, required this.list});

  @override
  State<PlatformBarChart> createState() => _PlatformBarChartState();
}

class _PlatformBarChartState extends State<PlatformBarChart>
    with SingleTickerProviderStateMixin {
  List<BarChartData> chartData = [];
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadData();
  }

  @override
  void didUpdateWidget(covariant PlatformBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list != widget.list) _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadData() {
    chartData = widget.list
        .map((d) =>
        BarChartData(d.platform ?? '', d.data ?? 0, Colors.transparent))
        .toList();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double maxValue = 0;
    for (final item in chartData) {
      maxValue = math.max(maxValue, item.desktop.toDouble());
    }
    final maxY = _AxisLayout.niceMax(maxValue);

    return GlassCard(
      title: 'Platforms'.tr,
      subtitle: 'Visitors by operating system'.tr,
      icon: Icons.devices_other_rounded,
      child: chartData.isEmpty
          ? const _EmptyChart(height: 205)
          : VisibilityDetector(
        key: const Key('platform-bar-chart'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.15 &&
              _controller.status == AnimationStatus.dismissed) {
            _controller.forward();
          }
        },
        child: _ChartFrame(
          height: 205,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AxisPainter(
                    xLabels: chartData.map((e) => e.x).toList(),
                    maxY: maxY,
                    gridColor: Glass.chartGrid(context),
                    labelColor: Glass.textMuted(context),
                    slotted: true,
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _PlatformBarPainter(
                    data: chartData,
                    maxY: maxY,
                    progress: _controller,
                    barColor: Glass.primary(context),
                    labelColor: Glass.textPrimary(context),
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

class _PlatformBarPainter extends CustomPainter {
  final List<BarChartData> data;
  final double maxY;
  final Animation<double> progress;
  final Color barColor;
  final Color labelColor;

  _PlatformBarPainter({
    required this.data,
    required this.maxY,
    required this.progress,
    required this.barColor,
    required this.labelColor,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const l = _AxisLayout.left;
    const r = _AxisLayout.right;
    const t = _AxisLayout.top;
    const b = _AxisLayout.bottom;

    final chartWidth = size.width - l - r;
    final chartHeight = size.height - t - b;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final anim = Curves.easeOutCubic.transform(progress.value);
    final slot = chartWidth / data.length;
    final barWidth = math.min(slot * .5, 28.0);
    final baseline = t + chartHeight;
    final paint = Paint()..color = barColor;

    for (int i = 0; i < data.length; i++) {
      final value = data[i].desktop.toDouble();
      final h = (value / maxY).clamp(0.0, 1.0) * chartHeight * anim;
      final cx = l + slot * (i + .5);

      if (h > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTRB(
                cx - barWidth / 2, baseline - h, cx + barWidth / 2, baseline),
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
          ),
          paint,
        );
      }

      if (anim >= 1) {
        final tp = TextPainter(
          text: TextSpan(
            text: _formatCount(value),
            style: pSemiBold10.copyWith(color: labelColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
            canvas, Offset(cx - tp.width / 2, baseline - h - tp.height - 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PlatformBarPainter old) =>
      old.data != data ||
          old.maxY != maxY ||
          old.barColor != barColor ||
          old.labelColor != labelColor;
}

// ============================================================
// BROWSERS / DEVICES
// Both use the same donut + list, so the two cards match.
// ============================================================

class BrowsersGraph extends StatelessWidget {
  final List<BrowserData>? browser;
  final List<DeviceData>? device;
  final bool isDevice;

  static const int _maxSlices = 5;

  const BrowsersGraph({
    super.key,
    this.browser,
    this.device,
    required this.isDevice,
  });

  List<MapEntry<String, int>> _rawData() {
    if (Prefs.getBool(AppConstant.isDemoMode) == true) {
      return isDevice
          ? const [
        MapEntry('WebKit', 350),
        MapEntry('iPhone', 140),
        MapEntry('Nexus', 120),
        MapEntry('Samsung', 100),
        MapEntry('Other', 120),
      ]
          : const [
        MapEntry('Chrome', 700),
        MapEntry('Edge', 540),
        MapEntry('Firefox', 420),
        MapEntry('Mozilla', 320),
        MapEntry('Safari', 200),
      ];
    }
    return isDevice
        ? (device ?? [])
        .map((e) => MapEntry(e.device ?? '', e.data ?? 0))
        .toList()
        : (browser ?? [])
        .map((e) => MapEntry(e.browser ?? '', e.data ?? 0))
        .toList();
  }

  /// Biggest first, colours in fixed order, anything past 5 folded into
  /// "Other" so we never run out of distinguishable colours.
  List<_ChartData> _chartData(BuildContext context) {
    final raw = _rawData().where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final palette = Glass.categorical(context);
    final result = <_ChartData>[];

    if (raw.length <= _maxSlices) {
      for (int i = 0; i < raw.length; i++) {
        result.add(_ChartData(raw[i].key, raw[i].value, palette[i]));
      }
      return result;
    }

    for (int i = 0; i < _maxSlices - 1; i++) {
      result.add(_ChartData(raw[i].key, raw[i].value, palette[i]));
    }
    final rest =
    raw.skip(_maxSlices - 1).fold<int>(0, (s, e) => s + e.value);
    result.add(_ChartData('Other'.tr, rest, Glass.other(context)));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _chartData(context);
    final total = chartData.fold<int>(0, (s, e) => s + e.y);

    return GlassCard(
      title: isDevice ? 'Devices'.tr : 'Browsers'.tr,
      subtitle: isDevice ? 'Visitors by device'.tr : 'Visitors by browser'.tr,
      icon: isDevice ? Icons.phone_iphone_rounded : Icons.public_rounded,
      child: chartData.isEmpty
          ? const _EmptyChart()
          : Column(
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SfCircularChart(
                  margin: EdgeInsets.zero,
                  series: [
                    DoughnutSeries<_ChartData, String>(
                      dataSource: chartData,
                      xValueMapper: (d, _) => d.x,
                      yValueMapper: (d, _) => d.y,
                      pointColorMapper: (d, _) => d.color,
                      radius: '95%',
                      innerRadius: '68%',
                      // 2px surface gap between slices
                      strokeWidth: 2,
                      strokeColor: Glass.surface(context),
                      animationDuration: 900,
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatCount(total),
                      style: pBold16.copyWith(
                        color: Glass.textPrimary(context),
                      ),
                    ),
                    verticalSpace(2),
                    Text(
                      'Total'.tr,
                      style: pRegular10.copyWith(
                        color: Glass.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          verticalSpace(14),
          ...chartData.map((d) => _legendRow(context, d, total)),
        ],
      ),
    );
  }

  Widget _legendRow(BuildContext context, _ChartData d, int total) {
    final percent = total <= 0 ? 0.0 : (d.y / total * 100);

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
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: d.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          horizontalSpace(10),
          Expanded(
            child: Text(
              d.x,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pMedium12.copyWith(color: Glass.textPrimary(context)),
            ),
          ),
          Text(
            '${percent.toStringAsFixed(percent >= 10 ? 0 : 1)}%',
            style: pRegular12.copyWith(color: Glass.textSecondary(context)),
          ),
          horizontalSpace(12),
          SizedBox(
            width: 44,
            child: Text(
              _formatCount(d.y),
              textAlign: TextAlign.end,
              style: pBold12.copyWith(color: Glass.textPrimary(context)),
            ),
          ),
        ],
      ),
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

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

const Color kGlassDeepNavy =
Color(0xFF070B14);

const Color kGlassMidNavy =
Color(0xFF101827);

class StatisticsTheme {
  // =========================
  // LIGHT
  // =========================

  static const lightBackground =
  Color(0xFFF5F7FA);

  static const lightCard =
  Color(0xFFFFFFFF);

  static const lightCardStrong =
  Color(0xFFF8FAFC);

  static const lightBorder =
  Color(0xFFE2E8F0);

  static const lightBorderStrong =
  Color(0xFFCBD5E1);

  static const lightText =
  Color(0xFF172033);

  static const lightSecondary =
  Color(0xFF64748B);

  static const lightMuted =
  Color(0xFF94A3B8);

  // =========================
  // DARK
  // =========================

  static const darkBackground =
  Color(0xFF070B14);

  static const darkCard =
  Color(0xFF101827);

  static const darkBorder =
  Color(0xFF263246);

  static const darkBorderStrong =
  Color(0xFF3A465A);

  static const darkText =
  Color(0xFFF8FAFC);

  static const darkSecondary =
  Color(0xFF94A3B8);

  static const darkMuted =
  Color(0xFF64748B);
}

class Glass {
  static bool isDark(
      BuildContext context,
      ) {
    return Theme.of(context).brightness ==
        Brightness.dark;
  }

  static Color surface(
      BuildContext context,
      ) {
    return isDark(context)
        ? Colors.white.withOpacity(.055)
        : StatisticsTheme.lightCard;
  }

  static Color surfaceStrong(
      BuildContext context,
      ) {
    return isDark(context)
        ? Colors.white.withOpacity(.095)
        : StatisticsTheme.lightCardStrong;
  }

  static Color border(
      BuildContext context,
      ) {
    return isDark(context)
        ? Colors.white.withOpacity(.11)
        : StatisticsTheme.lightBorder;
  }

  static Color borderStrong(
      BuildContext context,
      ) {
    return isDark(context)
        ? Colors.white.withOpacity(.22)
        : StatisticsTheme.lightBorderStrong;
  }

  static Color textPrimary(
      BuildContext context,
      ) {
    return isDark(context)
        ? StatisticsTheme.darkText
        : StatisticsTheme.lightText;
  }

  static Color textSecondary(
      BuildContext context,
      ) {
    return isDark(context)
        ? StatisticsTheme.darkSecondary
        : StatisticsTheme.lightSecondary;
  }

  static Color textMuted(
      BuildContext context,
      ) {
    return isDark(context)
        ? StatisticsTheme.darkMuted
        : StatisticsTheme.lightMuted;
  }

  static Color chartGrid(
      BuildContext context,
      ) {
    return isDark(context)
        ? Colors.white.withOpacity(.06)
        : const Color(0xFFE8EDF3);
  }

  static Color chartBackground(
      BuildContext context,
      ) {
    return isDark(context)
        ? kGlassMidNavy
        : Colors.white;
  }

  static Color tooltipBackground(
      BuildContext context,
      ) {
    return isDark(context)
        ? kGlassMidNavy
        : Colors.white;
  }
}

// ============================================================
// GLASS PANEL
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
    this.padding =
    const EdgeInsets.all(18),
    this.radius = 24,
    this.blur = 22,
    this.tint,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
    Glass.isDark(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(radius),
        boxShadow: shadows ??
            [
              BoxShadow(
                color:
                Colors.black.withOpacity(
                  isDark ? .25 : .06,
                ),
                blurRadius: 24,
                offset:
                const Offset(0, 12),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint ??
                  Glass.surface(context),
              borderRadius:
              BorderRadius.circular(
                radius,
              ),
              border: Border.all(
                color: borderColor ??
                    Glass.border(context),
              ),
              gradient: isDark
                  ? LinearGradient(
                begin:
                Alignment.topLeft,
                end: Alignment
                    .bottomRight,
                colors: [
                  Colors.white
                      .withOpacity(.055),
                  Colors.transparent,
                ],
              )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GLASS CARD
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
    this.padding =
    const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: padding,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  alignment:
                  Alignment.center,
                  decoration:
                  BoxDecoration(
                    borderRadius:
                    BorderRadius
                        .circular(11),
                    gradient:
                    LinearGradient(
                      colors: [
                        AppColor
                            .themeGreenColor,
                        AppColor.blueColor,
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: Colors.white,
                  ),
                ),

                horizontalSpace(10),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      title,
                      style:
                      pBold14.copyWith(
                        color:
                        Glass.textPrimary(
                          context,
                        ),
                      ),
                    ),

                    if (subtitle !=
                        null) ...[
                      verticalSpace(3),

                      Text(
                        subtitle!,
                        style:
                        pRegular10
                            .copyWith(
                          color: Glass
                              .textSecondary(
                            context,
                          ),
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

class GlassBackdrop extends StatefulWidget {
  const GlassBackdrop({
    super.key,
  });

  @override
  State<GlassBackdrop> createState() =>
      _GlassBackdropState();
}

class _GlassBackdropState
    extends State<GlassBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(
      vsync: this,
      duration:
      const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(context).size;

    final isDark =
    Glass.isDark(context);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? StatisticsTheme
                  .darkBackground
                  : StatisticsTheme
                  .lightBackground,
            ),
          ),
        ),

        if (isDark)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t =
                  _controller.value *
                      2 *
                      math.pi;

              return Stack(
                children: [
                  _blob(
                    color: AppColor
                        .themeGreenColor,
                    size:
                    size.width * .95,
                    left:
                    -size.width * .35 +
                        18 *
                            math.sin(t),
                    top:
                    -size.height * .06 +
                        14 *
                            math.cos(t),
                    opacity: .24,
                  ),

                  _blob(
                    color:
                    AppColor.blueColor,
                    size:
                    size.width * .85,
                    right:
                    -size.width * .30 +
                        16 *
                            math.cos(
                              t * 1.3,
                            ),
                    top:
                    size.height * .18 +
                        14 *
                            math.sin(
                              t * 1.3,
                            ),
                    opacity: .20,
                  ),

                  _blob(
                    color: AppColor
                        .themeGreenColor,
                    size:
                    size.width * .7,
                    left:
                    size.width * .05 +
                        18 *
                            math.cos(
                              t * .8,
                            ),
                    bottom:
                    -size.height * .08 +
                        14 *
                            math.sin(
                              t * .8,
                            ),
                    opacity: .13,
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _blob({
    required Color color,
    required double size,
    double? left,
    double? top,
    double? right,
    double? bottom,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration:
          BoxDecoration(
            shape: BoxShape.circle,
            gradient:
            RadialGradient(
              colors: [
                color.withOpacity(
                  opacity,
                ),
                color.withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HERO CARD
// ============================================================

class StatisticsHeroCard
    extends StatelessWidget {
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
    final isDark =
    Glass.isDark(context);

    return GlassPanel(
      radius: 28,
      blur: 28,
      padding:
      const EdgeInsets.fromLTRB(
        22,
        22,
        22,
        20,
      ),
      tint: isDark
          ? Colors.white.withOpacity(.05)
          : Colors.white,
      borderColor: AppColor
          .themeGreenColor
          .withOpacity(
        isDark ? .30 : .22,
      ),
      shadows: [
        BoxShadow(
          color: AppColor
              .themeGreenColor
              .withOpacity(
            isDark ? .16 : .08,
          ),
          blurRadius: 40,
          spreadRadius: -4,
          offset:
          const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black
              .withOpacity(
            isDark ? .35 : .06,
          ),
          blurRadius: 22,
          offset:
          const Offset(0, 10),
        ),
      ],
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  28,
                ),
                gradient:
                LinearGradient(
                  begin:
                  Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
                  colors: [
                    AppColor
                        .themeGreenColor
                        .withOpacity(
                      isDark ? .16 : .07,
                    ),
                    AppColor.blueColor
                        .withOpacity(
                      isDark ? .05 : .03,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration:
                              BoxDecoration(
                                shape: BoxShape
                                    .circle,
                                color: AppColor
                                    .themeGreenColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor
                                        .themeGreenColor
                                        .withOpacity(
                                      .9,
                                    ),
                                    blurRadius:
                                    6,
                                    spreadRadius:
                                    1,
                                  ),
                                ],
                              ),
                            ),

                            horizontalSpace(
                              7,
                            ),

                            Text(
                              "Overview".tr,
                              style:
                              pSemiBold14
                                  .copyWith(
                                color: Glass
                                    .textPrimary(
                                  context,
                                ).withOpacity(
                                  .9,
                                ),
                                letterSpacing:
                                .3,
                              ),
                            ),
                          ],
                        ),

                        verticalSpace(5),

                        Text(
                          periodLabel,
                          style:
                          pRegular10
                              .copyWith(
                            color: Glass
                                .textMuted(
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets
                        .all(10),
                    decoration:
                    BoxDecoration(
                      color: Glass
                          .surfaceStrong(
                        context,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                      border: Border.all(
                        color: Glass
                            .border(
                          context,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons
                          .auto_graph_rounded,
                      color: AppColor
                          .themeGreenColor,
                      size: 20,
                    ),
                  ),
                ],
              ),

              verticalSpace(20),

              Text(
                "Total page views".tr,
                style:
                pRegular10.copyWith(
                  color: Glass
                      .textSecondary(
                    context,
                  ),
                ),
              ),

              verticalSpace(4),

              ShaderMask(
                shaderCallback:
                    (rect) {
                  return LinearGradient(
                    colors: isDark
                        ? [
                      Colors.white,
                      AppColor
                          .themeGreenColor,
                    ]
                        : [
                      AppColor
                          .themeNavyBlueColor,
                      AppColor
                          .themeGreenColor,
                    ],
                  ).createShader(rect);
                },
                child:
                AnimatedCounterText(
                  value:
                  totalPageViews,
                  style:
                  pBold30.copyWith(
                    color:
                    Colors.white,
                  ),
                ),
              ),

              verticalSpace(20),

              Row(
                children: [
                  Expanded(
                    child:
                    _heroMiniStat(
                      context: context,
                      icon: Icons
                          .person_outline_rounded,
                      label:
                      "Unique visitors"
                          .tr,
                      value:
                      totalUniqueViews,
                    ),
                  ),

                  horizontalSpace(10),

                  Expanded(
                    child:
                    _heroMiniStat(
                      context: context,
                      icon: Icons
                          .link_rounded,
                      label:
                      "Top links".tr,
                      value:
                      topLinksCount,
                    ),
                  ),
                ],
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
      padding:
      const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration:
      BoxDecoration(
        color:
        Glass.surfaceStrong(
          context,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Glass.border(
            context,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.all(6),
            decoration:
            BoxDecoration(
              color: AppColor
                  .themeGreenColor
                  .withOpacity(.16),
              borderRadius:
              BorderRadius.circular(
                9,
              ),
            ),
            child: Icon(
              icon,
              color: AppColor
                  .themeGreenColor,
              size: 14,
            ),
          ),

          horizontalSpace(9),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                AnimatedCounterText(
                  value: value,
                  style:
                  pBold16.copyWith(
                    color: Glass
                        .textPrimary(
                      context,
                    ),
                  ),
                ),

                Text(
                  label,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  pRegular8.copyWith(
                    color: Glass
                        .textMuted(
                      context,
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
}

// ============================================================
// ANIMATED COUNTER
// ============================================================

class AnimatedCounterText
    extends StatelessWidget {
  final int value;
  final TextStyle style;
  final Duration duration;

  const AnimatedCounterText({
    super.key,
    required this.value,
    required this.style,
    this.duration =
    const Duration(
      milliseconds: 900,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<
        double>(
      tween: Tween(
        begin: 0,
        end: value.toDouble(),
      ),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (
          context,
          value,
          child,
          ) {
        return Text(
          value.round().toString(),
          style: style,
        );
      },
    );
  }
}

// ============================================================
// OLD STATISTICS CARD
// ============================================================

class StatisticsCard
    extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const StatisticsCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding =
    const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
      BoxDecoration(
        color: AppColor.cBackGround,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: AppColor.cBorder
              .withOpacity(.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.035),
            blurRadius: 15,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration:
                BoxDecoration(
                  color: AppColor
                      .themeNavyBlueColor,
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              horizontalSpace(10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      pBold14.copyWith(
                        color: AppColor
                            .cDarkGreyFont,
                      ),
                    ),

                    if (subtitle !=
                        null) ...[
                      verticalSpace(3),
                      Text(
                        subtitle!,
                        style:
                        pRegular10
                            .copyWith(
                          color: AppColor
                              .cDarkGreyFont
                              .withOpacity(
                            .65,
                          ),
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
// TOP URL ITEM
// ============================================================

Widget topUrlWidget({
  required BuildContext context,
  required String title,
  required String subTitle,
  required String total,
  required String digit,
  required Function() shareFun,
}) {
  final rankColors = [
    const Color(0xFFC9A227),
    const Color(0xFF9AA5B1),
    const Color(0xFFB2723A),
  ];

  final int rankIndex =
      int.tryParse(digit) ?? 99;

  final Color rankColor =
  rankIndex >= 1 &&
      rankIndex <= 3
      ? rankColors[rankIndex - 1]
      : AppColor
      .themeNavyBlueColor;

  return Container(
    margin:
    const EdgeInsets.only(
      bottom: 10,
    ),
    decoration:
    BoxDecoration(
      color: Glass.surface(context),
      borderRadius:
      BorderRadius.circular(15),
      border: Border.all(
        color: Glass.border(context),
      ),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius:
      BorderRadius.circular(15),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(15),
        onTap: shareFun,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment:
                Alignment.center,
                decoration:
                BoxDecoration(
                  color:
                  rankColor.withOpacity(
                    .18,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color: rankColor
                        .withOpacity(
                      .35,
                    ),
                  ),
                ),
                child: Text(
                  '#$digit',
                  style:
                  pBold12.copyWith(
                    color: rankColor,
                  ),
                ),
              ),

              horizontalSpace(12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons
                              .link_rounded,
                          size: 11,
                          color: Glass
                              .textMuted(
                            context,
                          ),
                        ),

                        horizontalSpace(4),

                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            pRegular10
                                .copyWith(
                              color: Glass
                                  .textMuted(
                                context,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    verticalSpace(3),

                    Text(
                      subTitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      pSemiBold12
                          .copyWith(
                        color: Glass
                            .textPrimary(
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              horizontalSpace(8),

              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color: AppColor
                      .themeGreenColor
                      .withOpacity(.16),
                  borderRadius:
                  BorderRadius.circular(
                    9,
                  ),
                ),
                child: Text(
                  total,
                  style:
                  pBold12.copyWith(
                    color: AppColor
                        .themeGreenColor,
                  ),
                ),
              ),

              horizontalSpace(6),

              InkWell(
                borderRadius:
                BorderRadius.circular(
                  9,
                ),
                onTap: shareFun,
                child: Container(
                  padding:
                  const EdgeInsets
                      .all(7),
                  decoration:
                  BoxDecoration(
                    color: Glass
                        .surfaceStrong(
                      context,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      9,
                    ),
                    border: Border.all(
                      color: Glass.border(
                        context,
                      ),
                    ),
                  ),
                  child: Icon(
                    Icons
                        .ios_share_rounded,
                    size: 15,
                    color: AppColor
                        .themeGreenColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// OLD VISITOR GRAPH
// ============================================================

class StatisticsVisitorGraph
    extends StatefulWidget {
  final List<VisitorChartData>
  visitorChart;

  const StatisticsVisitorGraph({
    Key? key,
    required this.visitorChart,
  }) : super(key: key);

  @override
  State<StatisticsVisitorGraph>
  createState() =>
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

    if (Prefs.getBool(
      AppConstant.isDemoMode,
    ) ==
        true) {
      chartData = [
        ChartData(
          '19-jul',
          5,
          8,
        ),
        ChartData(
          '20-jul',
          10,
          15,
        ),
        ChartData(
          '21-jul',
          12,
          17,
        ),
        ChartData(
          '22-jul',
          14,
          19,
        ),
        ChartData(
          '23-jul',
          12,
          17,
        ),
        ChartData(
          '24-jul',
          15,
          10,
        ),
        ChartData(
          '25-jul',
          8,
          5,
        ),
      ];
    } else {
      final data =
          widget.visitorChart;

      final start = data.length > 7
          ? data.length - 7
          : 0;

      chartData =
          data.sublist(start).map(
                (data) {
              return ChartData(
                data.date ?? '',
                data.uniquePageview ??
                    0,
                data.pageview ?? 0,
              );
            },
          ).toList();
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      height: 250,
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: AppColor.cBorder,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  AppColor
                      .themeNavyBlueColor,
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
                  AppColor
                      .themeGreenColor,
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
            child:
            _buildStackedBarChart(),
          ),
        ],
      ),
    );
  }

  SfCartesianChart
  _buildStackedBarChart() {
    return SfCartesianChart(
      enableAxisAnimation: true,
      plotAreaBorderWidth: 0,
      legend:
      Legend(isVisible: false),
      zoomPanBehavior:
      ZoomPanBehavior(
        enablePanning: true,
      ),
      primaryXAxis: CategoryAxis(
        borderWidth: 0,
        autoScrollingMode:
        AutoScrollingMode.start,
        autoScrollingDelta: 7,
        maximumLabels: 100,
        majorGridLines:
        MajorGridLines(
          color: AppColor.cBorder,
        ),
        axisLine: AxisLine(
          width: 0,
          color:
          AppColor.cTransparent,
        ),
        interval: 1,
        majorTickLines:
        MajorTickLines(
          width: 0,
        ),
        axisBorderType:
        AxisBorderType
            .withoutTopAndBottom,
      ),
      primaryYAxis: NumericAxis(
        borderWidth: 0,
        majorGridLines:
        MajorGridLines(
          color:
          AppColor.cTransparent,
        ),
        axisLine: AxisLine(
          width: 0,
          color:
          AppColor.cTransparent,
        ),
        majorTickLines:
        MajorTickLines(
          width: 0,
        ),
      ),
      tooltipBehavior:
      TooltipBehavior(
        enable: true,
        color:
        AppColor.cBackGround,
        activationMode:
        ActivationMode.singleTap,
        canShowMarker: true,
        shouldAlwaysShow: false,
        borderColor:
        AppColor.cBorder,
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

          final String title =
          isUnique
              ? "Unique Page View"
              .tr
              : "Total Page View".tr;

          final num value = isUnique
              ? chartData[pointIndex]
              .desktop
              : chartData[pointIndex]
              .mobile;

          return Container(
            decoration:
            BoxDecoration(
              color:
              AppColor.cBackGround,
              border: Border.all(
                color:
                AppColor.cBorder,
              ),
              borderRadius:
              BorderRadius.circular(
                8,
              ),
            ),
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  pBold12.copyWith(
                    color: AppColor
                        .cDarkGreyFont,
                  ),
                ),
                verticalSpace(8),
                Text(
                  value.toString(),
                  style:
                  pBold16.copyWith(
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
      series:
      _getStackedBarSeries(),
    );
  }

  List<CartesianSeries<ChartData,
      String>>
  _getStackedBarSeries() {
    return [
      StackedColumnSeries<
          ChartData, String>(
        dataSource: chartData,
        xValueMapper:
            (ChartData data, _) =>
        data.x,
        yValueMapper:
            (ChartData data, _) =>
        data.desktop,
        color:
        AppColor.themeGreenColor,
        name:
        'Unique Page View'.tr,
        animationDuration: 900,
        dataLabelSettings:
        DataLabelSettings(
          isVisible: true,
          textStyle:
          pMedium10.copyWith(
            color:
            AppColor.cWhite,
          ),
        ),
      ),
      StackedColumnSeries<
          ChartData, String>(
        dataSource: chartData,
        xValueMapper:
            (ChartData data, _) =>
        data.x,
        yValueMapper:
            (ChartData data, _) =>
        data.mobile,
        color:
        AppColor.themeNavyBlueColor,
        name:
        'Total Page View'.tr,
        animationDuration: 1100,
        borderRadius:
        const BorderRadius
            .vertical(
          top: Radius.circular(8),
        ),
        dataLabelSettings:
        DataLabelSettings(
          isVisible: true,
          textStyle:
          pMedium10.copyWith(
            color:
            AppColor.cWhite,
          ),
          borderRadius: 12,
        ),
      ),
    ];
  }
}

// ============================================================
// GLASS VISITOR CHART
// ============================================================

class GlassVisitorChart
    extends StatefulWidget {
  final List<VisitorChartData>
  visitorChart;

  const GlassVisitorChart({
    super.key,
    required this.visitorChart,
  });

  @override
  State<GlassVisitorChart>
  createState() =>
      _GlassVisitorChartState();
}

class _GlassVisitorChartState
    extends State<GlassVisitorChart> {
  List<ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(
      covariant GlassVisitorChart
      oldWidget,
      ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.visitorChart !=
        widget.visitorChart) {
      _load();
    }
  }

  void _load() {
    final data =
        widget.visitorChart;

    final start = data.length > 7
        ? data.length - 7
        : 0;

    chartData =
        data.sublist(start).map(
              (e) {
            return ChartData(
              e.date ?? '',
              e.uniquePageview ?? 0,
              e.pageview ?? 0,
            );
          },
        ).toList();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return GlassCard(
      title: "Visitors".tr,
      subtitle:
      "Page views over the selected period"
          .tr,
      icon: Icons.show_chart_rounded,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _legendDot(
                AppColor
                    .themeGreenColor,
                "Unique page view".tr,
              ),
              horizontalSpace(16),
              _legendDot(
                AppColor.blueColor,
                "Total page view".tr,
              ),
            ],
          ),

          verticalSpace(14),

          SizedBox(
            height: 190,
            child: chartData.isEmpty
                ? Center(
              child: Text(
                "No data".tr,
                style:
                pRegular10
                    .copyWith(
                  color: Glass
                      .textMuted(
                    context,
                  ),
                ),
              ),
            )
                : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(
      Color color,
      String label,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration:
          BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color:
                color.withOpacity(
                  .8,
                ),
                blurRadius: 6,
              ),
            ],
          ),
        ),

        horizontalSpace(7),

        Text(
          label,
          style: pMedium8.copyWith(
            color: Glass
                .textSecondary(
              context,
            ),
          ),
        ),
      ],
    );
  }

  SfCartesianChart _buildChart() {
    final isDark =
    Glass.isDark(context);

    return SfCartesianChart(
      enableAxisAnimation: true,
      plotAreaBorderWidth: 0,
      legend:
      Legend(isVisible: false),
      zoomPanBehavior:
      ZoomPanBehavior(
        enablePanning: true,
      ),
      primaryXAxis: CategoryAxis(
        borderWidth: 0,
        autoScrollingMode:
        AutoScrollingMode.start,
        autoScrollingDelta: 7,
        maximumLabels: 100,
        interval: 1,
        majorGridLines:
        MajorGridLines(
          color:
          Glass.chartGrid(
            context,
          ),
        ),
        axisLine: AxisLine(
          width: 0,
          color:
          AppColor.cTransparent,
        ),
        majorTickLines:
        const MajorTickLines(
          width: 0,
        ),
        axisBorderType:
        AxisBorderType
            .withoutTopAndBottom,
        labelStyle:
        pMedium8.copyWith(
          color: Glass.textMuted(
            context,
          ),
        ),
      ),
      primaryYAxis: NumericAxis(
        borderWidth: 0,
        majorGridLines:
        MajorGridLines(
          color:
          Glass.chartGrid(
            context,
          ),
        ),
        axisLine: AxisLine(
          width: 0,
          color:
          AppColor.cTransparent,
        ),
        majorTickLines:
        const MajorTickLines(
          width: 0,
        ),
        labelStyle:
        pMedium8.copyWith(
          color: Glass.textMuted(
            context,
          ),
        ),
      ),
      tooltipBehavior:
      TooltipBehavior(
        enable: true,
        color:
        Glass.tooltipBackground(
          context,
        ),
        activationMode:
        ActivationMode.singleTap,
        canShowMarker: true,
        shouldAlwaysShow: false,
        borderColor:
        Glass.borderStrong(
          context,
        ),
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

          final String title =
          isUnique
              ? "Unique Page View"
              .tr
              : "Total Page View".tr;

          final num value = isUnique
              ? chartData[pointIndex]
              .desktop
              : chartData[pointIndex]
              .mobile;

          return Container(
            decoration:
            BoxDecoration(
              color: Glass
                  .tooltipBackground(
                context,
              ),
              border: Border.all(
                color: Glass
                    .borderStrong(
                  context,
                ),
              ),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  pBold12.copyWith(
                    color: Glass
                        .textSecondary(
                      context,
                    ),
                  ),
                ),

                verticalSpace(6),

                Text(
                  value.toString(),
                  style:
                  pBold16.copyWith(
                    color: isUnique
                        ? AppColor
                        .themeGreenColor
                        : AppColor
                        .blueColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      series: <
          CartesianSeries<
              ChartData, String>>[
        SplineAreaSeries<
            ChartData, String>(
          dataSource: chartData,
          xValueMapper:
              (d, _) => d.x,
          yValueMapper:
              (d, _) => d.desktop,
          color: AppColor
              .themeGreenColor
              .withOpacity(.20),
          borderColor:
          AppColor
              .themeGreenColor,
          borderWidth: 2.4,
          animationDuration: 900,
          markerSettings:
          MarkerSettings(
            isVisible: true,
            color: isDark
                ? kGlassDeepNavy
                : Colors.white,
            borderColor:
            AppColor
                .themeGreenColor,
            borderWidth: 2,
            width: 6,
            height: 6,
          ),
        ),

        SplineSeries<
            ChartData, String>(
          dataSource: chartData,
          xValueMapper:
              (d, _) => d.x,
          yValueMapper:
              (d, _) => d.mobile,
          color:
          AppColor.blueColor,
          width: 2.4,
          animationDuration: 1100,
          markerSettings:
          MarkerSettings(
            isVisible: true,
            color: isDark
                ? kGlassDeepNavy
                : Colors.white,
            borderColor:
            AppColor.blueColor,
            borderWidth: 2,
            width: 6,
            height: 6,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PLATFORM CHART
// ============================================================

class PlatformBarChart
    extends StatefulWidget {
  final List<PlatformData> list;

  const PlatformBarChart({
    super.key,
    required this.list,
  });

  @override
  State<PlatformBarChart>
  createState() =>
      _PlatformBarChartState();
}

class _PlatformBarChartState
    extends State<PlatformBarChart> {
  List<BarChartData> chartData =
  [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    chartData = [];

    if (Prefs.getBool(
      AppConstant.isDemoMode,
    ) ==
        true) {
      chartData = [
        BarChartData(
          'Windows',
          5,
          Colors.pink,
        ),
        BarChartData(
          'OS X',
          10,
          Colors.purple,
        ),
        BarChartData(
          'Linux',
          12,
          Colors.amber,
        ),
        BarChartData(
          'iOS',
          14,
          Colors.brown,
        ),
        BarChartData(
          'AndroidOS',
          12,
          Colors.indigo,
        ),
        BarChartData(
          'Other',
          15,
          Colors.lime,
        ),
      ];
    } else {
      for (final data
      in widget.list) {
        chartData.add(
          BarChartData(
            data.platform ?? '',
            data.data ?? 0,
            HexColor(
              data.colour ??
                  '#000000',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return GlassCard(
      title: 'Platforms'.tr,
      subtitle:
      'Visitors by operating system'
          .tr,
      icon:
      Icons.devices_other_rounded,
      child: Column(
        children: [
          _buildPlatformLegend(),

          verticalSpace(12),

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
      children: chartData.map(
            (data) {
          return Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                BoxDecoration(
                  color: data.color,
                  shape:
                  BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: data.color
                          .withOpacity(
                        .7,
                      ),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),

              horizontalSpace(6),

              Text(
                data.x,
                style:
                pMedium8.copyWith(
                  color: Glass
                      .textSecondary(
                    context,
                  ),
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }

  Widget _buildChart() {
    return SfCartesianChart(
      enableAxisAnimation: true,
      plotAreaBorderWidth: 0,
      margin:
      const EdgeInsets.only(
        left: 0,
        right: 5,
        top: 10,
      ),
      primaryXAxis: CategoryAxis(
        interval: 1,
        borderWidth: 0,
        majorTickLines:
        const MajorTickLines(
          width: 0,
        ),
        majorGridLines:
        MajorGridLines(
          color:
          Glass.chartGrid(
            context,
          ),
        ),
        axisLine: AxisLine(
          width: 0,
          color:
          AppColor.cTransparent,
        ),
        labelStyle:
        pMedium8.copyWith(
          color: Glass.textSecondary(
            context,
          ),
        ),
      ),
      primaryYAxis: NumericAxis(
        borderWidth: 0,
        majorTickLines:
        const MajorTickLines(
          width: 0,
        ),
        majorGridLines:
        MajorGridLines(
          color:
          Glass.chartGrid(
            context,
          ),
        ),
        axisLine: AxisLine(
          width: 0,
          color:
          AppColor.cTransparent,
        ),
        labelStyle:
        pMedium8.copyWith(
          color: Glass.textMuted(
            context,
          ),
        ),
      ),
      tooltipBehavior:
      TooltipBehavior(
        enable: true,
        activationMode:
        ActivationMode.singleTap,
        color:
        Glass.tooltipBackground(
          context,
        ),
        borderColor:
        Glass.borderStrong(
          context,
        ),
        borderWidth: 1,
        builder: (
            data,
            point,
            series,
            pointIndex,
            seriesIndex,
            ) {
          final item =
          chartData[pointIndex];

          return Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration:
            BoxDecoration(
              color: Glass
                  .tooltipBackground(
                context,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: Glass
                    .borderStrong(
                  context,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  item.x,
                  style:
                  pMedium10.copyWith(
                    color: Glass
                        .textSecondary(
                      context,
                    ),
                  ),
                ),

                verticalSpace(5),

                Text(
                  item.desktop
                      .toString(),
                  style:
                  pBold16.copyWith(
                    color: item.color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      series: [
        ColumnSeries<
            BarChartData, String>(
          dataSource: chartData,
          width: .55,
          borderRadius:
          const BorderRadius
              .vertical(
            top:
            Radius.circular(8),
          ),
          xValueMapper:
              (data, _) => data.x,
          yValueMapper:
              (data, _) =>
          data.desktop,
          pointColorMapper:
              (data, _) =>
          data.color,
          name: 'Page View'.tr,
          dataLabelSettings:
          DataLabelSettings(
            isVisible: true,
            textStyle:
            pMedium10.copyWith(
              color:
              AppColor.cWhite,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BROWSER / DEVICE
// ============================================================

class BrowsersGraph
    extends StatefulWidget {
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
  State<BrowsersGraph>
  createState() =>
      _BrowsersGraphState();
}

class _BrowsersGraphState
    extends State<BrowsersGraph> {
  List<_ChartData> chartData =
  [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.isDevice) {
      if (Prefs.getBool(
        AppConstant.isDemoMode,
      ) ==
          true) {
        chartData = [
          _ChartData(
            'WebKit',
            350,
            Colors.pink,
          ),
          _ChartData(
            'Samsung',
            100,
            Colors.purple,
          ),
          _ChartData(
            'Nexus',
            120,
            Colors.amber,
          ),
          _ChartData(
            'iPhone',
            140,
            Colors.brown,
          ),
          _ChartData(
            'Other',
            120,
            Colors.indigo,
          ),
        ];
      } else {
        chartData =
            (widget.device ?? [])
                .map(
                  (element) {
                return _ChartData(
                  element.device ?? '',
                  element.data ?? 0,
                  HexColor(
                    element.colour ??
                        '#000000',
                  ),
                );
              },
            ).toList();
      }
    } else {
      if (Prefs.getBool(
        AppConstant.isDemoMode,
      ) ==
          true) {
        chartData = [
          _ChartData(
            'Safari',
            200,
            Colors.amber,
          ),
          _ChartData(
            'Mozilla',
            320,
            Colors.orange,
          ),
          _ChartData(
            'Firefox',
            420,
            Colors.green,
          ),
          _ChartData(
            'Edge',
            540,
            Colors.lightBlue,
          ),
          _ChartData(
            'Chrome',
            700,
            Colors.indigo,
          ),
        ];
      } else {
        chartData =
            (widget.browser ?? [])
                .map(
                  (element) {
                return _ChartData(
                  element.browser ?? '',
                  element.data ?? 0,
                  HexColor(
                    element.colour ??
                        '#000000',
                  ),
                );
              },
            ).toList();
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return GlassCard(
      title: widget.isDevice
          ? 'Devices'.tr
          : 'Browsers'.tr,
      subtitle: widget.isDevice
          ? 'Visitors by device'.tr
          : 'Visitors by browser'.tr,
      icon: widget.isDevice
          ? Icons.phone_iphone_rounded
          : Icons.public_rounded,
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
        PieSeries<
            _ChartData, String>(
          dataSource: chartData,
          xValueMapper:
              (data, _) => data.x,
          yValueMapper:
              (data, _) => data.y,
          pointColorMapper:
              (data, _) => data.color,
          explode: true,
          explodeIndex: 0,
          explodeOffset: '8%',
          radius: '90%',
          dataLabelSettings:
          DataLabelSettings(
            isVisible: true,
            labelPosition:
            ChartDataLabelPosition
                .outside,
            textStyle:
            pMedium10.copyWith(
              color: Glass
                  .textSecondary(
                context,
              ),
            ),
            connectorLineSettings:
            const ConnectorLineSettings(
              length: '12%',
              type: ConnectorType
                  .curve,
            ),
            builder: (
                data,
                point,
                series,
                pointIndex,
                seriesIndex,
                ) {
              return Text(
                chartData[pointIndex]
                    .y
                    .toString(),
                style:
                pSemiBold8.copyWith(
                  color:
                  chartData[
                  pointIndex]
                      .color,
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
        RadialBarSeries<
            _ChartData, String>(
          dataSource: chartData,
          maximumValue: 1000,
          radius: '90%',
          innerRadius: '30%',
          gap: '5%',
          strokeWidth: 0,
          trackColor:
          Glass.isDark(context)
              ? Colors.white
              .withOpacity(.06)
              : const Color(
            0xFFE9EEF4,
          ),
          cornerStyle:
          CornerStyle.bothCurve,
          xValueMapper:
              (data, _) => data.x,
          yValueMapper:
              (data, _) => data.y,
          pointColorMapper:
              (data, _) => data.color,
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: chartData.map(
            (data) {
          return Container(
            margin:
            const EdgeInsets.only(
              bottom: 8,
            ),
            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration:
            BoxDecoration(
              color: data.color
                  .withOpacity(.13),
              borderRadius:
              BorderRadius.circular(
                11,
              ),
              border: Border.all(
                color: data.color
                    .withOpacity(.28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                  BoxDecoration(
                    color: data.color,
                    shape:
                    BoxShape.circle,
                  ),
                ),

                horizontalSpace(9),

                Expanded(
                  child: Text(
                    data.x,
                    style:
                    pMedium10
                        .copyWith(
                      color:
                      data.color,
                    ),
                  ),
                ),

                Text(
                  data.y.toString(),
                  style:
                  pBold12.copyWith(
                    color:
                    data.color,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }
}

// ============================================================
// MODELS
// ============================================================

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
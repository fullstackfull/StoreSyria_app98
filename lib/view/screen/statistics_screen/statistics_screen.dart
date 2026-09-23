// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:store_go_app/core/controller/home_controller/statistic_controller.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

class StatisticsScreen extends StatefulWidget {
  StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  StatisticsController statisticsController =
  Get.put(StatisticsController());

  late final AnimationController _animController;

  bool _animStarted = false;

  /// Show / Hide Top URLs
  bool _showTopUrls = true;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1100,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void getData() {
    statisticsController.getStaticData();
  }

  void _maybeStartAnimation() {
    if (!_animStarted) {
      _animStarted = true;
      _animController.forward(from: 0);
    }
  }

  Widget _fadeSlide(
      int index,
      Widget child,
      ) {
    final start =
    (index * 0.12).clamp(0.0, 0.7);

    final end =
    (start + 0.45).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              0,
              (1 - animation.value) * 28,
            ),
            child: Transform.scale(
              scale:
              0.95 + (0.05 * animation.value),
              child: child,
            ),
          ),
        );
      },
    );
  }

  String _periodLabel(
      List<VisitorChartData>? chart,
      ) {
    if (chart == null || chart.isEmpty) {
      return "Last 7 days".tr;
    }

    final start =
    chart.length > 7
        ? chart.length - 7
        : 0;

    final window = chart.sublist(start);

    final first = window.first.date;
    final last = window.last.date;

    if (first == null || last == null) {
      return "Last 7 days".tr;
    }

    return '$first   →   $last';
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark
            ? StatisticsTheme.darkBackground
            : StatisticsTheme.lightBackground,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            const Positioned.fill(
              child: GlassBackdrop(),
            ),

            SafeArea(
              child: Column(
                children: [
                  _glassAppBar(),

                  Expanded(
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        6,
                        20,
                        20,
                      ),
                      child: Obx(() {
                        final isLoading =
                            statisticsController
                                .isDataAvailable
                                .value ==
                                true ||
                                statisticsController
                                    .staticsDataModel ==
                                    null;

                        if (!isLoading) {
                          WidgetsBinding.instance
                              .addPostFrameCallback(
                                (_) =>
                                _maybeStartAnimation(),
                          );
                        }

                        return AnimatedSwitcher(
                          duration:
                          const Duration(
                            milliseconds: 400,
                          ),
                          child: isLoading
                              ? Center(
                            key: const ValueKey(
                              'loading',
                            ),
                            child:
                            CircularProgressIndicator(
                              color: AppColor
                                  .themeGreenColor,
                              strokeWidth: 2.4,
                            ),
                          )
                              : _buildContent(
                            context,
                          ),
                        );
                      }),
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

  Widget _glassAppBar() {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final textColor = isDark
        ? StatisticsTheme.darkText
        : StatisticsTheme.lightText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        4,
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius:
            BorderRadius.circular(14),
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                Glass.surfaceStrong(context),
                borderRadius:
                BorderRadius.circular(14),
                border: Border.all(
                  color: Glass.border(context),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: textColor,
                size: 20,
              ),
            ),
          ),

          horizontalSpace(14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "analytics".tr,
                  style: pBold18.copyWith(
                    color: textColor,
                    letterSpacing: .2,
                  ),
                ),
                Text(
                  "store performance at a glance".tr,
                  style: pRegular10.copyWith(
                    color:
                    Glass.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      ) {
    final data =
    statisticsController
        .staticsDataModel!
        .data!;

    final visitorChart =
        data.visitorchart ?? [];

    final topUrlList =
        statisticsController.topUrlList;

    final platformList =
        data.platform ?? [];

    final browserList =
        data.browser ?? [];

    final deviceList =
        data.device ?? [];

    final totalPageViews =
    visitorChart.fold<int>(
      0,
          (sum, e) =>
      sum + (e.pageview ?? 0),
    );

    final totalUniqueViews =
    visitorChart.fold<int>(
      0,
          (sum, e) =>
      sum +
          (e.uniquePageview ?? 0),
    );

    int sectionIndex = 0;

    return SingleChildScrollView(
      key: const ValueKey('content'),
      physics:
      const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _fadeSlide(
            sectionIndex++,
            StatisticsHeroCard(
              periodLabel:
              _periodLabel(visitorChart),
              totalPageViews:
              totalPageViews,
              totalUniqueViews:
              totalUniqueViews,
              topLinksCount:
              topUrlList.length,
            ),
          ),

          verticalSpace(18),

          _fadeSlide(
            sectionIndex++,
            GlassVisitorChart(
              visitorChart: visitorChart,
            ),
          ),

          // =========================
          // TOP URL
          // =========================
          if (topUrlList.isNotEmpty) ...[
            verticalSpace(18),

            _fadeSlide(
              sectionIndex++,

              GlassCard(
                title: "Top URL".tr,
                subtitle:
                "Most visited links".tr,
                icon:
                Icons.emoji_events_rounded,

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [
                        _topUrlToggleButton(),
                      ],
                    ),

                    AnimatedCrossFade(
                      duration:
                      const Duration(
                        milliseconds: 250,
                      ),
                      firstCurve:
                      Curves.easeOut,
                      secondCurve:
                      Curves.easeIn,
                      crossFadeState:
                      _showTopUrls
                          ? CrossFadeState
                          .showFirst
                          : CrossFadeState
                          .showSecond,

                      firstChild:
                      Padding(
                        padding:
                        const EdgeInsets
                            .only(
                          top: 14,
                        ),
                        child: Column(
                          children:
                          topUrlList
                              .asMap()
                              .entries
                              .map(
                                (entry) {
                              final int
                              index =
                                  entry.key;

                              final TopUrl
                              topUrl =
                                  entry.value;

                              return topUrlWidget(
                                context:
                                context,
                                title:
                                "My Store"
                                    .tr,
                                subTitle:
                                topUrl.url ??
                                    '',
                                total:
                                topUrl
                                    .totalClick
                                    .toString(),
                                digit:
                                (index + 1)
                                    .toString(),
                                shareFun: () {
                                  onShare(
                                    link:
                                    '${topUrl.url}',
                                  );
                                },
                              );
                            },
                          )
                              .toList(),
                        ),
                      ),

                      secondChild:
                      const SizedBox
                          .shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // =========================
          // PLATFORM
          // =========================
          if (platformList.isNotEmpty) ...[
            verticalSpace(18),

            _fadeSlide(
              sectionIndex++,
              PlatformBarChart(
                list: platformList,
              ),
            ),
          ],

          // =========================
          // BROWSER
          // =========================
          if (browserList.isNotEmpty) ...[
            verticalSpace(18),

            _fadeSlide(
              sectionIndex++,
              BrowsersGraph(
                isDevice: false,
                browser: browserList,
              ),
            ),
          ],

          // =========================
          // DEVICE
          // =========================
          if (deviceList.isNotEmpty) ...[
            verticalSpace(18),

            _fadeSlide(
              sectionIndex++,
              BrowsersGraph(
                isDevice: true,
                device: deviceList,
              ),
            ),
          ],

          verticalSpace(10),
        ],
      ),
    );
  }

  Widget _topUrlToggleButton() {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return InkWell(
      borderRadius:
      BorderRadius.circular(11),
      onTap: () {
        setState(() {
          _showTopUrls =
          !_showTopUrls;
        });
      },
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 220),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: _showTopUrls
              ? AppColor
              .themeGreenColor
              .withOpacity(.12)
              : Glass.surfaceStrong(context),
          borderRadius:
          BorderRadius.circular(11),
          border: Border.all(
            color: _showTopUrls
                ? AppColor
                .themeGreenColor
                .withOpacity(.28)
                : Glass.border(context),
          ),
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              _showTopUrls
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 15,
              color: _showTopUrls
                  ? AppColor.themeGreenColor
                  : Glass.textMuted(context),
            ),

            horizontalSpace(6),

            Text(
              _showTopUrls
                  ? "Hide".tr
                  : "Show".tr,
              style: pMedium10.copyWith(
                color: _showTopUrls
                    ? AppColor
                    .themeGreenColor
                    : Glass.textSecondary(
                  context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
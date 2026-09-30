import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/statistic_controller.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/view/new_widgets/shimmer.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen_widget.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late final StatisticsController statisticsController;

  late final AnimationController _sectionController;
  late final AnimationController _chartController;
  late final AnimationController _lineOpacityController;

  bool _animationsStarted = false;

  @override
  void initState() {
    super.initState();

    statisticsController = Get.put(StatisticsController());

    _sectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _lineOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1, // مبين بالكامل من البداية
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      statisticsController.getStaticData();
    });
  }

  @override
  void dispose() {
    _sectionController.dispose();
    _chartController.dispose();
    _lineOpacityController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!mounted || _animationsStarted) return;
    _animationsStarted = true;

    // Plays once, when the data is on screen (not on a loop).
    _sectionController.forward(from: 0);
    _chartController.forward(from: 0);
  }

  Animation<double> _sectionAnimation(int index) {
    final start = (index * 0.10).clamp(0.0, 0.60);
    final end = (start + 0.35).clamp(0.0, 1.0);

    return CurvedAnimation(
      parent: _sectionController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Widget _fadeSlide(int index, Widget child) {
    final animation = _sectionAnimation(index);

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final value = animation.value.clamp(0.0, 1.0);

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: Transform.scale(
              scale: 0.97 + (0.03 * value),
              child: child,
            ),
          ),
        );
      },
    );
  }

  String _periodLabel(List<VisitorChartData>? chart) {
    if (chart == null || chart.isEmpty) {
      return "Last 7 days".tr;
    }

    final start = chart.length > 7 ? chart.length - 7 : 0;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: simpleAppBar(
          title: "analytics".tr,
          label: null,
          isBold: true,
          isBack: true,
          onNewLabelTap: () {},
        ),
        backgroundColor: Glass.background(context),
        body: Stack(
          children: [
            const Positioned.fill(child: GlassBackdrop()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Obx(() {
                  final isLoading = statisticsController.isDataAvailable.value ||
                      statisticsController.staticsDataModel == null;

                  if (isLoading) {
                    return const ShimmerDashboard(padding: EdgeInsets.zero);
                  }
                  return _buildContent(context);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final model = statisticsController.staticsDataModel;
    final data = model?.data;

    if (data == null) {
      return const SizedBox.shrink();
    }

    // Start the entrance + chart animation once the data is actually shown.
    if (!_animationsStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
    }

    final visitorChart = data.visitorchart ?? [];
    final topUrlList = statisticsController.topUrlList;
    final platformList = data.platform ?? [];
    final browserList = data.browser ?? [];
    final deviceList = data.device ?? [];

    final totalPageViews = visitorChart.fold<int>(
      0,
          (sum, item) => sum + (item.pageview ?? 0),
    );

    final totalUniqueViews = visitorChart.fold<int>(
      0,
          (sum, item) => sum + (item.uniquePageview ?? 0),
    );

    int sectionIndex = 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fadeSlide(
            sectionIndex++,
            StatisticsHeroCard(
              periodLabel: _periodLabel(visitorChart),
              totalPageViews: totalPageViews,
              totalUniqueViews: totalUniqueViews,
              topLinksCount: topUrlList.length,
            ),
          ),
          verticalSpace(18),
          _fadeSlide(
            sectionIndex++,
            GlassVisitorChart(
              visitorChart: visitorChart,
              animation: _chartController,
              lineOpacity: _lineOpacityController,
            ),
          ),
          if (topUrlList.isNotEmpty) ...[
            verticalSpace(18),
            _fadeSlide(
              sectionIndex++,
              GlassCard(
                title: "Top URL".tr,
                subtitle: "Most visited links".tr,
                icon: Icons.emoji_events_rounded,
                child: TopUrlChart(list: topUrlList),
              ),
            ),
          ],
          if (platformList.isNotEmpty) ...[
            verticalSpace(18),
            _fadeSlide(sectionIndex++, PlatformBarChart(list: platformList)),
          ],
          if (browserList.isNotEmpty) ...[
            verticalSpace(18),
            _fadeSlide(
              sectionIndex++,
              BrowsersGraph(isDevice: false, browser: browserList),
            ),
          ],
          if (deviceList.isNotEmpty) ...[
            verticalSpace(18),
            _fadeSlide(
              sectionIndex++,
              BrowsersGraph(isDevice: true, device: deviceList),
            ),
          ],
          verticalSpace(28),
        ],
      ),
    );
  }
}
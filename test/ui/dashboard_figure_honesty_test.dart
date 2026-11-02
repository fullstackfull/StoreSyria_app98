import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen_widget.dart';

/// P2-07-9 / WS K7 — EVERY FIGURE ITS PERIOD.
///
/// The acceptance is that the app dashboard "carries the same honesty the web one does", and the
/// web one is the reference rather than an idea: `resources/views/dashboard/overview.blade.php`
/// gives every tile a `:period` (`__('all time')`, `__('in this store')`), labels its money
/// figure "Order value" with "all time, gross", and adds a hint saying it is neither payments
/// received nor profit. The app had none of that.
///
/// THREE DISHONESTIES WERE MEASURED, and these pin the fixes:
///
///   1. No tile stated a window. "17" could be today's orders or the store's lifetime.
///   2. The middle tile said "Total Sales" over `Order::where('delivered_status', 1)->count()` —
///      a COUNT of delivered orders with no money in it. A merchant reads that as revenue.
///   3. The visitor chart's subtitle said "Page views over the selected period". There is no
///      selector in this app; the endpoint hardcodes its window, and the chart then plots only
///      the last 7 of the 15 days it is sent.
void main() {
  setUp(() {
    Get.clearTranslations();
    Get.addTranslations(<String, Map<String, String>>{'en_US': en});
    Get.locale = const Locale('en', 'US');
  });

  Widget host(Widget child) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, _) => GetMaterialApp(
          translations: _Translations(),
          locale: const Locale('en', 'US'),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );

  group('a dashboard figure states its period', () {
    testWidgets('the period is on screen beside the figure', (tester) async {
      await tester.pumpWidget(host(
        Builder(
          builder: (context) => totalProductWidget(
            context,
            image: null,
            title: 'Total',
            subTitle: 'Orders',
            total: '17',
            period: 'all time',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('17'), findsOneWidget);
      expect(find.text('all time'), findsOneWidget,
          reason: 'a bare number does not tell the merchant which window it covers');
    });

    /// A SCREEN READER MUST HEAR IT TOO, and in one utterance: read as separate nodes the figure,
    /// its name and its period arrive as three disconnected fragments.
    testWidgets('the period is part of the one merged label', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(host(
        Builder(
          builder: (context) => totalProductWidget(
            context,
            image: null,
            title: 'Total',
            subTitle: 'Orders',
            total: '17',
            period: 'all time',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Total Orders, all time'), findsOneWidget);

      handle.dispose();
    });

    /// BOTH FACTS IN ONE UTTERANCE when the figure is also withheld — the period and the refusal.
    testWidgets('a withheld figure announces its period and the refusal', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(host(
        Builder(
          builder: (context) => totalProductWidget(
            context,
            image: null,
            title: 'Total',
            subTitle: 'Orders',
            total: '0',
            period: 'all time',
            permitted: false,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp(r'Total Orders, all time, .*permission')),
        findsOneWidget,
      );
      expect(find.text('0'), findsNothing);

      handle.dispose();
    });

    testWidgets('a tile with no period is unchanged', (tester) async {
      await tester.pumpWidget(host(
        Builder(
          builder: (context) => totalProductWidget(
            context,
            image: null,
            title: 'Total',
            subTitle: 'Orders',
            total: '17',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Total Orders'), findsOneWidget);
    });
  });

  group('the visitor chart states the window it actually plots', () {
    /// THE 15-VERSUS-7 TRAP. `_loadChartData()` keeps only the last seven entries, so a subtitle
    /// built from the raw list would name a window two thirds of which is not on the chart. The
    /// subtitle must name the FIRST PLOTTED label, not the first one sent.
    testWidgets('the window is the plotted labels, not everything sent', (tester) async {
      final fifteenDays = <VisitorChartData>[
        for (var day = 1; day <= 15; day++)
          VisitorChartData(
            date: '2026-10-${day.toString().padLeft(2, '0')}',
            pageview: day,
            uniquePageview: day,
          ),
      ];

      await tester.pumpWidget(host(_chart(fifteenDays, tester)));
      await tester.pumpAndSettle();

      // Days 9..15 are the last seven; _shortDate turns them into MM/DD.
      expect(find.text('Page views, 10/09 to 10/15'), findsOneWidget,
          reason: 'the subtitle must name the window on the chart, not the one in the payload');
      expect(find.textContaining('10/01'), findsNothing,
          reason: 'day 1 is sent but never plotted, so it must not appear in the window');
    });

    testWidgets('an empty chart claims no window at all', (tester) async {
      await tester.pumpWidget(host(_chart(const <VisitorChartData>[], tester)));
      await tester.pumpAndSettle();

      expect(find.text('Page views'), findsOneWidget);
      expect(find.textContaining(' to '), findsNothing,
          reason: 'a chart with no data must not name a date range');
    });

    /// THE SENTENCE THAT WAS NOT TRUE. There is no period selector anywhere in this app.
    testWidgets('nothing claims a selected period any more', (tester) async {
      await tester.pumpWidget(host(_chart(
        <VisitorChartData>[
          VisitorChartData(date: '2026-10-01', pageview: 1, uniquePageview: 1),
        ],
        tester,
      )));
      await tester.pumpAndSettle();

      expect(find.textContaining('selected period'), findsNothing,
          reason: 'the app has no period selector, so no copy may refer to one');
    });
  });
}

Widget _chart(List<VisitorChartData> data, WidgetTester tester) {
  final controller = AnimationController(
    duration: const Duration(milliseconds: 1),
    vsync: tester,
  )..value = 1;

  addTearDown(controller.dispose);

  return GlassVisitorChart(
    visitorChart: data,
    animation: controller,
    lineOpacity: controller,
  );
}

class _Translations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => <String, Map<String, String>>{'en_US': en};
}

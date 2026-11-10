import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen_widget.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-STATS — the analytics screen, driven with real figures in all four combinations.
/// =================================================================================================
///
/// The one screen in the app that is almost entirely CHARTS: a visitor line chart, a top-URL list,
/// and three breakdown bars (platform, browser, device). It registers its own controller in
/// `initState` (`statistics_screen.dart:33`), so it needs no `register` callback.
///
/// WHAT HAD TO BE READ FIRST:
///
/// 1. **The controller gates on `data['status'] == 1`** (`statistic_controller.dart:36`) and shows
///    a toast otherwise, so a fixture that misses the gate renders `no_statistics_yet` — which
///    looks like a store with no traffic.
/// 2. **Each section is conditional on its OWN list being non-empty** (`:244, :256, ...`). A
///    fixture that fills `visitorchart` and nothing else captures a screen with one chart on it
///    and three sections silently absent. All five lists carry data here.
/// 3. **`data` is the field name for the VALUE in the breakdown rows** — `PlatformData.data`,
///    `BrowserData.data`, `DeviceData.data` (`static_model.dart:151, 173, 195`) — beside
///    `platform` / `browser` / `device` for the label and `colour` for the bar. A fixture using
///    `count` or `value` parses to null and the bars render empty.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  Map<String, Object?> statistics() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'visitorchart': <Object?>[
            <String, Object?>{'date': '2026-11-03', 'pageview': 420, 'unique_pageview': 310},
            <String, Object?>{'date': '2026-11-04', 'pageview': 515, 'unique_pageview': 388},
            <String, Object?>{'date': '2026-11-05', 'pageview': 602, 'unique_pageview': 441},
          ],
          'topurl': <Object?>[
            <String, Object?>{'url': '/sham/product/damascene-shirt', 'total_click': 182},
            <String, Object?>{'url': '/sham/category/clothing', 'total_click': 97},
          ],
          'platform': <Object?>[
            <String, Object?>{'platform': 'Android', 'data': 68, 'colour': '#3DDC84'},
            <String, Object?>{'platform': 'iOS', 'data': 24, 'colour': '#0EAED1'},
            <String, Object?>{'platform': 'Windows', 'data': 8, 'colour': '#335DA8'},
          ],
          'browser': <Object?>[
            <String, Object?>{'browser': 'Chrome', 'data': 71, 'colour': '#F4B400'},
            <String, Object?>{'browser': 'Safari', 'data': 21, 'colour': '#0EAED1'},
          ],
          'device': <Object?>[
            <String, Object?>{'device': 'Mobile', 'data': 84, 'colour': '#335DA8'},
            <String, Object?>{'device': 'Desktop', 'data': 16, 'colour': '#0EAED1'},
          ],
        },
      };

  for (final combination in kFourCombinations) {
    testWidgets('analytics renders its charts in ${combination.name}', (tester) async {
      final api = ApiStub()..on('staticsdata', statistics());

      await pumpScreen(
        tester,
        const StatisticsScreen(),
        api: api,
        combination: combination,
      );

      /// The top-URL list is the only section that renders TEXT from the response, so it is the
      /// needle: a chart that drew nothing and a chart that drew correctly look the same to a
      /// finder.
      await pumpUntil(
        tester,
        () => find.textContaining('damascene-shirt').evaluate().isNotEmpty,
        reason: 'the statistics never reached the screen, so it rendered its "no statistics yet" '
            'state and the capture would have frozen that. Recorded calls: ${api.calls}',
      );

      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'analytics threw while rendering in ${combination.name}');
      expect(api.sawRequestFor('staticsdata'), isTrue,
          reason: 'the statistics endpoint was never called. Recorded: ${api.calls}');

      /// ALL THREE BREAKDOWNS, NOT JUST THE FIRST. Each section is conditional on its own list
      /// being non-empty (`statistics_screen.dart:256, :261, :267`), so a fixture or a parse that
      /// filled only one would still pass the needle above and capture a screen with three
      /// sections silently missing.
      ///
      /// Asserted on the section WIDGETS, not on their labels. The first version looked for
      /// 'Android', 'Chrome' and 'Mobile' as text and found none: the breakdown names are painted
      /// by the chart library's own title builders, not mounted as `Text`. `PlatformBarChart`
      /// carries the platform breakdown and `BrowsersGraph` carries both the browser and the
      /// device one (`isDevice: false` / `true`), so two of these and one of those is the whole
      /// set.
      expect(find.byType(PlatformBarChart), findsOneWidget,
          reason: 'the platform breakdown is absent from this capture');
      expect(find.byType(BrowsersGraph), findsNWidgets(2),
          reason: 'the browser and device breakdowns are both drawn by BrowsersGraph, so two are '
              'expected and ${find.byType(BrowsersGraph).evaluate().length} rendered');
      expect(find.byType(TopUrlChart), findsOneWidget,
          reason: 'the top-URL section is absent from this capture');

      final context = tester.element(find.byType(StatisticsScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'analytics rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'analytics rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName('flutter-statistics', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the analytics capture is suspiciously small: a blank render');
      }

      /* ---- P2.5-FLUTTER-COMP: A SECOND CAPTURE, BELOW THE FOLD -------------------------------
         THE THREE `findsOneWidget` ASSERTIONS ABOVE ARE NOT EVIDENCE THAT ANYBODY HAS SEEN THESE
         CHARTS. They prove `PlatformBarChart` and the two `BrowsersGraph`s are MOUNTED; the
         capture is 360x800 and all three sit below it, so the image stops just under the
         visitors chart. The `Statistics widgets` inventory row stayed PENDING for exactly that
         reason while the `Analytics / statistics` SCREEN row was claimed on this file.

         `PlatformBarChart` is also the one widget in `lib/` holding a `VisibilityDetector`
         (`statistics_screen_widget.dart:1077`): it starts its bar animation when it scrolls INTO
         view, so a capture taken without scrolling would have photographed bars at zero height
         even if the viewport had reached them. `initScreenHarness` pins the detector's interval
         to zero so the callback fires synchronously rather than behind a timer the binding then
         fails on.

         The scroll position is ASSERTED, not assumed: `scrollUntilVisible` returning does not
         mean the widget is inside the 360x800 surface, and a capture of the wrong offset would
         look like a perfectly good photograph of something else. */
      await tester.scrollUntilVisible(
        find.byType(PlatformBarChart),
        240,
        maxScrolls: 30,
      );

      await pumpFrames(tester, frames: 16);

      final Rect barChart = tester.getRect(find.byType(PlatformBarChart));
      final Size surface = tester.view.physicalSize / tester.view.devicePixelRatio;

      expect(barChart.top, lessThan(surface.height),
          reason: 'the platform breakdown is still below the viewport after scrolling, so the '
              'second capture would photograph the same region as the first');
      expect(barChart.bottom, greaterThan(0),
          reason: 'the platform breakdown scrolled off the top');

      final lower =
          await captureScreen(tester, captureName('flutter-statistics-charts', combination));

      if (captureDir != null) {
        expect(lower, isNotNull);
        expect(lower!.lengthSync(), greaterThan(1000),
            reason: 'the lower analytics capture is suspiciously small');
      }

      await drainToasts(tester);
    });
  }

  testWidgets('premise: a refused response renders the empty state, not charts', (tester) async {
    /// The control, and it also exercises the status gate from note 1 — `status: 0` with a
    /// message is what the server sends when the store has no analytics integration.
    final api = ApiStub()
      ..on('staticsdata', <String, Object?>{'status': 0, 'message': 'No analytics configured'});

    await pumpScreen(tester, const StatisticsScreen(), api: api);
    await pumpFrames(tester);
    await drainToasts(tester);

    expect(find.textContaining('damascene-shirt'), findsNothing,
        reason: 'a top URL appears although the response was refused, so the populated assertions '
            'prove nothing about the response');
    expect(tester.takeException(), isNull);
  });
}

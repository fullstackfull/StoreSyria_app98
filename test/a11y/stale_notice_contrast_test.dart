// F277's CLASS OF DEFECT, IN A WIDGET I SHIPPED EARLIER IN THE SAME SESSION.
//
// `StaleDataNotice` carried one amber — `#D97706` — for both themes, exactly the
// single-shade mistake F277 records for the toast palette. Measured on the
// notice's OWN surfaces:
//
//     light  #D97706 on #FBF1E6   2.8561  FAIL   (WCAG 1.4.11 asks 3:1)
//     dark   #D97706 on #2B2E39   4.2456  ok
//
// The icon conveys meaning — it is the only non-text signal that the list below
// may be out of date — so 1.4.11 applies to it, and the retry label is text at
// 13sp, so 1.4.3's 4.5:1 applies to that.
//
// Fixed from the same source as F277: the Store Syria design system's per-theme
// semantic foregrounds. `--ss-amber-900` (#5D3F04) on light, its dark-mode
// counterpart (#F0C674) on dark. Measured after: 8.6432 and 8.3955.
//
// ---------------------------------------------------------------------------
// AND THIS FILE EXISTS BECAUSE THE FIX HAD NO TEST, WHICH A MUTATION FOUND.
//
// Reverting both shades to `#D97706` left `test/ui/` entirely green. The
// stale-notice tests assert that the notice renders, carries its reason, offers
// retry and announces itself — nothing measured its colours. A fix with no
// guard is the F237 shape, and it was mine, two hours after I wrote the note
// about F237 being the cautionary case.
//
// UNLIKE THE TOAST, THIS ONE IS MEASURED ON THE RENDERED WIDGET. `StaleDataNotice`
// is a public widget with no overlay controller, so the test pumps it in both
// themes and reads the colours the framework actually resolved — not a copy of
// the palette. That is the verification the toast cannot have, and the
// difference between the two files is stated rather than glossed.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';

/// WCAG 2.1 SC 1.4.11, non-text contrast.
const double nonTextMinimum = 3.0;

/// WCAG 2.1 SC 1.4.3, contrast of text below 18.66px bold / 24px regular.
const double bodyTextMinimum = 4.5;

double _channel(int v) {
  final double s = v / 255.0;
  return s <= 0.03928
      ? s / 12.92
      : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) =>
    0.2126 * _channel((c.r * 255).round()) +
    0.7152 * _channel((c.g * 255).round()) +
    0.0722 * _channel((c.b * 255).round());

double contrast(Color a, Color b) {
  final double la = _luminance(a) + 0.05;
  final double lb = _luminance(b) + 0.05;
  return la > lb ? la / lb : lb / la;
}

/// `fg` at [alpha] over `bg`, the way Flutter composites a simple alpha fill.
Color composite(Color fg, Color bg, double alpha) => Color.fromARGB(
  255,
  (alpha * (fg.r * 255) + (1 - alpha) * (bg.r * 255)).round(),
  (alpha * (fg.g * 255) + (1 - alpha) * (bg.g * 255)).round(),
  (alpha * (fg.b * 255) + (1 - alpha) * (bg.b * 255)).round(),
);

void main() {
  setUpAll(() => Get.addTranslations({'en': en, 'ar': ar}));
  setUp(() => Get.locale = const Locale('en', 'US'));

  Widget host(Brightness brightness) => ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        /* `onRetry` MUST be supplied, and leaving it out was a real hole in the
           first version of this file: the retry TextButton is rendered only
           when a callback is given, so `find.text('retry')` matched nothing and
           the two cases about it failed for the wrong reason — a missing widget
           rather than a bad colour. */
        body: StaleDataNotice(
          message: 'No internet connection',
          onRetry: () {},
        ),
      ),
    ),
  );

  /// The notice's own surface, read from the rendered Container rather than
  /// copied — so a change to the panel colour is included in the measurement
  /// instead of invalidating it.
  Color surfaceOf(WidgetTester tester) {
    for (final Element e in find.byType(Container).evaluate()) {
      final Decoration? d = (e.widget as Container).decoration;
      if (d is BoxDecoration && d.color != null && d.border != null) {
        return d.color!;
      }
    }
    fail('the notice panel was not found, so nothing was measured');
  }

  for (final MapEntry<String, Brightness> theme in <String, Brightness>{
    'light': Brightness.light,
    'dark': Brightness.dark,
  }.entries) {
    group('the stale-data notice is legible in ${theme.key} mode', () {
      testWidgets('its icon meets 3:1 against the panel it sits on', (
        tester,
      ) async {
        await tester.pumpWidget(host(theme.value));
        await tester.pumpAndSettle();

        final Icon icon = tester.widget<Icon>(
          find.byIcon(Icons.history_rounded),
        );

        expect(
          icon.color,
          isNotNull,
          reason: 'the icon has no explicit colour, so it inherits one this '
              'test cannot predict',
        );

        final double ratio = contrast(icon.color!, surfaceOf(tester));

        expect(
          ratio,
          greaterThanOrEqualTo(nonTextMinimum),
          reason:
              'the stale-data icon measures ${ratio.toStringAsFixed(4)} '
              'against its panel in ${theme.key} mode, under WCAG 1.4.11\'s '
              '3:1. It was 2.8561 in light mode before F277 was applied here, '
              'with one amber used for both themes.',
        );
      });

      testWidgets('its retry label meets 4.5:1, because it is body text', (
        tester,
      ) async {
        await tester.pumpWidget(host(theme.value));
        await tester.pumpAndSettle();

        final Text label = tester.widget<Text>(find.text('retry'.tr));

        expect(
          label.style?.color,
          isNotNull,
          reason: 'the retry label has no explicit colour',
        );

        final double ratio = contrast(label.style!.color!, surfaceOf(tester));

        expect(
          ratio,
          greaterThanOrEqualTo(bodyTextMinimum),
          reason:
              'the retry label measures ${ratio.toStringAsFixed(4)} in '
              '${theme.key} mode, under WCAG 1.4.3\'s 4.5:1 for 13sp text',
        );
      });

      testWidgets('and its title and message meet 4.5:1 too', (tester) async {
        await tester.pumpWidget(host(theme.value));
        await tester.pumpAndSettle();

        final Color surface = surfaceOf(tester);

        for (final String needle in <String>[
          'showing_older_data'.tr,
          'No internet connection',
        ]) {
          final Text t = tester.widget<Text>(find.text(needle));

          expect(
            t.style?.color,
            isNotNull,
            reason: '"$needle" has no explicit colour',
          );

          final double ratio = contrast(t.style!.color!, surface);

          expect(
            ratio,
            greaterThanOrEqualTo(bodyTextMinimum),
            reason:
                '"$needle" measures ${ratio.toStringAsFixed(4)} in '
                '${theme.key} mode, under 4.5:1',
          );
        }
      });

      testWidgets('the icon and the label use the SAME accent, so one fix '
          'cannot half-apply', (tester) async {
        await tester.pumpWidget(host(theme.value));
        await tester.pumpAndSettle();

        final Icon icon = tester.widget<Icon>(
          find.byIcon(Icons.history_rounded),
        );
        final Text label = tester.widget<Text>(find.text('retry'.tr));

        expect(
          label.style?.color,
          icon.color,
          reason:
              'the icon and the retry label have drifted apart. They are one '
              '`accent` local precisely so a contrast fix reaches both; two '
              'literals would let one of them regress alone.',
        );
      });
    });
  }

  testWidgets('the two themes do NOT use the same shade, which is the whole '
      'reason the light figure was failing', (tester) async {
    final List<Color> accents = <Color>[];

    for (final Brightness b in <Brightness>[
      Brightness.light,
      Brightness.dark,
    ]) {
      await tester.pumpWidget(host(b));
      await tester.pumpAndSettle();
      accents.add(
        tester.widget<Icon>(find.byIcon(Icons.history_rounded)).color!,
      );
    }

    expect(
      accents[0],
      isNot(accents[1]),
      reason:
          'both themes resolved the same accent colour. A single mid-tone '
          'amber is what measured 2.8561 against the light panel — the shade '
          'has to move with the surface, as the design system does on the web.',
    );
  });
}

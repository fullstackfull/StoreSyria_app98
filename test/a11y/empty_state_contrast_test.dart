// P2.5-A-04 -- the empty state and the error state, in LIGHT mode.
//
// These two widgets are the shared answer to "there is nothing here" and "it did not load", so
// every list in the merchant app routes through them. Measured against the light background they
// are painted on (`LightThemeColor.cBackGround`, #FFFFFF):
//
//   EmptyState  message  Colors.grey.shade400  #BDBDBD   1.88:1   WCAG 1.4.3 asks 4.5:1
//   EmptyState  icon     Colors.grey.shade400  #BDBDBD   1.88:1   WCAG 1.4.11 asks 3:1
//   ErrorState  icon     Colors.grey           #9E9E9E   2.68:1   WCAG 1.4.11 asks 3:1
//
// 1.88:1 is not "low contrast", it is barely visible: a merchant whose order list is empty is
// shown a sentence they cannot read telling them why. The dark side was already fine (8.94:1 and
// 3.54:1), which is the usual shape of this defect -- somebody checked one theme.
//
// THE REPAIR READS THE THEME instead of naming a grey, the same correction P2.5-D-02 made to the
// text fields: `LightThemeColor.cFont` (#66728C, 4.83:1) and `DarkThemeColor.cSecondaryText`
// (#A9B8D0, 8.66:1) are this app's own secondary-text colours, so the empty state now matches
// every other muted line in the app instead of being its own grey.
//
// THE ICON IS AS DARK AS THE TEXT, deliberately. An empty-state icon is usually lighter than its
// label, but it is a non-text graphic carrying the meaning of the screen, so 3:1 is a floor and no
// tint of this colour clears it while still reading as "lighter". The hierarchy comes from size
// -- 72r against 16sp -- which costs nothing in contrast.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';

double _lum(Color c) {
  double ch(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * ch((c.r * 255.0).round()) +
      0.7152 * ch((c.g * 255.0).round()) +
      0.0722 * ch((c.b * 255.0).round());
}

/// Contrast of [fg] over [bg], compositing [fg]'s alpha onto [bg] first.
double contrast(Color fg, Color bg) {
  final a = fg.a;
  final flat = Color.fromARGB(
    255,
    ((fg.r * a + bg.r * (1 - a)) * 255.0).round(),
    ((fg.g * a + bg.g * (1 - a)) * 255.0).round(),
    ((fg.b * a + bg.b * (1 - a)) * 255.0).round(),
  );
  final l1 = _lum(flat), l2 = _lum(bg);
  final hi = math.max(l1, l2), lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

String hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

Future<void> pump(WidgetTester tester, Widget child, {required bool dark}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The surface each state is actually painted on.
Color background({required bool dark}) =>
    dark ? DarkThemeColor.cBackGround : LightThemeColor.cBackGround;

void main() {
  group('EmptyState', () {
    testWidgets('its message is legible in light mode', (tester) async {
      await pump(tester, const EmptyState(message: 'No orders yet'), dark: false);

      final text = tester.widget<Text>(find.text('No orders yet'));
      final colour = text.style!.color!;
      final r = contrast(colour, background(dark: false));

      expect(r, greaterThanOrEqualTo(4.5),
          reason: 'the empty-state message is ${hex(colour)} on '
              '${hex(background(dark: false))} = ${r.toStringAsFixed(2)}:1');
    });

    testWidgets('its icon clears the non-text threshold in light mode', (tester) async {
      await pump(tester, const EmptyState(message: 'No orders yet'), dark: false);

      final icon = tester.widget<Icon>(find.byType(Icon));
      final r = contrast(icon.color!, background(dark: false));

      expect(r, greaterThanOrEqualTo(3.0),
          reason: 'the empty-state icon is ${hex(icon.color!)} = '
              '${r.toStringAsFixed(2)}:1; WCAG 1.4.11 asks 3:1 of a graphic that carries meaning');
    });

    testWidgets('dark mode stays legible too', (tester) async {
      await pump(tester, const EmptyState(message: 'No orders yet'), dark: true);

      final text = tester.widget<Text>(find.text('No orders yet'));
      expect(contrast(text.style!.color!, background(dark: true)),
          greaterThanOrEqualTo(4.5));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(contrast(icon.color!, background(dark: true)), greaterThanOrEqualTo(3.0));
    });

    // NEGATIVE CONTROL: the repair must not take away a caller's override.
    testWidgets('an explicit iconColor still wins', (tester) async {
      await pump(
        tester,
        const EmptyState(message: 'No orders yet', iconColor: Color(0xFFB3261E)),
        dark: false,
      );

      expect(tester.widget<Icon>(find.byType(Icon)).color, const Color(0xFFB3261E));
    });
  });

  group('ErrorState', () {
    testWidgets('its icon clears the non-text threshold in light mode', (tester) async {
      await pump(tester, const ErrorState(message: 'no_internet'), dark: false);

      final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
      expect(icons, isNotEmpty, reason: 'premise: the error state draws an icon');

      final r = contrast(icons.first.color!, background(dark: false));
      expect(r, greaterThanOrEqualTo(3.0),
          reason: 'the error icon is ${hex(icons.first.color!)} = '
              '${r.toStringAsFixed(2)}:1 on the light background');
    });

    testWidgets('its message is legible in both themes', (tester) async {
      for (final dark in [false, true]) {
        await pump(tester, const ErrorState(message: 'no_internet'), dark: dark);

        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        for (final t in texts) {
          final c = t.style?.color;
          if (c == null) continue;
          final r = contrast(c, background(dark: dark));
          expect(r, greaterThanOrEqualTo(4.5),
              reason: 'an error-state line is ${hex(c)} = ${r.toStringAsFixed(2)}:1 '
                  'in ${dark ? 'dark' : 'light'} mode');
        }
      }
    });
  });

  // THE PREMISE, so none of the above can be satisfied by a widget that paints nothing:
  // the colours being replaced really were below their thresholds on the surface they were on.
  test('the greys being replaced really were below threshold on white', () {
    const white = Color(0xFFFFFFFF);
    expect(contrast(const Color(0xFFBDBDBD), white), lessThan(2.0)); // grey.shade400
    expect(contrast(const Color(0xFF9E9E9E), white), lessThan(3.0)); // Colors.grey
  });
}

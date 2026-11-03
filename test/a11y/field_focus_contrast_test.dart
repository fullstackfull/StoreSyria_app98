// P2.5-D-02 -- the caret and the focus ring on every text field, in dark mode.
//
// `AppTextField` declares `static const Color navyBlue = Color(0xFF172C4E)` and uses it
// unconditionally for BOTH `cursorColor:` (:167) and `focusedBorder:` (:209). Navy on the dark
// theme's own field surface is, measured:
//
//   #172C4E on cSurface        #213252    1.09:1
//   #172C4E on cCardBackground #18263F    1.09:1
//   #172C4E on cBackGround     #0F1A2E    1.25:1
//   #172C4E on white (light mode)        13.94:1   <- correct, and must stay
//
// A caret and a focus indicator are NON-TEXT UI components, so WCAG 1.4.11 asks 3:1. At 1.09:1
// a merchant in dark mode cannot see where the cursor is or which field has focus -- and focus
// visibility is also WCAG 2.4.7, the criterion that makes a form keyboard-operable at all.
//
// THE FIX INTRODUCES NO NEW COLOUR. The dark theme already defines `DarkThemeColor.cPrimary`
// (#10AFC0, 4.82:1 on the field surface) and the light theme already defines the navy. Reading
// the THEME instead of a constant keeps both brands exactly as they are and corrects only the
// pairing. That restraint matters here: the Flutter app's brand is an open question reserved to
// the owner, and this slice must not pre-empt it.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/app_txt_field.dart';

/// WCAG 2.x relative luminance.
double _luminance(Color c) {
  double channel(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel((c.r * 255.0).round()) +
      0.7152 * channel((c.g * 255.0).round()) +
      0.0722 * channel((c.b * 255.0).round());
}

double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

Future<void> pumpField(WidgetTester tester, {required bool dark}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        home: const Scaffold(
          body: AppTextField(title: 'Store name', hint: 'Damascus Textiles'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the caret clears 3:1 on the dark field surface', (tester) async {
    await pumpField(tester, dark: true);

    final field = tester.widget<TextField>(find.byType(TextField));
    final r = contrast(field.cursorColor!, DarkThemeColor.cSurface);

    expect(r, greaterThanOrEqualTo(3.0),
        reason: 'The caret is ${field.cursorColor} on ${DarkThemeColor.cSurface} = '
            '${r.toStringAsFixed(2)}:1. WCAG 1.4.11 asks 3:1 for a non-text UI component.');
  });

  testWidgets('the focus ring clears 3:1 on the dark field surface', (tester) async {
    await pumpField(tester, dark: true);

    final field = tester.widget<TextField>(find.byType(TextField));
    final focused = field.decoration!.focusedBorder! as OutlineInputBorder;
    final r = contrast(focused.borderSide.color, DarkThemeColor.cSurface);

    expect(r, greaterThanOrEqualTo(3.0),
        reason: 'The focus ring is ${focused.borderSide.color} = '
            '${r.toStringAsFixed(2)}:1 on the dark field. Focus visibility is WCAG 2.4.7, and a '
            'ring nobody can see is the same as no ring.');
  });

  testWidgets('light mode keeps the navy it already had', (tester) async {
    await pumpField(tester, dark: false);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.cursorColor, LightThemeColor.cPrimary,
        reason: 'Light mode was already correct at 13.94:1. This slice must not restyle it, and '
            'must not pre-empt the open owner decision about the app brand.');
  });

  // THE PREMISE, so the two dark cases above cannot be satisfied by a surface that was never
  // dark: the colour being replaced really is invisible on the surface it is painted on.
  test('the replaced navy really was below 3:1 on the dark field', () {
    const navy = Color(0xFF172C4E);
    expect(contrast(navy, DarkThemeColor.cSurface), lessThan(1.5));
    expect(contrast(navy, const Color(0xFFFFFFFF)), greaterThan(4.5),
        reason: 'and really was fine on white, which is why the fix is conditional');
  });
}

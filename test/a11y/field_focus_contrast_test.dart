// P2.5-D-02 -- the caret and the focus ring on every text field, in dark mode.
//
// UPDATED 2026-11-03 FOR P2.5-BR-03, under the owner's instruction that "the earlier D-02 test
// protecting the original light-mode focus color reflected the old, undecided branding state.
// Update its expectations only where this new explicit owner decision intentionally changes the
// brand, while continuing to enforce focus visibility and accessibility. Do not weaken its safety
// assertions."
//
// So exactly one expectation moved: the light-mode focus colour is no longer the deep navy, because
// LightThemeColor.cPrimary is now the logo's own blue #335DA8. Nothing was relaxed -- the light-mode
// test used to assert only an IDENTITY ("it is still cPrimary"), which would have stayed green
// against a cPrimary of any contrast whatsoever. It now asserts the identity AND the 3:1 that WCAG
// 1.4.11 requires of a focus indicator, so the file is strictly stronger than it was.
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

  testWidgets('light mode reads the theme, and what it reads is visible', (tester) async {
    await pumpField(tester, dark: false);

    final field = tester.widget<TextField>(find.byType(TextField));

    // The ORIGINAL assertion, unchanged in substance: the widget reads the theme rather than a
    // hardcoded constant. That is what D-02 fixed and it must stay fixed.
    expect(field.cursorColor, LightThemeColor.cPrimary,
        reason: 'the field went back to a hardcoded colour instead of reading the light theme');

    // ADDED, not relaxed. The old test asserted identity alone, so it would have passed against a
    // cPrimary of any contrast at all -- including one invisible on white. Now the light focus
    // indicator must also clear the 3:1 that WCAG 1.4.11 asks of a non-text UI component.
    final r = contrast(field.cursorColor!, const Color(0xFFFFFFFF));
    expect(r, greaterThanOrEqualTo(3.0),
        reason: 'the light-mode caret is ${field.cursorColor} on white = '
            '${r.toStringAsFixed(2)}:1');

    final focused = field.decoration!.focusedBorder! as OutlineInputBorder;
    final ring = contrast(focused.borderSide.color, const Color(0xFFFFFFFF));
    expect(ring, greaterThanOrEqualTo(3.0),
        reason: 'the light-mode focus ring measures ${ring.toStringAsFixed(2)}:1 on white');
  });

  // THE PREMISE, so the two dark cases above cannot be satisfied by a surface that was never
  // dark: the colour D-02 replaced really is invisible on the surface it was painted on.
  //
  // This still names the navy literal rather than LightThemeColor.cPrimary, and that is now the
  // point rather than an oversight. D-02's defect was a HARDCODED #172C4E used in both themes.
  // BR-03 later moved the light brand off that navy, so reading the token here would quietly turn
  // this premise into a statement about whatever the brand happens to be today. The literal keeps
  // it a statement about the defect.
  test('the hardcoded navy D-02 replaced really was below 3:1 on the dark field', () {
    const navy = Color(0xFF172C4E);
    expect(contrast(navy, DarkThemeColor.cSurface), lessThan(1.5));
    expect(contrast(navy, const Color(0xFFFFFFFF)), greaterThan(4.5),
        reason: 'and really was fine on white, which is why the fix is conditional');
  });

  // AND THE BRAND CHANGE DID NOT UNDO D-02. The dark field must still not be painted with the
  // light-mode brand, whatever the light-mode brand now is.
  testWidgets('the dark field is not painted with the light brand', (tester) async {
    await pumpField(tester, dark: true);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.cursorColor, isNot(LightThemeColor.cPrimary),
        reason: 'the dark caret is using the light theme\'s brand again');
  });
}

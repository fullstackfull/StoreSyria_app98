import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/view/screen/customers/customer_bottom_sheet.dart';
import 'package:store_go_app/view/screen/home_screen/add_category_bottomsheet.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-SHEETS — an ON switch is invisible in dark mode.
/// =================================================================================================
///
/// MEASURED FROM THE PAINTED PIXELS, not from the declaration — the discipline
/// `dropdown_hint_contrast_test.dart` paid for. The capture
/// `evidence/flutter-sheets-2026-11-10/after/flutter-sheet-category-edit_*_dark.png` was sampled
/// at the switch's own rect (taken from `tester.getRect`, not guessed from the picture):
///
///     track  #172C4E   thumb #FFFFFF   surface #18263F     ON track vs surface  1.09:1
///
/// in BOTH `ar_rtl_dark` and `en_ltr_dark`. Light mode measures 13.94:1 and is fine.
///
/// **The declared value and the painted value agree here**, which is worth stating because it is
/// not guaranteed: Flutter's `CupertinoSwitch` constructor does
/// `activeTrackColor = activeTrackColor ?? activeColor` (cupertino/switch.dart:158), so the
/// `activeColor:` these sheets pass really is the colour the track is painted with. That was
/// checked in the SDK source before this test was written.
///
/// WHAT IT COSTS A MERCHANT. 1.09:1 is not "slightly low" — it is invisible. WCAG 1.4.11 asks 3:1
/// for a non-text control. Worse than the absolute figure is the RELATIVE one: the OFF track
/// (`Colors.white24` flattened to #4F5A6D) sits at 2.00:1 from the ON track, so in dark mode a
/// merchant cannot tell whether "trending" or "status" is on without toggling it and watching the
/// label change. On the customer sheet that switch is the account's active status.
///
/// THE CAUSE is the one CLAUDE.md names: a light-mode value carried into dark instead of being
/// derived. `navyBlue #172C4E` scores 13.94:1 on white and 1.09:1 on #18263F. The app already
/// ships the right token — `DarkThemeColor.cPrimary` is `StoreSyriaBrand.cyanOnDark` #2AC3E5,
/// which measures 7.23:1 on the card and 3.33:1 against the OFF track — so the fix uses the
/// design system's own dark primary rather than inventing a colour.
///
/// This test pins the RESOLVED property off the real widget tree, so it fails if anyone points
/// these switches back at a light-mode colour.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// The surface these switches are painted on in dark mode. All three sheets declare it
  /// identically: `darkCard = Color(0xFF18263F)` (customer_bottom_sheet.dart:69,
  /// delivery_boy_bottom_sheet.dart:48) and the same literal in the category sheet's
  /// `cardColor` getter.
  const Color darkCard = Color(0xFF18263F);

  /// WCAG 2.2 SC 1.4.11 Non-text Contrast.
  const double kNonTextMinimum = 3.0;

  double channel(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  double contrast(Color a, Color b) {
    final double la = luminance(a);
    final double lb = luminance(b);
    final double hi = math.max(la, lb);
    final double lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  Future<void> assertSwitchesReadable(
    WidgetTester tester,
    String label,
    Widget child, {
    void Function()? register,
    bool advanceWizard = false,
  }) async {
    final GoldenCombination dark =
        kFourCombinations.firstWhere((c) => c.dark && c.direction == TextDirection.ltr);

    await pumpScreen(
      tester,
      Material(type: MaterialType.transparency, child: Builder(builder: (_) => child)),
      api: ApiStub(),
      combination: dark,
      register: register,
    );

    await pumpFrames(tester, frames: 16);

    if (advanceWizard) {
      for (final String next in <String>['next', 'Next', 'التالي']) {
        final Finder f = find.text(next);
        if (f.evaluate().isNotEmpty) {
          await tester.tap(f.first, warnIfMissed: false);
          await tester.pumpAndSettle(const Duration(milliseconds: 600));
          break;
        }
      }
    }

    // BOTH TYPES, because the two sheets do not use the same control and the difference changes
    // which property is the track. The category sheet uses `CupertinoSwitch`, where
    // `activeTrackColor = activeTrackColor ?? activeColor`. The customer sheet uses
    // `Switch.adaptive` (customer_bottom_sheet.dart:303), which on this platform builds a
    // MATERIAL Switch -- and there `activeColor` is the THUMB, not the track. Looking only for
    // CupertinoSwitch found zero widgets on the customer sheet and would have been read as
    // "nothing to measure".
    // Collect BOTH control types, and read from each the property it actually paints.
    //
    //   CupertinoSwitch   `activeTrackColor = activeTrackColor ?? activeColor`
    //                     (cupertino/switch.dart:158) -- so `activeColor:` IS the track.
    //   Switch.adaptive   builds a MATERIAL Switch on this platform, where `activeColor` is the
    //                     THUMB, not the track.
    //
    // Either way the measured colour is the one the merchant has to see against the card, and a
    // navy thumb on a navy card is as unreadable as a navy track. What must NOT happen is
    // looking for one type, finding none, and reading that as "fine" -- which is what the first
    // version of this test did on the customer sheet.
    final List<({String kind, bool value, Color? paint})> found =
        <({String kind, bool value, Color? paint})>[];

    for (final Element e in find.byType(CupertinoSwitch).evaluate()) {
      final CupertinoSwitch w = e.widget as CupertinoSwitch;
      found.add((kind: 'CupertinoSwitch track', value: w.value, paint: w.activeTrackColor));
    }

    for (final Element e in find.byType(Switch).evaluate()) {
      final Switch w = e.widget as Switch;
      found.add((kind: 'Material Switch thumb', value: w.value, paint: w.activeColor));
    }

    expect(found, isNotEmpty,
        reason: '$label rendered no switch of either type, so this test measured nothing. '
            'A finder that matches nothing reads exactly like a passing check -- if the control '
            'moved, point this test at it rather than deleting the case.');

    var checked = 0;

    for (var i = 0; i < found.length; i++) {
      final s = found[i];

      // Only the ON state is in question; the OFF track is a separate, already-passing colour.
      if (!s.value) continue;

      final Color? active = s.paint;

      expect(active, isNotNull,
          reason: '$label switch $i (${s.kind}) sets no colour, so it falls back to the '
              'framework default and this app no longer controls it.');

      final double ratio = contrast(active!, darkCard);

      expect(ratio, greaterThanOrEqualTo(kNonTextMinimum),
          reason: '$label switch $i (${s.kind}) paints its ON state at '
              '#${(active.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()} '
              'on the dark card #18263F, which measures ${ratio.toStringAsFixed(2)}:1. '
              'WCAG 1.4.11 asks for $kNonTextMinimum:1. This is how the original defect looked: '
              'navyBlue #172C4E at 1.09:1, invisible, with only 2.00:1 between the ON and OFF '
              'states. Use DarkThemeColor.cPrimary (#2AC3E5, 7.23:1) in dark rather than a '
              'light-mode navy.');

      checked++;
    }

    expect(checked, greaterThan(0),
        reason: '$label had no switch in the ON state, so the ON track was never measured. '
            'Drive the sheet with isUpdate: true and status/trending set.');
  }

  testWidgets('the category sheet ON switches are visible in dark mode', (tester) async {
    await assertSwitchesReadable(
      tester,
      'the category sheet',
      const AddNewCategoriesWidget(
        isUpdate: true,
        categoryId: 3,
        name: 'أوشحة وشالات',
        trending: '1',
        status: '1',
      ),
      register: () {
        Get.put(CategoryController());
      },
    );
  });

  // THE CUSTOMER SHEET'S SWITCH IS ON THE CREATE PATH, STEP 2, AND NOWHERE ELSE.
  // `customer_bottom_sheet.dart:423` opens `if(!widget.isUpdate) ...[`, which holds the password
  // field and `_buildStatusSwitch()` (:451). Driven with `isUpdate: true` -- the obvious way to
  // get a switch into the ON state -- the control does not exist, and the finder returning zero
  // widgets reads exactly like "already fine".
  testWidgets('the customer sheet ON switch is visible in dark mode', (tester) async {
    await assertSwitchesReadable(
      tester,
      'the customer sheet (create, step 2)',
      const AddNewCustomerWidget(isUpdate: false),
      register: () {
        Get.put(CustomerController());
      },
      advanceWizard: true,
    );
  });
}

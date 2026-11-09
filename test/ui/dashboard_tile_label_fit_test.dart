import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-HOME-TILES — all three dashboard totals are labelled with an ellipsis.
/// =================================================================================================
///
/// Seen in the first populated captures of the dashboard
/// (`evidence/flutter-home-2026-11-09/`), in **both** languages:
///
/// | | English | Arabic |
/// |---|---|---|
/// | products | `Total Produc…` | `الإجمالي المنـ…` |
/// | sales | `Total Delive…` | `الإجمالي تم ال…` |
/// | orders | `Total Orders` | `الإجمالي الطـ…` |
///
/// Three tiles share a 360 pt row, so each gets roughly 105 pt, and the label is one line with
/// `overflow: TextOverflow.ellipsis` (`home_screen_widget.dart:483-486`). The NUMBER above it is
/// wrapped in `FittedBox(fit: BoxFit.scaleDown)` and therefore always fits; the label was given no
/// equivalent.
///
/// **This is not a screen-reader problem.** The `Semantics(label:)` above it already carries the
/// full string plus the period and the not-permitted note, and that was deliberate work
/// (`:463-475`). It is a problem for everyone who READS the screen: "الإجمالي الطـ" is not a word,
/// and on the merchant's home screen three numbers sit side by side with no legible indication of
/// which is which.
///
/// THE REPAIR is to let the label use a second line. The tile has no fixed height — it is a
/// `Container` sized by its `Column` (`home_screen_widget.dart:408`) — so wrapping costs a few
/// points of height and nothing else, and it keeps the font size, which shrinking it would not.
///
/// HOW THIS IS MEASURED. `didExceedMaxLines` on the laid-out `RenderParagraph` — the renderer's
/// own answer to "did this text run out of room", after layout, at the real design width. Reading
/// `maxLines` off the widget would only restate the source.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  Map<String, Object?> dashboard() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'user': <String, Object?>{'id': 7, 'name': 'سامر الحلبي'},
          'qr-code': <String, Object?>{'url': 'u', 'name': 'متجر الشام'},
          'products': 48,
          'sales': 37,
          'order': 126,
          'user_type': 'admin',
          'permissions': <Object?>['Manage Dashboard'],
        },
      };

  /// Every laid-out paragraph whose text starts with one of [prefixes], with the renderer's own
  /// verdict on whether it fitted.
  List<(String, bool)> labelFits(WidgetTester tester, List<String> prefixes) {
    final out = <(String, bool)>[];

    for (final element in find.byType(Text).evaluate()) {
      final text = (element.widget as Text).data;
      if (text == null) continue;
      if (!prefixes.any(text.startsWith)) continue;

      final renderObject = element.renderObject;
      if (renderObject is RenderParagraph) {
        out.add((text, !renderObject.didExceedMaxLines));
      }
    }

    return out;
  }

  for (final combination in kFourCombinations) {
    testWidgets('the Overview tile labels fit in ${combination.name}', (tester) async {
      final api = ApiStub()..on('dashboard', dashboard());

      await pumpScreen(
        tester,
        const HomeScreen(),
        api: api,
        combination: combination,
        register: () {
          Get.put(ThemeController());
          Get.put(NotificationController());
        },
      );

      await pumpUntil(
        tester,
        () => find.textContaining('سامر الحلبي').evaluate().isNotEmpty,
        reason: 'the dashboard did not load, so no tile label was measured',
      );
      await drainToasts(tester);

      /// The English labels start "Total "; the Arabic ones start "الإجمالي". Both prefixes are
      /// checked in every combination rather than branching on the direction, so a combination
      /// that silently rendered the wrong language would produce an EMPTY list and fail the
      /// premise below instead of passing vacuously.
      final measured = labelFits(tester, <String>['Total ', 'الإجمالي']);

      expect(measured, isNotEmpty,
          reason: 'premise: no Overview tile label was found at all in ${combination.name}, so '
              'this test measured nothing. Labels on screen: '
              '${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().take(20).toList()}');

      final clipped = measured.where((row) => !row.$2).map((row) => row.$1).toList();

      expect(clipped, isEmpty,
          reason: '${combination.name}: ${clipped.length} of ${measured.length} Overview tile '
              'labels ran out of room and are rendered with an ellipsis: $clipped. Three tiles '
              'share a 360 pt row, so each label has about 105 pt; the number above each one is '
              'inside a FittedBox and always fits, and the label was given no equivalent. A '
              'merchant reading "الإجمالي الطـ" cannot tell which total they are looking at.');
    });
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/model/wallet_model.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/new_widgets/transactions_widget.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-RICHTEXT — `RichText` does not inherit `DefaultTextStyle`, so three labels lost the
/// app's font.
/// =================================================================================================
///
/// **HOW THIS WAS FOUND, which matters because the symptom looked like a test artefact.** The first
/// populated capture of the wallet screen (`flutter-wallet_*`,
/// `evidence/flutter-ops-2026-11-09/`) rendered each transaction's AMOUNT — the largest number on
/// the row — as three solid coloured bars, while every other string on the same card rendered
/// normally. Solid bars are what the test environment draws for a glyph the loaded fonts do not
/// have, and the harness loads all seven Tajawal weights, so the amount was clearly being asked for
/// in some OTHER family.
///
/// THE CAUSE IS NOT THE HARNESS. `Text` wraps `RichText` and explicitly merges
/// `DefaultTextStyle.of(context).style` into its span; **`RichText` used directly does not** — it
/// is the low-level widget and takes its style only from the spans it is given. The app's
/// `ThemeData` applies the family through `base.textTheme.apply(fontFamily: 'Tajawal')`
/// (`theme_controller.dart:81`), which reaches text through `DefaultTextStyle` — exactly the
/// mechanism `RichText` skips.
///
/// So in PRODUCTION these spans do not render in boxes; they render in the PLATFORM default font —
/// Roboto on Android, San Francisco on iOS — beside Tajawal text on the same card. The test
/// environment has no platform font to fall back to, which is why it showed the fault plainly
/// instead of as a subtle mismatch a reviewer would have to notice.
///
/// THE CENSUS. `lib/` has three direct `RichText` uses:
///
/// | file | root span | verdict |
/// |---|---|---|
/// | `product_screen/add_new_product_screen.dart:645` | `pMedium12.copyWith(...)` | **fine** — the shared styles all carry `fontFamily` |
/// | `new_widgets/transactions_widget.dart:141` | none | **broken** — the wallet amount and currency code |
/// | `coupon_screen/new_coupon_bottomsheet.dart:223` | none | **broken** — every field label in the coupon form |
///
/// The fix is the one the product screen already demonstrates: give the ROOT span a style that
/// carries the family, so every child span inherits it.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);

  WalletTransaction transaction() => WalletTransaction.fromJson(<String, dynamic>{
        'id': 91,
        'type': 'topup',
        'direction': 'credit',
        'amount': '150000',
        'currency_code': 'SYP',
        'balance_before': '332500',
        'balance_after': '482500',
        'description': 'إيداع من الحوالة البنكية',
        'status': 'completed',
        'created_at': '2026-11-02 10:15:00',
      });

  /// Every leaf span's EFFECTIVE family: a child span's own style merged over its parent's, which
  /// is how `TextSpan` resolves. A leaf with no family anywhere above it resolves to null — and
  /// null is the fault, because it means "whatever font the platform picks".
  List<String?> leafFamilies(InlineSpan root) {
    final families = <String?>[];

    void walk(InlineSpan span, TextStyle? inherited) {
      final effective =
          span.style == null ? inherited : (inherited?.merge(span.style) ?? span.style);
      if (span is TextSpan) {
        final hasChildren = span.children != null && span.children!.isNotEmpty;
        if ((span.text ?? '').isNotEmpty) families.add(effective?.fontFamily);
        if (hasChildren) {
          for (final child in span.children!) {
            walk(child, effective);
          }
        }
      } else {
        families.add(effective?.fontFamily);
      }
    }

    walk(root, null);
    return families;
  }

  testWidgets('the wallet amount renders in the app font, not the platform default',
      (tester) async {
    pinGoldenSurface(tester);

    /// Hosted through `pumpScreen` rather than `goldenHost`, because `goldenHost` resolves the
    /// SAVED locale out of GetStorage and a bare `GetStorage.init()` leaves that box's backing
    /// field uninitialised — `LateInitializationError: Field '_data'`. `pumpScreen` builds its own
    /// shell with an explicit locale, which is what the screen tests already rely on.
    await pumpScreen(
      tester,
      /// Inside a `Builder`, because `transactionCard` calls ScreenUtil's `.w`/`.h` AT
      /// CONSTRUCTION (`transactions_widget.dart:34`). Built eagerly it throws
      /// `LateInitializationError: Field '_data'` — ScreenUtil is not initialised until
      /// `ScreenUtilInit` builds. `card_intrinsic_height_test.dart` passes a builder for the same
      /// reason.
      Builder(
        builder: (_) =>
            Scaffold(body: transactionCard(tx: transaction(), currency: 'SYP', isDark: false)),
      ),
      api: ApiStub(),
    );

    final amountSpans = find
        .byType(RichText)
        .evaluate()
        .map((e) => (e.widget as RichText).text)
        .where((span) => span.toPlainText().contains('150000'))
        .toList();

    expect(amountSpans, isNotEmpty,
        reason: 'premise: the amount 150000 never rendered, so nothing about its font was measured');

    for (final span in amountSpans) {
      final families = leafFamilies(span);
      expect(families, isNotEmpty, reason: 'premise: the span carries no text at all');
      expect(
        families,
        everyElement(isNotNull),
        reason: 'a span in the wallet amount resolves NO font family, so it renders in whatever '
            'font the platform supplies — Roboto beside Tajawal on the same card, and in the test '
            'environment a row of solid boxes. `RichText` does not inherit `DefaultTextStyle`; '
            'give its ROOT span a style that carries the family, as '
            '`add_new_product_screen.dart:645` already does. Resolved families: $families',
      );
    }
  });

  test('premise: the shared text styles really do carry a family, so the fix has something to use',
      () {
    /// If `pMedium12` had no `fontFamily` the repair above would be cosmetic — the root span would
    /// carry a style that still resolved nothing. This is the one fact the fix rests on.
    expect(pMedium12.fontFamily, appFontFamily,
        reason: 'the shared styles no longer carry the application family');
    expect(
      File('lib/core/controller/setting_controller/theme_controller.dart').readAsStringSync(),
      contains("fontFamily: '$appFontFamily'"),
      reason: 'the theme no longer applies $appFontFamily to its text theme, so the family the '
          'RichText roots name here would differ from the one everything else inherits',
    );
    final source = File('lib/utils/text_style.dart').readAsStringSync();
    expect(source, contains('fontFamily: _fontFamily'),
        reason: 'the shared styles stopped carrying a family, so every RichText root span that '
            'relies on one is now resolving nothing again');
  });

  test('census: no direct RichText in lib/ leaves its root span without a style', () {
    /// A GUARD, not a detector. The defect above was confirmed by rendering; this stops a fourth
    /// `RichText` from being added the same way. It reads only the three files the census found,
    /// and fails loudly if that count changes so the list is re-read rather than silently stale.
    final files = <String>[
      'lib/view/new_widgets/transactions_widget.dart',
      'lib/view/screen/coupon_screen/new_coupon_bottomsheet.dart',
      'lib/view/screen/product_screen/add_new_product_screen.dart',
    ];

    final found = <String>[];
    final root = Directory('lib');
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.readAsStringSync().contains('RichText(')) found.add(entity.path);
    }
    found.sort();

    expect(
      found.toSet(),
      files.toSet(),
      reason: 'the set of files using RichText directly has changed. Re-read each one: a root '
          '`TextSpan` with no `style` resolves no font family, because RichText does not inherit '
          'DefaultTextStyle. Then update this list.',
    );

    for (final path in files) {
      final source = File(path).readAsStringSync();
      final index = source.indexOf('RichText(');

      /// ONLY THE ROOT SPAN. The first version of this check looked at a fixed window after
      /// `RichText(`, and PASSED against the unfixed code — because the window swallowed the
      /// CHILD spans' own `style:` lines, which are exactly the styles that do not carry a
      /// family. The root span is the text between `RichText(` and the first `children:`.
      final childrenAt = source.indexOf('children:', index);
      expect(childrenAt, greaterThan(index),
          reason: '$path: could not find the root span\'s `children:`, so this check did not run');
      final rootSpan = source.substring(index, childrenAt);

      expect(
        rootSpan,
        contains('style:'),
        reason: '$path opens a RichText whose ROOT TextSpan has no `style:`, so every child span '
            'resolves the platform font instead of Tajawal. RichText does not inherit '
            'DefaultTextStyle. Root span read: $rootSpan',
      );
    }
  });
}

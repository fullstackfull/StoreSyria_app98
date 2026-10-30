// F212 — ABSOLUTE POSITIONING IN MERCHANT SURFACES MUST MIRROR IN ARABIC.
// ===========================================================================
//
// `PositionedDirectional` (and `Positioned.directional`) resolve `start`/`end`
// against `Directionality.of(context)`, so they mirror. Plain `Positioned`
// takes PHYSICAL `left`/`right` and never does.
//
// This app had both: 13 directional uses and 12 physical ones. Four of the
// physical ones were interactive controls in the MERCHANT product editor —
// `_removeImageButton` badges pinned at `top: 6, right: 6` over the cover and
// gallery images — so in an Arabic layout the image mirrored to the other side
// of the screen while its own remove button stayed on the physical right.
// Arabic is the platform's PRIMARY language and this app's default AND fallback
// locale (`prefer.dart`, `TranslationService.fallbackLocale`).
//
// IT WAS A GAP IN AN EARLIER PASS, NOT AN UNKNOWN. `3c45fbf` ("wire
// flutter_localizations, so an Arabic app finally lays out right-to-left")
// fixed the root cause — `GetMaterialApp` had neither `localizationsDelegates`
// nor `supportedLocales`, so `DefaultWidgetsLocalizations` forced
// `TextDirection.ltr` for the whole app — but converted only one `Positioned`.
// Once direction started working, every physical `Positioned` became a place
// where the direction is ignored.
//
// SCOPE: MERCHANT SURFACES ONLY, by owner instruction. The storefront and
// shared-presentation files (`category_widget`, `product_widget`,
// `common_snak_bar_widget`) are Phase 03's and are NOT asserted at zero here —
// their count is frozen instead, so a NEW physical site there is visible
// without this test claiming the existing ones are fixed. Widening a slice is
// what the standing rules forbid.
//
// A SOURCE SCAN RATHER THAN A RENDER, and the reason is stated rather than
// implied: this is the established style in this directory
// (`test/a11y/icon_button_names_test.dart` scans through
// `support/source_tree.dart`), it runs under `flutter test` in CI, and the
// property it checks — which widget class is written — is a source property.
// What it CANNOT check is semantic reading order; see the note on the last
// case.

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

/// The merchant surfaces this slice owns. An explicit list rather than a path
/// heuristic, so a reader can audit the scope instead of inferring it, and so
/// a new merchant screen is a deliberate addition rather than a silent one.
const _merchantFiles = <String>[
  'lib/view/screen/product_screen/add_new_product_screen.dart',
  'lib/view/screen/wallet/wallet_screen.dart',
];

/// Phase 03's, frozen rather than fixed. Raise this only by DELETING an entry.
const _storefrontPhysicalBudget = 7;

/// A `Positioned(` that is not `PositionedDirectional(` — the physical form.
///
/// The negative lookbehind is what separates them: `PositionedDirectional(`
/// contains `Positioned` as a prefix, so a naive match counts every directional
/// use as a physical one and the rule inverts.
final _positionedOpen = RegExp(r'(?<![A-Za-z])Positioned\(');

/// Lines after the opening in which a physical edge may appear. The shapes in
/// this codebase put `top:`/`right:` on the two lines after the constructor;
/// six is generous without reaching a sibling widget's arguments.
const _window = 6;

List<String> _physicalSites(String path, String source) {
  final sites = <String>[];
  final lines = codeOnly(source).split('\n');

  for (var i = 0; i < lines.length; i++) {
    if (!_positionedOpen.hasMatch(lines[i])) continue;

    final end = (i + _window < lines.length) ? i + _window : lines.length;
    final block = lines.sublist(i, end).join('\n');

    if (RegExp(r'\b(left|right):').hasMatch(block)) {
      sites.add('$path:${i + 1}');
    }
  }

  return sites;
}

void main() {
  test('no merchant surface positions anything by a physical left/right edge', () {
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      final path = relative(file);
      if (!_merchantFiles.contains(path)) continue;

      offenders.addAll(_physicalSites(path, file.readAsStringSync()));
    }

    expect(
      offenders,
      isEmpty,
      reason: 'These merchant-surface elements are pinned to a PHYSICAL edge, so '
          'they do not mirror in Arabic — the platform\'s primary language and '
          'this app\'s default and fallback locale. Use '
          '`PositionedDirectional(start:/end:)`, which resolves against '
          '`Directionality.of(context)`:\n  ${offenders.join('\n  ')}',
    );
  });

  test('PREMISE: the scan sees the merchant files at all', () {
    // Without this, the rule above passes vacuously the day a file is renamed
    // or moved — the single most likely way for a path-list scan to stop
    // measuring anything while still reporting success.
    final seen = libDartFiles().map(relative).where(_merchantFiles.contains).toList();

    expect(
      seen.length,
      _merchantFiles.length,
      reason: 'The scan did not find every file in `_merchantFiles`, so the rule '
          'above is asserting less than it appears to. Found: $seen',
    );
  });

  test('PREMISE: the directional form really is in use, so the rule is not trivial', () {
    var directional = 0;

    for (final file in libDartFiles()) {
      if (!_merchantFiles.contains(relative(file))) continue;
      directional += RegExp('PositionedDirectional\\(')
          .allMatches(codeOnly(file.readAsStringSync()))
          .length;
    }

    // Five at the time of writing: four remove-image badges in the product
    // editor and the filter-active dot in the wallet screen.
    expect(
      directional,
      greaterThanOrEqualTo(5),
      reason: 'The merchant files carry fewer directional positions than the '
          'five this slice converted, so either they were reverted or the '
          'absolute positioning was removed. Either way the rule above may now '
          'be passing because there is nothing left to position.',
    );
  });

  test('the storefront physical count is frozen, not fixed — Phase 03 owns it', () {
    final sites = <String>[];

    for (final file in libDartFiles()) {
      final path = relative(file);
      if (_merchantFiles.contains(path)) continue;

      sites.addAll(_physicalSites(path, file.readAsStringSync()));
    }

    // DELIBERATELY NOT `isEmpty`. Seven physical sites remain in
    // `category_widget` (3), `product_widget` (3) and `common_snak_bar_widget`
    // (1). They are storefront and shared presentation, which the owner
    // assigned to Phase 03, and converting them is a separate decision —
    // mirroring is the platform convention for a badge over its own image, but
    // for a snackbar's placement it is a design question, not a mechanical
    // swap. Freezing the count keeps a NEW one visible without pretending
    // these are handled.
    expect(
      sites.length,
      lessThanOrEqualTo(_storefrontPhysicalBudget),
      reason: 'A new physical `Positioned` has appeared outside the merchant '
          'surfaces. If it is a merchant screen, add it to `_merchantFiles` and '
          'convert it; if it is storefront, it belongs to the Phase 03 slice and '
          'the budget must not rise to accommodate it:\n  ${sites.join('\n  ')}',
    );
  });

  test('WHAT THIS FILE CANNOT ASSERT: semantic reading order', () {
    // `grep -rn 'OrdinalSortKey\|SemanticsSortKey\|sortKey' lib/` returns ZERO,
    // so semantic traversal order everywhere in this app is Flutter's default —
    // the widget tree. That is usually correct, and it is UNVERIFIED.
    //
    // Where tree order and visual order come apart is exactly a `Stack` with
    // absolutely-positioned children, which is what this file is about. For the
    // remove-image badges the tree order is image-then-badge, which is also the
    // sensible reading order (the thing, then the action on it) — so the
    // default is probably right here. "Probably" is the honest word: proving it
    // needs a RENDERED semantics tree, i.e. a `testWidgets` case walking
    // `tester.semantics`, and that needs the screen's GetX controllers and
    // bindings fixtured.
    //
    // Specified rather than written, so it needs no re-derivation: pump
    // `AddNewProductScreen` inside a `Directionality(textDirection: rtl)` with
    // its controller bound, then assert the semantics traversal reaches the
    // image before its remove button, in BOTH directions.
    //
    // This case asserts only that the premise of that gap still holds, so the
    // day someone adds a sort key, this stops being the whole story.
    var sortKeys = 0;

    for (final file in libDartFiles()) {
      sortKeys += RegExp(r'(OrdinalSortKey|SemanticsSortKey|sortKey)')
          .allMatches(codeOnly(file.readAsStringSync()))
          .length;
    }

    expect(
      sortKeys,
      0,
      reason: 'A semantic sort key now exists somewhere in lib/. That is not a '
          'defect — it may well be the fix — but it means reading order is no '
          'longer uniformly Flutter\'s default, so F212\'s reading-order half '
          'must be re-measured rather than inherited from this comment.',
    );
  });
}

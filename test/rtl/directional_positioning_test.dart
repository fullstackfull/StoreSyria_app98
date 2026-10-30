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
// SCOPE: MERCHANT SURFACES ONLY, by owner instruction — AND THAT IS THE WHOLE
// APP. An earlier version of this file split the app into "merchant" and
// "storefront" halves and froze seven physical sites in `category_widget`,
// `product_widget` and `common_snak_bar_widget` as Phase 03's. **THAT SPLIT WAS
// WRONG, and an independent audit of this repository found it.** Measured:
// `lib/routes/routes.dart` declares ONLY merchant screens — dashboard, orders,
// products, categories, customers, delivery boys, wallet, coupons, tax,
// shipping, statistics, plans, settings — and `lib/view/screen/` contains no
// cart, no checkout and no shopper screen at all. THIS REPOSITORY IS THE ADMIN
// APP. There is no storefront here to defer.
//
// So the three "storefront" files were merchant surfaces all along:
// `category_widget` is rendered only by `category_screen.dart`,
// `product_widget`'s `allProductsListItemWidget` only by `products_screen.dart`,
// and `common_snak_bar_widget` is the toast used by around forty merchant
// controllers. Two of the seven were interactive edit/delete popup menus pinned
// to `right:` — the same class of defect this slice calls the one that matters.
// Their own comments said `(top-left)` and `(top-right)` while naming positions
// the author clearly meant as start and end.
//
// All seven are converted, the budget is deleted, and the rule below now asserts
// ZERO across the whole of `lib/`. Freezing a count is the right tool for work
// that genuinely belongs to a later phase; it is the wrong tool for work
// mis-filed out of this one.
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

/// The files that carried a physical `Positioned` when this slice began, kept as
/// a PREMISE rather than as a scope: the rule below covers all of `lib/`, and
/// this list only proves the scan still reaches the places the defect was.
const _knownConvertedFiles = <String>[
  'lib/view/screen/product_screen/add_new_product_screen.dart',
  'lib/view/screen/wallet/wallet_screen.dart',
  'lib/view/new_widgets/category_widget.dart',
  'lib/view/screen/product_screen/product_widget.dart',
  'lib/view/widget/common_snak_bar_widget.dart',
];

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
  test('nothing anywhere in lib/ positions by a physical left/right edge', () {
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      offenders.addAll(_physicalSites(relative(file), file.readAsStringSync()));
    }

    expect(
      offenders,
      isEmpty,
      reason: 'These elements are pinned to a PHYSICAL edge, so they do not '
          'mirror in Arabic — the platform\'s primary language and this app\'s '
          'default and fallback locale. Use '
          '`PositionedDirectional(start:/end:)`, which resolves against '
          '`Directionality.of(context)`. Every screen in this repository is a '
          'merchant screen, so there is no later-phase bucket to defer one '
          'into:\n  ${offenders.join('\n  ')}',
    );
  });

  test('PREMISE: the scan sees the converted files at all', () {
    // Without this, the rule above passes vacuously the day a file is renamed
    // or moved — the single most likely way for a path-list scan to stop
    // measuring anything while still reporting success.
    final seen =
        libDartFiles().map(relative).where(_knownConvertedFiles.contains).toList();

    expect(
      seen.length,
      _knownConvertedFiles.length,
      reason: 'The scan did not find every file in `_knownConvertedFiles`, so the '
          'rule above is asserting less than it appears to. Found: $seen',
    );
  });

  test('PREMISE: the directional form really is in use, so the rule is not trivial', () {
    var directional = 0;

    for (final file in libDartFiles()) {
      directional += RegExp('PositionedDirectional\\(')
          .allMatches(codeOnly(file.readAsStringSync()))
          .length;
    }

    // Twelve converted by this slice in total — five in the first pass (four
    // remove-image badges in the product editor, the wallet filter dot) and
    // seven in the correction (category_widget 3, product_widget 3, the
    // snackbar 1) — on top of the thirteen that were already directional.
    expect(
      directional,
      greaterThanOrEqualTo(12),
      reason: 'lib/ carries fewer directional positions than the twelve this '
          'slice converted, so either they were reverted or the absolute '
          'positioning was removed. Either way the rule above may now be '
          'passing because there is nothing left to position.',
    );
  });

  test('no text is aligned to a physical left/right edge', () {
    // THE RATCHET'S OTHER BLIND SPOT, also found by the audit: it scanned only
    // `Positioned`, so direction-blind TEXT ALIGNMENT went unmeasured and ten
    // sites were live — customer and delivery-boy names at `TextAlign.left`,
    // order prices and totals at `TextAlign.right`, the tax screen, the
    // customer detail rows. `start`/`end` resolve against the ambient
    // direction; `left`/`right` do not.
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      final path = relative(file);
      final lines = codeOnly(file.readAsStringSync()).split('\n');

      for (var i = 0; i < lines.length; i++) {
        // `pw.TextAlign` is the PDF package's own enum in `invoice.dart`, and
        // every use there is already direction-aware
        // (`isArabic ? pw.TextAlign.right : pw.TextAlign.left`). Excluded by
        // the lookbehind rather than by skipping the file, so a NEW bare
        // `TextAlign.right` in `invoice.dart` is still caught.
        if (RegExp(r'(?<!pw\.)TextAlign\.(left|right)').hasMatch(lines[i])) {
          offenders.add('$path:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Use `TextAlign.start` / `TextAlign.end`, which resolve against '
          'the ambient direction. `left` and `right` are physical and read '
          'wrongly in Arabic:\n  ${offenders.join('\n  ')}',
    );
  });

  test('no padding or margin is applied to a physical left/right edge', () {
    // The third form of the same defect. Three sites were live, two of them two
    // lines from `Positioned` sites this slice had already converted: the
    // gallery thumbnails' trailing gap in the product editor, and
    // `common_button`'s trailing padding on a `mainAxisAlignment.start` row,
    // which in Arabic put the gap on the icon's side.
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      final path = relative(file);
      final lines = codeOnly(file.readAsStringSync()).split('\n');

      for (var i = 0; i < lines.length; i++) {
        if (!RegExp(r'EdgeInsets\.only\(').hasMatch(lines[i])) continue;
        if (RegExp(r'\b(left|right):').hasMatch(lines[i])) {
          offenders.add('$path:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Use `EdgeInsetsDirectional.only(start:/end:)`. `EdgeInsets.only` '
          'takes physical edges and does not mirror:\n  ${offenders.join('\n  ')}',
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

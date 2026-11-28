import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

/// SUPPORT-002 — THE ANNOUNCEMENT SCREEN MUST MIRROR, AND THE CENSUS MUST NOT
/// BE SATISFIED BY PROSE ABOUT IT.
/// ===========================================================================
///
/// Arabic is this platform's primary language and this app's DEFAULT and
/// FALLBACK locale (`TranslationService.fallbackLocale`). A physical
/// `left`/`right` never mirrors, so a padding or an alignment written that way
/// puts a label on the wrong side of an Arabic screen — and the screen still
/// renders, so nothing fails.
///
/// `directional_positioning_test.dart` already asserts ZERO physical
/// `Positioned` across `lib/`. This file covers the rest of the family for the
/// one screen this slice adds: `TextAlign`, `Alignment`, `EdgeInsets.only(left:`
/// and `EdgeInsets.fromLTRB`.
///
/// -----------------------------------------------------------------------------
/// THE COMMENT STRIP IS THE POINT OF THIS FILE'S CARE, NOT A DETAIL.
///
/// While writing the screen the padding was changed from `fromLTRB` to
/// `fromSTEB` and a comment was left EXPLAINING the change — which contains the
/// literal `fromLTRB`. A census that read the raw source would have failed
/// against correct code, and the obvious "fix" would have been to delete the
/// explanation. The mirror image is worse: a census that reads comments can be
/// SATISFIED by prose about the thing it measures. The repository's shared
/// `commentsStripped` helper is used, and a PREMISE test asserts that the strip
/// actually removed something — otherwise a helper that quietly stopped working
/// would make every assertion below a free pass, which reads exactly like a
/// clean run.
///
/// SCOPED TO THIS SLICE'S SCREEN. Widening it to all of `lib/view` is a better
/// instrument and a separate change: a ratchet whose first run reddens on
/// somebody else's drift gets suppressed rather than read.
void main() {
  const path = 'lib/view/screen/announcement_screen/announcement_screen.dart';

  late String raw;
  late String code;

  setUpAll(() {
    raw = File('${packageRoot().path}/$path').readAsStringSync();
    code = commentsStripped(raw);
  });

  test('PREMISE: the screen exists and the comment strip removed something', () {
    expect(raw, isNotEmpty);
    expect(raw.length, greaterThan(1000));
    expect(code.length, lessThan(raw.length),
        reason: 'the comment strip removed nothing, so every assertion below '
            'is reading prose as if it were code');
    // And the strip really removed THE comment that would break this census.
    expect(raw, contains('fromLTRB'),
        reason: 'this premise is pinned to a real comment in the screen that '
            'names the physical form while explaining it is not used; if that '
            'comment is rewritten, re-point this premise rather than deleting '
            'it');
    expect(code, isNot(contains('fromLTRB')));
  });

  test('it pins no physical direction', () {
    const forbidden = <String>[
      'TextAlign.left',
      'TextAlign.right',
      'Alignment.centerLeft',
      'Alignment.centerRight',
      'Alignment.topLeft',
      'Alignment.topRight',
      'EdgeInsets.only(left',
      'EdgeInsets.only(right',
      'EdgeInsets.fromLTRB',
      'Positioned(',
      'textDirection:',
    ];

    final found = forbidden.where(code.contains).toList();

    expect(found, isEmpty,
        reason: 'these never mirror, so an Arabic merchant reads this screen '
            'laid out for English: $found');
  });

  test('it uses the directional forms it should', () {
    expect(code, contains('EdgeInsetsDirectional'),
        reason: 'the screen has padding, and the directional form is what '
            'resolves start/end against the ambient direction');
    expect(code, contains('CrossAxisAlignment.start'));
  });

  /// THE SEVERITY AND STATE BADGES CARRY WORDS, NOT ONLY HUES (WCAG 1.4.1).
  ///
  /// This is asserted on the SOURCE rather than by pumping, because the
  /// property is "a translated label is passed to the chip", and a pumped test
  /// that looked for text would pass on a chip whose label happened to be the
  /// severity string itself.
  test('every badge is built from a translated label', () {
    for (final key in ['urgent', 'notice', 'happening_now', 'ended']) {
      expect(code, contains("'$key'.tr"),
          reason: 'the `$key` badge has no translated label, so the only '
              'carrier of its meaning is a colour');
    }
  });
}

// P2.5-WAVE-5 -- no emoji in the interface. The directive says so outright:
// "Do not use emojis as replacement interface icons."
//
// MEASURED: 38 emoji characters appear in `lib/`. THIRTY-FIVE of them are inside
// `AppLog.d(...)` debug logging and two more are in `network.dart`'s request and
// response log buffer. Those are developer output, they never reach a screen, and
// treating them as defects would be a census counting the wrong thing -- the same
// error that produced an inflated "Feather 95 uses" reading on the web side.
//
// EXACTLY ONE was in the interface: `top_orders.dart` rendered
// `Text("\u{1F525} $orderId")` -- a flame inside the text content. Two problems in
// one character:
//
//   * an emoji is not an icon. It renders in the platform's own emoji font, so it
//     carries none of the stroke weight, grid or colour of the Material set beside
//     it, and it looks different on every device.
//   * being inside the STRING, a screen reader announces it. The card heading was
//     read out as "fire 12345".
//
// So this test is deliberately NARROW: it looks at `lib/view/` -- the widget tree,
// where strings become pixels -- and ignores logging, services and controllers. A
// broad "no emoji anywhere" rule would fail on 37 harmless debug lines and be
// switched off within a week.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Emoji and pictographs. Deliberately NOT the whole of the symbol planes: the
/// arrows and dingbats blocks contain characters that are legitimate text.
final _emoji = RegExp(
  r'[\u{1F300}-\u{1FAFF}\u{1F000}-\u{1F0FF}\u{2600}-\u{27BF}]',
  unicode: true,
);

/// A line that only ever reaches a console, never a surface.
bool _isDeveloperOutput(String line) =>
    RegExp(r'\b(AppLog|debugPrint|print|log|logger|writeln)\b').hasMatch(line);

void main() {
  test('no emoji reaches the widget tree', () {
    final offenders = <String>[];

    final root = Directory('lib/view');
    expect(root.existsSync(), isTrue,
        reason: 'lib/view is missing, so this test is scanning nothing and would '
            'pass however many emoji were added');

    var scanned = 0;
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      scanned++;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (_isDeveloperOutput(line)) continue;
        if (_emoji.hasMatch(line)) {
          offenders.add('${entity.path}:${i + 1}  ${line.trim()}');
        }
      }
    }

    // PREMISE. Without it, a wrong path or a changed layout makes the assertion
    // below pass by scanning zero files.
    expect(scanned, greaterThan(50),
        reason: 'only $scanned Dart files were scanned under lib/view, which is far '
            'fewer than this app has -- the scan is not reaching the widget tree');

    // Joined into a local first. Nesting a quoted string inside an interpolation
    // inside a reason string is valid Dart but unreadable, and it is exactly the
    // construct that made a brace-balance check disagree with the compiler.
    final listed = offenders.join('\n');

    expect(offenders, isEmpty,
        reason: 'emoji used as interface content:\n'
            '$listed\n\n'
            'An emoji renders in the platform emoji font, so it matches nothing in the '
            'Material set beside it, and inside a string it is announced by screen '
            'readers. Use an Icon, and ExcludeSemantics it when the text already says '
            'what it means.');
  });

  test('PREMISE: the detector really does catch an emoji', () {
    // A regex that matches nothing would satisfy the test above forever.
    expect(_emoji.hasMatch('\u{1F525} 12345'), isTrue,
        reason: 'the emoji detector no longer matches a flame, so the rule above is vacuous');
    expect(_emoji.hasMatch('Order 12345'), isFalse,
        reason: 'the emoji detector matches ordinary text, so it would flag every line');
  });

  test('developer logging is deliberately exempt, and the exemption is narrow', () {
    // Built from pieces rather than written as a quote inside a quote. The nested
    // form is valid Dart and completely unreadable, and it is what made two
    // separate balance checks disagree with the compiler about this file.
    const flame = '\u{1F525}';
    const bell = '\u{1F514}';

    expect(_isDeveloperOutput('AppLog.d($bell notification);'), isTrue);
    expect(_isDeveloperOutput('buffer.writeln($flame REQUEST);'), isTrue);

    // ...but a widget string must NOT be exempted merely for mentioning a word.
    expect(_isDeveloperOutput('Text($flame orderId),'), isFalse,
        reason: 'the logging exemption is wide enough to swallow a real widget string');
  });
}

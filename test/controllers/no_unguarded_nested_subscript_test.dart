// A ratchet against the 24 unguarded nested reads coming back.
//
// test/controllers/nested_api_read_test.dart proves the 24 FIXED sites behave.
// It cannot prove that the 25th does not get written next week, and this
// pattern was written 26 times by hand in this codebase before anyone noticed
// it, so the habit is the defect.
//
// WHAT IS FLAGGED: two adjacent constant-string subscripts in lib/, in BOTH
// forms:
//
//   `x['a']['b']`   -- cannot be safe at all: the outer index runs first and
//                      throws NoSuchMethodError on a body that omits "a".
//   `x['a']?['b']`  -- guards null and NOTHING ELSE. Laravel serialises an
//                      empty collection as `"data": []`, and a List rejects a
//                      String subscript exactly as loudly as null does; same
//                      for the `"data": "ok"` shape. 25 of these were live in
//                      nine controllers, so the half-fix was as habitual as
//                      the no-fix.
//
// WHAT IS ALLOWED, and why:
//
//   * a line carrying its own `is Map` / `is! Map` type test. Two sites do
//     this correctly by hand and predate the helper
//     (order_controller.dart:632, product_controller.dart:143); both are
//     listed explicitly below rather than pattern-matched loosely.
//
// Comments are blanked before matching (commentsStripped in
// test/support/source_tree.dart) so the explanatory prose in result.dart,
// which spells the bad pattern out in full, cannot trip this.
//
// IT MUST BE commentsStripped AND NOT codeOnly. This test shipped using
// codeOnly and was VACUOUS: codeOnly blanks STRING LITERALS, quotes included,
// so `data['data']['message']` reaches the matcher as `data[      ][         ]`
// and the pattern -- which requires a quote after `[` -- can never fire.
// Proven, not deduced: with
// `String teethProbe(dynamic data) => data['data']['message'] ?? 'x';`
// appended to lib/utils/prefer.dart, the codeOnly version of this test
// reported `00:00 +2: All tests passed!`. The same probe against the version
// below fails and names prefer.dart.
//
// The cost of keeping literals is that a Dart STRING containing the pattern
// would now match. There is no such string in lib/ (measured: switching to
// commentsStripped adds zero offenders on a clean tree), and a guard test
// that fires on a string literal is a tolerable failure mode next to one that
// never fires at all.

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  // `['` then anything that is not a quote or bracket, then `']['` or
  // `']?['`.
  final nested =
      RegExp(r"""\[\s*['"][^'"\[\]]*['"]\s*\]\s*\??\s*\[\s*['"]""");

  // The two hand-written guarded reads. Keyed by file so a MOVE still passes
  // and a new file never does.
  const guardedByHand = <String>{
    'lib/core/controller/order_controller/order_controller.dart',
    'lib/core/controller/product_controller/product_controller.dart',
  };

  test('no lib/ source reads a decoded body with ["a"]["b"] or ["a"]?["b"]', () {
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      final path = relative(file);
      final lines =
          commentsStripped(file.readAsStringSync()).split('\n');

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!nested.hasMatch(line)) continue;

        // A type test on the same line makes the read safe. Only the two
        // known files may use that form; anywhere else, use apiValueAt.
        final selfGuarded =
            line.contains('is Map') || line.contains('is! Map');

        if (selfGuarded && guardedByHand.contains(path)) continue;

        offenders.add('$path:${i + 1}:${line.trim()}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Use apiValueAt / apiText / apiMessage from '
          'lib/network/result.dart instead. `x["a"]["b"] ?? fallback` is NOT '
          'guarded: the index runs first and throws on a body that simply '
          'omits "a", which is what an error payload looks like.\n'
          '${offenders.join('\n')}',
    );
  });

  test('the guard itself matches the pattern it is supposed to catch', () {
    // Without this, a typo in the regex would make the test above vacuous and
    // green forever. Two vacuous tests have already been found in this
    // project, so the pattern is asserted directly.
    expect(nested.hasMatch("data['data']['message'] ?? 'x'"), isTrue);
    expect(nested.hasMatch("data['data']['user_info']['current_store']"), isTrue);
    expect(nested.hasMatch('data["data"]["message"]'), isTrue);
    expect(nested.hasMatch("data['data'] ['message']"), isTrue);
    expect(nested.hasMatch("data['data']?['message'] ?? 'Error'"), isTrue);
    expect(nested.hasMatch("decodedData['data']?['message']"), isTrue);

    // And does not fire on the safe forms the fix uses.
    expect(nested.hasMatch("apiText(data, ['data', 'message'])"), isFalse);
    expect(nested.hasMatch("data['data']"), isFalse);
    expect(nested.hasMatch("node[key]"), isFalse);
    expect(nested.hasMatch("list[0]['a']"), isFalse);
  });
}

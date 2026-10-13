// A ratchet against the shape-blind parser handoff coming back.
//
// test/network/response_shape_resilience_test.dart proves the 32 response
// models survive an error-shaped and a version-skewed body. It cannot reach
// the CONTROLLER half of the same defect, because a controller needs GetX, a
// repository and a socket to run: when `home_controller.dart:112` passed
// `data['data']` straight into `ImageUrlData.fromJson`, no model test could
// see it. This closes that half statically, which is decidable, and it is the
// half that regresses when somebody adds a screen.
//
// WHAT IS FLAGGED in lib/:
//
//   1. `X.fromJson(something['key'])` -- a raw subscript of a decoded body
//      handed to a parser declared `fromJson(Map<String, dynamic> json)`. The
//      implicit downcast throws on `"data": []`, which is how Laravel
//      serialises an EMPTY Eloquent collection, and on the `{"status": 0}`
//      error envelope, which carries no `data` at all.
//   2. `something['key'] as Map<...>` / `as List<...>` -- a bare cast on a
//      decoded body. `as List? ?? []` is the same trap as
//      `['a']['b'] ?? fallback`: the cast runs and throws BEFORE the `??` is
//      consulted, so the fallback is decoration.
//   3. `final List x = something['key'] ?? []` -- a container-typed local
//      assigned straight off a body. The `??` covers null, and the declared
//      type forces a downcast on everything else.
//
// WHAT IS ALLOWED, and why:
//
//   * `jsonMap(...)` / `jsonList(...)` from lib/network/result.dart -- the fix.
//   * a type test on the SAME KEY within three lines above or one below. Nine
//     sites fixed in an earlier phase put the `is Map<String, dynamic>` on the
//     line above the cast, so a same-line-only rule would flag correct code.
//     The test is key-aware rather than "a guard appears nearby", so a guard
//     on a DIFFERENT key does not launder an unguarded read next to it.
//   * `X.fromJson(data)` / `(json)` / `(cached)` / `(item)` / `(v)` / `(e)` --
//     a WHOLE body or an already-type-tested element, not a subscript.
//   * `test/` is not scanned: a test MAY cast a body it built itself.
//
// Comments are blanked before matching, string literals are NOT
// (commentsStripped). codeOnly would be WRONG here and silently vacuous: it
// blanks string literals INCLUDING THE QUOTES, so `data['data']` arrives as
// `data[      ]` and every pattern below -- all of which need the quote to
// identify a string key -- can never fire. That is not hypothetical: the
// sibling ratchet in no_unguarded_nested_subscript_test.dart shipped on
// codeOnly and was proven vacuous this phase.

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  // Group 1 in each pattern is the key, so the guard check can be key-aware.
  final rules = <String, RegExp>{
    'parser handoff of a raw subscript': RegExp(
        r"""\.fromJson\(\s*[A-Za-z_]\w*\s*\[\s*['"]([^'"\]]+)['"]"""),
    'bare container cast on a subscript': RegExp(
        r"""\[\s*['"]([^'"\]]+)['"]\s*\]\s*as\s+(?:List|Map)\b"""),
    'container-typed local assigned off a subscript': RegExp(
        r"""(?:final\s+)?(?:List|Map)(?:<[^>]*>)?\s+[A-Za-z_]\w*\s*=\s*[A-Za-z_]\w*\s*\[\s*['"]([^'"\]]+)['"]"""),
  };

  /// Whether [key] is type-tested in the window around [index].
  bool guarded(List<String> lines, int index, String key) {
    final from = (index - 3).clamp(0, lines.length - 1);
    final to = (index + 1).clamp(0, lines.length - 1);

    for (var i = from; i <= to; i++) {
      final line = lines[i];
      final mentionsKey = line.contains("'$key'") || line.contains('"$key"');
      if (!mentionsKey) continue;
      if (line.contains('is Map') ||
          line.contains('is List') ||
          line.contains('is! Map') ||
          line.contains('is! List') ||
          line.contains('whereType')) {
        return true;
      }
    }
    return false;
  }

  test(
      'no lib/ source hands a raw decoded-body subscript to a parser or a '
      'container cast', () {
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      final path = relative(file);
      final lines = commentsStripped(file.readAsStringSync()).split('\n');

      for (var i = 0; i < lines.length; i++) {
        for (final rule in rules.entries) {
          final match = rule.value.firstMatch(lines[i]);
          if (match == null) continue;
          if (guarded(lines, i, match.group(1)!)) continue;

          offenders.add(
              '$path:${i + 1}  [${rule.key}]  key=${match.group(1)}  '
              '${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Wrap the argument in jsonMap() / jsonList() from '
          'lib/network/result.dart, or type-test the key on the same line. '
          '`Model.fromJson(data["data"])` is NOT guarded: `"data": []` is how '
          'Laravel serialises an empty collection, and the implicit downcast '
          'to Map<String, dynamic> throws on it. `as List? ?? []` is not '
          'guarded either -- the cast runs before the `??`.\n'
          '${offenders.join('\n')}',
    );
  });

  test('each rule matches the shape it is supposed to catch', () {
    // Without this, a typo in any of the three patterns would make the test
    // above vacuous and green forever -- which is exactly what happened to
    // the sibling ratchet, so the patterns are asserted directly rather than
    // trusted.
    final handoff = rules['parser handoff of a raw subscript']!;
    final bareCast = rules['bare container cast on a subscript']!;
    final typedLocal =
        rules['container-typed local assigned off a subscript']!;

    expect(handoff.hasMatch("ImageUrlData.fromJson(data['data'])"), isTrue);
    expect(handoff.hasMatch('WalletData.fromJson(data["data"]);'), isTrue);
    expect(handoff.firstMatch("X.fromJson(data['active_methods'])")!.group(1),
        'active_methods');

    expect(bareCast.hasMatch("data['data'] as Map<String, dynamic>"), isTrue);
    expect(bareCast.hasMatch("x['active_methods'] as List<dynamic>? ?? []"),
        isTrue);

    expect(typedLocal.hasMatch("final List products = data['data'] ?? [];"),
        isTrue);

    // And none fires on the fixed forms.
    expect(handoff.hasMatch("WalletData.fromJson(jsonMap(data['data']))"),
        isFalse);
    expect(handoff.hasMatch('OrderModel.fromJson(data)'), isFalse);
    expect(handoff.hasMatch('OrderData.fromJson(item)'), isFalse);
    expect(bareCast.hasMatch("jsonList(data['data'])"), isFalse);
    expect(typedLocal.hasMatch("final products = jsonList(data['data']);"),
        isFalse);
    // A list index is not a string key and must not be flagged.
    expect(typedLocal.hasMatch('List<Offset> _points = const [];'), isFalse);
  });

  test('the guard check is key-aware, not proximity-based', () {
    // A guard on a DIFFERENT key three lines up must not launder an
    // unguarded read. Without this the window would be a loophole wide
    // enough to drive the whole defect back through.
    final lines = <String>[
      "if (json['links'] is List) {",
      '  links = parse();',
      '}',
      "data = Model.fromJson(json['data']);",
    ];

    expect(guarded(lines, 3, 'data'), isFalse);
    expect(guarded(lines, 0, 'links'), isTrue);
  });
}

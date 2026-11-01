// WS K. A ratchet against telling the merchant an action worked when the
// server said it did not.
//
// `ApiResponser::error()` on the Laravel side returns **HTTP 200** with
// `{"status": 0, ...}` by default — 401 has to be passed explicitly and mostly
// is not, because the shipped app force-logs-out on any 401. So a refusal
// arrives at `onSuccess`, not `onFailure`: the transport succeeded, the
// operation did not, and `Result.fold` cannot tell the difference. Only the
// body can.
//
// THE CENSUS THAT PROMPTED THIS. Of the `onSuccess` closures in lib/ that show
// a GREEN SUCCESS TOAST, 22 already read `data['status']` before acting and 14
// did not. The majority pattern was already right; this brings the stragglers
// in line and stops the next one appearing.
//
// Several of the 14 did worse than toast. `deleteOrderData` ran
// `orderList.removeWhere(...)` — the merchant watched a refused order vanish
// from the list and found it still there on the next refresh.
// `updateOrderStatus` wrote the new status onto the detail model.
// `addReview` called `Get.back()`, dismissing the sheet with the typed review
// in it. The toast is the visible half; the state mutation is the half that
// makes the app disagree with the server.
//
// WHAT IS FLAGGED: an `onSuccess:` closure whose body contains
// `AppSnackBarType.success` and no status check.
//
// WHAT COUNTS AS A CHECK: `apiRefused(`, `['status']`, or `status ==`. The
// first is the helper added for this (lib/network/result.dart); the other two
// are the hand-written forms the 22 already use, and rewriting those would be
// churn with no reader who benefits.
//
// WHY ONLY THE SUCCESS-TOAST CLOSURES. "Did this closure mutate something it
// should not have" is not decidable from source. "Did it tell the merchant it
// worked" is — the toast type is a literal — and it is the half a merchant
// actually acts on. Reads that silently render an empty list on a refusal are
// a real but quieter defect, recorded separately rather than ratcheted here on
// a rule that could not be stated precisely.
//
// Comments are stripped before matching, NOT string literals: the guards added
// for this carry explanatory comments that name `AppSnackBarType.success`, and
// counting those would have flagged the fix itself. `codeOnly` would be wrong
// here for the reason its own docblock gives — it blanks string literals
// including the quotes.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

/// The body of each `onSuccess:` closure in [source], by brace balance.
///
/// A regex cannot do this: the closures contain nested braces, string
/// interpolation and further closures, so matching to the first `}` truncates
/// most of them and would miss a status check that sits after the truncation
/// point — flagging correct code.
List<({int line, String body})> onSuccessBodies(String source) {
  final out = <({int line, String body})>[];
  final opener = RegExp(r'onSuccess:\s*\([^)]*\)\s*(?:async\s*)?\{');

  for (final match in opener.allMatches(source)) {
    final start = match.end - 1;
    var depth = 0;
    var end = start;

    for (var i = start; i < source.length; i++) {
      if (source[i] == '{') {
        depth++;
      } else if (source[i] == '}') {
        depth--;
        if (depth == 0) {
          end = i;
          break;
        }
      }
    }

    out.add((
      line: '\n'.allMatches(source.substring(0, match.start)).length + 1,
      body: source.substring(start, end + 1),
    ));
  }

  return out;
}

bool _checksStatus(String body) =>
    body.contains('apiRefused(') ||
    body.contains("['status']") ||
    body.contains('status ==') ||
    body.contains('status==');

void main() {
  test('the closure extractor really extracts, and balances braces', () {
    // THE PREMISE. Every assertion below is satisfied by an extractor that
    // finds nothing, so a broken regex would report a clean tree forever.
    const sample = '''
      result.fold(
        onSuccess: (data) {
          if (data['ok'] == 1) { doThing(); }
          toast(AppSnackBarType.success, 'done');
        },
        onFailure: (a, b, c) {},
      );
    ''';

    final bodies = onSuccessBodies(sample);

    expect(bodies, hasLength(1));
    expect(
      bodies.single.body.contains('AppSnackBarType.success'),
      isTrue,
      reason: 'the body was truncated at the first nested `}`, so a status '
          'check after that point would be invisible and correct code would '
          'be flagged',
    );
  });

  test('and the status detector detects', () {
    expect(_checksStatus("if (apiRefused(data)) { return; }"), isTrue);
    expect(_checksStatus("if (data['status'] == 1) {}"), isTrue);
    expect(_checksStatus("toast('done');"), isFalse);
  });

  test('no onSuccess closure claims success without checking the body first',
      () {
    final offenders = <String>[];
    var guarded = 0;

    for (final File file in libDartFiles()) {
      final source = commentsStripped(file.readAsStringSync());

      for (final closure in onSuccessBodies(source)) {
        if (!closure.body.contains('AppSnackBarType.success')) continue;

        if (_checksStatus(closure.body)) {
          guarded++;
        } else {
          offenders.add('${relative(file)}:${closure.line}');
        }
      }
    }

    // The counting half has to be alive, or "0 offenders" means the scan
    // found nothing rather than that nothing is wrong.
    expect(
      guarded,
      greaterThan(20),
      reason: 'the scan found almost no guarded closures, so it is not '
          'reading lib/ — the offender list below means nothing',
    );

    expect(
      offenders,
      isEmpty,
      reason: 'These onSuccess closures show a GREEN SUCCESS TOAST without '
          'first asking whether the server refused. `ApiResponser::error()` '
          'answers HTTP 200 with `{"status": 0}`, so a refusal arrives here '
          'and the merchant is told their action worked:\n\n  '
          '${offenders.join("\n  ")}\n\n'
          'Guard with `if (apiRefused(data)) { ...error...; return; }` '
          '(lib/network/result.dart).',
    );
  });
}

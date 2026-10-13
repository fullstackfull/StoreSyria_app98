// A denial must not be rendered as an empty success.
//
// hand_rolled_status_handling_test.dart and forced_logout_test.dart together
// pin the SECURITY half of the 403 contract: 401 is the only forced logout,
// and 403 and 429 stay off that path. Those properties held. This file pins
// the half that did NOT hold -- whether a 403 is VISIBLE at all.
//
// Repo A is adding 403 fail-closed refusals on roughly eleven admin-API
// store-ownership sites, plus plan.order.show for a non-owner. Every one of
// those is a request this app already makes with `?store_id=` or a `store_id`
// body field. network.dart classifies the response correctly -- reason
// `unauthorized`, message `action_not_permitted`, no logout -- and then hands
// it to an `onFailure` closure, and at that point the classification is only
// as good as what the closure does with it.
//
// Three closures did nothing with it:
//
//   * add_review_controller.getReviewData  `reviewList.clear()` and no more.
//     `/reviewlist` carries `?store_id=`. `_buildReviewsList` renders
//     `'no_reviews_yet'.tr` for an empty list, so a refused request was
//     reported to the merchant as the positive claim "No reviews yet". This
//     is the exact failure mode: not a wrong error message, but a denial
//     wearing the costume of a successful empty answer.
//   * product_detail_controller.getProductDetail  `{}`, an empty closure.
//     `/viewproduct` carries `?store_id=`. The screen does not blank, because
//     `product` is already populated from the list row, so a 403 showed a
//     product with its sub-images and currency symbol silently missing.
//   * home_controller.setStoreIdData  the toast was COMMENTED OUT.
//     `/changestore` posts `store_id`, so this is the ownership endpoint
//     itself and a 403 on it means "that store is not yours". The merchant
//     was told nothing whatsoever.
//
// WHY A STATUS-CODE TEST WOULD NOT HAVE CAUGHT THIS. The status code was
// already right, and `FailureReason.unauthorized` was already being produced.
// Asserting either one passes with all three defects present. The thing that
// regresses is the HANDLER, which is why this file reads handlers.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

/// One `onFailure:` closure found in a source file.
class Handler {
  Handler(this.path, this.line, this.body);

  final String path;
  final int line;

  /// The closure body with comments and string literals blanked out, so prose
  /// and a commented-out toast both read as what they are: not code.
  final String body;

  @override
  String toString() => '$path:$line';
}

/// Every `onFailure:` closure body under `lib/`.
///
/// Hand-rolled rather than regex-matched because a closure body contains
/// braces of its own -- maps, nested folds, `if` blocks -- and a
/// non-greedy `\{.*?\}` stops at the first inner `}`, which would make a long
/// handler look empty and the detector fail OPEN. The brace depth is counted.
List<Handler> onFailureHandlers() {
  final handlers = <Handler>[];

  for (final file in libDartFiles()) {
    final path = relative(file);

    // The definition of `fold` itself, not a call site.
    if (path == 'lib/network/result.dart') continue;

    final source = codeOnly(file.readAsStringSync());

    var at = source.indexOf('onFailure:');

    while (at >= 0) {
      final line = source.substring(0, at).split('\n').length;

      // Skip the parameter list. The parameters in this codebase are plain
      // identifiers, so the first ')' after 'onFailure:' closes them.
      final paramsEnd = source.indexOf(')', at);

      if (paramsEnd < 0) break;

      // Then the body: '{', possibly after 'async'.
      final bodyStart = source.indexOf('{', paramsEnd);

      if (bodyStart < 0) break;

      var depth = 0;
      var i = bodyStart;

      for (; i < source.length; i++) {
        if (source[i] == '{') depth++;
        if (source[i] == '}') {
          depth--;
          if (depth == 0) break;
        }
      }

      handlers.add(
        Handler(path, line, source.substring(bodyStart + 1, i)),
      );

      at = source.indexOf('onFailure:', i < 0 ? at + 1 : i);
    }
  }

  return handlers;
}

/// True when a body contains no executable token at all.
bool _isSilent(String body) =>
    !RegExp(r'[A-Za-z0-9_]').hasMatch(body);

/// The brace-delimited block that starts at the first `{` at or after [from].
///
/// Shared by the scanner and the review-list assertions below so that both
/// read a WHOLE handler. A fixed-size window was tried first and is the wrong
/// tool: comments inside a handler are blanked to spaces, so a window wide
/// enough for a documented handler silently runs past a short one into the
/// next.
String bodyAfter(String source, int from) {
  final start = source.indexOf('{', from);

  if (start < 0) return '';

  var depth = 0;

  for (var i = start; i < source.length; i++) {
    if (source[i] == '{') depth++;
    if (source[i] == '}') {
      depth--;
      if (depth == 0) return source.substring(start + 1, i);
    }
  }

  return source.substring(start + 1);
}

void main() {
  late List<Handler> handlers;

  setUpAll(() {
    handlers = onFailureHandlers();
  });

  // ---------------------------------------------------------------------------
  group('the detector is not vacuous', () {
    test('it finds the app\'s failure handlers', () {
      // If a refactor renames `onFailure` or restructures `Result.fold`, this
      // file must go red rather than quietly scanning nothing and passing.
      expect(
        handlers.length,
        greaterThanOrEqualTo(60),
        reason: 'Only ${handlers.length} onFailure closures were found. The '
            'detector has stopped seeing the call sites it is meant to '
            'police.',
      );
    });

    test('it reads a whole body, not up to the first inner brace', () {
      // The failure mode that would make this file pass while blind: a
      // non-greedy brace match ends at the `}` of the inner `if`, leaving a
      // body that looks empty.
      const sample = '''
        thing.fold(
          onFailure: (reason, message, errors) {
            if (reason == FailureReason.notFound) { return; }
            errorMessage.value = message;
          },
        );
      ''';

      // Exercise the same brace-counting helper the scanner uses, on a known
      // input whose handler has an inner block.
      final source = codeOnly(sample);
      final at = source.indexOf('onFailure:');
      final body = bodyAfter(source, source.indexOf(')', at));

      expect(body, contains('errorMessage'));
      expect(body, contains('FailureReason'));
      expect(_isSilent(body), isFalse);
    });

    test('and it calls a genuinely empty body silent', () {
      expect(_isSilent(''), isTrue);
      expect(_isSilent('   \n  '), isTrue);

      // A commented-out toast is the home_controller defect, and `codeOnly`
      // is what makes it detectable: the comment is blanked, so the body is
      // empty code.
      expect(
        _isSilent(codeOnly('  // commonToast(message);  ')),
        isTrue,
      );

      // And a real call is not silent.
      expect(_isSilent('commonToast(message);'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  group('no failure handler discards the failure', () {
    test('every onFailure closure does something', () {
      // The general guard. A 403 reaching an empty closure is indistinguishable
      // from a success that returned nothing, at every call site equally --
      // so this is asserted across all of them rather than on the three that
      // were found wrong.
      final silent = handlers.where((h) => _isSilent(h.body)).toList();

      expect(
        silent,
        isEmpty,
        reason: 'These failure handlers discard the failure, so a 403 from '
            'the new store-ownership checks reaches the merchant as an empty '
            'success:\n${silent.join('\n')}',
      );
    });

    test('the log-only handlers are pinned to the two that have no store_id',
        () {
      // Writing to the log is not nothing, but it is not visible to a
      // merchant either, so the set is held at exactly the two endpoints that
      // are NOT store-ownership sites and therefore not in the 403 blast
      // radius: `/notification` takes no store_id, and the FCM token POST
      // reports through its own return value.
      //
      // A new log-only handler on a store_id-bearing endpoint has to come
      // through this expectation, which is the point.
      final logOnly = handlers
          .where(
            (h) =>
                !_isSilent(h.body) &&
                RegExp(r'AppLog|\blog\(').hasMatch(h.body) &&
                !h.body.contains('commonToast') &&
                !h.body.contains('rrorMessage'),
          )
          .map((h) => h.path)
          .toSet()
          .toList()
        ..sort();

      expect(
        logOnly,
        const <String>[
          'lib/core/controller/notification_controller/'
              'notification_controller.dart',
          'lib/core/services/fcm_token_service.dart',
        ],
        reason: 'A failure handler reports only to the log. If its endpoint '
            'sends store_id it can now be refused with 403, and the merchant '
            'would see stale or empty data with no indication why.',
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('the review list tells a denial apart from an empty list', () {
    late String controller;
    late String screen;

    setUpAll(() {
      // `commentsStripped`, not `codeOnly`: these assertions are ABOUT string
      // literals -- `'no_reviews_yet'.tr` and the `= ''` reset -- and
      // `codeOnly` blanks literals away, which made all three of these pass
      // vacuously or fail spuriously depending on which way they were
      // written. Comments are still removed, so the prose above a handler
      // cannot satisfy a `contains`.
      controller = commentsStripped(
        File('${packageRoot().path}/lib/core/controller/product_controller/'
                'add_review_controller.dart')
            .readAsStringSync(),
      );

      screen = commentsStripped(
        File('${packageRoot().path}/lib/view/screen/product_screen/'
                'product_detail_screen.dart')
            .readAsStringSync(),
      );
    });

    test('getReviewData records the reason when the request fails', () {
      final at = controller.indexOf('Future<void> getReviewData');

      expect(at, greaterThanOrEqualTo(0),
          reason: 'getReviewData has been renamed or removed.');

      final failAt = controller.indexOf('onFailure:', at);

      expect(failAt, greaterThanOrEqualTo(0));

      final handler = bodyAfter(controller, failAt);

      expect(
        handler,
        contains('reviewErrorMessage'),
        reason: 'Clearing reviewList without recording WHY leaves the view '
            'unable to tell "no reviews" from "not allowed to see the '
            'reviews", and it renders the former. Handler body was:\n'
            '$handler',
      );
    });

    test('and clears it when the request succeeds', () {
      // Otherwise a denial on one product would persist onto the next product
      // the merchant opens, which is the mirror-image bug: a success rendered
      // as a denial.
      final at = controller.indexOf('Future<void> getReviewData');
      final failAt = controller.indexOf('onFailure:', at);

      final successHalf = controller.substring(at, failAt);

      expect(
        RegExp(r"reviewErrorMessage\.value\s*=\s*''").hasMatch(successHalf),
        isTrue,
        reason: 'onSuccess must reset reviewErrorMessage, or a stale denial '
            'outlives the request that caused it.',
      );
    });

    test('the view checks the error BEFORE it checks for emptiness', () {
      // The order is the whole fix. Both conditions are true at once after a
      // 403 -- the list is empty AND there is an error -- so whichever is
      // tested first decides what the merchant is told.
      final errorAt = screen.indexOf('reviewErrorMessage');
      final emptyAt = screen.indexOf('reviewList.isEmpty');

      expect(errorAt, greaterThanOrEqualTo(0),
          reason: 'The reviews list no longer consults the error state.');
      expect(emptyAt, greaterThanOrEqualTo(0),
          reason: 'The empty-state branch has moved; re-check this ordering.');

      expect(
        errorAt,
        lessThan(emptyAt),
        reason: 'The empty-state branch is reached first, so a refused '
            'request still renders as "no reviews yet".',
      );
    });

    test('and the empty state is still there for a product with no reviews', () {
      // The negative half. Deleting the empty state would also make the test
      // above pass, and would be a regression of its own.
      expect(screen, contains("'no_reviews_yet'.tr"));
    });
  });
}

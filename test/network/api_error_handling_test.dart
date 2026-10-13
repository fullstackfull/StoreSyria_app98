// Regression guards for the response handling the repaired backend requires.
//
// Agent-1's server-side work changes which status codes the app actually sees:
// requests that used to be waved through anonymously now return 401, request
// validation returns 422, and rate limiting returns 429. The app's switch
// handled 400, 401, 404 and 500 only, so 422 and 429 both fell to `default`
// and reached the merchant as "an error occurred".
//
// These are source-level assertions. The behavioural ones are not reachable
// from a unit test: `_handleErrorResponse` is private, it needs an
// `http.Response`, and the messages go through GetX `.tr`, which needs a
// GetMaterialApp. Asserting on the source is the honest option and it does
// catch the regression that matters -- somebody simplifying the switch back.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/network/result.dart';

import '../support/source_tree.dart';

void main() {
  late String network;

  setUpAll(() {
    network =
        File('${packageRoot().path}/lib/network/network.dart').readAsStringSync();
  });

  group('FailureReason', () {
    test('rateLimited exists so 429 is distinguishable', () {
      // Without a reason of its own, a throttled merchant saw the generic
      // error and retried immediately, deepening the throttle.
      expect(FailureReason.values, contains(FailureReason.rateLimited));
    });

    test('the pre-existing reasons are all still there', () {
      // Adding an enum value must not have removed one: a dropped reason is a
      // compile break in every consumer, and `unauthorized` in particular is
      // what drives the forced logout.
      for (final reason in <FailureReason>[
        FailureReason.network,
        FailureReason.timeout,
        FailureReason.unauthorized,
        FailureReason.validation,
        FailureReason.notFound,
        FailureReason.unknown,
      ]) {
        expect(FailureReason.values, contains(reason));
      }
    });
  });

  group('status code handling', () {
    test('429 is handled and honours Retry-After', () {
      expect(codeOnly(network), contains('case 429'));
      expect(network, contains('retry-after'));
      expect(network, contains('FailureReason.rateLimited'));
    });

    test('422 is handled as validation, like Laravel sends it', () {
      expect(codeOnly(network), contains('case 422'));
    });

    test('403 is handled without clearing the session', () {
      // Laravel Policies and Gates answer a denial with 403. It used to fall
      // to `default` and show "an error occurred". It must NOT clear the
      // session: 403 means the session is valid and the action is not
      // allowed, so logging out would turn one denied action into a loop.
      final code = codeOnly(network);

      expect(code, contains('case 403'));

      final start = code.indexOf('case 403');
      final end = code.indexOf('case 404');

      expect(start, greaterThan(-1));
      expect(end, greaterThan(start));

      expect(
        code.substring(start, end),
        isNot(contains('handleUnauthorized')),
        reason: '403 must not trigger a forced logout.',
      );
    });

    test('401 still triggers a forced logout', () {
      final code = codeOnly(network);

      expect(code, contains('case 401'));
      expect(code, contains('handleUnauthorized'));
      expect(code, contains('Prefs.clear()'));
    });

    test('the forced logout is guarded against concurrent 401s', () {
      // The old guard compared Get.currentRoute against '/login', but the
      // navigation it performs produces an unnamed route, so it never matched.
      // With several requests in flight -- normal on the dashboard -- every
      // one of them cleared storage and pushed another login screen.
      expect(
        codeOnly(network),
        contains('_unauthorizedInFlight'),
        reason:
            'handleUnauthorized must be idempotent across a burst of 401s.',
      );
    });
  });

  group('response decoding is defensive', () {
    test('every verb has a catch-all around its decode', () {
      // A 200 whose body is HTML, empty, or a JSON array where an object was
      // expected must become a Failure, never an uncaught exception.
      final verbs = <String>[
        'getRequest',
        'postRequest',
        'putRequest',
        'multipartRequest',
        'deleteRequest',
      ];

      for (final verb in verbs) {
        expect(
          network,
          contains(verb),
          reason: '$verb is missing from the network layer',
        );
      }

      // One trailing `catch (e, stackTrace)` per verb, plus the private
      // helpers' own guards.
      final catchAlls =
          RegExp(r'catch \(e, stackTrace\)').allMatches(network).length;

      expect(
        catchAlls,
        greaterThanOrEqualTo(verbs.length),
        reason:
            'Each request verb needs a trailing catch-all so a malformed or '
            'unexpected body cannot escape as an exception.',
      );
    });

    test('the hand-rolled multipart sites check status before decoding', () {
      // profile_controller used to decode the body FIRST. On a 401 or 429 with
      // a non-JSON body that threw past the status handling, so its own 401
      // branch never ran and the dead session stayed in local storage.
      final profile = File(
        '${packageRoot().path}/lib/core/controller/profile_controller/'
        'profile_controller.dart',
      ).readAsStringSync();

      final code = codeOnly(profile);

      expect(
        code,
        contains('_decodeOrEmpty'),
        reason: 'A body that is not JSON must not throw past the status check.',
      );

      final statusCheck = code.indexOf('response.statusCode == 401');
      final decode = code.indexOf('_decodeOrEmpty(responseData)');

      expect(statusCheck, greaterThan(-1));
      expect(decode, greaterThan(-1));
      expect(
        decode,
        lessThan(statusCheck),
        reason:
            'The defensive decode must run before the status branches so both '
            'are always reached.',
      );

      final category = codeOnly(File(
        '${packageRoot().path}/lib/core/controller/home_controller/'
        'category_controller.dart',
      ).readAsStringSync());

      expect(
        category,
        contains('NetworkHttps.handleUnauthorized'),
        reason:
            'The category multipart site had no 401 handling at all; it must '
            'share the one forced-logout path.',
      );
    });
  });
}

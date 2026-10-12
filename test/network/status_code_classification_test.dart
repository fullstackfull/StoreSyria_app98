// Executable coverage for the HTTP status-code classification in
// NetworkHttps._handleErrorResponse.
//
// Everything else under test/ in this package is a source-tree assertion: it
// greps lib/ and proves a shape. Shape tests cannot tell you that a 429 does
// not log the merchant out, because that depends on which branch actually
// runs. These tests call the classifier with real http.Response objects and
// assert on the Failure it returns and on whether the forced-logout action
// fired, so the branch is executed rather than read.
//
// The forced-logout action is swapped for a counter via
// NetworkHttps.onUnauthorized. The production function clears GetStorage and
// drives the navigator, neither of which exists in a unit test; the seam
// exists so the 401-vs-429 distinction can be asserted at all.

import 'dart:convert';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/translations/en.dart';

void main() {
  var forcedLogouts = 0;

  setUpAll(() {
    // Without a locale GetX's `.tr` returns the key itself, so the assertions
    // below would be checking key names rather than the strings a merchant
    // sees. No engine is needed for this: Get.locale is a plain field.
    Get.addTranslations({'en': en});
    Get.locale = const Locale('en', 'US');
  });

  setUp(() {
    forcedLogouts = 0;
    NetworkHttps.onUnauthorized = () async {
      forcedLogouts++;
    };
  });

  tearDown(() {
    NetworkHttps.onUnauthorized = NetworkHttps.handleUnauthorized;
  });

  Failure<Map<String, dynamic>> classify(
    int status, {
    String body = '',
    Map<String, String> headers = const {},
  }) {
    final result = NetworkHttps.classifyErrorResponse<Map<String, dynamic>>(
      http.Response(body, status, headers: headers),
    );
    return result;
  }

  group('429 rate limiting', () {
    test('is classified as rateLimited, not unauthorized', () {
      final failure = classify(429);

      expect(failure.reason, FailureReason.rateLimited);
    });

    test('does NOT trigger a forced logout', () {
      classify(429, headers: {'retry-after': '60'});

      // This is the whole point of the finding. network.dart maps 401 to
      // Prefs.clear() + Get.offAll(login). If 429 shared that path, a merchant
      // who tripped the server's throttle would be logged out and would have
      // to sign in again, which is also the one thing most likely to make them
      // hammer the API harder.
      expect(
        forcedLogouts,
        0,
        reason: 'A throttled request must never clear the session.',
      );
    });

    test('puts the Retry-After seconds in the message', () {
      final failure = classify(429, headers: {'retry-after': '42'});

      expect(failure.message, contains('42'));
      expect(failure.message, isNot(contains('@seconds')));
    });

    test('reads Retry-After regardless of header casing', () {
      final failure = classify(429, headers: {'Retry-After': '17'});

      expect(failure.message, contains('17'));
    });

    test('falls back to the generic wording with no Retry-After', () {
      final failure = classify(429);

      expect(failure.reason, FailureReason.rateLimited);
      expect(failure.message, en['too_many_requests']);
    });

    test('falls back to the generic wording on a non-numeric Retry-After', () {
      // RFC 7231 permits an HTTP-date. Laravel does not send one, but an
      // intermediary may, and it must not produce "try again in null seconds".
      final failure = classify(
        429,
        headers: {'retry-after': 'Wed, 21 Oct 2026 07:28:00 GMT'},
      );

      expect(failure.message, en['too_many_requests']);
    });

    test('falls back to the generic wording on a zero Retry-After', () {
      final failure = classify(429, headers: {'retry-after': '0'});

      expect(failure.message, en['too_many_requests']);
    });

    test('survives a throttle response whose body is an HTML error page', () {
      // Nginx and some load balancers answer 429 with HTML, not JSON. The
      // decode must not throw past the status-code switch.
      final failure = classify(
        429,
        body: '<html><body>429 Too Many Requests</body></html>',
        headers: {'retry-after': '5'},
      );

      expect(failure.reason, FailureReason.rateLimited);
      expect(failure.message, contains('5'));
    });
  });

  group('401 unauthorized', () {
    test('is classified as unauthorized AND triggers the forced logout', () {
      final failure = classify(401);

      expect(failure.reason, FailureReason.unauthorized);
      expect(forcedLogouts, 1);
    });

    test('keeps a server-supplied message instead of the generic one', () {
      final failure = classify(
        401,
        body: jsonEncode({'message': 'Token expired.'}),
      );

      expect(failure.message, 'Token expired.');
      expect(forcedLogouts, 1);
    });

    test('uses the session-expired wording when the server sends none', () {
      final failure = classify(401);

      expect(failure.message, en['session_expired']);
    });
  });

  group('403 forbidden', () {
    test('is NOT a forced logout', () {
      // The backend returns 403 for a tenancy denial precisely because this
      // client turns 401 into a logout. If 403 were treated as 401, a merchant
      // touching another store's record would be signed out.
      final failure = classify(403);

      expect(failure.reason, FailureReason.unauthorized);
      expect(
        forcedLogouts,
        0,
        reason: 'A policy denial means the session is valid, not expired.',
      );
    });

    test('explains that the action is not permitted', () {
      final failure = classify(403);

      expect(failure.message, en['action_not_permitted']);
    });

    test('keeps the policy message the server sends', () {
      final failure = classify(
        403,
        body: jsonEncode({'message': 'This store is not yours.'}),
      );

      expect(failure.message, 'This store is not yours.');
      expect(forcedLogouts, 0);
    });
  });

  group('422 Laravel FormRequest validation', () {
    test('is classified as validation and carries the per-field errors', () {
      final failure = classify(
        422,
        body: jsonEncode({
          'message': 'The given data was invalid.',
          'errors': {
            'name': ['The name field is required.'],
          },
        }),
      );

      expect(failure.reason, FailureReason.validation);
      expect(failure.validationErrors, isNotNull);
      expect(failure.validationErrors!['name'], isNotNull);
      expect(failure.message, 'The given data was invalid.');
      expect(forcedLogouts, 0);
    });

    test('is still validation when the body carries no errors map', () {
      final failure = classify(422);

      expect(failure.reason, FailureReason.validation);
    });
  });

  group('the remaining codes', () {
    test('400 is validation', () {
      expect(classify(400).reason, FailureReason.validation);
    });

    test('404 is notFound with its own wording', () {
      final failure = classify(404);

      expect(failure.reason, FailureReason.notFound);
      expect(failure.message, en['resource_not_found']);
    });

    test('500 is unknown with its own wording', () {
      final failure = classify(500);

      expect(failure.reason, FailureReason.unknown);
      expect(failure.message, en['server_internal_error']);
    });

    test('an unmapped code is unknown and does not log anyone out', () {
      final failure = classify(418);

      expect(failure.reason, FailureReason.unknown);
      expect(forcedLogouts, 0);
    });

    test('no status code other than 401 reaches the forced logout', () {
      // Belt and braces across the whole mapped surface, because this is the
      // property that turns a transient server condition into a lost session.
      for (final status in const [400, 403, 404, 422, 429, 500, 502, 503]) {
        forcedLogouts = 0;
        classify(status);
        expect(
          forcedLogouts,
          0,
          reason: 'HTTP $status must not clear the merchant\'s session.',
        );
      }
    });
  });

  group('body decoding is defensive', () {
    test('an empty body does not throw and still classifies', () {
      expect(classify(503, body: '').reason, FailureReason.unknown);
    });

    test('a JSON array body does not throw', () {
      expect(classify(422, body: '[1,2,3]').reason, FailureReason.validation);
    });

    test('an HTML body does not throw', () {
      expect(
        classify(500, body: '<html>502 Bad Gateway</html>').reason,
        FailureReason.unknown,
      );
    });

    test('a nested data.message is preferred over a top-level message', () {
      final failure = classify(
        400,
        body: jsonEncode({
          'data': {'message': 'inner'},
          'message': 'outer',
        }),
      );

      expect(failure.message, 'inner');
    });
  });
}

// Regression guard for R7-N4 -- a blank server message produced a blank toast.
//
// `_handleErrorResponse` seeds `message` with the generic wording and then
// overwrites it from the body if `body['message'] != null`. An empty string is
// not null, so a server answering {"message": ""} replaced the generic wording
// with NOTHING and the merchant saw an error toast with no text in it -- no
// indication of what failed, and nothing to report to support.
//
// The 42 call sites that look like they defend against this are powerless:
// they are written `message ?? 'Error updating ...'`, but Failure.message is a
// non-nullable String (result.dart:41), so every one of those fallbacks is
// dead code. That is what the analyzer was reporting as
// `dead_null_aware_expression` -- six warnings describing a real hole.
//
// The fix resets a blank message to the sentinel BEFORE the status-code
// switch, so the per-status wording applies instead of a generic catch-all.
// These tests assert that per-status outcome, which is what pins the ordering:
// a fix applied after the switch would produce 'error_occurred' everywhere and
// fail here.

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
    // Without a locale GetX's `.tr` returns the key, so assertions would be
    // comparing key names rather than merchant-visible strings.
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

  Failure<Map<String, dynamic>> classify(int status, {String body = ''}) =>
      NetworkHttps.classifyErrorResponse<Map<String, dynamic>>(
        http.Response(body, status),
      );

  group('a blank message never reaches the merchant', () {
    test('an empty top-level message falls back to the status wording', () {
      final failure = classify(404, body: jsonEncode({'message': ''}));

      expect(failure.message, en['resource_not_found']);
      expect(failure.message, isNotEmpty);
    });

    test('an empty nested data.message falls back too', () {
      // data.message is checked FIRST and is the shape this API uses most, so
      // it is the likeliest way to hit the bug.
      final failure = classify(
        500,
        body: jsonEncode({
          'data': {'message': ''},
        }),
      );

      expect(failure.message, en['server_internal_error']);
    });

    test('an empty `error` key falls back', () {
      final failure = classify(400, body: jsonEncode({'error': ''}));

      expect(failure.message, isNotEmpty);
      expect(failure.reason, FailureReason.validation);
    });

    test('a whitespace-only message falls back', () {
      // Renders as an empty toast just the same, and is what a template with
      // an unfilled placeholder produces.
      final failure = classify(404, body: jsonEncode({'message': '   '}));

      expect(failure.message, en['resource_not_found']);
    });

    test('a newline-and-tab message falls back', () {
      final failure = classify(404, body: jsonEncode({'message': '\n\t '}));

      expect(failure.message, en['resource_not_found']);
    });

    test('no mapped status can produce an empty message', () {
      // The property that matters, stated across the whole surface rather than
      // one code at a time.
      for (final status in const [
        400, 401, 403, 404, 422, 429, 500, 502, 503, 418,
      ]) {
        for (final body in <String>[
          jsonEncode({'message': ''}),
          jsonEncode({'message': '  '}),
          jsonEncode({
            'data': {'message': ''},
          }),
          jsonEncode({'error': ''}),
        ]) {
          final failure = classify(status, body: body);

          expect(
            failure.message.trim(),
            isNotEmpty,
            reason: 'HTTP $status with body $body produced a blank message, '
                'which reaches the merchant as an empty toast.',
          );
        }
      }
    });
  });

  group('the blank-message fallback changes nothing else', () {
    test('a real server message is still preferred', () {
      final failure = classify(
        422,
        body: jsonEncode({'message': 'The name field is required.'}),
      );

      expect(failure.message, 'The name field is required.');
    });

    test('a blank message on 401 still forces the logout', () {
      // The fallback runs before the status switch, so it must not be able to
      // skip the switch's side effects.
      final failure = classify(401, body: jsonEncode({'message': ''}));

      expect(failure.message, en['session_expired']);
      expect(forcedLogouts, 1);
    });

    test('a blank message on 403 still does NOT force a logout', () {
      final failure = classify(403, body: jsonEncode({'message': ''}));

      expect(failure.message, en['action_not_permitted']);
      expect(
        forcedLogouts,
        0,
        reason: 'A policy denial means the session is valid.',
      );
    });

    test('a blank message on 429 keeps the rate-limited reason', () {
      final failure = classify(429, body: jsonEncode({'message': ''}));

      expect(failure.reason, FailureReason.rateLimited);
      expect(failure.message, isNotEmpty);
    });

    test('validation errors survive a blank message', () {
      // The per-field errors are what the form actually renders; a blank
      // top-level message must not cost them.
      final failure = classify(
        422,
        body: jsonEncode({
          'message': '',
          'errors': {
            'email': ['The email field is required.'],
          },
        }),
      );

      expect(failure.reason, FailureReason.validation);
      expect(failure.validationErrors, isNotNull);
      expect(failure.validationErrors!['email'], isNotNull);
      expect(failure.message, isNotEmpty);
    });
  });
}

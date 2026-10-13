// Behavioural unit tests for the logging seam (SEC-20a/b/c).
//
// Unlike the source-level guards, these actually exercise the redaction logic:
// if `safe` or `scrubString` stops masking, the guard tests would still pass
// while credentials flowed to the log again. This is the test that proves the
// seam does its job.
//
// Pure Dart. No device, no GetStorage, no network.

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/utils/app_log.dart';

void main() {
  group('AppLog.redact', () {
    test('masks a non-empty secret without revealing its length', () {
      expect(AppLog.redact('12|AbCdEfGhIjKlMnOp'), AppLog.redacted);
      expect(AppLog.redact('x'), AppLog.redacted);

      // Same marker regardless of input, so the output leaks nothing.
      expect(
        AppLog.redact('short'),
        AppLog.redact('a-much-longer-bearer-token-value'),
      );
    });

    test('distinguishes an absent secret from a masked one', () {
      expect(AppLog.redact(null), '(empty)');
      expect(AppLog.redact(''), '(empty)');
    });
  });

  group('AppLog.scrubString', () {
    test('masks a bearer token in a header-shaped string', () {
      final out = AppLog.scrubString(
        'Authorization: Bearer 12|AbCdEf.ghIjK-lmn_opQ',
      );

      expect(out, contains(AppLog.redacted));
      expect(out, isNot(contains('AbCdEf')));
      expect(out, isNot(contains('lmn_opQ')));
    });

    test('masks the bearer scheme in any casing', () {
      expect(AppLog.scrubString('bearer abc123'), isNot(contains('abc123')));
      expect(AppLog.scrubString('BEARER abc123'), isNot(contains('abc123')));
    });

    test('masks a password in a serialised request body', () {
      // This is literally what auth_controller.dart:152 used to log.
      final out = AppLog.scrubString(
        '{"email":"merchant@example.com","password":"hunter2"}',
      );

      expect(out, isNot(contains('hunter2')));
      expect(out, contains(AppLog.redacted));

      // The e-mail is not a credential and stays, so the line is still useful.
      expect(out, contains('merchant@example.com'));
    });

    test('masks the token in a login response body', () {
      // And this is what network.dart's response logger used to print.
      final out = AppLog.scrubString(
        '{"status":1,"data":{"id":7,"token":"12|AbCdEf","email":"m@e.com"}}',
      );

      expect(out, isNot(contains('12|AbCdEf')));
      expect(out, contains(AppLog.redacted));
      expect(out, contains('"status":1'));
    });

    test('masks single-quoted secret pairs too', () {
      expect(
        AppLog.scrubString("{'password': 'p@ss'}"),
        isNot(contains('p@ss')),
      );
    });

    test('masks prefixed token keys', () {
      final out = AppLog.scrubString(
        '{"access_token":"aaa","fcm_token":"bbb","refresh_token":"ccc"}',
      );

      expect(out, isNot(contains('aaa')));
      expect(out, isNot(contains('bbb')));
      expect(out, isNot(contains('ccc')));
    });

    test('leaves ordinary text alone', () {
      // A redactor that eats real data gets switched off, so this matters.
      expect(AppLog.scrubString('no secrets here'), 'no secrets here');

      expect(
        AppLog.scrubString('{"product_name":"Token Ring","price":10}'),
        contains('Token Ring'),
      );

      expect(AppLog.scrubString(''), '');
    });
  });

  group('AppLog.isSensitiveKey', () {
    test('matches regardless of case, dashes and underscores', () {
      for (final key in <String>[
        'password',
        'Password',
        'PASSWORD',
        'access_token',
        'access-token',
        'accessToken',
        'Authorization',
        'fcm_token',
        'cvv',
      ]) {
        expect(
          AppLog.isSensitiveKey(key),
          isTrue,
          reason: '$key should be treated as sensitive',
        );
      }
    });

    test('does not match ordinary field names', () {
      for (final key in <String>[
        'email',
        'name',
        'store_id',
        'product_name',
        'tokenizer',
        'price',
      ]) {
        expect(
          AppLog.isSensitiveKey(key),
          isFalse,
          reason: '$key should not be treated as sensitive',
        );
      }
    });
  });

  group('AppLog.safe', () {
    test('masks sensitive map values and keeps the rest', () {
      final input = <String, Object?>{
        'email': 'merchant@example.com',
        'password': 'hunter2',
        'token': '12|AbCdEf',
        'current_store': 3,
      };

      final out = AppLog.safe(input) as Map<String, Object?>;

      expect(out['email'], 'merchant@example.com');
      expect(out['current_store'], 3);
      expect(out['password'], AppLog.redacted);
      expect(out['token'], AppLog.redacted);

      // The caller's map must not be mutated.
      expect(input['password'], 'hunter2');
    });

    test('walks nested maps and lists', () {
      final out = AppLog.safe(<String, Object?>{
        'data': <String, Object?>{
          'user': <String, Object?>{'token': 'secret-value'},
          'items': <Object?>[
            <String, Object?>{'password': 'another-secret'},
          ],
        },
      });

      expect(out.toString(), isNot(contains('secret-value')));
      expect(out.toString(), isNot(contains('another-secret')));
    });

    test('survives a cyclic structure instead of hanging', () {
      final cycle = <String, Object?>{'name': 'loop'};
      cycle['self'] = cycle;

      // The depth bound is what makes this safe; without it a log call on a
      // cyclic object would hang the isolate.
      expect(() => AppLog.safe(cycle), returnsNormally);
    });

    test('passes primitives and null through unchanged', () {
      expect(AppLog.safe(null), isNull);
      expect(AppLog.safe(42), 42);
      expect(AppLog.safe(true), isTrue);
    });
  });

  group('AppLog.prettyJson', () {
    test('masks secrets in a JSON string', () {
      final out = AppLog.prettyJson(
        '{"token":"12|AbCdEf","name":"Shop"}',
      );

      expect(out, isNot(contains('12|AbCdEf')));
      expect(out, contains('Shop'));
    });

    test('does not throw on a body that is not JSON', () {
      expect(
        AppLog.prettyJson('<html><body>502 Bad Gateway</body></html>'),
        contains('502'),
      );
    });

    test('masks secrets in a map', () {
      expect(
        AppLog.prettyJson(<String, Object?>{'password': 'hunter2'}),
        isNot(contains('hunter2')),
      );
    });
  });
}

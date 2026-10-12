// Unit coverage for apiValueAt / apiText (lib/network/result.dart).
//
// These two functions are what the 24 call sites in
// test/controllers/nested_api_read_test.dart now go through, so the inputs
// here are the response shapes a Laravel API really produces -- including the
// ones that are not errors at all and still crashed the app, such as an
// unquoted integer.

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/network/result.dart';

void main() {
  group('apiValueAt walks a path without throwing', () {
    test('reads a value two levels down', () {
      expect(
        apiValueAt({
          'data': {'message': 'Saved'},
        }, ['data', 'message']),
        'Saved',
      );
    });

    test('reads a value three levels down', () {
      expect(
        apiValueAt({
          'data': {
            'user_info': {'current_store': 77},
          },
        }, ['data', 'user_info', 'current_store']),
        77,
      );
    });

    test('a missing intermediate level yields null, not a crash', () {
      // `{"status": 1}` -- the body that produced every one of the 24
      // NoSuchMethodErrors.
      expect(apiValueAt({'status': 1}, ['data', 'message']), isNull);
    });

    test('an explicitly null intermediate level yields null', () {
      expect(apiValueAt({'data': null}, ['data', 'message']), isNull);
    });

    test('a scalar where an object was expected yields null', () {
      // The case `?.[]` does NOT cover: a String subscript on a String is a
      // NoSuchMethodError just like on null.
      expect(apiValueAt({'data': 'OK'}, ['data', 'message']), isNull);
      expect(apiValueAt({'data': 7}, ['data', 'message']), isNull);
      expect(apiValueAt({'data': true}, ['data', 'message']), isNull);
    });

    test('a list where an object was expected yields null', () {
      // Laravel returns `"data": []` for an empty collection, which is the
      // single most likely real-world shape here.
      expect(apiValueAt({'data': <dynamic>[]}, ['data', 'message']), isNull);
      expect(apiValueAt({'data': [1, 2]}, ['data', 'message']), isNull);
    });

    test('a non-Map body yields null', () {
      // An HTML error page decoded as a String, or a top-level JSON array.
      expect(apiValueAt('<html>502</html>', ['data', 'message']), isNull);
      expect(apiValueAt(<dynamic>[], ['data', 'message']), isNull);
      expect(apiValueAt(null, ['data', 'message']), isNull);
    });

    test('an empty path returns the body itself', () {
      expect(apiValueAt({'a': 1}, const []), {'a': 1});
    });

    test('a deeper path than the body has yields null', () {
      expect(
        apiValueAt({
          'data': {'message': 'Saved'},
        }, ['data', 'message', 'deeper']),
        isNull,
      );
    });
  });

  group('apiText coerces and falls back', () {
    test('a string value comes back unchanged', () {
      expect(
        apiText({
          'data': {'reward_point': '25'},
        }, ['data', 'reward_point']),
        '25',
      );
    });

    test('an unquoted number is stringified rather than thrown', () {
      // The real defect at loyality_controller.dart:45 and
      // store_setting_controller.dart:645: both assigned a dynamic straight
      // into a non-nullable String position.
      expect(
        apiText({
          'data': {'reward_point': 150},
        }, ['data', 'reward_point']),
        '150',
      );
      expect(
        apiText({
          'data': {'reward_point': 12.5},
        }, ['data', 'reward_point']),
        '12.5',
      );
    });

    test('a bool is stringified rather than thrown', () {
      expect(
        apiText({
          'data': {'enabled': true},
        }, ['data', 'enabled']),
        'true',
      );
    });

    test('an absent value yields the fallback', () {
      expect(apiText({'status': 1}, ['data', 'x'], fallback: 'off'), 'off');
    });

    test('an empty-string value yields the fallback', () {
      // R7-N4 in miniature: an empty string is not null, so a plain `??`
      // let it through and the merchant saw a blank field.
      expect(
        apiText({
          'data': {'x': ''},
        }, ['data', 'x'], fallback: 'off'),
        'off',
      );
    });

    test('a whitespace-only value yields the fallback', () {
      expect(
        apiText({
          'data': {'x': '   '},
        }, ['data', 'x'], fallback: 'off'),
        'off',
      );
    });

    test('the default fallback is the empty string, never null', () {
      // Every caller assigns this into a non-nullable String.
      final value = apiText({'status': 1}, ['data', 'x']);

      expect(value, '');
      expect(value, isA<String>());
    });

    test('zero is a value, not an absence', () {
      // A store id of 0 or a reward point of 0 must not be swallowed by the
      // fallback -- that is the classic falsy-vs-absent bug.
      expect(
        apiText({
          'data': {'current_store': 0},
        }, ['data', 'current_store'], fallback: 'MISSING'),
        '0',
      );
    });
  });
}

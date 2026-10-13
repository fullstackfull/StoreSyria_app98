// Coverage for R7-N6 -- `data['data']['message'] ?? fallback` is not safe.
//
// Twenty-six call sites across twelve controllers read an API message as
// `data['data']['message']`. Most append `?? 'something'` and look defensive.
// They are not: `[]` is evaluated on `data['data']` BEFORE the `??`, so when
// the server answers `{"status": 1}` with no `data` object the index runs on
// null and throws NoSuchMethodError. The fallback never gets a chance.
//
// Two of those sites -- home_controller.setStoreIdData, the STORE SWITCH --
// had no fallback at all, so a present-but-null message was handed to
// commonToast, whose parameter is a non-nullable String
// (common_snak_bar_widget.dart:33-34), and threw a TypeError.
//
// WHY THIS IS WORSE THAN A VISIBLE CRASH. Both throws happen inside
// `onSuccess`, so every statement after the toast in that closure is skipped.
// In setStoreIdData that is Prefs.setStoreID(storeId), the FCM
// re-registration, and StoreChangeService.notifyStoreChanged() -- so the
// server switched the merchant's store, the app kept the OLD store id, and no
// screen reloaded. The merchant sees the previous store's data with no error
// at all.
//
// The precedence `apiMessage` implements is the one already hand-written
// correctly at product_controller.dart:143; this generalises it so the other
// sites have something to call.

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/network/result.dart';

void main() {
  group('apiMessage survives the shapes that used to throw', () {
    test('a body with no `data` key at all', () {
      // The exact shape that threw: `{"status": 1}`.
      expect(apiMessage({'status': 1}, fallback: 'fb'), 'fb');
    });

    test('a body whose `data` is explicitly null', () {
      expect(apiMessage({'status': 1, 'data': null}, fallback: 'fb'), 'fb');
    });

    test('a body whose `data` is a list, not a map', () {
      // Laravel returns a bare array for some index endpoints.
      expect(apiMessage({'data': <int>[1, 2]}, fallback: 'fb'), 'fb');
    });

    test('a body whose `data` is a scalar', () {
      expect(apiMessage({'data': 7}, fallback: 'fb'), 'fb');
    });

    test('a body whose nested message is null', () {
      // This is what reached commonToast(String) and threw a TypeError.
      expect(
        apiMessage({
          'data': {'message': null},
        }, fallback: 'fb'),
        'fb',
      );
    });

    test('a body whose nested message is empty or whitespace', () {
      // An empty toast is indistinguishable from a broken app.
      expect(
        apiMessage({
          'data': {'message': ''},
        }, fallback: 'fb'),
        'fb',
      );
      expect(
        apiMessage({
          'data': {'message': '   '},
        }, fallback: 'fb'),
        'fb',
      );
    });

    test('a body that is not a map at all', () {
      // jsonDecode of a top-level array, or of a bare string.
      expect(apiMessage(<int>[1, 2, 3], fallback: 'fb'), 'fb');
      expect(apiMessage('oops', fallback: 'fb'), 'fb');
      expect(apiMessage(null, fallback: 'fb'), 'fb');
    });

    test('an empty map', () {
      expect(apiMessage(<String, dynamic>{}, fallback: 'fb'), 'fb');
    });
  });

  group('apiMessage reads the message when there is one', () {
    test('the nested data.message is preferred', () {
      expect(
        apiMessage({
          'data': {'message': 'inner'},
          'message': 'outer',
        }),
        'inner',
      );
    });

    test('a top-level message is used when the nested one is absent', () {
      expect(apiMessage({'message': 'outer'}), 'outer');
    });

    test('a top-level message is used when the nested one is blank', () {
      // Precedence must fall through on blankness, not just on absence,
      // otherwise a blank nested message would mask a perfectly good outer one.
      expect(
        apiMessage({
          'data': {'message': '  '},
          'message': 'outer',
        }),
        'outer',
      );
    });

    test('`error` is read when no message key exists', () {
      expect(apiMessage({'error': 'boom'}), 'boom');
    });

    test('`message` wins over `error`', () {
      expect(apiMessage({'message': 'm', 'error': 'e'}), 'm');
    });

    test('a non-string message is stringified rather than thrown on', () {
      // Laravel validation sometimes answers with a list here.
      expect(apiMessage({'message': 42}), '42');
      expect(apiMessage({'message': true}), 'true');
    });

    test('the default fallback is used when none is given', () {
      expect(apiMessage({'status': 1}), 'Error');
    });

    test('the result is never empty', () {
      // The property every caller depends on: commonToast takes a
      // non-nullable String and renders it, so an empty return is a blank
      // toast.
      for (final body in <dynamic>[
        null,
        'x',
        <int>[1],
        <String, dynamic>{},
        {'status': 1},
        {'data': null},
        {
          'data': {'message': ''},
        },
        {'message': ''},
        {'error': '  '},
      ]) {
        expect(
          apiMessage(body, fallback: 'fb').trim(),
          isNotEmpty,
          reason: 'apiMessage returned something blank for $body',
        );
      }
    });
  });
}

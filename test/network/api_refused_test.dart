// WS K. The backend refuses at HTTP 200, so `onSuccess` is where a refusal
// arrives — and 14 closures showed a green success toast for one.
//
// `ApiResponser::error()` on the Laravel side returns 200 with
// `{"status": 0, ...}` by default; 401 has to be passed explicitly and mostly
// is not, because the shipped app force-logs-out on any 401. So the transport
// succeeded and the operation did not, and `Result.fold` cannot tell the
// difference — only the body can.
//
// WHAT `apiRefused` HAS TO GET RIGHT, and why the asymmetry is the whole
// design: it must say YES for every shape the backend really uses to refuse,
// and NO for everything else — including a body with no `status` at all, which
// plenty of this app's endpoints send. Treating absence as a refusal would
// break every one of those screens at once, which is the opposite of the
// compatibility this change exists to preserve.
//
// The refusal values are taken from the backend, not invented: `ApiResponser`
// writes `0`, `FlashSaleController::updateStatus` writes `false`, and a
// JSON-encoded form post can deliver either as a string.

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/network/result.dart';

void main() {
  group('an explicit refusal', () {
    test('the shape ApiResponser::error() really sends', () {
      expect(
        apiRefused(<String, dynamic>{
          'status': 0,
          'message': 'fail',
          'data': {'message': 'Permission denied.'},
        }),
        isTrue,
      );
    });

    test('the boolean shape, which updateStatus sends', () {
      expect(apiRefused(<String, dynamic>{'status': false}), isTrue);
    });

    test('either of those arriving as a string', () {
      expect(apiRefused(<String, dynamic>{'status': '0'}), isTrue);
      expect(apiRefused(<String, dynamic>{'status': 'false'}), isTrue);
      expect(apiRefused(<String, dynamic>{'status': 'Error'}), isTrue);
      expect(apiRefused(<String, dynamic>{'status': 'fail'}), isTrue);
    });
  });

  group('a success is never mistaken for a refusal', () {
    test('the shape ApiResponser::success() sends', () {
      expect(
        apiRefused(<String, dynamic>{'status': 1, 'data': <String, dynamic>{}}),
        isFalse,
      );
    });

    test('and its boolean and string spellings', () {
      expect(apiRefused(<String, dynamic>{'status': true}), isFalse);
      expect(apiRefused(<String, dynamic>{'status': '1'}), isFalse);
      expect(apiRefused(<String, dynamic>{'status': 'success'}), isFalse);
    });
  });

  group('FAILING OPEN is the point, not an oversight', () {
    test('a body with no status at all is NOT a refusal', () {
      expect(
        apiRefused(<String, dynamic>{'data': <String, dynamic>{'id': 7}}),
        isFalse,
        reason: 'Plenty of endpoints send no `status`. Reading absence as a '
            'refusal would break every one of those screens at once, which is '
            'the opposite of what this change is for.',
      );
    });

    test('an explicit null status is not a refusal either', () {
      expect(apiRefused(<String, dynamic>{'status': null}), isFalse);
    });

    test('a non-Map body is not a refusal', () {
      // A list is what Laravel serialises an empty Eloquent collection to, and
      // some endpoints answer with a bare list. There is no status to read.
      expect(apiRefused(<dynamic>[]), isFalse);
      expect(apiRefused('ok'), isFalse);
      expect(apiRefused(null), isFalse);
      expect(apiRefused(42), isFalse);
    });

    test('an unrecognised status value is not a refusal', () {
      // Better to leave a screen behaving exactly as it does today than to
      // start refusing on a value nobody has seen.
      expect(apiRefused(<String, dynamic>{'status': 'pending'}), isFalse);
      expect(apiRefused(<String, dynamic>{'status': 2}), isFalse);
    });
  });

  group('the real envelopes, end to end', () {
    test('a permission denial from the admin API is caught', () {
      // StoreFinanceController::addBalanceApi, verbatim shape.
      expect(
        apiRefused(<String, dynamic>{
          'status': 0,
          'message': 'fail',
          'data': {
            'message':
                'Permission denied. You do not have permission to add balance.',
          },
        }),
        isTrue,
      );
    });

    test('a successful order list is not', () {
      expect(
        apiRefused(<String, dynamic>{
          'status': 1,
          'message': 'success',
          'data': {
            'orders': <dynamic>[],
          },
        }),
        isFalse,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/network/result.dart';

/// P2-07-13 — a refusal must READ as a refusal, not as a fault.
///
/// Three order screens discarded the server's message and showed their own
/// ("Failed to load orders") for every failure alike. That was harmless while the only failures
/// were network faults, and became wrong the moment `orderlist`, `Top_orders` and the rest started
/// refusing on permission: a staff member who may not read orders was told the orders FAILED TO
/// LOAD — so they would retry something that can never work, and the screen would keep blaming
/// itself for a decision the server made on purpose.
///
/// It is the same defect as a withheld figure rendered as `0`: wrong information where withheld
/// information was called for.
void main() {
  group('failureMessage', () {
    test('a refusal shows the server reason', () {
      expect(
        failureMessage(
          FailureReason.unauthorized,
          'You do not have permission to perform this action.',
          'failed_to_load_orders',
        ),
        'You do not have permission to perform this action.',
      );
    });

    test('a network fault keeps the screen-specific fallback', () {
      for (final reason in const <FailureReason>[
        FailureReason.network,
        FailureReason.timeout,
        FailureReason.notFound,
        FailureReason.validation,
        FailureReason.rateLimited,
        FailureReason.unknown,
      ]) {
        expect(
          failureMessage(reason, 'Connection closed', 'failed_to_load_orders'),
          'failed_to_load_orders',
          reason: '$reason must not be reported as a permission refusal',
        );
      }
    });

    /// A refusal with no message would otherwise show an empty string, which reads as a rendering
    /// fault. `network.dart` substitutes `action_not_permitted` for a bare 403, so this is the
    /// belt to that braces.
    test('a refusal with no message falls back rather than showing nothing', () {
      for (final empty in const <String>['', '   ']) {
        expect(
          failureMessage(FailureReason.unauthorized, empty, 'failed_to_load_orders'),
          'failed_to_load_orders',
        );
      }
    });
  });
}

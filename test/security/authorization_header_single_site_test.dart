// Guard test for R7-N1 / NEW-auth-header-six-sites.
//
// The `Authorization` header used to be constructed in six places: the central
// helper in NetworkHttps plus four hand-rolled bypasses and three more
// commented out in the payment-settings controllers. Three of the four live
// bypasses were WRITE operations (logout, profile update, category
// create/update).
//
// Why that matters more than tidiness: a change to how the app presents its
// token — a scheme change, a refresh, an added header — applied only to the
// network layer would leave those four endpoints silently broken, and "silently
// broken write endpoint" is exactly the failure a merchant reports a week
// later as "it sometimes doesn't save". No app-side auth change should be
// attempted while more than one construction site exists, which is what this
// test enforces.

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  group('Authorization header', () {
    test('the Bearer scheme is written in exactly one file', () {
      // String literals are KEPT here (comments are not), because the thing
      // being located IS a string literal.
      final hits = <String>[];

      for (final file in libDartFiles()) {
        final lines = commentsStripped(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (RegExp(r'Bearer\s').hasMatch(lines[i])) {
            hits.add('${relative(file)}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      // Two permitted sites, and only two:
      //   * lib/network/network.dart — where the header is built
      //   * lib/utils/app_log.dart   — the fixed redaction marker, which
      //                                 contains no interpolation
      final files = hits
          .map((h) => h.split(':').first)
          .toSet()
          .toList()
        ..sort();

      expect(
        files,
        <String>['lib/network/network.dart', 'lib/utils/app_log.dart'],
        reason:
            'The Bearer scheme may appear only where the header is built and '
            'in the log redaction marker. Found:\n${hits.join('\n')}',
      );
    });

    test('only the network layer interpolates a token into the header', () {
      final hits = <String>[];

      for (final file in libDartFiles()) {
        final lines = commentsStripped(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          // `Bearer ` immediately followed by an interpolation is the shape of
          // a header being constructed, as opposed to a fixed marker string.
          if (RegExp(r'Bearer\s+\$').hasMatch(lines[i])) {
            hits.add('${relative(file)}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      expect(
        hits.length,
        1,
        reason:
            'Exactly one construction site is allowed, in '
            'lib/network/network.dart. Call NetworkHttps.authHeaders() instead '
            'of hand-rolling the header. Found:\n${hits.join('\n')}',
      );

      expect(hits.single, startsWith('lib/network/network.dart:'));
    });

    test('no controller hand-rolls an Authorization header key', () {
      final hits = <String>[];

      for (final file in libDartFiles()) {
        if (relative(file) == 'lib/network/network.dart') continue;

        final lines = commentsStripped(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (RegExp(
            r"""["']Authorization["']\s*:""",
          ).hasMatch(lines[i])) {
            hits.add('${relative(file)}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      expect(
        hits,
        isEmpty,
        reason:
            'An `Authorization:` map entry outside the network layer is a '
            'bypass. Use NetworkHttps.authHeaders(). Found:\n'
            '${hits.join('\n')}',
      );
    });
  });
}

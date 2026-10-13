// Two call sites bypass the network layer, and each has to re-make the same
// three decisions by hand.
//
// NetworkHttps._handleErrorResponse (network.dart:216-444) distinguishes 401,
// 403 and 429, and the distinction is load-bearing rather than cosmetic:
//
//   401  the session is over      -> Prefs.clear() + back to the login screen
//   403  the session is fine, the action is not allowed
//        -> a message, and DELIBERATELY NOT a logout: the server answers 403
//           instead of 401 precisely so that one denied action cannot turn
//           into a logout loop
//   429  slow down
//        -> a message, and deliberately kept OFF the logout path; clearing a
//           merchant's session for being throttled would be absurd
//
// Two controllers do not go through that classifier, because
// `http.MultipartRequest` cannot: profile_controller.dart:112 (profile update)
// and category_controller.dart:246 (category create/update). Both read
// `response.statusCode` themselves, which means each one is a SECOND,
// hand-written copy of the table above -- and a copy is where drift happens.
//
// It had already happened. Both handled 401 and 429 and NEITHER handled 403,
// so a policy denial -- the thing repo A's new Gate and Policy layer actually
// answers with -- fell through to the `else` branch. In category_controller
// that `else` shows `response.reasonPhrase`, i.e. the literal untranslated
// string "Forbidden", to a merchant using an Arabic UI. The security property
// held (no logout), the merchant's experience did not.
//
// So this file does not check that the two sites are correct line by line. It
// checks the thing that makes them go wrong: that every site handling any one
// of the three handles all three, and that none of them routes 403 or 429 into
// the forced logout.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  late Map<String, String> sources;

  setUpAll(() {
    sources = {
      for (final f in libDartFiles())
        relative(f): commentsStripped(f.readAsStringSync()),
    };
  });

  /// Files that read a status code themselves, i.e. that do NOT delegate the
  /// decision to NetworkHttps.
  List<String> handRolledSites() {
    final sites = <String>[];

    sources.forEach((path, source) {
      if (path == 'lib/network/network.dart') return;

      if (RegExp(r'statusCode\s*==\s*(401|403|429)').hasMatch(source)) {
        sites.add(path);
      }
    });

    sites.sort();
    return sites;
  }

  group('every hand-rolled status handler covers all three codes', () {
    test('the sites are the two that cannot use the network layer', () {
      // Pinned, so a THIRD hand-rolled site has to come through this file and
      // its author has to see the table above. The right answer for a new one
      // is almost always to use a NetworkHttps verb instead.
      expect(
        handRolledSites(),
        const <String>[
          'lib/core/controller/home_controller/category_controller.dart',
          'lib/core/controller/profile_controller/profile_controller.dart',
        ],
        reason: 'A new call site is handling HTTP status codes by hand. Use a '
            'NetworkHttps verb, which classifies them once, or add it here '
            'and give it all three branches.',
      );
    });

    test('each one distinguishes 401, 403 and 429', () {
      final missing = <String>[];

      for (final path in handRolledSites()) {
        final source = sources[path]!;

        for (final code in const ['401', '403', '429']) {
          // Raw string + concatenation. An interpolated non-raw string
          // here turned `\s` into a literal backslash-s and the regex
          // matched nothing, so every site looked like it handled no codes
          // at all -- a detector failing open.
          if (!RegExp(r'statusCode\s*==\s*' + code).hasMatch(source)) {
            missing.add(
              '$path does not handle $code, so it falls to the generic '
              'branch -- which in category_controller means showing the raw '
              'English reason phrase.',
            );
          }
        }
      }

      expect(missing, isEmpty, reason: missing.join('\n'));
    });

    test('403 and 429 are given the translated wording, not a fallthrough',
        () {
      final missing = <String>[];

      for (final path in handRolledSites()) {
        final source = sources[path]!;

        if (!source.contains("'action_not_permitted'.tr")) {
          missing.add('$path: 403 needs action_not_permitted');
        }
        if (!source.contains("'too_many_requests'.tr")) {
          missing.add('$path: 429 needs too_many_requests');
        }
      }

      expect(missing, isEmpty, reason: missing.join('\n'));
    });

    test('and both keys exist in both language maps', () {
      // A `.tr` with no entry renders the KEY. Asserted against the files
      // rather than assumed, because the branch above is the first use of
      // action_not_permitted outside the network layer.
      for (final lang in const ['en', 'ar']) {
        final map = File('${packageRoot().path}/lib/translations/$lang.dart')
            .readAsStringSync();

        for (final key in const [
          'action_not_permitted',
          'too_many_requests',
        ]) {
          expect(
            map.contains("'$key':"),
            isTrue,
            reason: '$key is missing from $lang.dart, so the merchant would '
                'see the raw key.',
          );
        }
      }
    });
  });

  group('only 401 may end the session', () {
    test('no hand-rolled site logs out on 403 or 429', () {
      // forced_logout_test.dart already asserts that every
      // handleUnauthorized() call sits in a 401 branch. This is the same
      // property approached from the other side: the 403 and 429 branches are
      // read directly and must not contain the call, so a refactor that moved
      // the forced logout INTO one of them -- rather than adding a new call
      // outside a 401 branch -- is caught too.
      final offenders = <String>[];

      for (final path in handRolledSites()) {
        final source = sources[path]!;

        for (final code in const ['403', '429']) {
          final at = source.indexOf('statusCode == $code');
          if (at < 0) continue;

          // From the branch condition to the start of the next branch.
          final rest = source.substring(at);
          final end = rest.indexOf('} else');
          final body = end < 0 ? rest : rest.substring(0, end);

          if (body.contains('handleUnauthorized')) {
            offenders.add(
              '$path routes $code into the forced logout. $code means the '
              'session is VALID.',
            );
          }
        }
      }

      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test('and each one does log out on 401', () {
      // The positive half. If this is empty the sites stopped handling an
      // expired session at all, which leaves a dead token in local storage --
      // and the test above would pass for the wrong reason.
      for (final path in handRolledSites()) {
        final source = sources[path]!;
        final at = source.indexOf('statusCode == 401');

        expect(at, greaterThanOrEqualTo(0), reason: path);

        final rest = source.substring(at);
        final end = rest.indexOf('} else');
        final body = end < 0 ? rest : rest.substring(0, end);

        expect(
          body.contains('NetworkHttps.handleUnauthorized'),
          isTrue,
          reason: '$path must share the one forced-logout path, which is '
              'latched against concurrent 401s (network.dart:485-511).',
        );
      }
    });
  });

  group('the detector is not vacuous', () {
    test('it finds a hand-rolled check and ignores a delegated one', () {
      expect(
        RegExp(r'statusCode\s*==\s*(401|403|429)')
            .hasMatch('if (response.statusCode == 403) {'),
        isTrue,
      );
      expect(
        RegExp(r'statusCode\s*==\s*(401|403|429)')
            .hasMatch('if (response.statusCode==429){'),
        isTrue,
      );

      // A controller that lets the network layer classify, which is what the
      // other ~40 of them do, must not be dragged in.
      expect(
        RegExp(r'statusCode\s*==\s*(401|403|429)').hasMatch(
          'response.fold(onSuccess: (d) {}, onFailure: (r, m, e) {});',
        ),
        isFalse,
      );

      // And a 200 check is not a hand-rolled ERROR classification.
      expect(
        RegExp(r'statusCode\s*==\s*(401|403|429)')
            .hasMatch('if (response.statusCode == 200) {'),
        isFalse,
      );
    });
  });
}

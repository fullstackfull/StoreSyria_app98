// Guard tests for SEC-20a / R7-02, SEC-20b / R7-03 and SEC-20c / R7-04.
//
// These three findings were all the same mistake made in four places: a
// debugging line that happened to sit on a credential path and was never taken
// out. The merchant's plaintext password went to the device log on every login,
// the bearer token went there on every cold start, and the network layer logged
// every full response body — including the login response the token comes from.
//
// WHY THIS TEST IS SOURCE-LEVEL. The behavioural question — does a credential
// actually reach logcat on a release build? — needs a physical device and a
// signed APK. The question that regresses in review, though, is "did somebody
// add a print back?", and that is decidable from the sources. This test is
// cheap, has no device dependency, and fails in the pull request that
// reintroduces the defect rather than in an incident.
//
// IT MUST STAY PAIRED WITH ENABLING CRASHLYTICS. Crashlytics uploads recent log
// output as crash breadcrumbs, so turning it on while any of this can leak
// would convert a local-access problem into a third-party data-processing
// problem with a retention period. Do not enable
// `firebase_crashlytics_collection_enabled` while this test is red.

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  group('no credential logging in lib/', () {
    test('no bare print( anywhere under lib/', () {
      final offenders = <String>[];

      for (final file in libDartFiles()) {
        final hits = matchingLines(file.readAsStringSync(), 'print(');
        for (final line in hits) {
          // debugPrint is a Flutter framework call and is itself a no-op in
          // release; it is not what this finding was about.
          offenders.add('${relative(file)}:$line');
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'Bare print() writes to the device log in RELEASE builds. Use '
            'AppLog (lib/utils/app_log.dart), which is inert when '
            'kReleaseMode is true and redacts tokens. Offending sites:\n'
            '${offenders.join('\n')}',
      );
    });

    test('no log call takes a credential-bearing expression', () {
      // The forbidden expressions. `Prefs.getToken()` is listed EXPLICITLY
      // because main.dart's `print("hi $token")` read the token through it —
      // a check that only looked for the word "password" would have missed the
      // most trivially greppable leak in the repository.
      final forbidden = <RegExp>[
        RegExp(r'password', caseSensitive: false),
        RegExp(r'Prefs\.getToken\(\)'),
        RegExp(r'response\.body'),
        RegExp(r'responseData'),
        RegExp(r'\bjson\.encode\(\s*data\s*\)'),
      ];

      // A log call plus the rest of its (single-line) argument list.
      final logCall = RegExp(
        r'(?:AppLog\.[a-z]+|print|debugPrint|developer\.log|\blog)\(([^;]*)',
      );

      final offenders = <String>[];

      for (final file in libDartFiles()) {
        final code = codeOnly(file.readAsStringSync());
        final lines = code.split('\n');

        for (var i = 0; i < lines.length; i++) {
          for (final call in logCall.allMatches(lines[i])) {
            final args = call.group(1) ?? '';

            // A redacted token is the whole point of the seam, so an argument
            // that routes through AppLog.redact is fine.
            final redactedArgs = args.replaceAll(
              RegExp(r'AppLog\.redact\([^)]*\)'),
              'REDACTED',
            );

            for (final pattern in forbidden) {
              if (pattern.hasMatch(redactedArgs)) {
                offenders.add(
                  '${relative(file)}:${i + 1}  matches ${pattern.pattern}'
                  '  ->  ${lines[i].trim()}',
                );
              }
            }
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'A credential or a whole response body must never be passed to a '
            'log call, at ANY level — not even in debug, because Crashlytics '
            'breadcrumbs and adb logcat do not care which level it was. '
            'Offending sites:\n${offenders.join('\n')}',
      );
    });

    test('the logging seam is guarded by kReleaseMode', () {
      final seam = libDartFiles().singleWhere(
        (f) => relative(f) == 'lib/utils/app_log.dart',
        orElse: () => throw StateError('lib/utils/app_log.dart is missing'),
      );

      final code = codeOnly(seam.readAsStringSync());

      expect(
        code,
        contains('kReleaseMode'),
        reason: 'AppLog must consult kReleaseMode, or none of this holds.',
      );

      expect(
        code,
        contains('Level.off'),
        reason:
            'The underlying logger must be switched off in release, not merely '
            'filtered, so no sink can be reached.',
      );
    });
  });
}

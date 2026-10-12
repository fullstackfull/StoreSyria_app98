// Guard test for SEC-21 / R7-01 — the Android release buildType must never be
// signed with the debug keystore again.
//
// WHAT THIS TEST CAN AND CANNOT PROVE. It proves things about the build
// configuration: that no debug signing config is referenced, that the real one
// is loaded from an untracked properties file, and that a missing key aborts
// the build. It CANNOT prove the shipped artifact's signer, because that needs
// a built APK. The authoritative check is, in CI or by hand:
//
//   apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
//
// and the certificate subject must not be `CN=Android Debug, O=Android, C=US`.
// This test is the cheap continuous half; that command is the real half.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  late String gradle;

  setUpAll(() {
    final file = File('${packageRoot().path}/android/app/build.gradle.kts');
    expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
    gradle = file.readAsStringSync();
  });

  group('Android release signing', () {
    test('the release buildType does not reference the debug signing config',
        () {
      // The debug keystore is PUBLIC and identical on every machine, so a
      // debug-signed APK can be re-signed by anyone and accepted by Android as
      // an in-place update -- inheriting the bearer token already on the
      // device. Checked against the whole file, comments included, so even a
      // commented-out example cannot teach it back.
      expect(
        gradle,
        isNot(contains('getByName("debug")')),
        reason: 'The release build must never fall back to the debug keystore.',
      );

      expect(
        gradle,
        isNot(contains('signingConfigs.debug')),
        reason: 'The release build must never fall back to the debug keystore.',
      );
    });

    test('the signing config is loaded from key.properties', () {
      expect(gradle, contains('key.properties'));
      expect(gradle, contains('signingConfigs'));
      expect(gradle, contains('storePassword'));
      expect(gradle, contains('keyAlias'));
      expect(gradle, contains('keyPassword'));
    });

    test('a missing or incomplete key.properties aborts a release build', () {
      // Without this, a missing config yields a QUIETLY UNSIGNED apk, which is
      // a different failure but just as unshippable -- and much easier to miss.
      expect(
        gradle,
        contains('GradleException'),
        reason:
            'A release build without a signing key must fail loudly, not '
            'produce an unsigned artifact.',
      );

      expect(
        gradle,
        contains('taskGraph'),
        reason:
            'The check must run against the resolved task graph, so that debug '
            'builds and IDE sync still work on a machine with no keystore.',
      );
    });

    test('code shrinking stays off, deliberately', () {
      // Flutter compiles Dart to AOT machine code, so R8 only touches the thin
      // Kotlin shim: the benefit is APK size, not security, while R8 without
      // correct keep-rules is a known cause of release-only crashes in
      // Firebase and other reflection-using plugins. If a future change turns
      // this on, it should be a deliberate decision that updates this test.
      expect(gradle, contains('isMinifyEnabled = false'));
    });

    test('key.properties is gitignored and no keystore is tracked', () {
      final root = packageRoot().path;

      final ignores = <String>[
        File('$root/.gitignore').existsSync()
            ? File('$root/.gitignore').readAsStringSync()
            : '',
        File('$root/android/.gitignore').existsSync()
            ? File('$root/android/.gitignore').readAsStringSync()
            : '',
      ].join('\n');

      expect(
        ignores,
        contains('key.properties'),
        reason:
            'android/key.properties holds the keystore passwords and must be '
            'ignored by git.',
      );

      expect(
        RegExp(r'\*\.(keystore|jks)').hasMatch(ignores),
        isTrue,
        reason: 'Keystore files must be ignored by git.',
      );

      final tracked = Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              !f.path.contains('/build/') &&
              !f.path.contains('/.git/') &&
              (f.path.endsWith('.jks') ||
                  f.path.endsWith('.keystore') ||
                  f.path.endsWith('/key.properties')))
          .map((f) => f.path)
          .toList();

      expect(
        tracked,
        isEmpty,
        reason:
            'A keystore or key.properties is present in the working tree. '
            'Neither may ever be committed. Found: $tracked',
      );
    });

    test('git itself ignores the secret paths', () {
      // The test above reads .gitignore as text and asserts a pattern string
      // is present. That proves the file says the right thing, not that git
      // acts on it: a later negation rule, a nested .gitignore, or a path
      // already in the index would all leave the pattern in place and the file
      // committable anyway. So ask git.
      final root = packageRoot().path;

      final probe = Process.runSync(
        'git',
        [
          '-C',
          root,
          'check-ignore',
          'android/key.properties',
          'android/app/storesyria-release.jks',
          'android/app/upload.keystore',
        ],
      );

      if (probe.exitCode == 128) {
        // Not a git work tree (an exported tarball, say). Nothing to assert.
        markTestSkipped('not a git work tree');
        return;
      }

      final ignored = (probe.stdout as String)
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toSet();

      expect(
        ignored,
        containsAll(<String>[
          'android/key.properties',
          'android/app/storesyria-release.jks',
          'android/app/upload.keystore',
        ]),
        reason:
            'git check-ignore did not ignore every secret path. '
            'Ignored: $ignored',
      );
    });

    test('no keystore or key.properties is in the git index', () {
      final root = packageRoot().path;

      final listing = Process.runSync(
        'git',
        ['-C', root, 'ls-files'],
      );

      if (listing.exitCode == 128) {
        markTestSkipped('not a git work tree');
        return;
      }

      final offenders = (listing.stdout as String)
          .split('\n')
          .map((l) => l.trim())
          .where((l) =>
              l.endsWith('.jks') ||
              l.endsWith('.keystore') ||
              l.endsWith('key.properties'))
          .toList();

      expect(
        offenders,
        isEmpty,
        reason:
            'These are tracked by git and must never be: $offenders. '
            'Note key.properties.example is a template and is allowed; '
            'key.properties itself is not.',
      );
    });

    test('the tracked template carries no real credential', () {
      final example =
          File('${packageRoot().path}/android/key.properties.example');

      expect(
        example.existsSync(),
        isTrue,
        reason:
            'android/key.properties.example documents what the owner must '
            'supply.',
      );

      final text = example.readAsStringSync();

      // The template must stay a template. Placeholders only.
      // Dart's RegExp (RE2-style) has no inline (?m) flag; multiline is a
      // named constructor argument. An inline flag group throws
      // FormatException: Invalid group at construction time.
      final storePassword = RegExp(r'^storePassword=(.*)$', multiLine: true)
          .firstMatch(text)
          ?.group(1)
          ?.trim();
      final keyPassword = RegExp(r'^keyPassword=(.*)$', multiLine: true)
          .firstMatch(text)
          ?.group(1)
          ?.trim();

      for (final value in <String?>[storePassword, keyPassword]) {
        expect(value, isNotNull);
        expect(
          value,
          'CHANGE_ME',
          reason:
              'The tracked example file must contain placeholders, never a '
              'real password. Real values belong in android/key.properties, '
              'which is gitignored.',
        );
      }
    });
  });
}

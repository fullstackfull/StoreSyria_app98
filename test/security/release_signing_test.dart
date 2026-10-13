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

      // WORKING-TREE SCAN, CORRECTED.
      //
      // This previously asserted that no file named key.properties, *.jks or
      // *.keystore EXISTS ON DISK. That conflates "present" with "committed" --
      // two different properties, and only one of them is a defect. It therefore
      // failed the moment the owner followed this branch's OWN runbook:
      // android/RELEASE_SIGNING.md:47 instructs them to create
      // android/key.properties and fill in the real keystore passwords. A
      // developer who cannot build a signed release without that file was being
      // told by the test suite that having it is a security violation.
      //
      // The property that actually matters is that such a file is IGNORED by git,
      // so it cannot be committed by accident. That is asserted here against git
      // itself, for whatever files are genuinely present -- which is strictly
      // stronger than forbidding their existence, and does not punish the
      // documented setup.
      final present = Directory(root)
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

      final committable = <String>[];

      for (final path in present) {
        final check = Process.runSync(
          'git',
          ['-C', root, 'check-ignore', '--quiet', path],
        );

        // 0 = ignored, 1 = NOT ignored, 128 = not a work tree.
        if (check.exitCode == 128) {
          markTestSkipped('not a git work tree');
          return;
        }

        if (check.exitCode != 0) {
          committable.add(path);
        }
      }

      expect(
        committable,
        isEmpty,
        reason:
            'A keystore or key.properties is present in the working tree and is '
            'NOT ignored by git, so it can be committed by accident. Either add '
            'it to .gitignore or move it out of the tree. Found: $committable',
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

  // ---------------------------------------------------------------------------
  group('the release abort covers every way a release is packaged', () {
    // CANNOT BE EXECUTED HERE, and is not claimed to be. There is no Android
    // SDK, no Gradle run and no device in this environment, so the guard is
    // read, not run; apksigner cannot be invoked and no built artifact is
    // verified by anything in this file. The authoritative check stays
    //
    //   apksigner verify --print-certs \
    //     build/app/outputs/flutter-apk/app-release.apk
    //
    // with a certificate subject that must not be
    // `CN=Android Debug, O=Android, C=US`.
    //
    // WHAT CAN STILL BE CHECKED, AND WHY IT IS WORTH CHECKING. The guard fires
    // only for task names it recognises as release packaging
    // (build.gradle.kts:156-180). Nothing asserted WHICH names those are, and
    // the existing coverage stops at `contains('taskGraph')`. Drop one prefix
    // and the guard still looks present, still compiles, and still passes
    // every other test in this file -- while the command it no longer covers
    // produces an unsigned artifact in silence.
    //
    // `bundle` is the one that matters most: `flutter build appbundle` runs
    // bundleRelease, and an App Bundle is what goes to the Play Store. An
    // unsigned or debug-signed AAB is rejected at upload at best, and at worst
    // a debug-signed APK is installable as an in-place update by anyone,
    // inheriting the bearer token already on the device -- which is the whole
    // reason SEC-21 / R7-01 exists.

    test('all four release packaging prefixes are matched', () {
      for (final prefix in const [
        'assemble', // flutter build apk
        'bundle', // flutter build appbundle  <- the Play Store path
        'package', // the packaging task itself
        'install', // flutter install --release
      ]) {
        expect(
          gradle,
          contains('name.startsWith("$prefix")'),
          reason: 'The release abort no longer covers $prefix*Release tasks, '
              'so that command can produce an unsigned artifact without '
              'failing.',
        );
      }
    });

    test('and it keys on Release, so debug builds still work', () {
      // The other half of the same property: a guard that fired for every
      // task would break `flutter run`, `flutter test` and IDE sync on any
      // machine without a keystore -- which is every developer machine and
      // every CI runner here. A broken debug build gets the guard deleted.
      expect(gradle, contains('name.contains("Release")'));
      expect(
        gradle,
        contains('if (hasReleaseSigning) return@whenReady'),
        reason: 'A correctly configured release machine must not be blocked '
            'by the guard meant for an unconfigured one.',
      );
    });

    test('a release signing config is only built from a real keystore', () {
      // `hasReleaseSigning` is the single predicate the signingConfig, the
      // buildType wiring and the abort all read, so what it requires is the
      // whole precondition. All four parts are asserted, because dropping the
      // keystoreFile.exists() check alone would let a key.properties pointing
      // at a missing keystore satisfy it.
      expect(gradle, contains('keystorePropertiesFile.exists()'));
      expect(gradle, contains('missingKeystoreKeys.isEmpty()'));
      expect(gradle, contains('keystoreFile != null'));
      expect(gradle, contains('keystoreFile.exists()'));

      // And the config is created inside that condition, not unconditionally.
      final configAt = gradle.indexOf('create("release")');
      expect(configAt, greaterThan(0));

      final before = gradle.substring(0, configAt);
      expect(
        before.lastIndexOf('if (hasReleaseSigning)'),
        greaterThan(before.lastIndexOf('signingConfigs {')),
        reason: 'The release signingConfig must be created only when a '
            'complete key.properties and a real keystore are both present.',
      );
    });

    test('every required key.properties field is demanded', () {
      // A missing keyPassword would otherwise be filled in from storePassword
      // by some tooling, or left blank, and the build would sign with
      // something nobody chose.
      for (final key in const [
        'storeFile',
        'storePassword',
        'keyAlias',
        'keyPassword',
      ]) {
        expect(gradle, contains('"$key"'), reason: '$key is no longer '
            'required by the signing precondition.');
      }
    });

    test('no keystore path is hard-coded in the build file', () {
      // storeFile must come from key.properties, which is gitignored. A path
      // written into build.gradle.kts would mean a keystore living at a fixed
      // place in the tree, which is how one gets committed.
      final hardCoded = RegExp(
        r'storeFile\s*=\s*(file\(|rootProject\.file\()?["\x27]',
      );

      expect(
        hardCoded.hasMatch(gradle),
        isFalse,
        reason: 'storeFile must be read from key.properties, never written '
            'into the build file.',
      );

      expect(gradle, contains('keystoreProperties.getProperty("storePassword")'));
    });

    test('the hard-coded-path detector finds one when it is there', () {
      final hardCoded = RegExp(
        r'storeFile\s*=\s*(file\(|rootProject\.file\()?["\x27]',
      );

      for (final sample in const [
        'storeFile = file("../app/release.keystore")',
        "storeFile = rootProject.file('upload.jks')",
        'storeFile = "/Users/dev/release.jks"',
      ]) {
        expect(hardCoded.hasMatch(sample), isTrue, reason: sample);
      }

      // The real line must not match: it reads from the properties object.
      expect(hardCoded.hasMatch('storeFile = keystoreFile'), isFalse);
    });
  });
}

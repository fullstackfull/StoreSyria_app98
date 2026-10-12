// Release-posture guards that need no keystore and no built artifact.
//
// test/security/release_signing_test.dart already covers the SIGNING config.
// This file covers the rest of the release posture that is decidable from the
// manifest, and it exists because of one finding in particular.
//
// R7-N7 -- THE APP DATA DIRECTORY WAS BACKUP-ELIGIBLE. `android:allowBackup`
// was not set in any manifest under android/ (verified: no allowBackup,
// usesCleartextTraffic, debuggable, networkSecurityConfig,
// dataExtractionRules or fullBackupContent attribute existed anywhere in the
// tree). Android DEFAULTS allowBackup TO TRUE, so the default was in force.
//
// That matters here more than it would in most apps. The bearer token is kept
// by GetStorage in an unencrypted JSON container inside the app's documents
// directory -- see the header of token_storage_test.dart, which records that
// as an open finding. Unencrypted AND backup-eligible together mean the token
// can leave the device without root: through `adb backup` on devices where it
// still works, and through Android's own cloud auto-backup. Either produces a
// copy of a live merchant credential outside the phone.
//
// Disabling backup is the conservative fix: this is a merchant admin client
// whose local state is a cache plus a credential, so there is nothing here
// worth restoring and a credential that must not be copied.
//
// WHAT THIS FILE STILL CANNOT PROVE. It reads the manifest SOURCES. The
// manifest the APK actually ships is the merge of these with every plugin's
// manifest, and a library can in principle contribute an attribute. Asserting
// the merged result needs a built artifact:
//
//   flutter build apk --release
//   aapt2 dump xmltree build/app/outputs/flutter-apk/app-release.apk \
//     --file AndroidManifest.xml
//
// which needs real signing material (build.gradle.kts aborts a release build
// without android/key.properties, deliberately). That command is the
// authoritative half; this is the cheap continuous half.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  late String mainManifest;
  late Map<String, String> allManifests;

  setUpAll(() {
    final root = packageRoot().path;

    final main = File('$root/android/app/src/main/AndroidManifest.xml');
    expect(main.existsSync(), isTrue, reason: '${main.path} is missing');
    mainManifest = main.readAsStringSync();

    allManifests = <String, String>{};
    for (final file in Directory('$root/android')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('AndroidManifest.xml'))) {
      allManifests[relative(file)] = file.readAsStringSync();
    }

    // Guards against a glob that silently found nothing.
    expect(allManifests.length, greaterThanOrEqualTo(3));
  });

  group('the app data directory is not backup-eligible', () {
    test('allowBackup is explicitly false, not merely unset', () {
      // Unset means TRUE on Android, which is how this was missed: there was
      // nothing to grep for.
      expect(
        mainManifest,
        contains('android:allowBackup="false"'),
        reason: 'The GetStorage container holds the bearer token in '
            'cleartext. With backup enabled, `adb backup` and Android cloud '
            'auto-backup can both copy a live merchant credential off the '
            'device.',
      );
    });

    test('no manifest re-enables backup', () {
      // The manifest merger takes the highest-priority value, so a debug or
      // profile manifest setting it true would win for those builds.
      allManifests.forEach((path, source) {
        expect(
          source,
          isNot(contains('android:allowBackup="true"')),
          reason: '$path re-enables backup of the app data directory.',
        );
      });
    });

    test('fullBackupContent is false for the pre-31 backup path', () {
      // allowBackup governs API 31+; fullBackupContent is what older devices
      // consult, and a large share of this app's install base is older.
      expect(mainManifest, contains('android:fullBackupContent="false"'));
    });
  });

  group('no manifest weakens transport security', () {
    test('cleartext traffic is never explicitly allowed', () {
      // API 28+ defaults this to false, so the risk is someone turning it ON
      // to debug against a local server and leaving it in. The base URL is
      // https (pinned in test/contract/endpoint_contract_test.dart); a
      // cleartext allowance would let the bearer token be read off the wire.
      allManifests.forEach((path, source) {
        expect(
          source,
          isNot(contains('android:usesCleartextTraffic="true"')),
          reason: '$path allows cleartext HTTP.',
        );
      });
    });

    test('no network security config is silently introduced', () {
      // A networkSecurityConfig resource can permit cleartext per-domain, or
      // trust user-installed CAs, without any attribute above changing. If one
      // is ever added deliberately, this test should be updated to assert its
      // CONTENTS rather than deleted.
      allManifests.forEach((path, source) {
        expect(
          source,
          isNot(contains('android:networkSecurityConfig')),
          reason: '$path introduces a network security config. Review it for '
              'cleartext permits and user-CA trust, then pin its contents '
              'here.',
        );
      });
    });
  });

  group('no manifest ships a debuggable application', () {
    test('android:debuggable is never set to true', () {
      // A debuggable release build lets any process on the device attach to
      // the app and read its memory, which includes the bearer token.
      // Normally gradle controls this, so an explicit attribute is the way it
      // goes wrong.
      allManifests.forEach((path, source) {
        expect(
          source,
          isNot(contains('android:debuggable="true"')),
          reason: '$path marks the application debuggable.',
        );
      });
    });
  });

  group('crash reporting stays off while it is not wanted', () {
    test('Crashlytics collection is explicitly disabled', () {
      // Pinned because it is a DELIBERATE state, not an accident. Crashlytics
      // uploads recent log output as crash breadcrumbs, which is the ordering
      // dependency recorded in app_log.dart's header: it must not be switched
      // on casually. AppLog now redacts and is inert in release, so this can
      // be revisited -- but it should be revisited on purpose, by editing this
      // test, rather than flipped by someone passing through.
      expect(
        mainManifest,
        contains('firebase_crashlytics_collection_enabled'),
        reason: 'The flag was removed; collection then follows the Firebase '
            'default, which is enabled.',
      );

      final index =
          mainManifest.indexOf('firebase_crashlytics_collection_enabled');
      final window = mainManifest.substring(
        index,
        (index + 200).clamp(0, mainManifest.length),
      );

      expect(
        window,
        contains('android:value="false"'),
        reason: 'The Crashlytics collection flag is no longer false.',
      );
    });
  });
}

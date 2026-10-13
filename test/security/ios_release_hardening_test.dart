// Release-configuration guards for iOS, which had NONE.
//
// `test/security/release_hardening_test.dart` covers the Android manifest:
// backup eligibility, cleartext traffic, a network security config, the
// debuggable flag, Crashlytics. Measured before this file existed: `grep -rln
// 'ios/' test/` returned nothing, so every one of those properties was
// unguarded on the other platform the app ships to.
//
// WHAT THIS CAN AND CANNOT PROVE. These are properties of committed
// configuration, which is decidable here. It cannot prove anything about a
// built .ipa or its signer: that needs macOS, Xcode and real Apple signing
// material, and the authoritative check is
//
//   codesign -dvvv --entitlements :- Runner.app
//
// whose Authority chain must name a distribution certificate. See the
// release-readiness note; that half is not verifiable in this environment and
// is not claimed.
//
// ONE OBSERVATION RECORDED RATHER THAN ASSERTED. All three iOS build
// configurations carry
// `"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer"`
// (ios/Runner.xcodeproj/project.pbxproj:339, :459, :516 -- the last of which
// is in the Release configuration ending at :539). That reads like the
// Android debug-keystore defect, and it is NOT asserted against here, for two
// reasons: it is the stock value in Flutter's own iOS template, and
// `CODE_SIGN_STYLE = Automatic` (:387, :404, :419) means Xcode resolves the
// actual identity at build time from the signing team. Changing it needs a
// Mac and a real Apple developer account to verify, and a wrong change breaks
// the iOS build outright. It is reported, not guessed at.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  late String plist;

  setUpAll(() {
    final file = File('${packageRoot().path}/ios/Runner/Info.plist');
    expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
    plist = file.readAsStringSync();
  });

  /// Whether [key] appears as a `<key>` element in the plist.
  bool hasKey(String key) => plist.contains('<key>$key</key>');

  /// The literal text following `<key>[key]</key>`, up to the next `<key>`.
  /// Good enough to tell `<true/>` from `<false/>`, which is all that is
  /// asked below.
  String valueAfter(String key) {
    final marker = '<key>$key</key>';
    final start = plist.indexOf(marker);
    if (start < 0) return '';
    final rest = plist.substring(start + marker.length);
    final next = rest.indexOf('<key>');
    return next < 0 ? rest : rest.substring(0, next);
  }

  group('App Transport Security is not weakened', () {
    test('the plist does not declare NSAppTransportSecurity at all', () {
      // The iOS counterpart of the Android `usesCleartextTraffic` guard. With
      // no NSAppTransportSecurity dictionary, ATS is at its secure default:
      // https only, TLS 1.2 minimum. The app talks to
      // https://storesyria.com/api/admin (lib/utils/base_api.dart), so it has
      // no legitimate need for an exception.
      expect(
        hasKey('NSAppTransportSecurity'),
        isFalse,
        reason: 'An NSAppTransportSecurity dictionary has appeared. If an '
            'exception is genuinely needed it must be domain-scoped and '
            'argued here, never NSAllowsArbitraryLoads.',
      );
    });

    test('arbitrary (cleartext) loads are never allowed', () {
      // Asserted separately from the key above, because the dictionary could
      // be reintroduced for a narrow reason while this specific switch must
      // stay off whatever else changes.
      for (final key in const [
        'NSAllowsArbitraryLoads',
        'NSAllowsArbitraryLoadsInWebContent',
        'NSAllowsArbitraryLoadsForMedia',
        'NSAllowsLocalNetworking',
      ]) {
        expect(
          plist.contains(key),
          isFalse,
          reason: '$key disables ATS and lets the bearer token travel over '
              'plaintext HTTP.',
        );
      }
    });
  });

  group('the token store is not exposed to the Files app or a desktop', () {
    // This is the iOS counterpart of `android:allowBackup="false"`, which was
    // set in an earlier phase precisely because the app data directory holds
    // the token. The same data is exposed on iOS by a different switch, and
    // nothing was asserting it.
    //
    // The chain, each link read rather than assumed:
    //   lib/main.dart:30     `await GetStorage.init();`  -- no path argument
    //   get_storage-2.1.1/lib/src/storage/io.dart:131-144
    //                        with no `path`, the container is
    //                        `getApplicationDocumentsDirectory()`
    //   lib/utils/prefer.dart:48-50
    //                        `getStorage!.read(KEY_TOKEN)` -- the bearer
    //                        token lives in that container
    //
    // On iOS `getApplicationDocumentsDirectory()` IS `<app>/Documents`, and
    // `UIFileSharingEnabled` publishes exactly that directory to the Files app
    // and to a desktop over USB. Turning it on would hand the plaintext
    // GetStorage file -- token included -- to anyone with the unlocked phone
    // or a cable.

    test('UIFileSharingEnabled is not enabled', () {
      if (hasKey('UIFileSharingEnabled')) {
        expect(
          valueAfter('UIFileSharingEnabled'),
          contains('<false/>'),
          reason: 'UIFileSharingEnabled publishes <app>/Documents, which is '
              'the GetStorage container holding the bearer token.',
        );
      } else {
        // Absent is the secure default, and the state measured today.
        expect(hasKey('UIFileSharingEnabled'), isFalse);
      }
    });

    test('LSSupportsOpeningDocumentsInPlace does not become file sharing', () {
      // `LSSupportsOpeningDocumentsInPlace` IS present today and is NOT the
      // defect: on its own it lets the app open a document the user picks, it
      // does not publish the app's own container. It is named here so a future
      // reader does not mistake one for the other and "fix" the wrong key --
      // the pair of them together is what exposes Documents.
      expect(hasKey('LSSupportsOpeningDocumentsInPlace'), isTrue,
          reason: 'If this key is removed, update this test rather than '
              'deleting it: the property being guarded is the PAIR.');

      final sharingOn = hasKey('UIFileSharingEnabled') &&
          valueAfter('UIFileSharingEnabled').contains('<true/>');

      expect(sharingOn, isFalse);
    });
  });

  group('no iOS signing material is carried by git', () {
    // The Android side of this is .github/scripts/check-signing-material.sh,
    // run by the hygiene job. The iOS side had no .gitignore rule at all:
    // `git check-ignore ios/Runner/dist.mobileprovision` answered NO before
    // this phase, so a provisioning profile or a distribution certificate
    // dropped into the tree was committable. Asserted here as well as in the
    // script so a local `flutter test` catches it without running CI.
    //
    // IGNORED, not absent -- the distinction that already broke one test in
    // this repository: a release engineer's machine legitimately holds these
    // files (android/RELEASE_SIGNING.md:47 for the Android analogue).

    test('git ignores the iOS signing paths', () {
      final root = packageRoot().path;

      const paths = <String>[
        'ios/Runner/dist.mobileprovision',
        'ios/Runner/dist.cer',
        'ios/certs/dist.pfx',
        'ios/Runner/dummy.p12',
      ];

      final notIgnored = <String>[];

      for (final path in paths) {
        final probe = Process.runSync(
          'git',
          ['-C', root, 'check-ignore', '--quiet', path],
        );

        if (probe.exitCode == 128) {
          markTestSkipped('not a git work tree');
          return;
        }
        if (probe.exitCode != 0) notIgnored.add(path);
      }

      expect(
        notIgnored,
        isEmpty,
        reason: 'git does not ignore these iOS signing paths, so they can be '
            'committed by accident: $notIgnored',
      );
    });

    test('no iOS signing material is in the index', () {
      final root = packageRoot().path;

      final probe = Process.runSync(
        'git',
        [
          '-C',
          root,
          'ls-files',
          '--',
          '*.mobileprovision',
          '*.cer',
          '*.p12',
          '*.pfx',
          'ios/**/*.pem',
        ],
      );

      if (probe.exitCode == 128) {
        markTestSkipped('not a git work tree');
        return;
      }

      expect(
        (probe.stdout as String).trim(),
        isEmpty,
        reason: 'iOS signing material is tracked by git. Removing it from HEAD '
            'is not a fix -- the object stays reachable in the pack and the '
            'certificate must be revoked.',
      );
    });
  });
}

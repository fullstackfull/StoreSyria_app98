// What a FORCED logout destroys, and what it must not.
//
// network.dart maps any 401 to Prefs.clear() + Get.offAll(login)
// (network.dart:317-329, 485-511), and the server returns 403 rather than 401
// for an authorization denial precisely so that a denied action cannot log a
// merchant out. status_code_classification_test.dart already pins that
// distinction at the status-code level: 401 calls the forced-logout action,
// and no other code does.
//
// This file covers the OTHER half of the audit -- not "what triggers a
// logout" but "what a logout takes with it". Prefs.clear() was
// `getStorage.erase()`, and the container it erases holds two keys that are
// not session state:
//
//   * `language`, whose getter defaults to 'ar' (prefer.dart:115-117), so an
//     English-speaking merchant came back to an Arabic UI after any session
//     expiry;
//   * `onboarding_completed`, which welcome_screen.dart:68-73 tests BEFORE
//     the token, so an expired session replayed the onboarding tour instead
//     of showing the login screen.
//
// Both are reached by a mere session expiry -- no bad input, no attacker, no
// unusual device. The tests below execute the real Prefs and the real
// OnboardingController getter that welcome_screen reads.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/prefer.dart';

import '../support/source_tree.dart';

void main() {
  late Directory storageDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    storageDir = Directory.systemTemp.createTempSync('store_go_logout_test');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDir.path,
    );

    await GetStorage.init();
    app.getStorage = GetStorage();
  });

  tearDownAll(() {
    // See nested_api_read_test.dart: this delete can lose a race with GetStorage's
    // background flush and fail with errno 39 even with recursive: true.
    try {
      if (storageDir.existsSync()) storageDir.deleteSync(recursive: true);
    } catch (_) {
      // Intentionally ignored.
    }
  });

  setUp(() async {
    await Prefs.clear();
    await Prefs.remove(Prefs.LANGUAGE);
    await Prefs.remove(Prefs.onboardingKey);
  });

  group('a forced logout destroys the session', () {
    test('the token, user id and store id are gone', () async {
      Prefs.setToken('1|abcdefGHIJKL0123456789');
      Prefs.setUserID('7');
      Prefs.setStoreID('99');

      await Prefs.clear();

      expect(Prefs.getToken(), '');
      expect(Prefs.getUserID(), '');
      expect(Prefs.getStoreID(), '');
    });

    test('the device identifiers are gone too', () async {
      Prefs.setFcmToken('fcm-abc');
      Prefs.setDeviceId('dev-abc');

      await Prefs.clear();

      expect(Prefs.getFcmToken(), '');
      expect(Prefs.getDeviceId(), '');
    });

    test('a key nobody allowlisted is erased by default', () async {
      // The allowlist has to be the safe direction: a key added to Prefs next
      // year must be erased unless someone thought about it. If this ever
      // fails, clear() has become a denylist.
      Prefs.setString('some_future_cached_thing', 'merchant-scoped');

      await Prefs.clear();

      expect(Prefs.getString('some_future_cached_thing'), '');
    });

    test('the next request built afterwards carries no credential', () async {
      Prefs.setToken('1|abcdefGHIJKL0123456789');
      expect(NetworkHttps.authHeaders()['authorization'], isNotNull);

      await Prefs.clear();

      expect(
        NetworkHttps.authHeaders().containsKey('authorization'),
        isFalse,
        reason: 'A cleared session must not keep presenting the old token.',
      );
    });
  });

  group('a forced logout keeps what is not session state', () {
    test('the chosen language survives', () async {
      Prefs.setLanguage('en');
      Prefs.setToken('1|abcdefGHIJKL0123456789');

      await Prefs.clear();

      expect(
        Prefs.getLanguage(),
        'en',
        reason: 'A session expiry must not silently switch the UI language.',
      );
      expect(Prefs.getToken(), '');
    });

    test('a language that was never chosen still defaults to ar', () async {
      // The preserve step must not invent a value: an untouched install keeps
      // the documented default.
      await Prefs.clear();

      expect(Prefs.getLanguage(), 'ar');
    });

    test('completed onboarding is not replayed', () async {
      Prefs.setBool(Prefs.onboardingKey, true);
      Prefs.setToken('1|abcdefGHIJKL0123456789');

      await Prefs.clear();

      expect(Prefs.getBool(Prefs.onboardingKey), isTrue);
    });

    test(
      'the getter welcome_screen actually reads still says completed',
      () async {
        // welcome_screen.dart:61 asks OnboardingController, not Prefs, so the
        // assertion goes through the same getter the routing decision uses.
        // With this false, welcome_screen routes to '/onboarding' and the
        // merchant never reaches the login screen.
        final onboarding = OnboardingController();
        onboarding.completeOnboarding();

        expect(onboarding.isOnboardingCompleted, isTrue);

        await Prefs.clear();

        expect(
          onboarding.isOnboardingCompleted,
          isTrue,
          reason: 'A session expiry must land on /login, not /onboarding.',
        );
      },
    );

    test('an install that never finished onboarding still has not', () async {
      final onboarding = OnboardingController();

      await Prefs.clear();

      expect(onboarding.isOnboardingCompleted, isFalse);
    });
  });

  group('the clear path has no bypass', () {
    test('only Prefs erases the storage container', () {
      // A controller holding its own `GetStorage()` handle gets the SAME
      // default container (store_setting_controller.dart:17 does exactly
      // this), so an erase() anywhere else would wipe the allowlist too and
      // nothing would point at it.
      final offenders = <String>[];

      for (final file in libDartFiles()) {
        final path = relative(file);
        if (path == 'lib/utils/prefer.dart') continue;

        final lines = codeOnly(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('.erase()')) {
            offenders.add('$path:${i + 1}:${lines[i].trim()}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Clear the session through Prefs.clear(), which keeps the '
            'language and the onboarding flag.\n${offenders.join('\n')}',
      );
    });

    test('every forced-logout call sits in a 401 branch', () {
      // A 403 reaching handleUnauthorized would log the merchant out for a
      // denied action, which is the whole reason the server answers 403 and
      // not 401. Two call sites outside the network layer hand-roll their
      // status handling (profile_controller and category_controller use
      // http.MultipartRequest directly), so this is checked structurally
      // rather than assumed.
      final callSites = <String>[];
      final bad = <String>[];

      for (final file in libDartFiles()) {
        final path = relative(file);
        if (path == 'lib/network/network.dart') continue;

        final lines = codeOnly(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (!lines[i].contains('handleUnauthorized(')) continue;

          callSites.add('$path:${i + 1}');

          // Walk back to the nearest enclosing condition.
          var guard = '';
          for (var j = i; j >= 0 && j > i - 12; j--) {
            if (lines[j].contains('if (') || lines[j].contains('if(')) {
              guard = lines[j];
              break;
            }
          }

          if (!guard.contains('401')) {
            bad.add('$path:${i + 1} guarded by: ${guard.trim()}');
          }
        }
      }

      expect(
        callSites,
        isNotEmpty,
        reason: 'The hand-rolled multipart call sites must still share the '
            'one forced-logout path. If this is empty, either they stopped '
            'handling 401 at all or this test has gone vacuous.',
      );

      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  });
}

// WS K. A merchant whose account an administrator disabled was told to check
// their password.
//
// `Api\DashboardController::login` refuses a disabled principal with
//
//     Your Account is disable,please contact your Administrator.
//
// (DashboardController.php:918, reached when `is_active == 0`, or
// `is_enable_login == 0`, or the owner's `is_enable_login == 0`). The app threw
// that away and showed `login_failed` — "Login failed. Check your email and
// password" / "فشل تسجيل الدخول. تحقق من البريد الإلكتروني وكلمة المرور".
//
// So the one person who cannot fix this by trying again was told to try again,
// and the instruction that would actually help — contact your administrator —
// was discarded.
//
// ------------------------------------------------------------------------
// WHY THE REFUSAL ARRIVES IN `onSuccess` TERRITORY AT ALL, and why no status
// code is involved: the backend's own comment at DashboardController.php:891-894
// says it keeps `error()`'s default shape — HTTP 200 with `status: 0` — because
// "the shipped app force-clears its session on any 401, and this is a login, so
// the only thing that would change is which message it shows". So the body is
// the only signal, and reading it is the whole fix.
//
// NO 429 BRANCH IS ADDED HERE, deliberately. `throttle:auth` is on the route
// (routes/api.php:134) and surfacing it would mean a hand-rolled status check in
// this file — which `test/security/hand_rolled_status_handling_test.dart` pins
// to exactly two files, requires to handle 401/403/429 together, and requires to
// call `NetworkHttps.handleUnauthorized` in the 401 arm. That last requirement
// would wire the forced logout into the LOGIN screen, which is precisely what
// the backend shaped its refusals to avoid. The 429 gap keeps its existing owner
// at RouteServiceProvider.php:65-67.
//
// ------------------------------------------------------------------------
// THE ONE LITERAL THIS FILE COUPLES TO, STATED RATHER THAN HIDDEN.
//
// `adminlogin` carries only `AdminApiLog` and `throttle:auth` — NO locale
// middleware (routes/api.php:134) — so `__()` resolves against the backend's
// default locale and the message arrives in ENGLISH whatever language the
// merchant uses. `resources/lang/ar.json:689` holds an Arabic translation that
// this endpoint can never emit.
//
// Showing the English string would be accurate and untranslated; showing the
// generic is translated and wrong. So the known literal is MAPPED to an app-side
// key, exactly — `==`, not `contains`. A loose match would also catch a future
// unrelated message containing the word, and a `contains('disable')` sniff in
// particular would silently stop matching the day anyone makes the API
// locale-aware, reverting this fix with no test going red. That is the F265/F274
// shape this project keeps meeting, and the test below is what makes the
// coupling fail loudly instead: it drives the literal.

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/auth/auth_controller.dart';
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';

void main() {
  setUpAll(() => Get.addTranslations({'en': en, 'ar': ar}));
  setUp(() => Get.locale = const Locale('en', 'US'));

  Map<String, dynamic> refusal(String message) => <String, dynamic>{
    'status': 0,
    'message': 'fail',
    'data': <String, dynamic>{'message': message},
  };

  group('a disabled account is told what to do about it', () {
    test('the server literal maps to the translated key', () {
      final shown = loginRefusalMessage(
        refusal('Your Account is disable,please contact your Administrator.'),
      );

      expect(shown, 'account_disabled_contact_admin'.tr);
      expect(
        shown,
        isNot('login_failed'.tr),
        reason:
            'the merchant is still being told to check a password they '
            'cannot fix this with',
      );
      expect(shown.toLowerCase(), contains('administrator'));
    });

    test('and in Arabic, which the endpoint itself can never send', () {
      Get.locale = const Locale('ar', 'SA');

      final shown = loginRefusalMessage(
        refusal('Your Account is disable,please contact your Administrator.'),
      );

      expect(shown, 'account_disabled_contact_admin'.tr);
      expect(
        shown,
        isNot(contains('Administrator')),
        reason:
            'an Arabic merchant is being shown the English server string. '
            'adminlogin has no locale middleware, so mapping it app-side is '
            'the only way they see Arabic.',
      );
    });

    test('THE COUPLING: the literal is matched exactly, not sniffed', () {
      // A message that merely CONTAINS the word must not be mapped — that is
      // the loose-match failure this file exists to avoid.
      expect(
        loginRefusalMessage(refusal('Feature disabled for your plan')),
        'Feature disabled for your plan',
        reason:
            'a substring match would swallow unrelated refusals into the '
            'disabled-account copy',
      );
    });
  });

  group('and loginAuth actually calls it', () {
    // THE MAPPER IS USELESS IF NOTHING CALLS IT, and a mutation proved the
    // tests above could not tell: reverting the call site to `'login_failed'.tr`
    // left every one of them green. This is the same gap that hid an untested
    // claim release on the Laravel side in the same session.
    test('the refusal site passes the decoded body to the mapper', () {
      final source = File(
        'lib/core/controller/auth/auth_controller.dart',
      ).readAsStringSync();

      expect(
        source.contains('loginRefusalMessage(decoded)'),
        isTrue,
        reason:
            'loginAuth no longer routes its refusal through the mapper, so '
            'a disabled merchant is back to being told to check their password',
      );

      // And the generic is no longer passed raw at that site. It still appears
      // INSIDE the mapper as the fallback, which is correct — this checks the
      // call site specifically.
      final refusalBlock = source.substring(
        source.indexOf('if (decoded[\'status\'] == 1'),
      );
      expect(
        refusalBlock.contains("            'login_failed'.tr,"),
        isFalse,
        reason:
            'the refusal site is passing the generic directly again, '
            'bypassing the mapper',
      );
    });
  });

  group('every other refusal', () {
    test('wrong credentials keep the translated generic, which is better copy '
        'than the server string', () {
      expect(
        loginRefusalMessage(refusal('Invalid login details')),
        'login_failed'.tr,
      );
    });

    test('an unknown refusal is SHOWN rather than hidden', () {
      expect(
        loginRefusalMessage(refusal('Your subscription has lapsed')),
        'Your subscription has lapsed',
        reason:
            'hiding a refusal the app does not recognise behind the generic '
            'is how a merchant is left guessing — the server knows something '
            'the app does not, and it should say so',
      );
    });

    test('an empty or absent message falls back to the generic', () {
      // `refusal('')` leaves `data.message` empty, so `apiMessage` falls back
      // to the TOP-LEVEL `message` — which `ApiResponser::error()` defaults to
      // the bare word `fail` (ApiResponser.php:54). The first version of the
      // mapper returned that, which would have shown a merchant a toast
      // reading "fail". This case is why it does not.
      expect(loginRefusalMessage(refusal('')), 'login_failed'.tr);
      expect(
        loginRefusalMessage(<String, dynamic>{'status': 0, 'message': 'fail'}),
        'login_failed'.tr,
        reason: 'the envelope sentinel is reaching the merchant as copy',
      );
      expect(
        loginRefusalMessage(<String, dynamic>{'status': 0}),
        'login_failed'.tr,
      );
      expect(loginRefusalMessage(null), 'login_failed'.tr);
      expect(loginRefusalMessage('not a map'), 'login_failed'.tr);
    });
  });
}

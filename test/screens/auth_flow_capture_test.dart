import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/auth/auth_controller.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';
import 'package:store_go_app/view/screen/auth/login_widget.dart';
import 'package:store_go_app/view/screen/onboarding_screen/onboarding_screen.dart';
import 'package:store_go_app/view/screen/welcome_screen.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-AUTH — the three screens before a merchant is signed in.
/// =================================================================================================
///
/// Splash/Welcome, Onboarding and Login. They are the first thing anyone sees of this product and
/// the only part of it a merchant meets before they have an account, and none of them had a
/// capture.
///
/// THE WELCOME SCREEN NAVIGATES AWAY FROM ITSELF, which makes it the one screen here that cannot
/// simply be pumped and photographed. `_checkAndNavigate` is a `Future.delayed` of **1500 ms**
/// that then calls `Get.offAllNamed` for onboarding, the dashboard or login depending on stored
/// state (`welcome_screen.dart:60`). Pump past that and the capture is of whatever it left for.
/// The test therefore pumps a bounded window that stays INSIDE the delay, and asserts it is still
/// on the welcome screen when the picture is taken — otherwise the evidence would quietly be of a
/// different surface, which is the exact failure the project's capture guards exist to catch.
///
/// None of the three fetches anything, so the stub is here to intercept rather than to answer: if
/// one of them ever starts calling the network on mount, `api.calls` will show it.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);


  /// Stub destinations for the welcome screen's three redirects
  /// (`welcome_screen.dart:69, :71, :73`). Each is a bare `Scaffold` with a key, so a test can
  /// assert WHICH one it landed on without mounting the real screen behind it.
  List<GetPage<dynamic>> redirectTargets() => <GetPage<dynamic>>[
        GetPage(
          name: '/onboarding',
          page: () => const Scaffold(key: Key('stub-onboarding')),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const Scaffold(key: Key('stub-dashboard')),
        ),
        GetPage(
          name: '/login',
          page: () => const Scaffold(key: Key('stub-login')),
        ),
      ];

  for (final combination in kFourCombinations) {
    testWidgets('onboarding renders in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        const OnboardingScreen(),
        api: api,
        combination: combination,
        register: () {
          Get.put(OnboardingController());
        },
      );
      await pumpFrames(tester, frames: 12);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'onboarding threw while rendering in ${combination.name}');

      /// The controller ships its pages as data (`onboarding_controller.dart:17`), so the premise
      /// is that there really are pages to show — a carousel with an empty list renders a blank
      /// screen and photographs as a finished one.
      expect(Get.find<OnboardingController>().onboardingPages, isNotEmpty,
          reason: 'onboarding has no pages, so this capture shows nothing');

      final context = tester.element(find.byType(OnboardingScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'onboarding rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'onboarding rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName('flutter-onboarding', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the onboarding capture is suspiciously small: a blank render');
      }
    });

    testWidgets('login renders in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        NormalLoginWidget(),
        api: api,
        combination: combination,
        register: () {
          Get.put(AuthController());
        },
      );
      await pumpFrames(tester, frames: 12);
      await drainToasts(tester);

      expect(tester.takeException(), isNull,
          reason: 'login threw while rendering in ${combination.name}');

      /// A login screen with no fields is not a login screen. Two is the premise: an identifier
      /// and a password.
      expect(find.byType(TextFormField).evaluate().length + find.byType(TextField).evaluate().length,
          greaterThanOrEqualTo(2),
          reason: 'login rendered fewer than two input fields, so this capture is not of a usable '
              'sign-in form');

      final context = tester.element(find.byType(NormalLoginWidget));
      expect(Directionality.of(context), combination.direction,
          reason: 'login rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'login rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName('flutter-login', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the login capture is suspiciously small: a blank render');
      }
    });

    testWidgets('welcome renders before it navigates away in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        const WelComeScreen(),
        api: api,
        combination: combination,
        register: () {
          Get.put(AuthController());
          Get.put(OnboardingController());
        },
        pages: redirectTargets(),
        // INSIDE the 1500 ms `_checkAndNavigate` delay: 12 frames of 50 ms is 600 ms.
        frames: 12,
      );
      await pumpFrames(tester, frames: 6);

      /// The assertion that makes the capture mean something. If the screen has already redirected,
      /// the picture below is of onboarding, the dashboard or login — a different surface under
      /// this one's name.
      expect(find.byType(WelComeScreen), findsOneWidget,
          reason: 'the welcome screen already navigated away, so the capture about to be taken is '
              'of whatever it left for and not of the welcome screen');

      expect(tester.takeException(), isNull,
          reason: 'welcome threw while rendering in ${combination.name}');

      final context = tester.element(find.byType(WelComeScreen));
      expect(Directionality.of(context), combination.direction,
          reason: 'welcome rendered the wrong direction in ${combination.name}');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: 'welcome rendered the wrong brightness in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName('flutter-welcome', combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the welcome capture is suspiciously small: a blank render');
      }

      /// Let the redirect fire before teardown so its timer does not outlive the tree.
      await drainToasts(tester);
    });
  }

  testWidgets('premise: the welcome screen really does redirect, so the window above is real',
      (tester) async {
    /// Without this, "it was still on screen at 600 ms" would also be true of a welcome screen
    /// whose navigation had silently stopped working — and the bounded window would be guarding
    /// nothing. This drives past the delay and asserts it left.
    final api = ApiStub();

    await pumpScreen(
      tester,
      const WelComeScreen(),
      api: api,
      pages: redirectTargets(),
      register: () {
        Get.put(AuthController());
        Get.put(OnboardingController());
      },
    );

    expect(find.byType(WelComeScreen), findsOneWidget,
        reason: 'premise: the welcome screen was not on screen to begin with');

    await pumpFrames(tester, frames: 20, step: const Duration(milliseconds: 200));
    await drainToasts(tester);

    expect(find.byType(WelComeScreen), findsNothing,
        reason: 'the welcome screen is STILL on screen 4 seconds in, so `_checkAndNavigate` no '
            'longer redirects and a merchant opening the app would sit on the splash for ever');
  });
}

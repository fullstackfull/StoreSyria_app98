import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/view/new_widgets/shimmer.dart';
import 'package:store_go_app/view/screen/customers/customer_screen.dart';

import 'golden_harness.dart';
import 'screen_harness.dart';

/// P2.5-FLUTTER-HARNESS — the harness tested as the infrastructure it is.
/// =================================================================================================
///
/// `screen_harness.dart` makes four claims about this application, each of which decided a design
/// choice. A harness whose premises are wrong produces confident screenshots of nothing, so every
/// one of them is asserted here rather than left in a comment:
///
///   1. the `runWithClient` zone really does reach a fetch started from `initState`;
///   2. `pumpAndSettle` really cannot return on a loading screen;
///   3. the failure path's toast really does drain;
///   4. `pumpUntil` really does fail — with a readable message — instead of hanging.
///
/// It also pins the two silent-success traps. A screen that fetched nothing and a screen whose
/// fetch escaped the stub look IDENTICAL on screen; and a stub whose rule never matched answers
/// the fallback, which also looks like success. Both are caught by asserting on `ApiStub.calls`.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// One page of customers, in the shape `CustomerModel.fromJson` reads.
  Map<String, Object?> customerPage() => <String, Object?>{
        'status': 1,
        'data': <String, Object?>{
          'customers': <Object?>[
            <String, Object?>{
              'id': 1,
              'customer_info': <String, Object?>{'name': 'أمينة حداد', 'mobile': '0911222333'},
              'email': 'amina@example.test',
              'state_name': 'دمشق',
              'status': 1,
            },
          ],
          'pagination': <String, Object?>{'last_page': 1},
        },
      };

  // ===============================================================================================
  //  CLAIM 1 — the zone reaches an initState fetch
  // ===============================================================================================

  testWidgets('the stub intercepts a fetch started from a post-frame callback', (tester) async {
    /// THE CLAIM THE WHOLE HARNESS RESTS ON. `package:http` warns that "Flutter does not guarantee
    /// that callbacks are executed in a particular Zone", so a zone-scoped client could plausibly
    /// have missed a request started from `WidgetsBinding.instance.addPostFrameCallback` inside
    /// `initState` — which is exactly where `CustomerScreen` starts its fetch
    /// (`customer_screen.dart:39-46`). If this ever stops being true, every screen test in the
    /// project is silently talking to the real network.
    final api = ApiStub()..on('customerlist', customerPage());

    await pumpScreen(
      tester,
      const CustomerScreen(),
      api: api,
      register: () {
        Get.put(CustomerController());
      },
    );

    expect(
      api.calls,
      isNotEmpty,
      reason: 'the screen made no HTTP call the stub could see. Either the screen stopped '
          'fetching on mount, or the runWithClient zone no longer reaches it — and in the second '
          'case the call went to the real network.',
    );
    expect(api.sawRequestFor('customerlist'), isTrue, reason: 'calls were ${api.calls}');
  });

  testWidgets('the stubbed data reaches the controller, not just the wire', (tester) async {
    /// Intercepting the request is not the same as the screen USING the answer. Without this, a
    /// stub whose body the model cannot parse would still satisfy the test above.
    final api = ApiStub()..on('customerlist', customerPage());
    final controller = CustomerController();

    await pumpScreen(
      tester,
      const CustomerScreen(),
      api: api,
      register: () {
        Get.put(controller);
      },
    );

    await pumpUntil(
      tester,
      () => controller.customerList.isNotEmpty,
      reason: 'the customer list never filled from the stubbed page',
    );

    expect(controller.customerList.length, 1);
    expect(controller.isLoading.value, isFalse);
  });

  // ===============================================================================================
  //  CLAIM 2 — pumpAndSettle cannot work here, and this is why
  // ===============================================================================================

  testWidgets('the loading shimmer repeats for ever, so there is nothing to settle to',
      (tester) async {
    /// THE MEASUREMENT BEHIND THE DESIGN. `shimmer.dart:76` is
    /// `_controller.repeat(min: -0.5, max: 1.5, period: ...)`. While a screen is loading the tree
    /// therefore schedules frames without end, which is why every helper in the harness is bounded
    /// and why `pumpAndSettle` is not used anywhere in it.
    ///
    /// Asserted on the WIDGET rather than on a screen, so the claim is about the mechanism and
    /// cannot be invalidated by a screen changing its loading state.
    await tester.pumpWidget(
      MaterialApp(
        home: AppShimmer(child: Container(width: 100, height: 20, color: Colors.grey)),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(
      tester.binding.hasScheduledFrame,
      isTrue,
      reason: 'the shimmer stopped scheduling frames. If that is a deliberate change, '
          'pumpAndSettle may now be usable and this harness could be simplified — but check '
          'every loading state before assuming it.',
    );

    // And it is still going much later, which is what "for ever" means in practice.
    await tester.pump(const Duration(seconds: 30));

    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  // ===============================================================================================
  //  CLAIM 3 — the failure path drains
  // ===============================================================================================

  testWidgets('a 500 shows the failure state and its toast drains without a pending timer',
      (tester) async {
    /// The path the original blocker named. A 500 makes the controller call `commonToast`, which
    /// is `Get.snackbar` with a 4s duration — and a test that ends with that timer still pending
    /// fails in teardown. `drainToasts` advances the fake clock past it; nothing about the
    /// production toast changes.
    final api = ApiStub(fallbackStatus: 500, fallbackBody: {'message': 'boom'});
    final controller = CustomerController();

    await pumpScreen(
      tester,
      const CustomerScreen(),
      api: api,
      register: () {
        Get.put(controller);
      },
    );

    expect(api.calls, isNotEmpty, reason: 'the failure path was never reached');

    await drainToasts(tester);

    expect(
      controller.customerList,
      isEmpty,
      reason: 'a 500 must leave the list empty rather than half-populated',
    );
  });

  // ===============================================================================================
  //  CLAIM 4 — pumpUntil fails readably instead of hanging
  // ===============================================================================================

  testWidgets('pumpUntil fails at its cap rather than holding the suite open', (tester) async {
    /// The guarantee that makes the harness safe to leave in CI. Without a cap, a screen whose
    /// data never arrives holds the runner until the job times out and reports nothing useful.
    final api = ApiStub()..on('customerlist', customerPage());

    await pumpScreen(
      tester,
      const CustomerScreen(),
      api: api,
      register: () {
        Get.put(CustomerController());
      },
    );

    Object? thrown;

    try {
      await pumpUntil(
        tester,
        () => false,
        reason: 'a condition that can never hold',
        maxFrames: 3,
      );
    } catch (error) {
      thrown = error;
    }

    expect(thrown, isNotNull, reason: 'pumpUntil returned for a condition that is always false');
    expect(
      thrown.toString(),
      allOf(
        contains('pumpUntil gave up after 3 frames'),
        contains('a condition that can never hold'),
        contains('shimmer'),
      ),
      reason: 'the failure must name the cap, the caller\'s reason and why the bound exists: '
          '$thrown',
    );
  });

  // ===============================================================================================
  //  THE TWO SILENT-SUCCESS TRAPS
  // ===============================================================================================

  testWidgets('a screen that fetches nothing is distinguishable from one that was intercepted',
      (tester) async {
    /// Both render. Only `ApiStub.calls` tells them apart, which is why every screen test asserts
    /// on it before it asserts on anything visual.
    final api = ApiStub()..on('customerlist', customerPage());

    await pumpScreen(
      tester,
      const SizedBox.shrink(),
      api: api,
      register: () {},
    );

    expect(
      api.calls,
      isEmpty,
      reason: 'a widget that fetches nothing recorded a call, so `calls` is not measuring what '
          'the screen did',
    );
  });

  testWidgets('an unmatched rule answers the fallback, and the call is still recorded',
      (tester) async {
    /// The second trap: a stub rule with a typo never matches, the fallback answers, and the
    /// screen renders an empty state that looks like a legitimate result. The recorded call is the
    /// evidence that the rule, not the screen, was wrong.
    final api = ApiStub()..on('this-fragment-matches-nothing', customerPage());
    final controller = CustomerController();

    await pumpScreen(
      tester,
      const CustomerScreen(),
      api: api,
      register: () {
        Get.put(controller);
      },
    );

    expect(api.sawRequestFor('customerlist'), isTrue,
        reason: 'the request was made and recorded even though no rule matched it');
    expect(controller.customerList, isEmpty,
        reason: 'the fallback body carries no customers, so the list stays empty — which is '
            'exactly why `calls` has to be asserted on');
  });

  testWidgets('an arrow `register:` fails by name instead of as a missing controller',
      (tester) async {
    /// THE TRAP, PINNED. `register: () => Get.put(Foo())` makes Dart infer `Get.put<void>` from
    /// the `void Function()` context, so the instance is registered under `void` and the screen's
    /// own `Get.find<Foo>()` throws `"Foo" not found` — which reads like a missing registration
    /// rather than a mis-typed one. MEASURED:
    ///
    ///     arrow  isRegistered<CustomerController>=false  isRegistered<void>=true
    ///     block  isRegistered<CustomerController>=true   isRegistered<void>=false
    ///
    /// The harness detects it and says so. This test is what keeps that detection honest.
    final api = ApiStub()..on('customerlist', customerPage());

    Object? thrown;

    try {
      await pumpScreen(
        tester,
        const CustomerScreen(),
        api: api,
        // ignore: unnecessary_lambdas
        register: () => Get.put(CustomerController()),
      );
    } catch (error) {
      thrown = error;
    }

    expect(thrown, isNotNull, reason: 'the arrow form was not detected');
    expect(
      thrown.toString(),
      allOf(contains('registered under the type `void`'), contains('block body')),
      reason: 'the failure must name the cause and the remedy: $thrown',
    );
  });

  testWidgets('a previous test\'s cached page cannot show up in this one', (tester) async {
    /// THE POLLUTION THAT COST TWO RED TESTS BEFORE IT WAS UNDERSTOOD.
    ///
    /// `CacheService.save` (`cahe.dart:16`) writes every successful page to GetStorage under
    /// `cache_*`, and the controller reads it back on mount. `Get.reset()` does not touch
    /// GetStorage, so a test that stubbed a 500 still rendered the PREVIOUS test's customers —
    /// the screen showed data the stub never served, which is the exact class of false reading
    /// this project treats as the enemy. The signature was unmistakable once seen: the two tests
    /// failed together and passed in isolation.
    ///
    /// `resetScreenHarness` clears the `cache_` keys. This test fails if that stops happening.
    final warm = ApiStub()..on('customerlist', customerPage());
    final first = CustomerController();

    await pumpScreen(tester, const CustomerScreen(), api: warm, register: () {
      Get.put(first);
    });

    await pumpUntil(tester, () => first.customerList.isNotEmpty,
        reason: 'premise: the first pass really did load and cache a page');

    // What `tearDown` does, run here so the assertion is in one test rather than across two.
    resetScreenHarness();

    final cold = ApiStub(fallbackStatus: 500, fallbackBody: {'message': 'boom'});
    final second = CustomerController();

    await pumpScreen(tester, const CustomerScreen(), api: cold, register: () {
      Get.put(second);
    });

    await drainToasts(tester);

    expect(
      second.customerList,
      isEmpty,
      reason: 'the second pass stubbed a 500 and still has customers, so it is rendering the '
          'first pass\'s cached page — data the stub never served',
    );
  });

  // ===============================================================================================
  //  THE FOUR COMBINATIONS
  // ===============================================================================================

  for (final combination in kFourCombinations) {
    testWidgets('the screen mounts in ${combination.name} with the right direction and theme',
        (tester) async {
      /// Phase 2.5 requires every surface in four combinations, so the harness has to produce all
      /// four — and has to prove it produced them rather than rendering the same one four times.
      /// That is a defect this project has already shipped once: `RESUME-POINT-2026-10-27.md`
      /// records four "configurations" whose LTR and RTL PNGs were byte-identical.
      final api = ApiStub()..on('customerlist', customerPage());

      await pumpScreen(
        tester,
        const CustomerScreen(),
        api: api,
        combination: combination,
        register: () {
        Get.put(CustomerController());
      },
      );

      final context = tester.element(find.byType(CustomerScreen));

      expect(Directionality.of(context), combination.direction,
          reason: '${combination.name} rendered the wrong direction');
      expect(
        Theme.of(context).brightness,
        combination.dark ? Brightness.dark : Brightness.light,
        reason: '${combination.name} rendered the wrong brightness',
      );
    });
  }

  // ===============================================================================================
  //  THE ZONE, AND WHAT ESCAPES IT
  // ===============================================================================================

  testWidgets('a fetch started AFTER pumpScreen returns escapes the stub unless wrapped',
      (tester) async {
    /// `http.runWithClient` is `runZoned` with a zone value, so the stub lives exactly as long as
    /// the call that installed it. [pumpScreen] returns, the zone unwinds, and anything the test
    /// drives afterwards — a filter tap, a second page, a pull-to-refresh — reaches the REAL
    /// client.
    ///
    /// It fails silently in the worst way: the request never lands in `api.calls`, so an assertion
    /// waiting for it reports that the SCREEN never made the call. That cost a wrong diagnosis
    /// once; this is the measurement, so the next person reads it instead of repeating it.
    final api = ApiStub()..on('customerlist', customerPage());

    await pumpScreen(tester, const CustomerScreen(), api: api, register: () {
      Get.put(CustomerController());
    });

    final duringMount = api.calls.length;
    expect(duringMount, greaterThan(0), reason: 'premise: the mount itself was not intercepted');

    /// Outside the zone. `NetworkHttps` reaches `package:http`'s own client, which in a widget
    /// test answers 400 without touching the network — the point is only that the STUB did not
    /// see it.
    await http.get(Uri.parse('https://storesyria.com/api/admin/customerlist'));
    expect(api.calls.length, duringMount,
        reason: 'the stub recorded a request made outside its zone, so this trap no longer '
            'exists and `runWithApi` may be unnecessary');

    /// Inside, via the helper.
    await runWithApi(api, () async {
      await http.get(Uri.parse('https://storesyria.com/api/admin/customerlist'));
    });
    expect(api.calls.length, duringMount + 1,
        reason: 'runWithApi did not reinstall the stub, so no post-mount interaction can be '
            'driven against it');
  });

  testWidgets('recorded calls keep the query string, so one endpoint can be told from another',
      (tester) async {
    /// `calls` used to record `url.path` alone. `on()` matched against the FULL url even then, so
    /// a rule keyed on `page=2` answered correctly while `sawRequestFor('page=2')` was false —
    /// the stub working and the assertion claiming the request never happened. Everything that
    /// distinguishes one call to an endpoint from another lives in the query: the page, the
    /// status filter, the date range.
    final api = ApiStub()..on('customerlist', customerPage());

    await pumpScreen(tester, const CustomerScreen(), api: api, register: () {
      Get.put(CustomerController());
    });

    await runWithApi(api, () async {
      await http.get(Uri.parse('https://storesyria.com/api/admin/orderlist?store_id=1&page=2'));
    });

    expect(api.sawRequestFor('page=2'), isTrue,
        reason: 'the query string is being dropped from `calls` again. Recorded: ${api.calls}');
    expect(api.calls.last, contains('?'),
        reason: 'the recorded call carries no query at all: ${api.calls.last}');
  });
}

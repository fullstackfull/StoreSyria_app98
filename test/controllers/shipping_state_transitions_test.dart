// P2.5 — the SHIPPING list's four states, asserted on the controller fields a view can branch on.
// =================================================================================================
//
// WHY A CONTROLLER TEST AND NOT A WIDGET TEST. The obvious proof would pump `ShippingScreen` and
// look for `ShimmerList` / `ErrorState` / `EmptyState`. That test cannot be written against this
// screen: `shipping_screen.dart` holds `Get.put(ShippingController())` in a FIELD INITIALIZER, and
// `Get.put` overwrites whatever instance a test registered first, so a fake repository can never be
// injected before `initState`; `initState` then calls `Prefs.getString`, which is `getStorage!.read`
// on a nullable global, and fires a real request from a post-frame callback. So the states are
// proved where they are decided — in the controller — and the census
// (`test/ui/screen_state_census_test.dart`) proves the screen WIRES them. The census is a source
// scan and says so itself (:31-40); this file is the half it cannot do.
//
// THE FOUR CASES ARE THE FOUR BRANCHES, in the order the view evaluates them:
//
//   (a) loaded with rows     -> isLoading false, errorMessage empty, list non-empty  -> the list
//   (b) transport failure    -> errorMessage set, list empty                         -> ErrorState
//   (c) status-0 refusal     -> errorMessage set, list empty                         -> ErrorState
//   (d) page 2 came back []  -> errorMessage empty, list empty, currantPage 2        -> the list
//
// CASE (c) IS THE ONE THAT MATTERS and it is why `errorMessage` had to exist at all.
// `getShippingData`'s `onSuccess` calls `shippingList.clear()` UNCONDITIONALLY, before it looks at
// `data['status']`. So a server refusal empties the list. Without an `errorMessage` to branch on, a
// refusal is indistinguishable from "you have no shipping methods" — and once an `EmptyState` is
// wired, that stops being a blank rectangle and becomes an affirmative lie, announced to a screen
// reader (`EmptyState` carries `liveRegion: true`). The assertion below is the thing that keeps
// that case on the error branch.
//
// CASE (d) IS THE MIRROR LIE. A page past the last page answers `status: 1` with `data: []`, which
// also empties the list — with no error. So the view's empty branch is page-scoped
// (`isEmpty && currantPage <= 1`) and this case must fall through to the list, rendering
// `itemCount: 0`. The predicate is re-asserted here in the test's own words so the controller state
// that feeds it stays pinned even if the view is refactored.
//
// HOW IT RUNS. `ShippingController` holds its repository in a NON-final field, so a subclass
// returning a canned `Result` drives the real production method — the same lever
// `nested_api_read_test.dart:131-150` uses. No `Get.put`, no `GetStorage`, no HTTP, no pump:
// `getShippingData` touches none of them. `commonToast` is a deliberate no-op here, not an
// accident — `_show` returns early when `Get.overlayContext` is null
// (common_snak_bar_widget.dart:235-237), and there is no overlay under `flutter test`.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/config/repository/shipping_repository.dart';
import 'package:store_go_app/core/controller/home_controller/shipping_controller.dart';
import 'package:store_go_app/network/result.dart';

/// Answers `getShippingData` with one canned result. Overrides that method ONLY — the fake in
/// `nested_api_read_test.dart` overrides exactly two, so `ShippingRepository` must stay free of
/// abstract members or both files break.
class _CannedShippingRepository extends ShippingRepository {
  _CannedShippingRepository(this.result);

  final Result<Map<String, dynamic>> result;

  @override
  Future<Result<Map<String, dynamic>>> getShippingData(int page) async => result;
}

/// Never answers until the test says so, which is what makes the in-flight flag observable.
class _GatedShippingRepository extends ShippingRepository {
  _GatedShippingRepository(this.gate);

  final Completer<Result<Map<String, dynamic>>> gate;

  @override
  Future<Result<Map<String, dynamic>>> getShippingData(int page) => gate.future;
}

Success<Map<String, dynamic>> _ok(Map<String, dynamic> body) =>
    Success<Map<String, dynamic>>(body);

Map<String, dynamic> _page({
  required List<Map<String, dynamic>> rows,
  int lastPage = 1,
}) =>
    <String, dynamic>{
      'status': 1,
      'data': <String, dynamic>{
        'current_page': 1,
        'data': rows,
        'last_page': lastPage,
      },
    };

void main() {
  // `commonToast` reads `Get.overlayContext`, which reads `WidgetsBinding.instance`. With no
  // binding at all that getter THROWS rather than returning null, so the toast would blow up the
  // very tests it is irrelevant to. Initialised, it returns null and `_show` returns early
  // (common_snak_bar_widget.dart:235-237) — the no-op the controller tests rely on. No GetStorage
  // and no path_provider mock are needed here: `getShippingData` reads neither.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShippingController.getShippingData — the states a view branches on', () {
    test('PREMISE: the controller exposes a loading flag and an error message', () {
      // Without these two fields the screen has nothing to branch on, which is the whole defect:
      // in-flight, empty and failed all painted the same blank area under the "Shipping" heading.
      final c = ShippingController();

      expect(c.isLoading.value, isFalse);
      expect(c.errorMessage.value, isEmpty);
    });

    test('(a) a successful page with rows leaves no error and a populated list', () async {
      final c = ShippingController()
        ..shippingRepository = _CannedShippingRepository(
          _ok(_page(rows: [
            {'id': 1, 'name': 'DHL', 'description': 'overnight'},
            {'id': 2, 'name': 'Aramex', 'description': 'standard'},
          ])),
        );

      await c.getShippingData(1);

      expect(c.isLoading.value, isFalse, reason: 'the shimmer must come down when the page lands');
      expect(c.errorMessage.value, isEmpty);
      expect(c.shippingList, hasLength(2));
    });

    test('(b) a transport failure sets errorMessage and leaves the list empty', () async {
      final c = ShippingController()
        ..shippingRepository = _CannedShippingRepository(
          const Failure<Map<String, dynamic>>(
            FailureReason.network,
            'no_internet_connection',
          ),
        );

      await c.getShippingData(1);

      expect(c.isLoading.value, isFalse);
      expect(c.errorMessage.value, 'no_internet_connection',
          reason: 'the view renders this string in ErrorState; a toast gone in three seconds is '
              'the only thing that reported this failure before');
      expect(c.shippingList, isEmpty);
    });

    test('(c) a status-0 REFUSAL sets errorMessage, so the empty list is not read as "none"',
        () async {
      // `onSuccess` clears the list before it checks `status`, so a refusal always arrives with an
      // empty list. `errorMessage` is the only thing that distinguishes it from a genuinely empty
      // catalogue — and an EmptyState here would tell a merchant with several shipping methods
      // that they have none.
      final c = ShippingController()
        ..shippingRepository = _CannedShippingRepository(
          _ok(<String, dynamic>{'status': 0, 'message': 'refused'}),
        );

      await c.getShippingData(1);

      expect(c.isLoading.value, isFalse);
      expect(c.shippingList, isEmpty);
      expect(c.errorMessage.value, 'refused');

      // The view's branch order, restated: error is tested BEFORE empty, so this lands on
      // ErrorState and never on EmptyState.
      expect(c.errorMessage.value.isNotEmpty && c.shippingList.isEmpty, isTrue,
          reason: 'a refusal must satisfy the ErrorState predicate');
    });

    test('(d) an empty PAGE 2 must not satisfy the empty-state predicate', () async {
      // Reachable in normal use: the scroll listener increments `currantPage` on every
      // notification at the bottom with no in-flight guard, so a page past `last_page` is one
      // bounce away. It answers status 1 with `data: []`, which empties the list with no error.
      final c = ShippingController()
        ..shippingRepository = _CannedShippingRepository(
          _ok(_page(rows: const [], lastPage: 1)),
        )
        ..currantPage.value = 2;

      await c.getShippingData(2);

      expect(c.shippingList, isEmpty);
      expect(c.errorMessage.value, isEmpty);
      expect(c.currantPage.value, 2);

      // THE VIEW PREDICATE, asserted here because this is the case that would lie. The empty
      // branch is `isEmpty && currantPage <= 1`; on page 2 it is FALSE, so the body falls through
      // to the list and renders `itemCount: 0` — today's blank area, which is honest, rather than
      // "no shipping methods found", which is not.
      expect(c.shippingList.isEmpty && c.currantPage.value <= 1, isFalse,
          reason: 'EmptyState must NOT render for an empty page 2 — the merchant has rows on '
              'page 1 and they are still the truth');
    });

    test('isLoading is true WHILE the request is in flight', () async {
      final gate = Completer<Result<Map<String, dynamic>>>();
      final c = ShippingController()
        ..shippingRepository = _GatedShippingRepository(gate);

      final inFlight = c.getShippingData(1);

      expect(c.isLoading.value, isTrue,
          reason: 'set before the await, or the first frame after a tap is a blank area');

      // Drain the microtask queue to prove the flag is not reset by the scheduling itself.
      await Future<void>.delayed(Duration.zero);
      expect(c.isLoading.value, isTrue);

      gate.complete(_ok(_page(rows: const [])));
      await inFlight;

      expect(c.isLoading.value, isFalse);
    });

    test('a retry after a failure clears the previous error', () async {
      // The ErrorState carries an onRetry; if `errorMessage` is not cleared on the way in, the
      // error branch wins forever and the retry button does nothing visible.
      final c = ShippingController()
        ..shippingRepository = _CannedShippingRepository(
          const Failure<Map<String, dynamic>>(FailureReason.network, 'boom'),
        );

      await c.getShippingData(1);
      expect(c.errorMessage.value, 'boom');

      c.shippingRepository = _CannedShippingRepository(
        _ok(_page(rows: [
          {'id': 3, 'name': 'Local', 'description': 'same day'},
        ])),
      );

      await c.getShippingData(1);

      expect(c.errorMessage.value, isEmpty);
      expect(c.shippingList, hasLength(1));
    });
  });
}

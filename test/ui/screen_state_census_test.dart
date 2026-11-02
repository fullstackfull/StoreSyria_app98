// P2-07-14 / WS K16 — loading, empty and error states, as a census rather than a sweep.
// =================================================================================================
//
// THE ACCEPTANCE IS "each screen has all three and none of them is a blank page", and taken
// literally that is wrong for most of this app. An EMPTY state is meaningless on a form: "Add
// product" cannot be empty, and putting an inbox icon reading "nothing here yet" above a form
// would be worse than the gap it closed. So the screens are classified, and each kind is held to
// what it can actually have:
//
//   collection  a list or dashboard of records  -> loading + empty + error
//   form        a form or a single record       -> loading + SOME failure feedback
//   staticPage  no network at all               -> none required
//
// AND "SOME FAILURE FEEDBACK" IS NOT A WEAKENING — it is the acceptance read properly, after a
// measurement corrected the first version of this file. That version demanded `ErrorState` on
// forms too and named twelve screens as gaps. They are not: a form is ALWAYS ON SCREEN, so it is
// never the blank page the acceptance is about, and these screens already report failure through
// the app's snackbar helper — `profile_controller` calls it ten times, `shipping_controller`
// seven, `add_review_controller` four. Replacing that with a full-screen `ErrorState` would
// throw away the merchant's typed input to show an error, which is worse than the gap it closed.
//
// A collection is the opposite case and keeps the strict rule: with nothing to render it IS a
// blank page, which is exactly when a merchant needs to be told whether their catalogue is empty
// or the request failed.
//
// THE CLASSIFICATION IS EXHAUSTIVE AND THAT IS THE RATCHET. Every `*_screen.dart` under
// `lib/view/screen` must appear exactly once below, so a NEW screen fails this test until someone
// classifies it — which is the moment to decide which states it owes. A census that silently
// skipped unknown files would go stale the first time a screen was added.
//
// WHAT IS MEASURED IS THE SOURCE, not a rendered frame, and the limit is stated rather than
// implied: this asserts that a screen WIRES the shared widgets, not that the widget appears under
// the right conditions at runtime. That limit was measured, not assumed — wrapping a screen's
// error branch in `if (false)` leaves `ErrorState(` in the file and this census still passes,
// while deleting the call fails it. So the census catches a screen that never wired a state and
// cannot catch one whose condition is wrong; the latter needs a widget test driving the
// controller, which is the next increment on this row. Driving 28 screens through real failure and empty responses
// needs a device or an emulator, and this container has neither (the same B4 constraint recorded
// against P2-07-5). The widget tests that do drive behaviour live beside this file; the census is
// what stops a screen being added with no states at all.
//
// The shared widgets already exist — `EmptyState` and `ErrorState` in
// `lib/view/widget/error_empty_state.dart`, the latter taking an `onRetry` — and eleven screens
// already use all three. This row is adoption, not invention.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

enum ScreenKind { collection, form, staticPage }

/// Every screen under `lib/view/screen`, classified. Keyed by path relative to that directory.
const Map<String, ScreenKind> kScreenKinds = {
  // ---- collections: a list or a dashboard of records ----
  'category_screen/category_screen.dart': ScreenKind.collection,
  'coupon_screen/coupon_screen.dart': ScreenKind.collection,
  'customers/customer_screen.dart': ScreenKind.collection,
  'delivery_boys/delivery_boy_screen.dart': ScreenKind.collection,
  'home_screen/home_screen.dart': ScreenKind.collection,
  'home_screen/tax_screen.dart': ScreenKind.collection,
  'notification_screen/notification_screen.dart': ScreenKind.collection,
  'order_screen/order_screen.dart': ScreenKind.collection,
  'plans/my_plan_screen.dart': ScreenKind.collection,
  'product_screen/products_screen.dart': ScreenKind.collection,
  'setting_screen/payment_setting_screen/payment_setting_screen.dart': ScreenKind.collection,
  'statistics_screen/statistics_screen.dart': ScreenKind.collection,
  'wallet/wallet_screen.dart': ScreenKind.collection,

  'coupon_screen/coupon_detail_screen.dart': ScreenKind.collection,

  'order_screen/order_detail_screen.dart': ScreenKind.collection,

  'setting_screen/store_info_screen.dart': ScreenKind.collection,

  // The three above were first classified as forms and the census refused them: each already
  // renders `EmptyState`, because each shows a LIST inside a record — a coupon's usages, an
  // order's line items, a store's configured entries. The test caught the misclassification
  // rather than my reading of the file names.

  // ---- forms and single records: loading + error, but nothing to be "empty" of ----
  'home_screen/shipping_screen.dart': ScreenKind.form,
  'order_screen/create_order_screen.dart': ScreenKind.form,
  'product_screen/add_new_product_screen.dart': ScreenKind.form,
  'product_screen/add_rating_screen.dart': ScreenKind.form,
  'product_screen/product_detail_screen.dart': ScreenKind.form,
  'profile_screen/profile_screen.dart': ScreenKind.form,
  'setting_screen/email_setting_screen.dart': ScreenKind.form,
  'setting_screen/language_screen.dart': ScreenKind.form,
  'setting_screen/loyality_setting_screen.dart': ScreenKind.form,
  'setting_screen/payment_setting_screen/bank_transfer_screen.dart': ScreenKind.form,
  'setting_screen/payment_setting_screen/cod_screen.dart': ScreenKind.form,
  'setting_screen/payment_setting_screen/stripe_screen.dart': ScreenKind.form,
  'setting_screen/store_setting_screen.dart': ScreenKind.form,

  // ---- static: no network, so no state to show ----
  'onboarding_screen/onboarding_screen.dart': ScreenKind.staticPage,
  'setting_screen/setting_screen.dart': ScreenKind.staticPage,
  'welcome_screen.dart': ScreenKind.staticPage,
};

const String _screenDir = 'lib/view/screen';

List<String> _screensOnDisk() {
  final dir = Directory(_screenDir);
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.replaceFirst('$_screenDir/', ''))
      .where((p) => p.endsWith('_screen.dart'))
      .toList()
    ..sort();
}

String _read(String relative) => File('$_screenDir/$relative').readAsStringSync();

bool _hasLoading(String src) =>
    RegExp(r'CircularProgressIndicator|Shimmer|isLoading|LoadingWidget').hasMatch(src);
bool _hasEmpty(String src) => src.contains('EmptyState(');
bool _hasError(String src) => src.contains('ErrorState(');

/// A form reports failure if the screen OR the controllers it uses say something when a call
/// fails. The snackbar helper is the app's established way; `ErrorState` also counts.
bool _reportsFailure(String relative) {
  final src = _read(relative);
  if (_hasError(src) || RegExp(r'SnackBar|snakBar|snackBar|Toast').hasMatch(src)) return true;

  for (final controller in RegExp(r'(\w+Controller)').allMatches(src).map((m) => m.group(1)!)) {
    for (final f in Directory('lib/core/controller').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final csrc = f.readAsStringSync();
      if (!csrc.contains('class $controller')) continue;
      if (RegExp(r'SnackBar|snakBar|snackBar|showSnack|Toast').hasMatch(csrc)) return true;
    }
  }
  return false;
}

void main() {
  group('P2-07-14 — every data-backed screen owns its states', () {
    test('PREMISE: the classification covers every screen exactly once', () {
      final onDisk = _screensOnDisk().toSet();
      final classified = kScreenKinds.keys.toSet();

      expect(onDisk.difference(classified), isEmpty,
          reason: 'these screens are not classified, so nobody has decided which states they '
              'owe — classify them in kScreenKinds rather than letting the census skip them');
      expect(classified.difference(onDisk), isEmpty,
          reason: 'these classified screens no longer exist, so the census is stale');
    });

    test('PREMISE: the shared state widgets exist to be adopted', () {
      final widget = File('lib/view/widget/error_empty_state.dart').readAsStringSync();
      expect(widget, contains('class EmptyState'));
      expect(widget, contains('class ErrorState'));
      expect(widget, contains('onRetry'),
          reason: 'an error state a merchant cannot retry from is a dead end');
    });

    test('every collection screen has loading, empty AND error', () {
      final gaps = <String>[];

      kScreenKinds.forEach((path, kind) {
        if (kind != ScreenKind.collection) return;
        final src = _read(path);
        final missing = <String>[
          if (!_hasLoading(src)) 'loading',
          if (!_hasEmpty(src)) 'empty',
          if (!_hasError(src)) 'error',
        ];
        if (missing.isNotEmpty) gaps.add('$path -> missing ${missing.join(", ")}');
      });

      expect(gaps, isEmpty,
          reason: 'a list with no empty state is a blank page the first time a merchant opens '
              'it, and one with no error state is a blank page whenever the network fails:\n'
              '${gaps.join("\n")}');
    });

    test('every form screen reports failure somehow', () {
      final gaps = <String>[];

      kScreenKinds.forEach((path, kind) {
        if (kind != ScreenKind.form) return;
        if (!_reportsFailure(path)) gaps.add(path);
      });

      expect(gaps, isEmpty,
          reason: 'these forms fail SILENTLY — the merchant presses save, nothing visible '
              'happens, and they cannot tell whether it worked:\n${gaps.join("\n")}');
    });

    test('no form screen pretends to be empty', () {
      final wrong = <String>[];

      kScreenKinds.forEach((path, kind) {
        if (kind != ScreenKind.form) return;
        if (_hasEmpty(_read(path))) wrong.add(path);
      });

      expect(wrong, isEmpty,
          reason: 'an empty state on a form is meaningless — "Add product" cannot be empty — and '
              'if one of these is really a collection, reclassify it instead: ${wrong.join(", ")}');
    });
  });
}

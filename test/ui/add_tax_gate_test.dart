// P2.5-B-07 -- the Create/Update gate on the Add Tax sheet.
//
// WHAT WAS WRONG. The gate read
//
//   if (name.isNotEmpty || amount.isNotEmpty || chargesType.isNotEmpty)
//
// -- three conditions joined by OR where the sibling sheet
// (add_shipping_bottomsheet.dart:166-170) joins five by AND. `chargesType` is
// `RxString chargesType = 'Flat'.obs` and its only writers are a dropdown fed
// from `['Flat','Percentage']` and `clearTaxFields()`, which resets it to
// 'Flat'. So on a FRESH sheet the third disjunct is constant true, the whole
// condition is constant true, and tapping Create on an untouched sheet posts a
// blank name.
//
// WHY THE SEVERITY IS NOT "a blank tax record is stored". It is not: the
// `taxes` table is (id, name, store_id, created_at, updated_at), `Api\
// DashboardController::AddTax` validates `name` as required and writes only
// name + store_id, and `Tax::$fillable` is ['name','store_id']. Amount, Charges
// Type and Status are posted and discarded. On the CREATE path the real symptom
// is a wasted round-trip ending in a server-worded failure toast.
//
// THE UPDATE PATH IS WHERE IT ACTUALLY BITES, and that is why the second test
// below exists. `UpdateTax` validates `tax_id` only and writes the name only
// `if (!empty($request->name))`, then returns success -- so clearing the name
// and tapping Update today produces "Tax Updated successfully!" with nothing
// changed. A LYING SUCCESS TOAST. The web merchant form
// (TaxController.php:112-116) does validate `name` as required, so requiring it
// in the app is WEB PARITY, named as such, not a new business rule.
//
// AND THE `else` WAS NOT DEAD CODE, though the first reading said so. :42 does
// `chargesType.value = widget.chargeType!.capitalizeFirst!` and the server
// never returns `tax_type`, so after any visit to the Update sheet
// `chargesType` is '' -- and TaxController is a Get.put singleton whose
// clearTaxFields() runs only on success. Open Update, Close, open Create: all
// three disjuncts are false and the toast fires. It is replaced here because it
// is untranslated ('Please fill all field' renders raw English in Arabic),
// not because it was unreachable.
//
// WHAT MUST NOT CHANGE, and is pinned below. Amount and Charges Type stay
// OPTIONAL. There is no tax_amount column, AddTax ignores the key and the web
// form validates name alone, so requiring Amount would block a create the
// server accepts -- inventing a business rule, which Phase 2.5 may not do.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/tax_repository.dart';
import 'package:store_go_app/core/controller/home_controller/tax_controller.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/view/screen/home_screen/add_tax_bottomsheet.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';

/// Records whether the sheet reached the network at all. The gate is only
/// repaired if this stays false for a blank name -- a `validator:` with no
/// `Form` ancestor paints inline text and SUBMITS ANYWAY, which is the exact
/// way this fix can look right and be as inert as the bug it replaces.
class _SpyTaxRepository extends TaxRepository {
  int addCalls = 0;
  String? lastName;

  @override
  Future<Result<Map<String, dynamic>>> addTaxData({
    required bool isUpdate,
    required String taxId,
    required String taxName,
    required String type,
    required String taxAmount,
    required String status,
  }) async {
    addCalls++;
    lastName = taxName;
    // NEVER COMPLETES, on purpose -- AND THE REASON RECORDED HERE WAS WRONG
    // UNTIL D-42.6. It used to say that completing the Future sends the
    // controller into a branch that calls `commonToast`, and that "an overlay
    // toast cannot be pumped in this harness", so the exception would land
    // asynchronously after the assertions. The toast CAN be pumped now: the
    // overlay defect it was describing is repaired in
    // `common_snak_bar_widget.dart` and every refusal toast in this file is
    // asserted rather than swallowed.
    //
    // The Future still must not complete, for a different and smaller reason:
    // the toast it would raise owns a 3-second `Timer`, and a test that ends
    // with a pending timer fails on `!timersPending` -- measured, three cases
    // in this file did exactly that the moment the repair landed. The call is
    // what is under test and it has already been recorded, so there is nothing
    // to gain by completing it. A pending Future is not a pending Timer, so it
    // does not fail the test either.
    return Completer<Result<Map<String, dynamic>>>().future;
  }

  @override
  Future<Result<Map<String, dynamic>>> getTaxData(int page) async =>
      const Failure<Map<String, dynamic>>(
        FailureReason.network,
        'not under test',
      );
}

Future<_SpyTaxRepository> _pumpSheet(
  WidgetTester tester, {
  bool isUpdate = false,
  String name = '',
  String amount = '',
  String chargeType = '',
}) async {
  // Registered BEFORE the widget builds. The sheet's field initialiser does
  // `Get.put(TaxController())`, and GetX's put does not replace a live
  // singleton, so this instance is the one the sheet uses.
  // The default 800x600 test viewport puts the action row outside the sheet's
  // `height: Get.height / 1.5` scroll area, where a tap lands on the Material
  // behind it and fires nothing -- which made the two "does not reach the
  // network" tests below pass against the UNFIXED widget. Pin the design
  // viewport instead.
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);

  final controller = Get.put(TaxController());
  final spy = _SpyTaxRepository();
  controller.taxRepository = spy;

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        locale: const Locale('en', 'US'),
        fallbackLocale: TranslationService.fallbackLocale,
        translations: TranslationService(),
        localizationsDelegates: TranslationService.localizationsDelegates,
        supportedLocales: TranslationService.supportedLocales,
        home: const Scaffold(body: Center(child: Text('ORIGIN'))),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // PUSHED, not used as `home:`, because that is how production opens the sheet
  // -- over the app, from the tax list.
  //
  // THE REASON THIS COMMENT USED TO GIVE WAS FALSE, and it is corrected rather
  // than quietly rewritten. It said the failure toast "throws No Overlay widget
  // found when the sheet IS the home widget", implying that pushing it fixed
  // that. Pushing changed nothing: `Get.overlayContext` is the root
  // `OverlayState`'s `_Theater` child either way, and `Overlay.of` on a
  // `_Theater` could not resolve in EITHER shape -- measured in both. The toast
  // was broken for all 271 call sites, not for un-pushed ones. That is D-42.6,
  // repaired in `common_snak_bar_widget.dart`.
  Get.to(
    () => Scaffold(
      body: AddTaxWidget(
        isUpdate: isUpdate,
        taxId: '7',
        name: name,
        chargeType: chargeType,
        amount: amount,
        status: '1',
      ),
    ),
  );
  await tester.pumpAndSettle();
  return spy;
}

/// Asserts that the refusal the merchant is owed ACTUALLY APPEARS.
///
/// ──────────────────────────────────────────────────────────────────────────
/// WHAT THIS REPLACES, AND WHY THE REPLACEMENT IS STRONGER
/// ──────────────────────────────────────────────────────────────────────────
///
/// This was `_drainUnpumpableToast`, and it asserted
///
///     expect(thrown.toString(), contains('No Overlay widget found'))
///
/// -- i.e. it took a real production failure and pinned it as expected
/// behaviour. The reasoning it carried was that `Get.overlayContext` has no
/// `Overlay` ancestor "under `flutter_test`", so an overlay toast "cannot be
/// pumped". The first half is true and the second half does not follow: the
/// same lookup fails in the SHIPPED APP, where `GetMaterialApp`'s `builder:`
/// installs `ThemeSwitchOverlay` -- a `Stack`, not an `Overlay`. It was never a
/// harness limit. It was the toast being broken for all 271 call sites, and
/// this file was the place it had been written down as normal.
///
/// Repaired in `common_snak_bar_widget.dart` (D-42.6), proved in
/// `test/ui/toast_overlay_test.dart` against the real app shape with no
/// harness-supplied `Overlay`.
///
/// The assertion is not weakened by the correction, it is widened. The old
/// version proved only that the refusal branch REACHED `commonToast`, by
/// catching the exception that call raised. This proves the refusal branch
/// reached `commonToast` AND that an error-variant toast rendered AND that it
/// carries the words the merchant needs -- the same proof plus two facts the
/// old one could not reach. Nothing is swallowed: an unexpected exception now
/// fails the case instead of being inspected and discarded.
Future<void> _expectRefusalToast(WidgetTester tester) async {
  await tester.pumpAndSettle();

  expect(
    tester.takeException(),
    isNull,
    reason: 'The refusal path raised instead of showing a toast. Before D-42.6 '
        'this was `No Overlay widget found` from `Overlay.of(Get.overlayContext, '
        'rootOverlay: true)`, on every one of the 271 toast call sites.',
  );

  // PREMISE, before the message assertion: the ERROR variant of the toast is on
  // screen. `Icons.error_rounded` belongs to `_SnackType.error` alone and
  // appears nowhere else in this tree -- `CommonIconButton` takes a `String?
  // iconData` asset path, not an `IconData` -- so this cannot match the sheet's
  // own Close control.
  final Finder toast = find.ancestor(
    of: find.byIcon(Icons.error_rounded),
    matching: find.byWidgetPredicate(
      (Widget w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(14),
      description: 'the toast surface (14px radius)',
    ),
  );
  expect(
    toast,
    findsOneWidget,
    reason: 'premise: no error toast rendered, so the assertion below would be '
        'reading some other widget',
  );

  // THE REAL ASSERTION, read from INSIDE the toast rather than from the whole
  // tree. `find.text('Field is required')` alone would be satisfied by the
  // inline validator text, which renders either way -- that is the vacuous pass
  // this descendant scope exists to make impossible.
  expect(
    find.descendant(of: toast, matching: find.text('Field is required')),
    findsOneWidget,
    reason: "the refusal toast does not carry 'field_required'.tr. It must be a "
        'key present in BOTH translation maps: "Please fill all field" was in '
        'knownUntranslatedKeys and rendered raw English to an Arabic merchant.',
  );
}

/// Lets the toast's own 3-second `Timer` fire, the way production dismisses it.
///
/// Required now that the toast really renders: a case that ends with the timer
/// still pending fails on `!timersPending`, which is what all three refusal
/// cases in this file did the moment D-42.6 landed.
Future<void> _letTheToastExpire(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Future<void> _tapSubmit(WidgetTester tester) async {
  // The action row holds exactly two CommonIconButtons: Close, then submit.
  // Anchored on POSITION rather than on a translated title, because the submit
  // title is 'Create'.tr on one branch and 'update'.tr on the other -- and
  // 'Create' is ALSO the sheet's heading at :95, so find.text would match two
  // widgets and a careless finder would tap the wrong thing. The count is
  // asserted first: this repository has already published a measurement taken
  // from the wrong control once.
  final buttons = find.descendant(
    of: find.byType(AddTaxWidget),
    matching: find.byType(CommonIconButton),
  );
  expect(buttons, findsNWidgets(2),
      reason: 'The action row changed shape; this helper taps the wrong control.');

  await tester.ensureVisible(buttons.last);
  await tester.pumpAndSettle();

  // warnIfMissed stays ON. A tap that misses prints a warning and fires
  // nothing, so a "did not reach the network" assertion would pass for the
  // wrong reason -- which is precisely what happened on the first run of this
  // file before the viewport was pinned.
  await tester.tap(buttons.last);
  await tester.pump();
}

void main() {
  tearDown(Get.reset);

  testWidgets('CREATE with a blank name does not reach the network',
      (tester) async {
    final spy = await _pumpSheet(tester);

    await _tapSubmit(tester);

    await _expectRefusalToast(tester);

    expect(spy.addCalls, 0,
        reason: 'The sheet posted a blank name. The OR gate is constant true on '
            'a fresh sheet, so this is the defect itself; and if it fails after '
            'the repair it means the validator was added WITHOUT a Form '
            'ancestor, which decorates the field and submits anyway.');

    await _letTheToastExpire(tester);
  });

  testWidgets('UPDATE with the name cleared does not reach the network',
      (tester) async {
    // This is the path where today's behaviour is a LYING SUCCESS TOAST:
    // UpdateTax validates tax_id only and writes the name only if non-empty,
    // then reports success.
    final spy = await _pumpSheet(tester, isUpdate: true, name: 'VAT',
        amount: '5', chargeType: '');

    final field = find.descendant(
      of: find.byType(AddProductTextField).first,
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, '');
    await tester.pumpAndSettle();

    await _tapSubmit(tester);

    await _expectRefusalToast(tester);

    expect(spy.addCalls, 0,
        reason: 'Clearing the name on the Update sheet still posted. The gate '
            'governs both branches, so the update path must be covered too.');

    await _letTheToastExpire(tester);
  });

  testWidgets('a name with a BLANK AMOUNT still submits -- Amount stays optional',
      (tester) async {
    // THE NEGATIVE CONTROL AGAINST OVER-REACH. `taxes` has no tax_amount
    // column, AddTax discards the key, and the web form validates name alone.
    // Requiring Amount here would block a create the server accepts.
    final spy = await _pumpSheet(tester);

    final field = find.descendant(
      of: find.byType(AddProductTextField).first,
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, 'VAT');
    await tester.pumpAndSettle();

    await _tapSubmit(tester);

    expect(spy.addCalls, 1,
        reason: 'A tax with a name and no amount must still be creatable. If '
            'this fails the repair over-reached into a business rule: chaining '
            'all three conditions with AND, or validating Amount.');
    expect(spy.lastName, 'VAT');
  });

  testWidgets('the blank-name refusal is reported to the merchant',
      (tester) async {
    // The sheet is a fixed `height: Get.height / 1.5` container whose scroll
    // area shrinks by the keyboard inset, so the name field can sit above the
    // fold while the submit button stays tappable. Inline-only feedback can
    // therefore be invisible at the moment of the tap, and `?? false` on a null
    // FormState would make the button silently dead. So a refusal must also
    // say something.
    await _pumpSheet(tester);

    await _tapSubmit(tester);

    // THE TOAST, asserted from inside the toast subtree.
    await _expectRefusalToast(tester);

    // AND THE INLINE ERROR BESIDE IT. Two sites now, where this case could
    // previously only reach one: `findsNWidgets(2)` rather than `findsWidgets`,
    // because the count is the thing that changed and a lenient matcher would
    // hide a regression in either half. The inline text is the `validator:` at
    // add_tax_bottomsheet.dart:117; the toast is the `else` at :224.
    expect(find.text('Field is required'), findsNWidgets(2),
        reason: 'A blank name must produce VISIBLE feedback in words that exist '
            "in BOTH translation maps. 'Please fill all field' is in "
            'knownUntranslatedKeys and rendered raw English to an Arabic '
            'merchant. Exactly two renderings are expected: the inline '
            'validator, which rendered before D-42.6 too, and the toast, which '
            'did not render at all because `Overlay.of(Get.overlayContext)` '
            'could not resolve.');

    await _letTheToastExpire(tester);
  });
}

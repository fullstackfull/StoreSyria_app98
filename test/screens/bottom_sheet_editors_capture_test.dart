import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/view/screen/customers/customer_bottom_sheet.dart';
import 'package:store_go_app/view/screen/home_screen/add_category_bottomsheet.dart';
import 'package:store_go_app/view/screen/home_screen/add_shipping_bottomsheet.dart';
import 'package:store_go_app/view/screen/home_screen/add_tax_bottomsheet.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-SHEETS — the four `showModalBottomSheet` editors.
/// =================================================================================================
///
/// Category, customer, tax and shipping are each edited in a bottom sheet rather than on a screen
/// of their own, so none of them appears in a route table and none was reached by any capture
/// wave that navigates. They are pumped here as the widgets the sheet actually builds:
///
///   category_screen.dart:86   -> AddNewCategoriesWidget
///   customer_screen.dart:97   -> AddNewCustomerWidget
///   tax_screen.dart           -> AddTaxWidget
///   shipping_screen.dart      -> AddShippingWidget
///
/// **EACH INVENTORY ROW SAYS "Add / edit", so each is driven twice.** `isUpdate` is not cosmetic:
/// it decides the title, the submit label, and whether the fields arrive populated. A capture of
/// the empty create state proves nothing about the edit state, which is the one that has to lay
/// out real values -- an Arabic name beside a Latin SKU, a long category title in a fixed-height
/// sheet.
///
/// **TWO OF THE FOUR NEED A CONTROLLER AND TWO REGISTER THEIR OWN**, which is exactly the trap the
/// editor screens recorded. `add_category_bottomsheet.dart:53` and `customer_bottom_sheet.dart:79`
/// both call `Get.find`, so their controllers must already exist; `add_tax_bottomsheet.dart:36`
/// calls `Get.put` in a field initialiser and must NOT be registered here, or the sheet and the
/// test would hold two different instances.
/// Tap the customer wizard's Next control to reach step 2.
///
/// The label comes from the active locale, so both spellings are tried rather than importing the
/// translation map into the test -- a test that asserts a translation AND uses it to drive the UI
/// fails for two different reasons at once and tells you neither.
Future<void> advanceCustomerWizard(WidgetTester tester) async {
  for (final label in <String>['next', 'Next', 'التالي']) {
    final finder = find.text(label);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      return;
    }
  }

  fail('the customer wizard Next control was not found, so step 2 was never reached. '
      'Its label is built from the locale at customer_bottom_sheet.dart:546.');
}

void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// One sheet, one state, four combinations.
  void sheetCase({
    required String slug,
    required String label,
    required Widget Function() build,
    void Function()? register,
    required GoldenCombination combination,
    Future<void> Function(WidgetTester)? advance,
  }) {
    testWidgets('$label renders in ${combination.name}', (tester) async {
      final api = ApiStub();

      await pumpScreen(
        tester,
        // A TRANSPARENT `Material`, and both halves of that matter.
        //
        // Pumped bare, every one of these four threw "No Material widget found. TextField
        // widgets require a Material widget ancestor" -- 32 of 32 cases. In the app they never
        // are bare: `showModalBottomSheet` wraps whatever its builder returns in the
        // BottomSheet's own Material, which is where the real TextFields find theirs. So this
        // reproduces the real ancestor chain rather than papering over a defect.
        //
        // `MaterialType.transparency` because all four paint their OWN surface with a
        // BoxDecoration (add_category_bottomsheet.dart:195, customer_bottom_sheet.dart:244,
        // add_tax_bottomsheet.dart:61, add_shipping_bottomsheet.dart:49). An opaque Material
        // would lay its colour under them and the dark captures would be evidence of the
        // harness's background, not the sheet's.
        Material(
          type: MaterialType.transparency,
          child: Builder(builder: (_) => build()),
        ),
        api: api,
        combination: combination,
        register: register,
      );

      await pumpFrames(tester, frames: 16);
      await drainToasts(tester);

      // Some sheets are wizards. The customer sheet is two steps (`_currentStep`,
      // customer_bottom_sheet.dart:52) and step 1 holds the name, phone and email while step 2
      // holds the password and the ACCOUNT STATUS switch. Capturing only what the sheet opens on
      // would be evidence for half a surface -- and it is the half without the control.
      if (advance != null) await advance(tester);

      expect(tester.takeException(), isNull, reason: '$label threw in ${combination.name}');

      final context = tester.element(find.byType(Builder).first);
      expect(Directionality.of(context), combination.direction,
          reason: '$label rendered the wrong direction in ${combination.name}');

      // A sheet with no field is a sheet that did not build. Every one of these four is a form.
      expect(
        find.byType(TextField).evaluate().length +
            find.byType(TextFormField).evaluate().length,
        greaterThan(0),
        reason: '$label rendered no input at all in ${combination.name}',
      );

      final captured = await captureScreen(tester, captureName(slug, combination));
      if (captureDir != null) {
        expect(captured, isNotNull);
        expect(captured!.lengthSync(), greaterThan(1000),
            reason: 'the $label capture is suspiciously small');
      }
    });
  }

  for (final combination in kFourCombinations) {
    // ---- category ---------------------------------------------------------------------------
    sheetCase(
      slug: 'flutter-sheet-category-create',
      label: 'the category sheet (create)',
      build: () => const AddNewCategoriesWidget(isUpdate: false),
      register: () { Get.put(CategoryController()); },
      combination: combination,
    );

    sheetCase(
      slug: 'flutter-sheet-category-edit',
      label: 'the category sheet (edit)',
      build: () => const AddNewCategoriesWidget(
        isUpdate: true,
        categoryId: 3,
        name: 'أوشحة وشالات',
        trending: '1',
        status: '1',
      ),
      register: () { Get.put(CategoryController()); },
      combination: combination,
    );

    // ---- customer ---------------------------------------------------------------------------
    sheetCase(
      slug: 'flutter-sheet-customer-create',
      label: 'the customer sheet (create)',
      build: () => const AddNewCustomerWidget(isUpdate: false),
      register: () { Get.put(CustomerController()); },
      combination: combination,
    );

    sheetCase(
      slug: 'flutter-sheet-customer-edit',
      label: 'the customer sheet (edit)',
      build: () => const AddNewCustomerWidget(
        isUpdate: true,
        customerId: '7',
        firstName: 'أمينة',
        lastName: 'حداد',
        email: 'amina.haddad@example.test',
        mobile: '0912345678',
        status: '1',
      ),
      register: () { Get.put(CustomerController()); },
      combination: combination,
    );

    // CREATE, STEP 2 -- and this is the only place the password field and the ACCOUNT STATUS
    // switch exist. `customer_bottom_sheet.dart:423` opens `if(!widget.isUpdate) ...[`, so both
    // are rendered on the create path ONLY; editing a customer offers neither. Capturing the
    // edit path alone would have missed the control entirely, which is exactly what happened
    // the first time round.
    sheetCase(
      slug: 'flutter-sheet-customer-create-step2',
      label: 'the customer sheet (create, step 2)',
      build: () => const AddNewCustomerWidget(isUpdate: false),
      register: () { Get.put(CustomerController()); },
      combination: combination,
      advance: advanceCustomerWizard,
    );

    // STEP 2 of the same wizard -- password and account status. Reached by tapping the step-1
    // Next button, which is labelled from the active locale, so both spellings are tried.
    sheetCase(
      slug: 'flutter-sheet-customer-edit-step2',
      label: 'the customer sheet (edit, step 2)',
      build: () => const AddNewCustomerWidget(
        isUpdate: true,
        customerId: '7',
        firstName: 'أمينة',
        lastName: 'حداد',
        email: 'amina.haddad@example.test',
        mobile: '0912345678',
        status: '1',
      ),
      register: () { Get.put(CustomerController()); },
      combination: combination,
      advance: advanceCustomerWizard,
    );

    // ---- tax: registers its own controller at add_tax_bottomsheet.dart:36 --------------------
    sheetCase(
      slug: 'flutter-sheet-tax-create',
      label: 'the tax sheet (create)',
      build: () => AddTaxWidget(isUpdate: false),
      combination: combination,
    );

    sheetCase(
      slug: 'flutter-sheet-tax-edit',
      label: 'the tax sheet (edit)',
      build: () => AddTaxWidget(
        isUpdate: true,
        taxId: '2',
        name: 'ضريبة القيمة المضافة',
        chargeType: 'percentage',
        amount: '15',
        status: '1',
      ),
      combination: combination,
    );

    // ---- shipping ---------------------------------------------------------------------------
    sheetCase(
      slug: 'flutter-sheet-shipping-create',
      label: 'the shipping sheet (create)',
      build: () => AddShippingWidget(isUpdate: false),
      combination: combination,
    );

    sheetCase(
      slug: 'flutter-sheet-shipping-edit',
      label: 'the shipping sheet (edit)',
      build: () => AddShippingWidget(
        isUpdate: true,
        shippingId: '1',
        name: 'توصيل داخل دمشق',
        description: 'التوصيل خلال يوم عمل واحد داخل المدينة.',
      ),
      combination: combination,
    );
  }
}

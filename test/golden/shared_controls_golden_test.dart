// ROUTE 1 · wave 3 — the shared CONTROL surfaces: text field, buttons, app bar, search, filter,
// menu and the second status indicator.
// =================================================================================================
//
// FIVE SURFACES, EACH OF WHICH THE INVENTORY CARRIES IN ITS OWN RIGHT, and each of which has a
// repair in its history that a picture would have caught earlier than a measurement did:
//
//   text-field-column        `AppTextField`. Its caret and focus ring were `navyBlue` (#172C4E)
//                            unconditionally, in BOTH themes — 1.09:1 on the dark field surface
//                            (`app_txt_field.dart:86-97`). In dark mode a merchant could not tell
//                            which field had focus or where the cursor was.
//   button-column            `CommonButton`, whose own author called `isLoading` "the key
//                            variable" (`common_button.dart:15`) — and the loading state is the
//                            one a screenshot taken mid-flow never shows. The disabled state is
//                            an `AnimatedOpacity` of 0.5 with no other signal, which is exactly
//                            the kind of affordance a reviewer has to SEE to judge.
//   app-bar-column           `simpleAppBar`. Its back control is a `Container(height: 30.h,
//                            width: 40.w)` inside a bare GestureDetector — a 30x40 tap target
//                            against the 44pt floor, recorded as `flutter-touch-targets-below-44`
//                            — and it declares `preferredSize: Size.fromHeight(70)` while padding
//                            its content by `Get.height * 0.05`, which is the overflow recorded as
//                            `appbar-overflows-on-tall-devices`. Both are geometry, and geometry
//                            is what a baseline pins.
//   search-filter-menu-column `SearchRowWidget`, `orderStatusTabsWidget` and `AppPopupMenu`. The
//                            filter offered seven of the nine `delivered_status` values and the
//                            two it hid are the awkward ones (`filter_tabs.dart:6-25`); the row
//                            is horizontally scrollable, so whether the selected chip is VISIBLE
//                            at 360pt is a rendering question, not a logic one.
//   status-pill-pair         `statusPill` — a DIFFERENT widget from `CommonStatusBadge`, which
//                            `status_badge_golden_test.dart` already covers. It draws its label in
//                            the same hue as its own 9% tint, recorded as
//                            `flutter-statuspill-tint-contrast`, and it is the indicator on the
//                            customer, delivery-man and coupon cards. Two states, because a pill
//                            that looks the same either way is the defect.
//
// `pumpAndSettle` IS BANNED IN THE BUTTON CASE. `CommonButton(isLoading: true)` renders a
// `CircularProgressIndicator` (`common_button.dart:88`), an indeterminate animation that never
// completes, so there is nothing to settle to and `pumpAndSettle` times out. The fixed two-pump
// schedule below is deterministic because a widget test drives a fake clock. The same schedule
// also carries the 200ms `AnimatedOpacity` past its end, so the disabled specimen is photographed
// at its final opacity rather than mid-fade.
//
// THE SPECIMENS IDENTIFY THEMSELVES THROUGH THE WIDGET'S OWN TEXT — "Store Name", "Email",
// "price", "sku" — rather than through captions, so the picture holds nothing the app does not
// draw. The reading order is top to bottom in the order listed in each case below.
//
// KEYS, NOT INVENTED ENGLISH. `component_gallery_capture_test.dart` records the mistake twice: a
// specimen given `'New Order'` instead of a snake_case key renders as English inside the Arabic
// image and reads as a missing translation in the component, when the specimen is what was wrong.
// Every string below is either a real key or server-shaped data.
//
// NOTHING IS ASSERTED UNTIL A HUMAN HAS LOOKED. Each case skips while its baseline is absent.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/new_widgets/app_txt_field.dart';
import 'package:store_go_app/view/new_widgets/filter_tabs.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
import 'package:store_go_app/view/new_widgets/search_widget.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';

import '../support/golden_harness.dart';

// The only scaffolding in these images — see `status_badge_golden_test.dart` for why a component
// flush against the physical viewport edge is a framing the app never draws. Symmetric, so it adds
// no direction signal of its own.
const double kControlGutter = 12;

void main() {
  setUpAll(loadAppFonts);

  // See trap 2 in golden_harness.dart: ThemeController.theme mutates the process-global AppColor.
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  // Runtime skip, not `skip:` — see the note in customer_card_golden_test.dart.
  bool skipUnlessCaptured(String surface, GoldenCombination combination) {
    if (goldenReady(surface, combination)) return false;
    markTestSkipped(goldenSkipReason(surface, combination));
    return true;
  }

  Widget column(List<Widget> children) => Padding(
        padding: const EdgeInsets.all(kControlGutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  for (final combination in kFourCombinations) {
    testWidgets(
      'the shared text field renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('text-field-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) => column(<Widget>[
              AppTextField(title: 'Store Name'.tr, hint: 'Enter store name'.tr),
              SizedBox(height: 6.h),
              AppTextField(
                title: 'Email'.tr,
                hint: 'Enter store email'.tr,
                icon: Icons.mail_outline,
              ),
              SizedBox(height: 6.h),
              // A FILLED FIELD IS A DIFFERENT PICTURE FROM AN EMPTY ONE: the hint is gone and the
              // value is painted in the field's own text colour, which is the pairing a hint
              // contrast test cannot reach. `24.00` is server-shaped, not a key.
              AppTextField(
                title: 'price'.tr,
                hint: '0.00',
                controller: TextEditingController(text: '24.00'),
              ),
              SizedBox(height: 6.h),
              // READ-ONLY, not `enabled: false`. Both exist on this widget and they are not the
              // same branch; the read-only one is what the SKU and date fields really use.
              AppTextField(
                title: 'sku'.tr,
                hint: 'SKU-0041',
                readOnly: true,
                controller: TextEditingController(text: 'SKU-0041'),
              ),
            ]),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('text-field-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the shared buttons render as their baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('button-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) => column(<Widget>[
              CommonButton(title: 'Save Changes'.tr, onPressed: () {}),
              SizedBox(height: 10.h),
              CommonButton(title: 'Save Changes'.tr, isLoading: true),
              SizedBox(height: 10.h),
              // NO HANDLER AT ALL, which is how this widget is really disabled: `onPressed: null`
              // drives `isInert` and the 0.5 opacity. There is no `enabled:` flag.
              CommonButton(title: 'Send'.tr),
              SizedBox(height: 10.h),
              // The dialog's own button, a separate class that ships inside AppDialog and is a
              // row of its own in the inventory.
              AppButton(text: 'delete'.tr, onPressed: () {}),
            ]),
          ),
        ));

        // A FIXED SCHEDULE, NOT `pumpAndSettle` — see this file's header.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('button-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the shared app bar renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('app-bar-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          // NO GUTTER ON THIS ONE. An app bar is full-bleed by definition — it is handed to
          // `Scaffold.appBar` and paints to both physical edges. Insetting it would photograph a
          // framing no screen produces, and would hide whether its own internal padding is
          // directional.
          child: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                simpleAppBar(
                  isBack: true,
                  title: 'all_categories'.tr,
                  label: 'add_category'.tr,
                  onNewLabelTap: () {},
                ),
                SizedBox(height: 8.h),
                simpleAppBar(
                  title: 'product_details'.tr,
                  label: null,
                  onNewLabelTap: () {},
                ),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('app-bar-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the search row, status filter and row menu render as their baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('search-filter-menu-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) => column(<Widget>[
              // `hint:` IS NOT OPTIONAL IN PRACTICE, and the first capture here proved it.
              // Without one the field renders completely EMPTY — a search box with no
              // placeholder, which no merchant ever sees: all four call sites pass one
              // (`products_screen.dart:509`, `customer_screen.dart:130`,
              // `order_screen.dart:257` pass `'search'`, `wallet_screen.dart:124` passes
              // `'search_by_id'`). `component_gallery_capture_test.dart`'s specimen omits it
              // too, so its search captures have the same blank field.
              SearchRowWidget(
                context: context,
                controller: TextEditingController(),
                hint: 'search'.tr,
              ),
              SizedBox(height: 10.h),
              // INDEX 1, NOT 0. Index 0 is "all", which is the chip the row opens on; selecting a
              // later one is what shows the selected-chip treatment AND where the scroll offset
              // starts, which is the question at 360pt.
              orderStatusTabsWidget(
                context: context,
                selectedIndex: 1,
                onChanged: (_) {},
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppPopupMenu(viewFun: () {}, changeFun: () {}, deleteFun: () {}),
              ),
            ]),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('search-filter-menu-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the status pill renders both states as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('status-pill-pair', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) => column(<Widget>[
              statusPill(label: 'active'.tr, isActive: true),
              SizedBox(height: 8.h),
              statusPill(label: 'inactive'.tr, isActive: false),
            ]),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('status-pill-pair', combination)),
        );
      },
      tags: const <String>['golden'],
    );
  }
}

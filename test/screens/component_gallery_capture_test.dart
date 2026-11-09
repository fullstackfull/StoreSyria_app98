import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/new_widgets/app_txt_field.dart';
import 'package:store_go_app/view/new_widgets/filter_tabs.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
import 'package:store_go_app/view/new_widgets/search_widget.dart';
import 'package:store_go_app/view/new_widgets/shimmer.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_drop_down_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';

import '../support/golden_harness.dart';
import '../support/screen_harness.dart';

/// P2.5-FLUTTER-COMPONENTS — the shared components, rendered in isolation.
/// =================================================================================================
///
/// The coverage inventory carries these as surfaces of their own — "Shared empty / error / stale
/// states", "Shared skeletons", "Shared text field", "Shared status badge / pill", "Shared buttons
/// / loader" — and they are, because each appears on many screens and a defect in one is a defect
/// everywhere at once. A capture taken inside some host screen is evidence for that screen, not
/// for the component: it shows one instance, in one state, at one size.
///
/// So each is rendered ALONE here, in all four combinations, with the states that actually differ
/// put side by side in one frame. `CommonButton` is captured idle AND loading, because
/// `isLoading` is the state its own author called "the key variable"; `statusPill` is captured
/// active AND inactive, because a pill that looks the same either way is the defect.
///
/// THESE ARE NOT NEW ASSERTIONS ABOUT CONTRAST OR LAYOUT. Those already exist and are stronger
/// than a picture — `settings_card_contrast_test.dart`, `card_intrinsic_height_test.dart`,
/// `toast_overlay_test.dart`, `order_status_label_test.dart`, `image_placeholder_contrast_test.dart`.
/// What was missing was the *evidence a reviewer can look at*, in both languages and both themes.
/// This supplies that and asserts only what a capture can honestly carry: that the component
/// rendered, in the direction and brightness asked for, without throwing.
void main() {
  setUpAll(initScreenHarness);
  tearDownAll(disposeScreenHarness);
  tearDown(resetScreenHarness);

  /// A labelled specimen, so one frame can hold several states of the same component and a
  /// reviewer can tell which is which without counting.
  Widget specimen(String caption, Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(caption, style: const TextStyle(fontSize: 11, color: Color(0xFF8A94A6))),
            const SizedBox(height: 6),
            child,
          ],
        ),
      );

  final galleries = <_Gallery>[
    _Gallery(
      surface: 'flutter-component-states',
      label: 'empty / error / stale states',
      build: () => Column(
        children: <Widget>[
          // EACH IS GIVEN A BOUNDED HEIGHT, because `EmptyState` and `ErrorState` build a
          // `CustomScrollView` (`error_empty_state.dart:49`) -- they are FULL-VIEWPORT
          // components designed to be the body of a scroll area, not inline blocks. Dropped into
          // an unbounded column they throw "Vertical viewport was given unbounded height", which
          // is exactly what would happen to anyone placing one inside a scrolling form.
          specimen('EmptyState',
              SizedBox(height: 190, child: EmptyState(message: 'no_orders_found'.tr))),
          specimen('ErrorState',
              SizedBox(height: 210, child: ErrorState(message: 'connection_failed'.tr, onRetry: () {}))),
          // The REAL usage passes a server message, not a key: every call site is
          // `StaleDataNotice(message: controller.errorMessage.value, ...)`. The first version of
          // this specimen invented a key, which rendered as the identifier underneath the
          // component's own Arabic heading -- a reviewer would have read that as a missing
          // translation in the component. It is the specimen that was wrong.
          specimen(
            'StaleDataNotice',
            StaleDataNotice(message: 'connection_failed'.tr, onRetry: () {}),
          ),
        ],
      ),
    ),
    _Gallery(
      surface: 'flutter-component-skeletons',
      label: 'skeletons',
      build: () => Column(
        children: <Widget>[
          // `AppShimmer` WRAPS the bones it animates -- it takes a child, it is not one. Passing
          // it nothing was the first mistake here, and it is the same confusion that would make a
          // skeleton render as an empty box on a real screen.
          specimen(
            'AppShimmer over a bone',
            const AppShimmer(
              child: SizedBox(
                height: 64,
                width: double.infinity,
                child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFE3E7EE))),
              ),
            ),
          ),
          specimen('ShimmerTable', const SizedBox(height: 220, child: ShimmerTable())),
        ],
      ),
    ),
    _Gallery(
      surface: 'flutter-component-textfield',
      label: 'text field',
      build: () => Column(
        children: <Widget>[
          specimen('idle', AppTextField(title: 'Store Name'.tr, hint: 'Enter store name'.tr)),
          specimen('with icon', AppTextField(
            title: 'Email'.tr,
            hint: 'Enter store email'.tr,
            icon: Icons.mail_outline,
          )),
        ],
      ),
    ),
    _Gallery(
      surface: 'flutter-component-pill',
      label: 'status badge / pill',
      build: () => Column(
        children: <Widget>[
          specimen('active', statusPill(label: 'active'.tr, isActive: true)),
          specimen('inactive', statusPill(label: 'inactive'.tr, isActive: false)),
        ],
      ),
    ),
    _Gallery(
      surface: 'flutter-component-appbar',
      label: 'app bar',
      build: () => Column(
        children: <Widget>[
          // `simpleAppBar` reads `Theme.of(Get.context!)`, so it needs the harness's shell to be
          // mounted -- which it is, since the gallery runs inside `pumpScreen`.
          // KEYS COPIED FROM REAL CALL SITES. Every `simpleAppBar` in the app passes snake_case
          // keys -- `all_categories`, `add_category`, `product_details` -- and the first version
          // of this specimen invented `'New Order'` and `'Analytics'`, which are not keys at all.
          // They rendered as English in the Arabic capture and looked like a missing translation
          // in the component. The specimen was wrong, which is the same mistake the
          // StaleDataNotice specimen made.
          specimen('with a back control and an action',
              simpleAppBar(isBack: true, title: 'all_categories'.tr, label: 'add_category'.tr,
                  onNewLabelTap: () {})),
          specimen('title only',
              simpleAppBar(title: 'product_details'.tr, label: null, onNewLabelTap: () {})),
        ],
      ),
    ),
    _Gallery(
      surface: 'flutter-component-dropdown',
      label: 'dropdown',
      build: () => Column(
        children: <Widget>[
          specimen('with a selection', commonDropdownButtonWidget<String>(
            value: 'Percentage',
            labelText: 'charges_type'.tr,
            list: const <String>['Percentage', 'Flat'],
            itemLabel: (v) => v,
            onChanged: (_) {},
          )),
          specimen('empty', commonDropdownButtonWidget<String>(
            labelText: 'charges_type'.tr,
            list: const <String>['Percentage', 'Flat'],
            itemLabel: (v) => v,
            onChanged: (_) {},
          )),
        ],
      ),
    ),
    _Gallery(
      surface: 'flutter-component-dialog-button',
      label: 'dialog button',
      build: () => Column(
        children: <Widget>[
          // `AppDialog` opens an overlay, which a static gallery cannot hold; its BUTTON is the
          // part that ships inside the dialog and is a row of its own in the inventory.
          specimen('AppButton', AppButton(text: 'delete'.tr, onPressed: () {})),
        ],
      ),
    ),
    _Gallery(
      surface: 'flutter-component-search-filter-menu',
      label: 'search, filter tabs and popup menu',
      build: () => Column(
        children: <Widget>[
          specimen('SearchRowWidget', Builder(
            builder: (context) => SearchRowWidget(
              context: context,
              controller: TextEditingController(),
            ),
          )),
          specimen('orderStatusTabsWidget', Builder(
            builder: (context) => orderStatusTabsWidget(
              context: context,
              selectedIndex: 1,
              onChanged: (_) {},
            ),
          )),
          specimen('AppPopupMenu', Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppPopupMenu(viewFun: () {}, changeFun: () {}, deleteFun: () {}),
          )),
        ],
      ),
    ),
    _Gallery(
      surface: 'flutter-component-buttons',
      label: 'buttons and loader',
      build: () => Column(
        children: <Widget>[
          specimen('idle', CommonButton(title: 'Save Changes'.tr, onPressed: () {})),
          // `isLoading` is the state this widget's own author called "the key variable", and it is
          // the one a screenshot taken mid-flow would never show.
          specimen('loading', CommonButton(title: 'Save Changes'.tr, isLoading: true)),
          specimen('disabled (no handler)', CommonButton(title: 'Send'.tr)),
        ],
      ),
    ),
  ];

  for (final combination in kFourCombinations) {
    for (final gallery in galleries) {
      testWidgets('${gallery.label} render in ${combination.name}', (tester) async {
        await pumpScreen(
          tester,
          Builder(
            builder: (_) => Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: gallery.build(),
              ),
            ),
          ),
          api: ApiStub(),
          combination: combination,
        );
        await pumpFrames(tester, frames: 10);
        await drainToasts(tester);

        expect(tester.takeException(), isNull,
            reason: '${gallery.label} threw while rendering in ${combination.name}');

        final context = tester.element(find.byType(Scaffold).first);
        expect(Directionality.of(context), combination.direction,
            reason: '${gallery.label} rendered the wrong direction in ${combination.name}');
        expect(
          Theme.of(context).brightness,
          combination.dark ? Brightness.dark : Brightness.light,
          reason: '${gallery.label} rendered the wrong brightness in ${combination.name}',
        );

        final captured = await captureScreen(tester, captureName(gallery.surface, combination));
        if (captureDir != null) {
          expect(captured, isNotNull);
          expect(captured!.lengthSync(), greaterThan(1000),
              reason: 'the ${gallery.label} capture is suspiciously small: a blank render');
        }
      });
    }
  }

  // ===============================================================================================
  //  THE SAME GALLERIES ON A TABLET SURFACE
  // ===============================================================================================
  //
  // Phase 2.5 asks for responsive coverage, and a component that reflows is only proven to reflow
  // by being rendered at a second width. It also gives the inventory's DUPLICATE rows evidence of
  // their own: `Shared app bar` and `Shared app bar (simpleAppBar)` are the same widget named
  // twice, as are the text field, the skeletons, the status indicators and the button family.
  // Claiming both from one picture is what the owner's constraints forbid, so the duplicates are
  // claimed on this set instead -- different surface, different render, different file.
  for (final combination in kFourCombinations) {
    for (final gallery in galleries) {
      testWidgets('${gallery.label} render on a tablet in ${combination.name}', (tester) async {
        await pumpScreen(
          tester,
          Builder(
            builder: (_) => Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: gallery.build(),
              ),
            ),
          ),
          api: ApiStub(),
          combination: combination,
          surface: kGoldenTabletSize,
        );
        await pumpFrames(tester, frames: 10);
        await drainToasts(tester);

        expect(tester.takeException(), isNull,
            reason: '${gallery.label} threw on a tablet in ${combination.name}');

        final context = tester.element(find.byType(Scaffold).first);
        expect(MediaQuery.of(context).size.width, kGoldenTabletSize.width,
            reason: 'the tablet pass rendered at the phone width, so this set is not the second '
                'width it claims to be');

        final captured =
            await captureScreen(tester, captureName('${gallery.surface}-tablet', combination));
        if (captureDir != null) {
          expect(captured, isNotNull);
          expect(captured!.lengthSync(), greaterThan(1000),
              reason: 'the tablet ${gallery.label} capture is suspiciously small');
        }
      });
    }
  }

  testWidgets('premise: the two pill states are visually different', (tester) async {
    /// A status pill that looks the same active and inactive carries no information, and a
    /// gallery capture would not notice — both specimens would simply be present. This measures
    /// the fills apart.
    await pumpScreen(
      tester,
      Builder(
        builder: (_) => Scaffold(
          body: Column(
            children: <Widget>[
              statusPill(label: 'active', isActive: true),
              statusPill(label: 'inactive', isActive: false),
            ],
          ),
        ),
      ),
      api: ApiStub(),
    );
    await pumpFrames(tester, frames: 6);

    final fills = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.color)
        .whereType<Color>()
        .toList();

    expect(fills.length, greaterThanOrEqualTo(2),
        reason: 'premise: fewer than two pill fills were found, so nothing was compared');
    expect(fills[0], isNot(fills[1]),
        reason: 'the active and inactive status pills render the same fill, so the pill carries '
            'no information about the state it is naming');
  });
}

class _Gallery {
  _Gallery({required this.surface, required this.label, required this.build});

  final String surface;
  final String label;
  final Widget Function() build;
}

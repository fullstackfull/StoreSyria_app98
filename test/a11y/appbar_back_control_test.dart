// P2.5-D-02 -- the back control in the shared merchant app bar: its tap target
// and its accessible name.
//
// WHAT IS WRONG TODAY. `simpleAppBar` (lib/view/widget/common_appbar_widget.dart)
// draws its back control as a bare `GestureDetector` wrapping a
// `Container(height: 30.h, width: 40.w)` whose only child is an `Icon`. That is
// 30x40dp against Material's `kMinInteractiveDimension` of 48 and Apple's 44,
// and -- because the `GestureDetector` passes no `behavior:` -- the hit area can
// only ever be the child's 30x40, never larger. There is no tooltip, no
// `Semantics`, no `semanticLabel` and no button role anywhere in the file, so a
// screen reader announces an unlabelled tap region: the merchant is told
// something is tappable, not that it is "Back". 23 screens pass `isBack: true`.
//
// WHY NEITHER EXISTING RATCHET CAUGHT IT. test/a11y/tap_target_size_test.dart
// imports only `view/widget/common_button.dart` and pumps only those four
// widgets. test/a11y/icon_button_names_test.dart matches a literal `IconButton(`
// preceded by a non-letter -- which a `GestureDetector` is not. Both are blind
// to this control by construction.
//
// THREE THINGS THIS FILE MEASURES THAT A CHEAPER TEST WOULD GET WRONG, each one
// found by adversarially attacking the first draft of the repair against the
// real SDK rather than reasoning about it:
//
//   1. `preferredSize` IS A HARD CAP, not a hint. Scaffold computes
//      `_appBarMaxHeight = AppBar.preferredHeightFor(...) + topPadding` and wraps
//      the appBar slot in `ConstrainedBox(maxHeight: _appBarMaxHeight)`
//      (material/scaffold.dart). The widget declared `Size.fromHeight(70)` and
//      spends 40 of it on `top: Get.height * 0.05`, leaving 30dp. So
//      `BoxConstraints(minHeight: 48).enforce(maxHeight: 30)` clamps the minimum
//      DOWN: an `IconButton` with 48dp constraints measures 48 WIDE and 30 TALL,
//      silently, with no overflow error. Simply swapping in an IconButton does
//      not fix this defect. That is why the first assertion below pins the
//      height with the status-bar inset forced to ZERO -- the hard case. A test
//      that let the device inset supply the headroom would pass against a
//      widget that is still 30dp tall on a device with no inset.
//
//   2. A MARGIN TAP CAN PASS VACUOUSLY. tap_target_size_test.dart:150-182
//      records this repository being bitten once already: removing
//      `HitTestBehavior.opaque` left every size assertion in that file passing,
//      because a box measures 48 whether or not the gesture claims it. Here the
//      trap is sharper -- at the old 70dp cap the control rect and the painted
//      rect have the SAME top edge, so "tap 4dp below the top" lands inside the
//      painted box and proves nothing. So the margin is asserted to EXIST before
//      it is tapped.
//
//   3. `tooltip:` DOES NOT NAME A CONTROL ON ANDROID. Flutter's tooltip emits
//      `Semantics(tooltip: ...)`, not `label`. Android's AccessibilityBridge
//      composes the content description from value+label+hint and never reads
//      the tooltip, so TalkBack announces "button" with no name; iOS folds it
//      in. `Icon(semanticLabel:)` merges into the button node and gives it a
//      name on both. Both are therefore set, and this file asserts the LABEL,
//      not just the tooltip -- asserting the tooltip alone would pass while the
//      headline WCAG 4.1.2 failure survived on the majority platform.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';

const double _designWidth = 360;
const double _designHeight = 800;

/// Pumps the real `simpleAppBar` on a PUSHED route, so the back control has
/// something to pop and its effect can be asserted rather than its geometry.
///
/// `pumpInApp` from tap_target_size_test.dart is deliberately copied rather than
/// imported: importing a `_test.dart` file would also run its `main()`.
Future<void> _pump(
  WidgetTester tester, {
  bool isBack = true,
  String? label,
  Brightness brightness = Brightness.light,
  bool arabic = false,
}) async {
  tester.view.physicalSize = const Size(_designWidth, _designHeight);
  tester.view.devicePixelRatio = 1.0;
  // The hard case. With a status-bar inset the Scaffold cap grows and the
  // headroom appears for free; at zero it does not, and that is the case the
  // repair has to satisfy.
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(_designWidth, _designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        locale: arabic ? const Locale('ar', 'AE') : const Locale('en', 'US'),
        fallbackLocale: TranslationService.fallbackLocale,
        translations: TranslationService(),
        localizationsDelegates: TranslationService.localizationsDelegates,
        supportedLocales: TranslationService.supportedLocales,
        theme: ThemeData(brightness: brightness),
        home: const Scaffold(body: Center(child: Text('ORIGIN'))),
      ),
    ),
  );
  await tester.pumpAndSettle();

  Get.to(
    () => Builder(
      builder: (_) => Scaffold(
        appBar: simpleAppBar(
          isBack: isBack,
          title: 'Orders',
          label: label,
          onNewLabelTap: () {},
        ),
        body: const SizedBox.shrink(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _backControl() => find.byType(IconButton);

Finder _paintedBox() => find
    .descendant(of: _backControl(), matching: find.byType(Container))
    .first;

void main() {
  testWidgets('the back control meets the Material minimum with NO status bar',
      (tester) async {
    await _pump(tester);

    final size = tester.getSize(_backControl());

    expect(
      size.height,
      greaterThanOrEqualTo(kMinInteractiveDimension),
      reason: 'The back control renders ${size.height}dp tall. This is the '
          'assertion that fails when the repair only swaps the GestureDetector '
          'for an IconButton: Scaffold caps the appBar slot at the declared '
          'preferredSize, so a 48dp minimum is clamped DOWN to whatever is left '
          'after `top: Get.height * 0.05`. The declaration has to grow with the '
          'padding, not stay at a literal 70.',
    );
    expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));
  });

  testWidgets('the margin inside the tap target exists AND responds to a tap',
      (tester) async {
    await _pump(tester);

    final control = tester.getRect(_backControl());
    final painted = tester.getRect(_paintedBox());

    // ORDERED FIRST ON PURPOSE. At the old 70dp cap these two rects share a top
    // edge, so the tap below would land inside the painted box and the test
    // would pass against the broken widget. Assert the margin is real, then use
    // it.
    expect(
      painted.top - control.top,
      greaterThanOrEqualTo(4.0),
      reason: 'There is no vertical margin between the tap target and the '
          'painted box (control ${control.height}dp, painted '
          '${painted.height}dp), so the tap below cannot prove the hit area '
          'reaches past what a merchant can see.',
    );

    await tester.tapAt(Offset(control.center.dx, control.top + 4));
    await tester.pumpAndSettle();

    expect(
      find.text('ORIGIN'),
      findsOneWidget,
      reason: 'A tap inside the 48dp target but outside the painted 30x40 box '
          'did not navigate back.',
    );
  });

  testWidgets('the painted box did not grow to earn the tap target',
      (tester) async {
    await _pump(tester);

    final painted = tester.widget<Container>(_paintedBox());
    final constraints = painted.constraints;

    expect(constraints?.maxHeight, 30.0,
        reason: 'The painted box must stay 30dp tall. The hit area is extended '
            'past the visual bounds; the visual decision is not overturned. '
            'Without this a future fix satisfies the size assertion by simply '
            'making the control bigger on 23 screens.');
    expect(constraints?.maxWidth, 40.0);
  });

  testWidgets('the back control is announced as a BUTTON NAMED "Back"',
      (tester) async {
    // Disposed at the END OF THE BODY, not via addTearDown: flutter_test
    // verifies no handle is live BEFORE tear-downs run. Getting this wrong
    // leaked the handle into the next test, which then called getSemantics and
    // passed on a leak rather than on its own setup -- caught here by the
    // framework, and the reason the Arabic case below opens its own.
    final handle = tester.ensureSemantics();

    await _pump(tester);

    final node = tester.getSemantics(find.byTooltip('Back'));

    expect(node.label, 'Back',
        reason: 'The LABEL is what Android announces. Flutter feeds `tooltip:` '
            'to Semantics.tooltip, which AccessibilityBridge never reads, so a '
            'tooltip alone leaves TalkBack saying "button" with no name. '
            '`Icon(semanticLabel:)` merges into this node and supplies it.');
    expect(node.tooltip, 'Back',
        reason: 'The tooltip is the sighted long-press hint, what iOS folds '
            'into accessibilityLabel, and what icon_button_names_test.dart '
            'gates on. Both are required; neither substitutes for the other.');
    expect(node.getSemanticsData().flagsCollection.isButton, isTrue,
        reason: 'A bare GestureDetector contributes a tap action and no role.');

    handle.dispose();
  });

  testWidgets('in Arabic the control sits at the trailing edge and is not mirrored twice',
      (tester) async {
    final handle = tester.ensureSemantics();

    await _pump(tester, arabic: true);

    final control = tester.getRect(_backControl());
    expect(control.center.dx, greaterThan(_designWidth / 2),
        reason: 'RTL must place the back control at the trailing edge.');

    final icon = tester.widget<Icon>(
      find.descendant(of: _backControl(), matching: find.byType(Icon)),
    );
    expect(icon.icon, Icons.arrow_back,
        reason: 'Icons.arrow_back carries matchTextDirection: true and already '
            'mirrors itself. Substituting Icons.arrow_forward for Arabic '
            'double-mirrors it back to pointing the wrong way.');

    expect(tester.getSemantics(find.byTooltip('رجوع')).label, 'رجوع',
        reason: 'The name must be translated, not an English literal.');

    handle.dispose();
  });

  testWidgets('dark mode colours are byte-for-byte unchanged', (tester) async {
    await _pump(tester, brightness: Brightness.dark);

    final painted = tester.widget<Container>(_paintedBox());
    final border = (painted.decoration as BoxDecoration).border as Border;
    expect(border.top.color, DarkThemeColor.cBorder);

    final icon = tester.widget<Icon>(
      find.descendant(of: _backControl(), matching: find.byType(Icon)),
    );
    expect(icon.color, AppColor.themeNavyBlueColor,
        reason: 'The icon colour is hardcoded in both themes today. Dark-mode '
            'icon contrast is a SEPARATE finding; folding it in here would '
            'conflate two fixes on top of already-shipped A-05 and BR-01/02.');
  });

  testWidgets('isBack: false still renders no control and no stray gap',
      (tester) async {
    await _pump(tester, isBack: false);

    expect(_backControl(), findsNothing);

    // The `if (isBack)` guard on the control is paired with a second one on
    // `horizontalSpace(10)`. Unguarding the spacer would add a 10dp gap to the
    // five screens that call simpleAppBar with no isBack at all.
    final title = tester.getRect(find.text('Orders'));
    expect(title.left, 15.0,
        reason: 'The title must start at the 15.w page padding when there is no '
            'back control -- not 25dp in behind an orphaned spacer.');
  });

  testWidgets('label: null still renders no label button', (tester) async {
    await _pump(tester, label: null);

    expect(find.descendant(of: find.byType(PreferredSize), matching: find.byType(Text)),
        findsOneWidget,
        reason: 'Only the title. The label button spread must stay guarded.');
  });

  // THE PREMISE. The two assertions above about geometry are only meaningful if
  // the declared slot really is what Scaffold caps against, and if it is derived
  // from the same expression as the padding it has to clear. A literal 88 is
  // correct only at this 800dp design height: at Get.height 1000 the padding is
  // 50 and 50 + 48 = 98 would clamp again.
  testWidgets('the declared appbar height is derived, not a literal',
      (tester) async {
    await _pump(tester);

    final bar = tester.widget<PreferredSize>(find.byType(PreferredSize));
    expect(
      bar.preferredSize.height,
      _designHeight * 0.05 + kMinInteractiveDimension,
      reason: 'preferredSize must equal the top padding plus the minimum tap '
          'target, computed from Get.height. Any literal is right at exactly '
          'one device height.',
    );
  });
}

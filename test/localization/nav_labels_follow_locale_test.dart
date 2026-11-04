// P2.5-B-11 -- the five bottom-navigation labels kept the language the merchant just left.
//
// THE DEFECT. `DashboardManagerController` resolved its five labels in an INSTANCE FIELD
// INITIALISER (dashboard_manager_controller.dart:14-20), so `.tr` ran exactly once, at
// construction, and the labels were frozen to whatever `Get.locale` held at that moment.
//
// `.tr` re-reads `Get.locale` on every invocation
// (get-4.7.3/lib/get_utils/src/extensions/internacionalization.dart:81-111) -- so every OTHER
// `.tr` on the screen re-resolves after a switch, and only these five do not. The switch path
// cannot reach them:
//
//   app_settings.dart:87 -> lang_widget.dart:177/:222 -> TranslationService.changeLocale
//     -> Get.updateLocale -> forceAppUpdate() -> engine.performReassemble()
//
// which REBUILDS the tree but CONSTRUCTS NO CONTROLLER. And `Get.put` DISCARDS the instance it
// is handed when a live, non-dirty registration already exists (get-4.7.3 get_instance.dart
// :157-186, guard at :168), so re-running `DashboardBinding.dependencies()` cannot replace the
// frozen one either.
//
// THE COROLLARY A FIXER WILL OTHERWISE MISS: moving the list into `onInit()` is NOT a fix, for
// the same reason -- `onInit` runs only on the instance actually inserted, which is the frozen
// one. The repair has to re-resolve on READ, hence a getter.
//
// WHY THIS IS A CONTROLLER TEST AND NOT A RENDERED ONE. Pumping `DashBoardManagerScreen` is not
// available at this cost: its `IndexedStack` builds all five children, and between them
// home_screen.dart, order_screen.dart, products_screen.dart and category_screen.dart stand up
// six controllers and call `getData()` from `initState` -- live HTTP. The getter is the unit that
// broke, so the getter is the unit under test; a rendered check needs a stub layer for six
// controllers and belongs in its own slice.
//
// TWO HARNESS FACTS, BOTH MEASURED HERE RATHER THAN ASSUMED:
//
//  1. `Get.locale` MUST BE SEEDED. internacionalization.dart:88 is
//     `if (Get.locale?.languageCode == null) return this;` -- it returns the RAW KEY and never
//     consults `fallbackLocale`. In a bare flutter_test nothing sets `Get.locale`, so a test
//     written as "fallbackLocale is ar, so with no switch I must see Arabic" goes RED against a
//     CORRECT fix. (First-launch Arabic in the real app comes from `Get.locale`, which
//     store_go.dart:45 sets from `TranslationService.currentLocale` -- not from the fallback.)
//
//  2. `TranslationService.changeLocale` CANNOT RUN IN THIS HARNESS, and the reason is worth
//     recording. Its first statement is `Prefs.setLanguage` (translation_service.dart:70), and
//     `Prefs` writes through the `getStorage` global (prefer.dart:171, main.dart:19/:31), whose
//     `GetStorage.init()` fails under flutter_test with
//     `MissingPluginException(No implementation found for method
//     getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)` -- measured,
//     and `changeLocale` then dies on `Null check operator used on a null value`. So the switch
//     below is driven by `Get.updateLocale`, which is `changeLocale`'s SECOND statement
//     (translation_service.dart:72) and the one that moves the locale. `changeLocale` is not
//     merely assumed to end there: the last test pins it.
//
//  3. `Get.updateLocale` CANNOT BE CALLED HERE EITHER, and finding that out is why this file
//     looks the way it does. It is
//
//         Future<void> updateLocale(Locale l) async { Get.locale = l; await forceAppUpdate(); }
//         Future<void> forceAppUpdate() async { await engine.performReassemble(); }
//         (get-4.7.3 extension_navigation.dart:1040-1060)
//
//     The FIRST statement is synchronous and is the one that moves the locale. The second cannot
//     run under `AutomatedTestWidgetsFlutterBinding`: `performReassemble` -> `scheduleWarmUpFrame`
//     trips `assert(inTest)` in a plain `test()`
//     (flutter_test/lib/src/binding.dart:2351-2355), and inside a `testWidgets` it gets past that
//     only to trip `assert(schedulerPhase == SchedulerPhase.idle)` in `handleBeginFrame`
//     (flutter/lib/src/scheduler/binding.dart:1253). Both measured here, in that order.
//
//     AND THE FAILURE HIDES ITSELF: it is thrown across an asynchronous gap, so a case whose own
//     assertion fails FIRST reports the assertion and never mentions the binding. The first draft
//     of this file called `Get.updateLocale`; its two switch cases "failed on the label
//     comparison", which looks exactly like the defect -- so the repair would have landed, and
//     those two cases would then have begun failing on the binding instead of passing. That is
//     the "a test that fails for the wrong reason" trap, caught by driving the bite test rather
//     than trusting the red.
//
//     So the switch below assigns `Get.locale` directly: `updateLocale`'s own first statement,
//     nothing more. What the reassemble adds is the WIDGET rebuild, and that was never the broken
//     part -- `performReassemble` reaches an unconditional `markNeedsBuild()`
//     (flutter/lib/src/widgets/binding.dart:1701-1710 -> framework.dart:3466-3476 -> :3767-3772),
//     so the `Obx` at dashboard_manager.dart:54 already re-ran and every other `.tr` on the
//     screen already re-resolved. These five did not, because they were never re-read at all.
//     The unit that broke is the getter, so the getter is what is driven. The last two tests pin
//     both halves of the stand-in so it cannot drift from the shipped path.
//
// `TestWidgetsFlutterBinding.ensureInitialized()` is the first line of main() deliberately --
// `Get.updateLocale` reaches `Get.engine`, which calls `WidgetsFlutterBinding.ensureInitialized()`,
// and if that runs first it installs a REAL binding that the test binding cannot then replace.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/dashboard_manager_controller/dashboard_manager_controller.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/utils/images.dart';

const _ar = Locale('ar', 'AE');
const _en = Locale('en', 'US');

const _arTitles = ['الرئيسية', 'الطلبات', 'المنتجات', 'التصنيفات', 'المزيد'];
const _enTitles = ['Home', 'Orders', 'Products', 'Categories', 'More'];
const _keys = ['Home', 'Orders', 'Products', 'Categories', 'More'];

List<String> titlesOf(DashboardManagerController c) =>
    c.naviBarItemList.map((e) => e['title'] as String).toList();

/// The locale change as the app performs it, minus the part the test binding refuses.
///
/// `Get.updateLocale(l)` is `{ Get.locale = l; await forceAppUpdate(); }`. This is the first
/// statement -- the one that moves the locale. The second reassembles the widget tree and cannot
/// run here; see harness fact 3 in the header, and the two pin tests at the bottom of this file.
void switchLocale(Locale l) => Get.locale = l;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.addTranslations(TranslationService().keys);
    Get.fallbackLocale = TranslationService.fallbackLocale;
    Get.locale = _ar; // mandatory -- see harness fact 1
  });

  tearDown(Get.reset);

  // THE CONTROL that separates this defect from a translation gap. It passes both before and
  // after the repair; if it ever fails, the problem is the ar map, not the getter.
  test('first launch, no switch: the labels are in the seeded locale', () {
    final c = Get.put(DashboardManagerController());
    expect(titlesOf(c), _arTitles);
  });

  test('switching ar -> en re-resolves the labels on the SAME controller', () {
    final c = Get.put(DashboardManagerController());
    expect(titlesOf(c), _arTitles, reason: 'premise: it starts Arabic');

    switchLocale(_en);

    expect(titlesOf(c), _enTitles,
        reason: 'the merchant switched to English and the bottom bar still reads '
            '${titlesOf(c)} -- the labels were resolved once, at construction');
  });

  test('switching en -> ar re-resolves them too (both directions)', () {
    Get.locale = _en;
    final c = Get.put(DashboardManagerController());
    expect(titlesOf(c), _enTitles, reason: 'premise: it starts English');

    switchLocale(_ar);

    expect(titlesOf(c), _arTitles);
  });

  // NEGATIVE CONTROL. The cheap wrong fix is to throw the controller away on a locale change
  // (Get.delete / Get.replace / offAllNamed). That would re-resolve the labels AND lose the
  // merchant's place in the app. Controller IDENTITY is the assertion that catches it -- note
  // that `screens` identity alone would not, since a fresh controller hands back a fresh list
  // without failing an `identical` taken off that same new instance.
  test('the switch does not throw the controller away', () {
    final c = Get.put(DashboardManagerController());
    c.currantIndex.value = 3;
    final screensBefore = c.screens;

    switchLocale(_en);

    expect(identical(Get.find<DashboardManagerController>(), c), isTrue,
        reason: 'the locale switch replaced the controller instance');
    expect(c.currantIndex.value, 3,
        reason: 'the merchant was on tab 3 and the switch sent them back to tab 0');
    expect(identical(c.screens, screensBefore), isTrue,
        reason: 'the five screens were rebuilt, losing their state');
  });

  // NEGATIVE CONTROL. The getter must still hand back the same SHAPE the vendored bar consumes:
  // dashboard_manager.dart:117 maps it to BottomBarItem, reading element['icon'] TWICE (:120
  // icon, :129 selectedIcon) and element['title'] once (:138), and the TabController is built
  // with a hard `length: 5` (:28).
  test('the shape the bottom bar consumes is unchanged', () {
    final c = Get.put(DashboardManagerController());
    final items = c.naviBarItemList;

    expect(items.length, 5, reason: 'TabController is constructed with length: 5');

    const expectedIcons = [
      'assets/svg/dashboard.svg',
      'assets/svg/orders.svg',
      'assets/svg/product.svg',
      'assets/svg/categories.svg',
      'assets/svg/more.svg',
    ];
    expect(
      [DefaultImages.dashboardIcn, DefaultImages.ordersIcn, DefaultImages.productIcn,
        DefaultImages.categoriesIcn, DefaultImages.moreIcn],
      expectedIcons,
      reason: 'premise: these are the DefaultImages constants the order is asserted against',
    );

    for (var i = 0; i < 5; i++) {
      final icon = items[i]['icon'];
      expect(icon, isA<String>(),
          reason: 'SvgPicture.asset takes a non-nullable String; entry $i is ${icon.runtimeType}');
      expect(icon as String, isNotEmpty);
      expect(icon, expectedIcons[i], reason: 'the tab order moved at index $i');

      expect(items[i]['title'], isA<String>(),
          reason: 'Text() takes a non-nullable String; entry $i is not one');
    }
  });

  // NEGATIVE CONTROL. translation_keys_test.dart sweeps lib/ for literal `.tr` keys and requires
  // each in both maps. Measured: 'Home', 'Categories' and 'More' have NO other literal `.tr`
  // site in lib/, so a repair that replaced the five literals with a loop over a list of keys
  // would silently drop three keys out of that sweep's coverage. Both halves are asserted: the
  // keys resolve in both maps, and the five literals are still in the source.
  test('all five keys still exist in both maps, and still appear as literals in the source', () {
    final maps = TranslationService().keys;
    for (final k in _keys) {
      expect(maps['ar']!.containsKey(k), isTrue, reason: '"$k" is missing from the ar map');
      expect(maps['en']!.containsKey(k), isTrue, reason: '"$k" is missing from the en map');
    }

    final src = File(
      'lib/core/controller/dashboard_manager_controller/dashboard_manager_controller.dart',
    ).readAsStringSync();
    for (final k in _keys) {
      expect(src.contains("'$k'.tr"), isTrue,
          reason: "the literal \"'$k'.tr\" is gone from the controller, so translation_keys_test "
              'no longer sees it; three of these five have no other literal site in lib/');
    }
  });

  // THE STAND-IN IS PINNED TO THE REAL PATH. These tests drive `Get.updateLocale` because
  // `changeLocale` cannot run here (harness fact 2). This asserts the two have not drifted:
  // `changeLocale` must still end in `Get.updateLocale`, and must still map the two codes to the
  // two supported locales.
  test('changeLocale still routes through Get.updateLocale, so the stand-in is faithful', () {
    final src = File('lib/translations/translation_service.dart').readAsStringSync();
    expect(src.contains('Get.updateLocale(locale)'), isTrue,
        reason: 'TranslationService.changeLocale no longer calls Get.updateLocale, so driving '
            'the locale directly in this file is no longer equivalent to the real switch');
    expect(TranslationService.locales, [_ar, _en],
        reason: 'the two locales this file switches between are no longer the supported set');
  });

  // THE SECOND HALF OF THE PIN. `switchLocale` stands in for `Get.updateLocale` by assigning
  // `Get.locale`. That is only faithful while `updateLocale`'s FIRST act is that same assignment,
  // synchronously, before it awaits anything. If a future GetX bumps that behind the await -- or
  // routes it through a setter with side effects -- this file would be testing something the app
  // no longer does, and every case in it would still pass. So assert it against the vendored
  // source, which is pinned by pubspec.lock.
  test('Get.updateLocale still assigns Get.locale synchronously, before the reassemble', () {
    final get = File(
      '/root/.pub-cache/hosted/pub.dev/get-4.7.3/lib/get_navigation/src/'
      'extension_navigation.dart',
    );
    expect(get.existsSync(), isTrue,
        reason: 'premise: the vendored GetX source is where pubspec.lock pins it');

    final body = RegExp(
      r'Future<void>\s+updateLocale\(Locale\s+l\)\s+async\s*\{([^}]*)\}',
    ).firstMatch(get.readAsStringSync());
    expect(body, isNotNull, reason: 'premise: updateLocale is still declared as an async method');

    final src = body!.group(1)!;
    final assign = src.indexOf('Get.locale = l');
    final awaited = src.indexOf('await');
    expect(assign, greaterThanOrEqualTo(0),
        reason: 'updateLocale no longer assigns Get.locale directly: $src');
    expect(awaited, greaterThan(assign),
        reason: 'updateLocale now awaits BEFORE assigning the locale, so assigning Get.locale is '
            'no longer equivalent to its synchronous prefix: $src');
  });
}

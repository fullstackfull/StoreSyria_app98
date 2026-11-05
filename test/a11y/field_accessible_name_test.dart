// P2.5-A-10 -- the accessible name of the shared merchant text field.
//
// WHAT WAS WRONG, and it is worse than "the label is not associated".
// `AppTextField` renders its visible label as a SIBLING `Text(title!)` in a
// plain `Column` -- which does no semantics merging -- and gives the field only
// `hintText`. Nothing associates them: a grep for labelText / InputDecoration.
// label / MergeSemantics / Semantics / semanticsLabel over the whole file
// returned zero matches.
//
// Because the SDK makes the hint's own name conditional, the consequence is not
// a wrong name but NO name:
//
//   empty field   ->  "Damascus Textiles"   (named by its placeholder)
//   after typing  ->  ""                    (nameless)
//
// input_decorator.dart visits `label!` always and `hint!` only `if (isFocused)`
// or `else if (label == null)`; the hint sits in an `AnimatedOpacity` and
// `visitChildrenForSemantics` skips an alpha-0 child. So the moment a merchant
// types, the field stops having a name at all -- on 45 call sites, including
// every password field.
//
// WHY THERE IS NO `textField: true` ON THE WRAPPER. This is the one token that
// would have made the repair a no-op, and it was caught by measuring rather
// than reasoning. `RenderEditable` already sets `isTextField`; two nodes
// carrying that flag CONFLICT; a sibling conflict forces the field to form its
// OWN node, so the wrapper's label never reaches it. Measured, the patched
// widget then reported label == "" -- identical to the defect -- plus a phantom
// edit box with a name, no value and no actions. Obscured fields were worse
// still: the phantom carried TEXTFIELD without OBSCURED.
//
// WHY THE VISIBLE LABEL IS *NOT* WRAPPED IN ExcludeSemantics. The first draft
// did that too. Measured: the field's name is byte-identical with and without
// it, so exclusion only removes the label from screen-reader traversal and
// touch exploration for zero naming benefit. Keeping it is the `<label for>`
// behaviour; the cost is hearing the word twice on a linear swipe, which is the
// right trade for a form label.
//
// WHAT IS DELIBERATELY NOT DONE. `hintText:` is NOT swapped for a hand-built
// `hint:` widget wrapped in ExcludeSemantics. That would drop the placeholder
// from the name of an EMPTY field, which is tidier but is not the failure: an
// empty field already announces its label first, and the swap silently drops
// `hintMaxLines` and `hintTextDirection` handling. `labelText: title` is also
// not used -- it renders as a floating Material label inside the border, so
// every field would show its label twice unless the sibling Text were deleted,
// which would change the admin's form language across ten files.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/translation_service.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/app_txt_field.dart';
import 'package:store_go_app/view/new_widgets/search_widget.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the field is named by its visible label, empty AND filled',
      (tester) async {
    final handle = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(
      tester,
      AppTextField(
        title: 'Store name',
        hint: 'Damascus Textiles',
        controller: controller,
      ),
    );

    expect(tester.getSemantics(find.byType(TextField)).label,
        contains('Store name'),
        reason: 'An EMPTY field is not named by its label.');

    // THE CASE THAT MATTERS. A test that pumps only an empty field passes today
    // for the wrong reason, through the hint. This is the state that measured
    // "" before the repair.
    await tester.enterText(find.byType(TextField), 'Damascus Textiles Co');
    await tester.pumpAndSettle();

    final node = tester.getSemantics(find.byType(TextField));
    expect(node.label, contains('Store name'),
        reason: 'A FILLED field has no accessible name. The hint is dropped '
            'from the tree once it is hidden, and there is no label to fall '
            'back to.');

    // ONE node, not two. If the wrapper gained `textField: true` the field
    // would split off and the name would be on a phantom node instead.
    expect(node.getSemanticsData().flagsCollection.isTextField, isTrue,
        reason: 'The field lost its own role. The wrapper must MERGE into the '
            "field's node, not replace it -- so no `container: true` and no "
            '`excludeSemantics: true`.');
    expect(node.value, 'Damascus Textiles Co',
        reason: "The field's own value stopped reaching the node.");

    handle.dispose();
  });

  testWidgets('a password field stays obscured and does not leak its value',
      (tester) async {
    final handle = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(
      tester,
      AppTextField(
        title: 'Password',
        hint: '........',
        obscureText: true,
        controller: controller,
      ),
    );

    await tester.enterText(find.byType(TextField), 'hunter2');
    await tester.pumpAndSettle();

    final node = tester.getSemantics(find.byType(TextField));
    expect(node.label, contains('Password'));
    expect(node.getSemanticsData().flagsCollection.isObscured, isTrue,
        reason: 'The obscured flag was dropped. A wrapper that replaces the '
            "field's config instead of merging into it loses this, and a "
            'screen reader would then read the password aloud.');
    expect(node.value, isNot(contains('hunter2')),
        reason: 'The plaintext password reached the semantics value.');

    handle.dispose();
  });

  testWidgets('a field with no title and no semanticLabel is left alone',
      (tester) async {
    final handle = tester.ensureSemantics();

    await _pump(tester, const AppTextField(hint: 'Search products'));

    // The other ten call sites pass neither, and must be byte-identical
    // no-ops: `label: null` means no annotation at all.
    expect(tester.getSemantics(find.byType(TextField)).label,
        contains('Search products'));

    handle.dispose();
  });

  testWidgets('the search row is named even though it has no title',
      (tester) async {
    final handle = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

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
          home: Scaffold(
            body: Builder(
              builder: (context) => SearchRowWidget(
                context: context,
                controller: controller,
                hint: 'Search products',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'tea');
    await tester.pumpAndSettle();

    final node = tester.getSemantics(find.byType(TextField));
    expect(node.label, contains('Search'),
        reason: 'SearchRowWidget passes no title, so it needed a name of its '
            'own -- four screens use it and all of them went nameless the '
            'moment a merchant typed.');
    expect(node.label, isNot(contains('Search products Search products')),
        reason: 'Using the hint as the name makes the field announce the same '
            'sentence twice.');

    handle.dispose();
  });

  group('negative controls -- the repair must not have broken these', () {
    testWidgets('exactly one TextField, and the visible label still rendered',
        (tester) async {
      await _pump(
        tester,
        const AppTextField(title: 'Store name', hint: 'Damascus Textiles'),
      );

      // field_focus_contrast_test.dart does tester.widget<TextField>(
      // find.byType(TextField)) in four places, which throws on 0 or 2.
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Store name'), findsOneWidget,
          reason: 'The visible label widget was deleted. It is what a sighted '
              'merchant reads, and ExcludeSemantics would have been the wrong '
              'fix anyway -- it buys no name and costs touch exploration.');
    });

    testWidgets('the dark focus colour is unchanged', (tester) async {
      await _pump(
        tester,
        const AppTextField(title: 'Store name', hint: 'Damascus Textiles'),
        dark: true,
      );

      expect(tester.widget<TextField>(find.byType(TextField)).cursorColor,
          DarkThemeColor.cPrimary,
          reason: 'BR-03 set this. A semantics change must not touch it.');
    });

    testWidgets('the const constructor survives', (tester) async {
      // field_focus_contrast_test.dart:70 instantiates this inside a
      // `const Scaffold(...)`, so the new optional parameter must not break
      // const-ness. This line failing to compile IS the assertion.
      await _pump(tester, const AppTextField(title: 'X', hint: 'y'));
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  testWidgets('PREMISE: a sibling label in a plain Column names nothing',
      (tester) async {
    // If this ever stops holding, the repair above is unnecessary and the
    // reasoning in this file needs revisiting.
    final handle = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(
      tester,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Store name'),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Damascus Textiles'),
          ),
        ],
      ),
    );

    await tester.enterText(find.byType(TextField), 'typed');
    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.byType(TextField)).label, '',
        reason: 'A Column does not merge semantics, so an unassociated label '
            'leaves the field nameless once the hint is hidden. This is the '
            'defect, reproduced in isolation.');

    handle.dispose();
  });
}

// Every icon-only control must have an accessible name.
//
// `grep -rn "Semantics(\|semanticLabel" lib` returned ZERO across 198 files,
// and not one of the app's `IconButton`s carried a `tooltip`. An IconButton
// renders no text, so without one it reaches TalkBack and VoiceOver as
// "button" and nothing else: a merchant using a screen reader could not tell
// the close button from the clear button from the delete button.
//
// `tooltip` is the right mechanism rather than a hand-rolled Semantics
// wrapper: Flutter's IconButton feeds it straight to the semantics node AND
// gives sighted users a long-press hint, so one property serves both.
//
// WHAT IS CHECKED: every real `IconButton(` in lib/ has a `tooltip:` within
// the few lines that open it.
//
// WHAT IS DELIBERATELY NOT CHECKED: this project's own `CommonIconButton` and
// `SmallCommonIconButton` (lib/view/widget/common_button.dart). Their names
// end in "IconButton(" -- which is how a first version of this sweep matched
// them and tried to pass them a `tooltip` they do not accept, producing 36
// analyzer errors -- but they render a visible title, so they already have an
// accessible name and are not icon-only.
//
// THAT EXCLUSION IS TIED TO A RENDER, not to a substring, since P2.5-R-04.
// It used to be pinned by `src.contains('title!')` -- the force-unwrap was
// standing in for "renders a title". R-04 repaired those force-unwraps
// (the widgets declared the parameter optional and then crashed without it),
// which broke the proxy while the property it stood for was still true. The
// test below now PUMPS the widget and looks for the text, which is what the
// exclusion actually depends on and cannot be falsified by a refactor.
//
// Comments are blanked (codeOnly) so the prose above cannot satisfy it.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/widget/common_button.dart';

import '../support/source_tree.dart';

/// Lines within an IconButton's opening where a `tooltip:` may appear.
///
/// Large enough for the formatting actually used in this codebase, small
/// enough that it cannot reach a *different* widget's arguments further down.
const _window = 12;

void main() {
  test('every icon-only IconButton in lib/ has an accessible name', () {
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      final lines = codeOnly(file.readAsStringSync()).split('\n');

      for (var i = 0; i < lines.length; i++) {
        // A real Flutter IconButton: "IconButton(" NOT preceded by a letter,
        // which is what excludes CommonIconButton / SmallCommonIconButton.
        if (!RegExp(r'(?<![A-Za-z])IconButton\(').hasMatch(lines[i])) continue;

        final end = (i + _window < lines.length) ? i + _window : lines.length;
        final block = lines.sublist(i, end).join('\n');

        if (!block.contains('tooltip:')) {
          offenders.add('${relative(file)}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'An IconButton renders no text, so without a tooltip it reaches '
          'a screen reader as "button" and nothing else:\n  '
          '${offenders.join('\n  ')}',
    );
  });

  test('the custom button classes still exist to be excluded', () {
    final src = codeOnly(
      libDartFiles()
          .firstWhere(
              (f) => relative(f).endsWith('view/widget/common_button.dart'))
          .readAsStringSync(),
    );
    expect(src.contains('CommonIconButton'), isTrue);
    expect(src.contains('SmallCommonIconButton'), isTrue);
  });

  // THE EXCLUSION, ASSERTED BY RENDERING. If either widget ever stops painting
  // its title, it becomes icon-only and the sweep above has a hole -- so this
  // pumps them and looks for the text a screen reader would announce.
  testWidgets('the excluded buttons really do render their title', (tester) async {
    for (final entry in <String, Widget>{
      'CommonIconButton': CommonIconButton(title: 'Save order', onPressed: () {}),
      'SmallCommonIconButton':
          SmallCommonIconButton(title: 'Edit order', onPressed: () {}),
    }.entries) {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) =>
              GetMaterialApp(home: Scaffold(body: Center(child: entry.value))),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('order'),
        findsOneWidget,
        reason: '${entry.key} is excluded from the tooltip sweep because it '
            'renders a visible title. It no longer renders one, so it is now '
            'icon-only and needs its own accessible name.',
      );
    }
  });

  test('the detector finds an unlabelled IconButton when one is there', () {
    // Anti-vacuity: the regex is the whole test, and a regex that stops
    // matching fails silently and forever.
    const bad = 'IconButton(\n  onPressed: () {},\n  icon: Icon(Icons.close),\n)';
    const good = 'IconButton(\n  tooltip: "Close",\n  onPressed: () {},\n)';
    const custom = 'CommonIconButton(\n  title: "Save",\n  onPressed: () {},\n)';

    final re = RegExp(r'(?<![A-Za-z])IconButton\(');
    expect(re.hasMatch(bad), isTrue, reason: 'a real IconButton must match');
    expect(bad.contains('tooltip:'), isFalse, reason: 'and be reported');
    expect(good.contains('tooltip:'), isTrue, reason: 'a labelled one must not');
    expect(re.hasMatch(custom), isFalse,
        reason: 'CommonIconButton must NOT match -- matching it is what caused '
            '36 analyzer errors the first time round');
  });
}

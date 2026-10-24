// The app ROOT must actually pass the localization config.
//
// test/localization/ambient_direction_test.dart proves that
// TranslationService's delegates produce a right-to-left tree. It cannot prove
// that GetMaterialApp is given them, because it builds its own
// GetMaterialApp -- so on its own it would keep passing while the shipped app
// rendered LTR, which is exactly the state this repository was already in:
// `flutter_localizations` was a declared dependency for the whole life of the
// project and no widget ever received it.
//
// This test reads lib/store_go.dart and asserts the wiring is present. That is
// the right shape for the question: "is the root wired?" is decidable
// statically, and it is what regresses when somebody tidies an argument list.
//
// Comments and string literals are blanked (codeOnly, test/support/
// source_tree.dart) so the long explanatory comment next to the wiring in
// store_go.dart -- which names both parameters -- cannot make this pass on its
// own prose.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  late String code;

  setUpAll(() {
    final file = File('${packageRoot().path}/lib/store_go.dart');
    expect(file.existsSync(), isTrue, reason: 'lib/store_go.dart is the app root');
    code = codeOnly(file.readAsStringSync());
  });

  test('store_go.dart passes localizationsDelegates to GetMaterialApp', () {
    expect(
      code,
      contains('localizationsDelegates:'),
      reason: 'Without it MaterialApp uses DefaultWidgetsLocalizations, whose '
          'textDirection is always LTR -- and Arabic is this app\'s default '
          'and fallback locale.',
    );
    expect(
      code,
      contains('TranslationService.localizationsDelegates'),
      reason: 'It must come from TranslationService so the behavioural test '
          'and the shipped app are checking the same list.',
    );
  });

  test('store_go.dart passes supportedLocales to GetMaterialApp', () {
    expect(code, contains('supportedLocales:'));
    expect(code, contains('TranslationService.supportedLocales'));
  });

  test('the two deliberate LTR pins are still deliberate', () {
    // delivery_boy_widget and customer_widget pin LTR for numeric rows. Those
    // are correct and must survive the ambient direction becoming RTL -- a
    // phone number or an amount reads left-to-right in an Arabic UI too.
    for (final path in const [
      'lib/view/new_widgets/delivery_boy_widget.dart',
      'lib/view/new_widgets/customer_widget.dart',
    ]) {
      final src = codeOnly(File('${packageRoot().path}/$path').readAsStringSync());
      expect(
        src,
        contains('TextDirection.ltr'),
        reason: '$path pins LTR deliberately for a numeric row.',
      );
    }
  });

  test('no file in lib/ hard-codes a TextDirection from a stale source', () {
    // A Directionality wrapper is allowed, but it must derive from the same
    // locale the app root uses, or a screen can disagree with its own app.
    // The four wrappers that exist all do (two pin LTR on purpose, two read
    // TranslationService.currentLocale). This fails if a fifth appears that
    // reads something else, e.g. Prefs directly.
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      final src = codeOnly(file.readAsStringSync());
      if (!src.contains('Directionality(')) continue;

      final derivesFromLocale = src.contains('TranslationService.currentLocale') ||
          src.contains('TranslationService.isRTL') ||
          src.contains('Get.locale') ||
          src.contains('Directionality.of(');
      final pinsDeliberately = src.contains('TextDirection.ltr') &&
          !src.contains('TextDirection.rtl');

      if (!derivesFromLocale && !pinsDeliberately) {
        offenders.add(relative(file));
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'These wrap themselves in a Directionality that neither derives '
          'from the app locale nor pins a direction deliberately, so they can '
          'disagree with the ambient direction: ${offenders.join(', ')}',
    );
  });
}

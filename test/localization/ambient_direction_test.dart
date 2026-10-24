// Regression guard for the app's product-defining UI bug.
//
// `pubspec.yaml` declares `flutter_localizations`, Arabic is BOTH the default
// locale (`prefer.dart`) and the fallback (`TranslationService.fallbackLocale`
// -> Locale('ar','AE')) -- and `GetMaterialApp` was given neither
// `localizationsDelegates` nor `supportedLocales`.
//
// Without GlobalWidgetsLocalizations, MaterialApp falls back to
// DefaultWidgetsLocalizations, whose textDirection is ALWAYS
// TextDirection.ltr. So the ambient Directionality was left-to-right while
// every string on screen was Arabic. Three consequences, all of them silent:
//
//   * the `*Directional` layout calls across the app (PositionedDirectional,
//     EdgeInsetsDirectional) resolve start/end as left/right, so layouts
//     written to mirror did not mirror -- direction-aware code, inert;
//   * only four files self-corrected by wrapping themselves in an explicit
//     Directionality, and two of those pin LTR deliberately for numeric rows;
//   * Material and Cupertino built-ins -- date pickers, text-selection menus,
//     tooltips -- rendered ENGLISH labels regardless of the app locale.
//
// `TranslationService.isRTL` existed and was never called anywhere in lib/.
//
// These tests pump a real GetMaterialApp wired exactly as the app root wires
// it, and read the ambient direction and the resolved Material locale out of
// the tree. The first one FAILS before the fix.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/translation_service.dart';

/// Pumps a GetMaterialApp configured the way StoreGoApp configures it, and
/// hands back what the widget tree actually resolved.
Future<({TextDirection direction, Locale? materialLocale})> _pump(
  WidgetTester tester,
  Locale locale,
) async {
  TextDirection? direction;
  Locale? materialLocale;

  await tester.pumpWidget(
    GetMaterialApp(
      locale: locale,
      fallbackLocale: TranslationService.fallbackLocale,
      translations: TranslationService(),
      localizationsDelegates: TranslationService.localizationsDelegates,
      supportedLocales: TranslationService.supportedLocales,
      home: Builder(
        builder: (context) {
          direction = Directionality.of(context);
          materialLocale = Localizations.localeOf(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  return (direction: direction!, materialLocale: materialLocale);
}

void main() {
  testWidgets('Arabic gives the tree a right-to-left ambient Directionality',
      (tester) async {
    final r = await _pump(tester, const Locale('ar', 'AE'));
    expect(
      r.direction,
      TextDirection.rtl,
      reason: 'Arabic is the default AND the fallback locale. An LTR ambient '
          'direction makes every EdgeInsetsDirectional/PositionedDirectional '
          'in the app resolve the wrong way round, silently.',
    );
  });

  testWidgets('English still gives the tree a left-to-right direction',
      (tester) async {
    final r = await _pump(tester, const Locale('en', 'US'));
    expect(r.direction, TextDirection.ltr);
  });

  testWidgets('Material resolves Arabic rather than falling back to English',
      (tester) async {
    final r = await _pump(tester, const Locale('ar', 'AE'));
    expect(
      r.materialLocale?.languageCode,
      'ar',
      reason: 'If Material resolves en here, its built-ins -- the date picker '
          'in date_filter.dart, text-selection menus, default tooltips -- '
          'render English labels to an Arabic merchant.',
    );
  });

  test('the delegate list carries all three global delegates', () {
    final delegates = TranslationService.localizationsDelegates.toList();
    expect(delegates, contains(GlobalMaterialLocalizations.delegate));
    expect(delegates, contains(GlobalWidgetsLocalizations.delegate));
    expect(
      delegates,
      contains(GlobalCupertinoLocalizations.delegate),
      reason: 'Cupertino widgets appear on iOS even in a Material app.',
    );
  });

  test('supported locales cover both shipped languages', () {
    final codes =
        TranslationService.supportedLocales.map((l) => l.languageCode).toSet();
    expect(codes, containsAll(<String>['ar', 'en']));
  });

  test('isRTL agrees with the locale it is asked about', () {
    Get.locale = const Locale('ar', 'AE');
    expect(TranslationService.isRTL, isTrue);
    Get.locale = const Locale('en', 'US');
    expect(TranslationService.isRTL, isFalse);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'ar.dart';
import 'en.dart';
import 'package:store_go_app/utils/prefer.dart';

class TranslationService extends Translations {
  static const fallbackLocale = Locale('ar', 'AE');

  static final locales = [
    const Locale('ar', 'AE'),
    const Locale('en', 'US'),
  ];

  /// The delegates `GetMaterialApp` must be given, or the app renders
  /// left-to-right no matter what locale it is in.
  ///
  /// `flutter_localizations` was declared in pubspec.yaml and never wired up.
  /// Without GlobalWidgetsLocalizations, MaterialApp falls back to
  /// DefaultWidgetsLocalizations, whose textDirection is ALWAYS
  /// TextDirection.ltr -- so with Arabic as both the default and the fallback
  /// locale, every `*Directional` layout call in the app resolved start/end as
  /// left/right and the mirroring silently did not happen. Material's own
  /// built-ins (date pickers, selection menus, tooltips) also rendered their
  /// English labels regardless of locale.
  ///
  /// Cupertino is included because Cupertino widgets appear on iOS even inside
  /// a Material app.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// What Material is allowed to resolve to.
  ///
  /// This is `locales`, named for what `GetMaterialApp` calls it. Keep the two
  /// in step: a locale offered in the language screen but missing here
  /// resolves to the FIRST entry instead, which would silently hand an English
  /// user an Arabic date picker.
  static List<Locale> get supportedLocales => locales;

  @override
  Map<String, Map<String, String>> get keys => {
    'ar': ar,
    'en': en,
  };

  static Locale get currentLocale {
    final langCode = Get.locale?.languageCode ?? Prefs.getLanguage();

    if (langCode == 'en') {
      return const Locale('en', 'US');
    }

    return const Locale('ar', 'AE');
  }

  static bool get isRTL {
    return currentLocale.languageCode == 'ar';
  }

  static void changeLocale(String langCode) {
    final locale = langCode == 'en'
        ? const Locale('en', 'US')
        : const Locale('ar', 'AE');

    Prefs.setLanguage(locale.languageCode);

    Get.updateLocale(locale);
  }
}
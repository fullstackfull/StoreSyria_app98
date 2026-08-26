import 'package:flutter/material.dart';
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
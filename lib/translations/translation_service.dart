//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'ar.dart';
// import 'en.dart';
//
// class TranslationService extends Translations {
//   static const Locale fallbackLocale = Locale('ar', 'AE');
//
//   static final List<Locale> locales = [
//     const Locale('ar', 'AE'),
//     const Locale('en', 'US'),
//   ];
//
//   @override
//   Map<String, Map<String, String>> get keys => {
//         'ar': ar,
//         'en': en,
//       };
//
//   static Locale get currentLocale {
//     if (Get.isRegistered<AppSettingsController>()) {
//       return Get.find<AppSettingsController>().locale.value;
//     }
//
//     final String langCode = Get.locale?.languageCode ?? 'ar';
//
//     if (langCode == 'en') {
//       return const Locale('en', 'US');
//     }
//
//     return const Locale('ar', 'AE');
//   }
//
//   static bool get isRTL {
//     if (Get.isRegistered<AppSettingsController>()) {
//       return Get.find<AppSettingsController>().isArabic;
//     }
//
//     return currentLocale.languageCode == 'ar';
//   }
//
//   static Future<void> changeLocale(String langCode) async {
//     if (Get.isRegistered<AppSettingsController>()) {
//       await Get.find<AppSettingsController>().changeLanguage(langCode);
//       return;
//     }
//
//     if (Get.isRegistered<StorageService>()) {
//       await Get.find<StorageService>().saveLanguage(langCode);
//     }
//
//     final Locale locale = langCode == 'en'
//         ? const Locale('en', 'US')
//         : const Locale('ar', 'AE');
//
//     await Get.updateLocale(locale);
//     Get.forceAppUpdate();
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ar.dart';
import 'en.dart';

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
    final langCode = Get.locale?.languageCode ?? 'en';
    if (langCode == 'en') {
      return const Locale('en', 'US');
    }
    return const Locale('ar', 'AE');
  }

  static bool get isRTL {
    return currentLocale.languageCode == 'ar';
  }

  static void changeLocale(String langCode) {
    final locale = langCode == 'en' ? const Locale('en', 'US') : const Locale('ar', 'AE');
    Get.updateLocale(locale);
  }
}

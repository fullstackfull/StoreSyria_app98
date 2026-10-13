import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:store_go_app/store_go.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/utils/app_log.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/core/services/firebase_messaging_service.dart';
import 'package:store_go_app/core/services/fcm_token_service.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';
import 'core/controller/home_controller/store_change_service.dart';

GetStorage? getStorage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp();

  await GetStorage.init();
  getStorage = GetStorage();

  final language = Prefs.getLanguage();
  AppLog.d('Current language: $language');

  await FirebaseMessagingService().initialize();
  await FcmTokenService().initialize();

  await dotenv.load(fileName: "assets/.env");
  String isDemoMode = dotenv.get(AppConstant.isDemoMode);
  Prefs.setBool(AppConstant.isDemoMode, bool.parse(isDemoMode));

  final onboardingController = OnboardingController();
  final isOnboardingCompleted = onboardingController.isOnboardingCompleted;
  AppLog.d('Onboarding completed: $isOnboardingCompleted');

  AppLog.d('Demo mode: ${Prefs.getBool(AppConstant.isDemoMode)}');
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  Get.put(StoreChangeService(), permanent: true);
  runApp(DevicePreview(enabled: false, builder: (context) => StoreGoApp()));
}
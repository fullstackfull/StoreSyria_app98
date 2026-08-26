
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:store_go_app/store_go.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/core/services/firebase_messaging_service.dart';
import 'package:store_go_app/core/services/fcm_token_service.dart';
import 'package:store_go_app/core/controller/onboarding_controller/onboarding_controller.dart';

GetStorage? getStorage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp();


  await GetStorage.init();
  getStorage = GetStorage();

  await FirebaseMessagingService().initialize();

  await FcmTokenService().initialize();

  await dotenv.load(fileName: "assets/.env");
  String isDemoMode = dotenv.get(AppConstant.isDemoMode);
  Prefs.setBool(AppConstant.isDemoMode, bool.parse(isDemoMode));
  
  final onboardingController = OnboardingController();
  final isOnboardingCompleted = onboardingController.isOnboardingCompleted;
  print('🔍 حالة OnBoarding: $isOnboardingCompleted');
  
  final token = Prefs.getToken();
  print("hi $token");
  print("isDemo========> $isDemoMode = ${Prefs.getBool(AppConstant.isDemoMode)}");
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(DevicePreview(enabled: true, builder: (context) => StoreGoApp()));
}
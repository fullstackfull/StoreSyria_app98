// ignore_for_file: avoid_print, sdk_version_since

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:store_go_app/store_go.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';

GetStorage? getStorage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  getStorage = GetStorage();
  await dotenv.load(fileName: "assets/.env");
  String isDemoMode = dotenv.get(AppConstant.isDemoMode);
  Prefs.setBool(AppConstant.isDemoMode, bool.parse(isDemoMode));
  final token = Prefs.getToken();
  print("hi $token");
  print("isDemo========> $isDemoMode = ${Prefs.getBool(AppConstant.isDemoMode)}");
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(DevicePreview(enabled: false ,builder:(context) =>  StoreGoApp()));
}

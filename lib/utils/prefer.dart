// ignore_for_file: avoid_print, constant_identifier_names

import '../main.dart';

class Prefs {
  static const String USER_ID = 'userId';
  static const String storeId = 'storeId';
  static const String KEY_TOKEN = 'TOKEN';
  static const String BASE_URL = 'base_url';
  static const String FCM_TOKEN = 'fcm_token';
  static const String DEVICE_ID = 'device_id';
  static const String ONBOARDING_COMPLETED = 'onboarding_completed';

  static setString(String key, String value) {
    return getStorage!.write(key, value);
  }

  static getString(String key) {
    return getStorage!.read(key) ?? '';
  }

  static setBool(String key, bool value) {
    return getStorage!.write(key, value);
  }

  static bool getBool(String key) {
    return getStorage!.read(key) ?? false;
  }

  static setInt(String key, int value) {
    return getStorage!.write(key, value);
  }

  static int getInt(String key) {
    return getStorage!.read(key) ?? 0;
  }

  static String getBaseUrl() {
    return getStorage!.read(BASE_URL) ?? '';
  }

  static setBaseUrl(String baseUrl) {
    return getStorage!.write(BASE_URL, baseUrl);
  }

  static String getToken() {
    return getStorage!.read(KEY_TOKEN) ?? '';
  }

  static setToken(String token) {
    return getStorage!.write(KEY_TOKEN, token);
  }

  static String getUserID() {
    return getStorage!.read(USER_ID) ?? '';
  }

  static setUserID(String userID) {
    return getStorage!.write(USER_ID, userID);
  }

  static String getStoreID() {
    return getStorage!.read(storeId) ?? '';
  }

  static setStoreID(String userID) {
    return getStorage!.write(storeId, userID);
  }

  static remove(String key) {
    return getStorage!.remove(key);
  }

  static clear() {
    print('PREFS CLEARED');
    return getStorage!.erase();
  }

  static String getFcmToken() {
    return getStorage!.read(FCM_TOKEN) ?? '';
  }

  static setFcmToken(String token) {
    return getStorage!.write(FCM_TOKEN, token);
  }

  static String getDeviceId() {
    return getStorage!.read(DEVICE_ID) ?? '';
  }

  static setDeviceId(String deviceId) {
    return getStorage!.write(DEVICE_ID, deviceId);
  }
}

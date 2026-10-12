// ignore_for_file: constant_identifier_names

import '../main.dart';
import 'app_log.dart';

class Prefs {
  static const String USER_ID = 'userId';
  static const String storeId = 'storeId';
  static const String KEY_TOKEN = 'TOKEN';
  static const String BASE_URL = 'base_url';
  static const String FCM_TOKEN = 'fcm_token';
  static const String DEVICE_ID = 'device_id';
  static const String onboardingKey = 'onboarding_completed';
  static const String LANGUAGE = 'language';


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

  /// The merchant's currently selected store id, CACHED from the server.
  ///
  /// NOT AUTHORITATIVE, and must never be used for an authorization decision
  /// in the app (finding NEW-client-supplied-store-id / R7-N2). It lives in
  /// unencrypted local storage, which means it is attacker-controlled on a
  /// rooted or compromised device.
  ///
  /// It is still sent as `?store_id=` on the API calls that expect it, because
  /// changing the wire format would break against today's backend. The
  /// authoritative fix is server-side: the backend derives the tenant from the
  /// authenticated principal and must validate or ignore this parameter. When
  /// it does, a store_id the merchant does not own answers 403 -- which the
  /// network layer now reports as 'action_not_permitted' rather than a
  /// generic error.
  ///
  /// Write it only from a value the SERVER supplied: the login response's
  /// `current_store`, the store list, or the store-settings response.
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
    AppLog.d('PREFS CLEARED');
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

  static String getLanguage() {
  return getStorage!.read(LANGUAGE) ?? 'ar';
  }

  static setLanguage(String language) {
  return getStorage!.write(LANGUAGE, language);
  }

  bool get isOnboardingCompleted {
    return Prefs.getBool(onboardingKey);
  }

  void completeOnboarding() {
    Prefs.setBool(onboardingKey, true);
  }
}
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

  /// The only keys that survive [clear].
  ///
  /// NEW-forced-logout-erases-device-preferences. [clear] is what a FORCED
  /// logout runs (network.dart handleUnauthorized, on any 401) as well as the
  /// deliberate one, and it was `getStorage.erase()` -- the whole container.
  /// Two of the keys in that container are not session state at all:
  ///
  ///   * `language`. [getLanguage] defaults to 'ar', so a merchant who had
  ///     chosen English came back after a session expiry to an Arabic UI and
  ///     had to find the language setting again in a language they do not
  ///     read.
  ///   * `onboarding_completed`. welcome_screen.dart:68-73 tests this FIRST
  ///     and routes to '/onboarding' when it is false, before it ever looks
  ///     at the token. So an expired session did not land the merchant on the
  ///     login screen -- it replayed the three-page product tour at them.
  ///
  /// Neither is a credential and neither is scoped to a store, so neither can
  /// leak anything to the next merchant who signs in on this device.
  ///
  /// This list is an ALLOWLIST on purpose. A key added to this class later is
  /// erased by default; it has to be named here to survive, which is the safe
  /// direction for a function whose job is to destroy a session.
  static const List<String> preservedOnClear = <String>[
    LANGUAGE,
    onboardingKey,
  ];

  /// Erases the session.
  ///
  /// Order matters and is deliberate. GetStorage clears and writes its
  /// in-memory map SYNCHRONOUSLY and only the disk flush is asynchronous
  /// (get_storage-2.1.1/lib/src/storage_impl.dart:101-129), and its flushes
  /// run through one serial queue. Reading the preserved values, erasing, and
  /// writing them back therefore all happen before this method yields, so a
  /// caller that does not await it still sees a correct container -- and the
  /// erase still reaches the disk before the restore does.
  static Future<void> clear() async {
    AppLog.d('PREFS CLEARED');

    final preserved = <String, dynamic>{};

    for (final key in preservedOnClear) {
      final value = getStorage!.read(key);
      if (value != null) preserved[key] = value;
    }

    final erased = getStorage!.erase();

    final restored = <Future<void>>[
      for (final entry in preserved.entries)
        getStorage!.write(entry.key, entry.value),
    ];

    await erased;
    await Future.wait(restored);
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
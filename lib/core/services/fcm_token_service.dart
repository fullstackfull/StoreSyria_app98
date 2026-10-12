import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/app_log.dart';

/// خدمة إدارة FCM Token - Singleton
class FcmTokenService {
  static final FcmTokenService _instance = FcmTokenService._internal();
  factory FcmTokenService() => _instance;
  FcmTokenService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 🚀 تهيئة الخدمة
  Future<void> initialize() async {
    AppLog.d('🔔 بدء تهيئة خدمة FCM Token...');

    // الحصول على أو إنشاء Device ID
    await _initializeDeviceId();

    // الحصول على FCM Token الحالي
    await _refreshFcmToken();

    // الاستماع لتغييرات التوكن
    _listenTokenRefresh();

    AppLog.d('✅ تهيئة خدمة FCM Token اكتملت');
  }

  /// 📱 الحصول على أو إنشاء Device ID فريد
  Future<void> _initializeDeviceId() async {
    String? deviceId = Prefs.getDeviceId();

    if (deviceId.isEmpty) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = 'android-${androidInfo.id}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = 'ios-${iosInfo.identifierForVendor}';
        } else {
          // For web or other platforms, generate a random ID
          deviceId = 'web-${DateTime.now().millisecondsSinceEpoch}';
        }

        if (deviceId.isNotEmpty) {
          Prefs.setDeviceId(deviceId);
          AppLog.d('📱 Device ID تم إنشاؤه: $deviceId');
        }
      } catch (e) {
        AppLog.d('❌ خطأ في الحصول على Device ID: $e');
        // Fallback: generate a random ID
        deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}';
        Prefs.setDeviceId(deviceId);
      }
    } else {
      AppLog.d('📱 Device ID موجود: $deviceId');
    }
  }

  /// 🔄 الحصول على FCM Token جديد
  Future<String?> _refreshFcmToken() async {
    try {
      String? token = await _messaging.getToken();
      
      if (token != null && token.isNotEmpty) {
        _saveFcmToken(token);
        AppLog.d('🔑 FCM Token تم الحصول عليه: ${AppLog.redact(token)}');
        return token;
      }
    } catch (e) {
      AppLog.d('❌ خطأ في الحصول على FCM Token: $e');
    }
    return null;
  }

  /// 💾 حفظ FCM Token محلياً
  void _saveFcmToken(String token) {
    String oldToken = Prefs.getFcmToken();
    
    if (oldToken != token) {
      Prefs.setFcmToken(token);
      AppLog.d('💾 FCM Token تم حفظه محلياً');
      
      // إذا كان التوكن تغير، أرسله للسيرفر
      if (oldToken.isNotEmpty) {
        AppLog.d('🔄 التوكن تغير، سيتم إرساله للسيرفر');
      }
    }
  }

  /// 👂 الاستماع لتغييرات التوكن
  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((String newToken) {
      AppLog.d('🔄 FCM Token تم تحديثه: ${AppLog.redact(newToken)}');
      _saveFcmToken(newToken);
      
      // أرسل التوكن الجديد للسيرفر تلقائياً
      sendFcmTokenToServer();
    });
  }

  /// 📤 إرسال FCM Token للسيرفر
  /// 
  /// هذه الدالة ترسل التوكن للسيرفر مع معلومات المتجر الحالي
  /// تستدعى عند:
  /// 1. تسجيل الدخول الناجح
  /// 2. تغيير المتجر
  /// 3. تحديث FCM Token
  Future<bool> sendFcmTokenToServer({String? storeId}) async {
    try {
      // دائماً جلب توكن مضمون وجديد من Firebase
      String fcmToken = await _messaging.getToken() ?? '';
      
      if (fcmToken.isEmpty) {
        AppLog.d('❌ فشل الحصول على FCM Token من Firebase');
        return false;
      }

      _saveFcmToken(fcmToken);

      // التحقق من وجود Device ID
      String deviceId = Prefs.getDeviceId();
      if (deviceId.isEmpty) {
        AppLog.d('⚠️ لا يوجد Device ID محفوظ');
        await _initializeDeviceId();
        deviceId = Prefs.getDeviceId();
      }

      // استخدام storeId الممرر أو المحفوظ
      String currentStoreId = storeId ?? Prefs.getStoreID();
      if (currentStoreId.isEmpty) {
        AppLog.d('⚠️ لا يوجد Store ID');
        return false;
      }

      // تحديد المنصة
      String platform = 'android';
      if (Platform.isIOS) {
        platform = 'ios';
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        platform = 'web';
      }

      // إعداد البيانات
      Map<String, dynamic> data = {
        'store_id': int.tryParse(currentStoreId) ?? 0,
        'fcm_token': fcmToken,
        'device_id': deviceId,
        'platform': platform,
      };

      AppLog.d('📤 إرسال FCM Token جديد للسيرفر...');
      AppLog.d('   Store ID: $currentStoreId');
      AppLog.d('   Platform: $platform');
      AppLog.d('   Device ID: $deviceId');
      AppLog.d('   FCM Token: ${AppLog.redact(fcmToken)}');

      // إرسال الطلب
      final result = await NetworkHttps.postRequest(API.fcmTokenUrl, data);

      return result.fold(
        onSuccess: (data) {
          AppLog.d('✅ FCM Token تم إرساله بنجاح للسيرفر للمتجر $currentStoreId');
          return true;
        },
        onFailure: (reason, message, errors) {
          AppLog.d('❌ فشل إرسال FCM Token: $message');
          return false;
        },
      );
    } catch (e) {
      AppLog.d('❌ استثناء في إرسال FCM Token: $e');
      return false;
    }
  }

  /// 🧹 مسح وإلغاء FCM Token (عند تسجيل الخروج)
  Future<void> clearFcmToken() async {
    try {
      // إلغاء وتدمير التوكن في سيرفرات Firebase يمنع استلام إشعارات الحساب السابق ويولد توكن جديد عند دخول مستخدم جديد
      await _messaging.deleteToken();
      AppLog.d('🗑️ FCM Token تم حذفه وتدميره من Firebase بنجاح');
    } catch (e) {
      AppLog.d('⚠️ خطأ في حذف FCM Token من Firebase: $e');
    }

    Prefs.setFcmToken('');
    AppLog.d('🧹 FCM Token تم مسحه محلياً');
  }

  /// 🔍 الحصول على FCM Token الحالي
  String? getCurrentFcmToken() {
    String token = Prefs.getFcmToken();
    return token.isNotEmpty ? token : null;
  }
}
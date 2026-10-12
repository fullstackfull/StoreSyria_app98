import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/utils/app_log.dart';

/// 🔑 Top-level function لمعالجة الإشعارات في Background (مهم جداً!)
/// يجب أن يكون outside أي class و top-level
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // لا تستدعي Firebase.initializeApp() هنا إذا كان التطبيق يستخدم Firebase بالفعل
  // لأن Firebase Core يتم تهيئته تلقائياً في Background
  AppLog.d('📩 [BACKGROUND] إشعار وارد: ${message.messageId}');
  AppLog.d('📩 [BACKGROUND] Title: ${message.notification?.title}');
  AppLog.d('📩 [BACKGROUND] Body: ${message.notification?.body}');
  AppLog.d('📩 [BACKGROUND] Data: ${message.data}');
}

/// 🔔 خدمة إدارة الإشعارات - Singleton
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// 🔑 FCM Token الحالي
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// 🚀 تهيئة الإشعارات (تستدعى مرة واحدة في main)
  Future<void> initialize() async {
    AppLog.d('🔔 بدء تهيئة الإشعارات...');

    // 1️⃣ تسجيل handler الخلفية (يجب قبل أي شيء)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2️⃣ طلب إذن الإشعارات
    await _requestPermission();

    // 3️⃣ إعداد الإشعارات المحلية
    await _setupLocalNotifications();

    // 4️⃣ إعداد قناة الإشعارات (Android 8+)
    await _createNotificationChannel();

    // 5️⃣ الاستماع للإشعارات عندما التطبيق مفتوح (Foreground)
    _listenForegroundMessages();

    // 6️⃣ الاستماع للضغط على الإشعار (عند فتح التطبيق من الإشعار)
    _listenNotificationTap();

    // 7️⃣ الحصول على FCM Token
    await _refreshFcmToken();

    // 8️⃣ الاستماع لتغيير التوكن
    _listenTokenRefresh();

    AppLog.d('✅ تهيئة الإشعارات اكتملت');
  }

  /// 🛡️ طلب إذن الإشعارات
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
    );

    AppLog.d('🔔 حالة إذن الإشعارات: ${settings.authorizationStatus}');
  }

  /// 📱 إعداد الإشعارات المحلية
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLog.d('👆 تم الضغط على إشعار محلي: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );
  }

  /// 📢 إنشاء قناة إشعارات (Android 8+)
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'إشعارات مهمة',
      description: 'قناة الإشعارات الرئيسية للتطبيق',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 👂 الاستماع للإشعارات في Foreground (التطبيق مفتوح)
  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLog.d('📩 [FOREGROUND] إشعار وارد:');
      AppLog.d('   Title: ${message.notification?.title}');
      AppLog.d('   Body: ${message.notification?.body}');
      AppLog.d('   Data: ${message.data}');

      // زيادة عدد الإشعارات غير المقروءة
      try {
        final notificationController = Get.find<NotificationController>();
        notificationController.incrementUnreadCount();
      } catch (e) {
        AppLog.d('⚠️ لم يتم العثور على NotificationController: $e');
      }

      // عرض إشعار محلي لأن FCM لا يعرض إشعارات تلقائياً في Foreground
      _showLocalNotification(message);
    });
  }

  /// 📱 عرض إشعار محلي
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'إشعارات مهمة',
            channelDescription: 'قناة الإشعارات الرئيسية للتطبيق',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// 👂 الاستماع للضغط على الإشعار (فتح التطبيق من الإشعار)
  void _listenNotificationTap() {
    // عندما التطبيق كان في Background وضغط المستخدم على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLog.d('👆 [BACKGROUND TAP] تم الضغط على الإشعار:');
      AppLog.d('   Data: ${message.data}');
      try {
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().getNotifications(showLoading: false);
        }
      } catch (e) {
        AppLog.d('⚠️ خطأ في تحديث الإشعارات عند الضغط: $e');
      }
      _handleNotificationTap(jsonEncode(message.data));
    });

    // التحقق إذا فُتح التطبيق من إشعار (Terminated state)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        AppLog.d('👆 [TERMINATED TAP] التطبيق فُتح من إشعار:');
        AppLog.d('   Data: ${message.data}');
        try {
          if (Get.isRegistered<NotificationController>()) {
            Get.find<NotificationController>().getNotifications(showLoading: false);
          }
        } catch (e) {
          AppLog.d('⚠️ خطأ في تحديث الإشعارات عند فتح التطبيق المغلق: $e');
        }
        _handleNotificationTap(jsonEncode(message.data));
      }
    });
  }

  /// 🎯 معالجة الضغط على الإشعار (التوجيه)
  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      AppLog.d('🎯 معالجة الإشعار: $data');

      final String? type = data['type']?.toString();
      final String? id = data['id']?.toString();

      // TODO: أضف منطق التوجيه حسب نوع الإشعار
      switch (type) {
        case 'order':
        // Get.toNamed('/order-details', arguments: id);
          AppLog.d('🛒 توجيه لصفحة الطلب: $id');
          break;
        case 'product':
        // Get.toNamed('/product-details', arguments: id);
          AppLog.d('📦 توجيه لصفحة المنتج: $id');
          break;
        case 'message':
        // Get.toNamed('/messages');
          AppLog.d('💬 توجيه لصفحة الرسائل');
          break;
        default:
          AppLog.d('📌 نوع إشعار غير معروف: $type');
      }
    } catch (e) {
      AppLog.d('❌ خطأ في معالجة الإشعار: $e');
    }
  }

  /// 🔄 الحصول على FCM Token جديد
  Future<String?> _refreshFcmToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      AppLog.d('🔑 FCM Token: ${AppLog.redact(_fcmToken)}');
      return _fcmToken;
    } catch (e) {
      AppLog.d('❌ خطأ في الحصول على FCM Token: $e');
      return null;
    }
  }

  /// 🔄 الاستماع لتغيير FCM Token
  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((String newToken) {
      AppLog.d('🔄 FCM Token تغير: ${AppLog.redact(newToken)}');
      _fcmToken = newToken;
      // TODO: أرسل التوكن الجديد للـ Backend
      _sendTokenToBackend(newToken);
    });
  }

  /// 📤 إرسال FCM Token للـ Backend (تستدعى عند تسجيل الدخول)
  Future<bool> sendFcmTokenToBackend({
    required String authToken,
    required int storeId,
  }) async {
    try {
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        _fcmToken = await _refreshFcmToken();
      }

      if (_fcmToken == null) {
        AppLog.d('❌ لا يوجد FCM Token');
        return false;
      }

      return await _sendTokenToBackend(_fcmToken!, authToken: authToken, storeId: storeId);
    } catch (e) {
      AppLog.d('❌ خطأ في إرسال FCM Token: $e');
      return false;
    }
  }

  /// 📤 إرسال التوكن للـ Backend (private)
  Future<bool> _sendTokenToBackend(
      String token, {
        String? authToken,
        int? storeId,
      }) async {
    // TODO: استبدل هذا بـ API الحقيقي
    AppLog.d('📤 إرسال FCM Token للـ Backend:');
    AppLog.d('   Token: ${AppLog.redact(token)}');
    AppLog.d('   Store ID: $storeId');

    // مثال على استدعاء API:
    /*
    final response = await http.post(
      Uri.parse('${Prefs.getBaseUrl()}/api/fcm-token'),
      // R7-N1: do NOT hand-roll the Authorization header. There is exactly one
      // construction site: NetworkHttps.authHeaders().
      headers: NetworkHttps.authHeaders(),
      body: jsonEncode({
        'fcm_token': token,
        'store_id': storeId,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
      }),
    );

    if (response.statusCode == 200) {
      AppLog.d('✅ FCM Token أُرسل بنجاح');
      return true;
    } else {
      AppLog.d('❌ فشل إرسال FCM Token: ${response.statusCode}');
      return false;
    }
    */

    return true;
  }

  /// 🗑️ حذف FCM Token (عند تسجيل الخروج)
  Future<void> deleteFcmToken() async {
    await _messaging.deleteToken();
    _fcmToken = null;
    AppLog.d('🗑️ FCM Token حُذف');
  }

  /// 📋 الحصول على FCM Token الحالي
  Future<String?> getCurrentToken() async {
    if (_fcmToken != null) return _fcmToken;
    return await _refreshFcmToken();
  }
}
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
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

/// 🔔 خدمة عرض الإشعارات وتوجيهها - Singleton
///
/// NEW-duplicate-fcm-services. This service and [FcmTokenService] were BOTH
/// initialized from main() and BOTH registered a
/// `FirebaseMessaging.instance.onTokenRefresh.listen(...)` subscription, so a
/// single token rotation ran two different handlers: this one wrote the token
/// to an in-memory field and called a `_sendTokenToBackend` whose entire HTTP
/// call was commented out behind a TODO and which returned `true` regardless;
/// the other wrote it to [Prefs] and POSTed it to `API.fcmTokenUrl` for real.
/// Two owners of one piece of state, one of which only pretended to work.
///
/// The FCM token now has exactly ONE owner: [FcmTokenService]. That is the
/// path app code already used -- AuthController and HomeController call
/// `FcmTokenService().sendFcmTokenToServer(...)` and `clearFcmToken()`, and
/// nothing anywhere called this class's token members. This service is
/// responsible for notification PERMISSION, DISPLAY and TAP ROUTING only, and
/// deliberately holds no token state.
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

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

    // NOTE: the FCM token is deliberately NOT read or subscribed to here.
    // FcmTokenService owns it, including the single onTokenRefresh listener.

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

}
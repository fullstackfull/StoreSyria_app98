// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:store_go_app/core/model/notification_model.dart';
import 'package:store_go_app/network_dio/network_dio.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class NotificationController extends GetxController with WidgetsBindingObserver {
  RxList<NotificationData> notificationList = <NotificationData>[].obs;
  RxBool isLoading = false.obs;
  RxInt unreadCount = 0.obs;
  NotificationModelData? notificationData;
  int? lastSavedCount;


  final RxSet<int> tappedNotificationIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadLastSavedCount();
    _loadTappedIds();
    getNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 التطبيق عاد للواجهة من الخلفية (Resumed) -> إعادة جلب الإشعارات لتحديث عداد الجرس');
      getNotifications(showLoading: false);
    }
  }

  /// 📥 جلب الإشعارات من السيرفر
  Future<void> getNotifications({bool showLoading = true}) async {
    if (showLoading && notificationList.isEmpty) {
      isLoading.value = true;
    }

    try {
      final response = await NetworkHttps.getRequest(API.notificationUrl);

      response.fold(
        onSuccess: (data) {
          NotificationModel model = NotificationModel.fromJson(data);
          notificationData = model.data;
          notificationList.value = notificationData?.data ?? [];
          
          // حساب الإشعارات غير المقروءة بناءً على المنطق الجديد
          _calculateUnreadCount(model.count ?? 0);
          
          notificationList.refresh();
          update();
        },
        onFailure: (reason, message, errors) {
          print('❌ فشل جلب الإشعارات: $message');
        },
      );
    } catch (e) {
      print('❌ استثناء في جلب الإشعارات: $e');
    }

    isLoading.value = false;
  }

  int? notificationModelCount;

  /// 🧮 حساب عدد الإشعارات غير المقروءة
  void _calculateUnreadCount(int currentCount) {
    notificationModelCount = currentCount;
    int lastCount = lastSavedCount ?? 0;
    int difference = currentCount - lastCount;
    unreadCount.value = difference > 0 ? difference : 0;
    
    // إذا كان العدد الحالي أصغر من المحفوظ، نحدث المحفوظ
    if (currentCount < lastCount) {
      lastSavedCount = currentCount;
      _saveLastSavedCount(currentCount);
      unreadCount.value = 0;
    }
    
    print('🔔 عدد الإشعارات غير المقروءة: ${unreadCount.value}');
    print('🔔 العدد الحالي من السيرفر: $currentCount');
    print('🔔 آخر عدد محفوظ عند القراءة: $lastSavedCount');
  }

  /// 💾 حفظ آخر عدد محفوظ محلياً
  void _saveLastSavedCount(int count) {
    Prefs.setInt('last_notification_count', count);
  }

  /// 📥 تحميل آخر عدد محفوظ
  void _loadLastSavedCount() {
    lastSavedCount = Prefs.getInt('last_notification_count');
    print('🔔 تم تحميل آخر عدد محفوظ: $lastSavedCount');
  }

  // ══════════════════════════════════════════
  // 👆 Tapped Notifications (Local Tracking)
  // ══════════════════════════════════════════

  static const String _tappedIdsKey = 'tapped_notification_ids';

  /// 📥 تحميل معرّفات الإشعارات المضغوطة من التخزين المحلي
  void _loadTappedIds() {
    final raw = Prefs.getString(_tappedIdsKey);
    if (raw.isNotEmpty) {
      final ids = raw.split(',').map((e) => int.tryParse(e.trim())).whereType<int>();
      tappedNotificationIds.addAll(ids);
    }
    print('👆 تم تحميل الإشعارات المضغوطة: ${tappedNotificationIds.length}');
  }

  /// 💾 حفظ معرّفات الإشعارات المضغوطة
  void _saveTappedIds() {
    final raw = tappedNotificationIds.join(',');
    Prefs.setString(_tappedIdsKey, raw);
  }

  /// 👆 تسجيل أن المستخدم ضغط على هذا الإشعار
  void markNotificationTapped(int notificationId) {
    if (!tappedNotificationIds.contains(notificationId)) {
      tappedNotificationIds.add(notificationId);
      _saveTappedIds();
      print('👆 تم تسجيل الضغط على الإشعار: $notificationId');
    }
  }

  /// ✅ هل تم الضغط على هذا الإشعار مسبقاً؟
  bool isNotificationTapped(int notificationId) {
    return tappedNotificationIds.contains(notificationId);
  }

  /// ✅ تحديد جميع الإشعارات كمضغوطة (محلياً للمظهر البصري فقط)
  void markAllAsTapped() {
    for (var notification in notificationList) {
      if (notification.id != null) {
        tappedNotificationIds.add(notification.id!);
      }
    }
    _saveTappedIds();
    print('✅ تم تحديد جميع الإشعارات كمضغوطة بصرياً');
  }

  /// ✅ تحديد إشعار كمقروء
  Future<void> markAsRead(int notificationId) async {
    try {
      int index = notificationList.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notificationList[index].isRead = true;
        notificationList.refresh();
        
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
      }
    } catch (e) {
      print('❌ استثناء في تحديد الإشعار كمقروء: $e');
    }
  }

  /// ✅ تحديد جميع الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    try {
      for (var notification in notificationList) {
        notification.isRead = true;
      }
      notificationList.refresh();
      
      // تصفير العداد وحفظ العدد الحالي
      int currentTotal = notificationModelCount ?? notificationData?.total ?? notificationList.length;
      lastSavedCount = currentTotal;
      _saveLastSavedCount(currentTotal);
      unreadCount.value = 0;
      
      print('✅ تم تحديد جميع الإشعارات كمقروءة');
    } catch (e) {
      print('❌ استثناء في تحديد جميع الإشعارات كمقروءة: $e');
    }
  }

  /// 🔄 تحديث العداد عند وصول إشعار جديد (من FCM)
  void incrementUnreadCount() {
    unreadCount.value++;
    print('🔔 تم زيادة عدد الإشعارات غير المقروءة: ${unreadCount.value}');
  }

  /// 🧹 مسح بيانات الإشعارات عند تسجيل الخروج
  void clearNotificationData() {
    notificationList.clear();
    unreadCount.value = 0;
    lastSavedCount = null;
    tappedNotificationIds.clear();
    Prefs.setInt('last_notification_count', 0);
    Prefs.setString(_tappedIdsKey, '');
    print('🧹 تم مسح بيانات الإشعارات');
  }
}

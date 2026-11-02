import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/notification_model.dart';
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';
import 'package:store_go_app/utils/app_log.dart';

class NotificationController extends GetxController
    with WidgetsBindingObserver
    implements StoreAware {

  static const String _cacheNotificationKey = 'home_notification_list_data';

  RxList<NotificationData> notificationList = <NotificationData>[].obs;
  RxBool isLoading = false.obs;

  /// P2-07-14. Empty while a request is FAILING is not the same as empty because there is
  /// nothing. `onFailure` only wrote to the log, so a merchant whose network dropped saw the
  /// "no notifications" state and concluded they had none.
  RxString errorMessage = ''.obs;
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
    _loadCachedNotifications();
    StoreChangeService.instance.register(() => this);
    getNotifications();
  }

  void _loadCachedNotifications() {
    final cached =
    CacheService.get<Map<String, dynamic>>(_cacheNotificationKey);
    if (cached == null) return;
    try {
      NotificationModel model = NotificationModel.fromJson(cached);
      notificationData = model.data;
      notificationList.value = notificationData?.data ?? [];

      _calculateUnreadCount(model.count ?? 0);

      notificationList.refresh();
    } catch (_) {
      notificationData = null;
    }
  }

  @override
  void resetForStoreChange() {
    notificationList.clear();
    notificationList.refresh();
    notificationData = null;
    unreadCount.value = 0;

    CacheService.clear(_cacheNotificationKey);

    getNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> getNotifications({bool showLoading = true}) async {
    if (showLoading && notificationList.isEmpty) {
      isLoading.value = true;
    }

    errorMessage.value = '';

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

          // نخزن آخر رد ناجح محلياً عشان يستخدم كبيانات فورية
          // بالمرة الجاية اللي المستخدم يفتح فيها التطبيق/الشاشة.
          CacheService.save(_cacheNotificationKey, data);
        },
        onFailure: (reason, message, errors) {
          AppLog.d('❌ فشل جلب الإشعارات: $message');
          // Only surface the failure when there is nothing cached to show: a refresh that
          // fails behind a populated list should not replace it with an error screen.
          if (notificationList.isEmpty) {
            errorMessage.value = message;
          }
        },
      );
    } catch (e) {
      AppLog.d('❌ استثناء في جلب الإشعارات: $e');
      if (notificationList.isEmpty) {
        errorMessage.value = 'connection_failed'.tr;
      }
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
    
    AppLog.d('🔔 عدد الإشعارات غير المقروءة: ${unreadCount.value}');
    AppLog.d('🔔 العدد الحالي من السيرفر: $currentCount');
    AppLog.d('🔔 آخر عدد محفوظ عند القراءة: $lastSavedCount');
  }

  /// 💾 حفظ آخر عدد محفوظ محلياً
  void _saveLastSavedCount(int count) {
    Prefs.setInt('last_notification_count', count);
  }

  /// 📥 تحميل آخر عدد محفوظ
  void _loadLastSavedCount() {
    lastSavedCount = Prefs.getInt('last_notification_count');
    AppLog.d('🔔 تم تحميل آخر عدد محفوظ: $lastSavedCount');
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
    AppLog.d('👆 تم تحميل الإشعارات المضغوطة: ${tappedNotificationIds.length}');
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
      AppLog.d('👆 تم تسجيل الضغط على الإشعار: $notificationId');
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
    AppLog.d('✅ تم تحديد جميع الإشعارات كمضغوطة بصرياً');
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
      AppLog.d('❌ استثناء في تحديد الإشعار كمقروء: $e');
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
      
      AppLog.d('✅ تم تحديد جميع الإشعارات كمقروءة');
    } catch (e) {
      AppLog.d('❌ استثناء في تحديد جميع الإشعارات كمقروءة: $e');
    }
  }

  /// 🔄 تحديث العداد عند وصول إشعار جديد (من FCM)
  void incrementUnreadCount() {
    unreadCount.value++;
    AppLog.d('🔔 تم زيادة عدد الإشعارات غير المقروءة: ${unreadCount.value}');
  }

  /// 🧹 مسح بيانات الإشعارات عند تسجيل الخروج
  void clearNotificationData() {
    notificationList.clear();
    unreadCount.value = 0;
    lastSavedCount = null;
    tappedNotificationIds.clear();
    Prefs.setInt('last_notification_count', 0);
    Prefs.setString(_tappedIdsKey, '');
    AppLog.d('🧹 تم مسح بيانات الإشعارات');
  }
}

import 'package:store_go_app/main.dart';
import 'package:store_go_app/utils/app_log.dart';

/// خدمة كاش بسيطة مبنية فوق GetStorage الموجودة أصلاً بالمشروع
/// (نفس الأداة المستخدمة بكلاس Prefs)، ما بتضيف أي مكتبة جديدة.
///
/// الفكرة: بعد أي طلب API ناجح، نخزن آخر Response محلياً تحت مفتاح معيّن.
/// وبأول ما الكنترولر ينفتح (onInit) منقرأ هالكاش ونعبّي فيه الشاشة
/// فوراً (بدون لودر)، وبنفس الوقت طلب الـ API الأصلي بيكمل شغل
/// بالخلفية ويحدّث الواجهة تلقائياً لما يوصل رد جديد (عن طريق نفس
/// الـ Rx / GetBuilder الموجودين أصلاً بالكود - ما في أي تغيير عليهم).
class CacheService {
  static const String _prefix = 'cache_';

  /// تخزين بيانات (Map / List / أي نوع يدعمه GetStorage) تحت مفتاح معيّن
  static Future<void> save(String key, dynamic data) async {
    try {
      await getStorage?.write('$_prefix$key', data);
    } catch (e) {
      AppLog.d('CacheService.save error [$key]: $e');
    }
  }

  /// قراءة البيانات المخزّنة لمفتاح معيّن، أو null إذا ما في كاش
  static T? get<T>(String key) {
    try {
      final value = getStorage?.read('$_prefix$key');
      if (value == null) return null;
      return value as T;
    } catch (e) {
      AppLog.d('CacheService.get error [$key]: $e');
      return null;
    }
  }

  /// حذف كاش مفتاح معيّن (مفيدة مستقبلاً، مثلاً عند تسجيل الخروج)
  static Future<void> clear(String key) async {
    try {
      await getStorage?.remove('$_prefix$key');
    } catch (e) {
      AppLog.d('CacheService.clear error [$key]: $e');
    }
  }
}

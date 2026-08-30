import 'package:get/get.dart';

/// أي كنترولر عنده بيانات مرتبطة بالمتجر الحالي (Categories, Products,
/// Coupons, Orders, Notifications...) ولازم يترجع يتصفر / يعيد تحميل
/// بياناته لما يتغير المتجر، لازم يعمل implement لهاد الـ interface.
abstract class StoreAware {
  /// بتنستدعى تلقائياً لما يتغير المتجر بنجاح.
  /// جوّاها: امسحي القوائم/الكاش الخاص بهاد الكنترولر، وإذا بدك
  /// اعيدي جلب البيانات الجديدة من السيرفر مباشرة.
  void resetForStoreChange();
}

/// سيرفيس مركزي وحيد بيربط كل الكنترولرز المرتبطة بالمتجر.
/// بيتسجل مرة وحدة بالـ main.dart، وكل كنترولر بسجل نفسه فيه
/// بالـ onInit تبعه.
class StoreChangeService extends GetxService {
  static StoreChangeService get instance => Get.find<StoreChangeService>();

  final List<StoreAware Function()> _resolvers = [];

  /// تسجيل كنترولر جديد. منمرر function (مو instance مباشرة) عشان
  /// نضمن نجيب أحدث instance موجودة بالذاكرة وقت الاستدعاء الفعلي،
  /// حتى لو الكنترولر انعمله dispose وrecreate بينهم.
  void register(StoreAware Function() resolver) {
    _resolvers.add(resolver);
  }

  /// بتستدعى مرة وحدة بس من مكان تغيير المتجر (HomeController)
  /// بعد نجاح العملية، وبتصفر كل الكنترولرز المسجلة أوتوماتيك.
  void notifyStoreChanged() {
    for (final resolve in _resolvers) {
      try {
        resolve().resetForStoreChange();
      } catch (e) {
        // الكنترولر مو مسجل حالياً بالذاكرة (Get.isRegistered == false)
        // أو انعمله dispose - نتجاهله بأمان وما منوقف باقي الكنترولرز.
      }
    }
  }
}
import 'package:store_go_app/config/repository/dashboard_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/model/image_base_url_model.dart';
import 'package:store_go_app/core/model/dashboard_model.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/services/fcm_token_service.dart';

import 'store_change_service.dart';
import 'cahe.dart';
import 'package:store_go_app/utils/app_log.dart';

class HomeController extends GetxController implements StoreAware {
  // مفاتيح الكاش الخاصة بهاد الكنترولر
  static const String _cacheDashboardKey = 'home_dashboard_data';
  static const String _cacheImageUrlKey = 'home_image_url_data';

  DashboardRepository dashboardRepository = DashboardRepository();
  RxList<ProductData> topProductList = <ProductData>[].obs;
  RxList<RecentOrder> recentOrderList = <RecentOrder>[].obs;
  RxList<Coupons> couponsList = <Coupons>[].obs;
  RxString imageBaseUrl = ''.obs;
  RxBool isStore = false.obs;
  RxBool isDataAvailable = false.obs;
  DashboardData? dashboardData;
  ImageUrlData? imageUrlData;
  List<Store> myStoreList = [Store(name: 'Grocery', id: 3), Store(id: 7, name: "Babycare")];

  @override
  void onInit() {
    super.onInit();
    // نحمّل آخر بيانات محفوظة محلياً فوراً (لو موجودة) عشان الشاشة
    // تفتح مباشرة بدون لودر. الطلب الحقيقي من السيرفر بيصير بعدها
    // بالخلفية (زي ما هو مبرمج أصلاً بـ getData() بالشاشة) وبيحدّث
    // نفس المتغيرات لما يوصل رد جديد.
    _loadCachedDashboard();
    _loadCachedImageUrl();

    // نسجل هاد الكنترولر بالسيرفيس المركزي عشان ينعمله reset
    // تلقائياً لما يتغير المتجر، بدون الحاجة لاستدعاء يدوي.
    StoreChangeService.instance.register(() => this);
  }

  /// بتنستدعى تلقائياً من StoreChangeService لما يتغير المتجر.
  @override
  void resetForStoreChange() {
    _resetDashboardData();
    getDashboardData();
  }

  void _loadCachedDashboard() {
    final cached = CacheService.get<Map<String, dynamic>>(_cacheDashboardKey);
    if (cached == null) return;
    try {
      dashboardData = DashboardData.fromJson(cached);
      topProductList.value = dashboardData!.product ?? [];
      recentOrderList.value = dashboardData!.recentOrder ?? [];
      couponsList.value = dashboardData!.coupons ?? [];
      topProductList.refresh();
      recentOrderList.refresh();
      couponsList.refresh();
      update();
    } catch (_) {
      // لو تغير شكل البيانات وصار الكاش القديم غير متوافق، نتجاهله
      // ونخلي الطلب العادي من السيرفر يعبّي البيانات كالمعتاد.
      dashboardData = null;
    }
  }

  void _loadCachedImageUrl() {
    final cached = CacheService.get<Map<String, dynamic>>(_cacheImageUrlKey);
    if (cached == null) return;
    try {
      imageUrlData = ImageUrlData.fromJson(cached);
      if (imageUrlData?.imageUrl != null) {
        imageBaseUrl.value = imageUrlData!.imageUrl!;
      }
    } catch (_) {
      imageUrlData = null;
    }
  }

  /// بتمسح كل بيانات الداشبورد (القوائم + الكاش المحلي) فوراً.
  /// بتنستدعى لما يتغير المتجر عشان ما تضل بيانات المتجر القديم
  /// ظاهرة أو محفوظة بالكاش لحد ما يوصل رد المتجر الجديد.
  void _resetDashboardData() {
    dashboardData = null;

    topProductList.clear();
    recentOrderList.clear();
    couponsList.clear();

    topProductList.refresh();
    recentOrderList.refresh();
    couponsList.refresh();

    update();

    CacheService.clear(_cacheDashboardKey);
  }

  getImageBaseUrl() async {
    isDataAvailable.value = true;

    final response = await dashboardRepository.getImageBaseData();

    response.fold(
      onSuccess: (data) {
        imageUrlData = ImageUrlData.fromJson(data['data']);
        imageBaseUrl.value = imageUrlData!.imageUrl!;
        Prefs.setString(AppConstant.imageUrl, imageUrlData!.imageUrl!);
        Prefs.setString(AppConstant.paymentUrl, imageUrlData!.paymentUrl!);
        CacheService.save(_cacheImageUrlKey, data['data']);
      },
      onFailure: (reason, message, errors) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );

    isDataAvailable.value = false;
  }
  setStoreIdData({required String storeId}) async {
    isDataAvailable.value = true;

    final response =
    await dashboardRepository.setStoreIdData(storeId: storeId);

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          isStore.value = false;
          commonToast(
            type: AppSnackBarType.success,
            apiMessage(data, fallback: 'store_changed'.tr),
          );

          Prefs.setStoreID(storeId);

          _sendFcmTokenAfterStoreChange(storeId);

          // بدل ما ننادي getDashboardData() هون بس، منطلق حدث
          // مركزي وكل الكنترولرز المسجلة (Home, Category, Product,
          // Coupon, Order, Notification...) بتتصفر وتعيد التحميل
          // لحالها تلقائياً، كل وحدة حسب الـ resetForStoreChange
          // تبعها.
          StoreChangeService.instance.notifyStoreChanged();
        } else {
          commonToast(
            type: AppSnackBarType.error,
            apiMessage(data, fallback: 'error_occurred'.tr),
          );
        }
      },
      onFailure: (reason, message, errors) {
        // commonToast(message);
      },
    );

    isDataAvailable.value = false;
  }
  getDashboardData() async {
    isDataAvailable.value = true;

    final response = await dashboardRepository.getDashBoardData();

    response.fold(
      onSuccess: (data) {
        dashboardData = DashboardData.fromJson(data['data']);

        topProductList.value = dashboardData!.product ?? [];
        recentOrderList.value = dashboardData!.recentOrder ?? [];
        couponsList.value = dashboardData!.coupons ?? [];

        topProductList.refresh();
        recentOrderList.refresh();
        couponsList.refresh();

        update();

        // نخزن آخر رد ناجح محلياً عشان يستخدم كبيانات فورية
        // بالمرة الجاية اللي المستخدم يفتح فيها الشاشة.
        CacheService.save(_cacheDashboardKey, data['data']);
      },
      onFailure: (reason, message, errors) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );

    isDataAvailable.value = false;
  }

  /// إرسال FCM Token للسيرفر بعد تغيير المتجر
  Future<void> _sendFcmTokenAfterStoreChange(String storeId) async {
    try {
      final fcmService = FcmTokenService();
      await fcmService.sendFcmTokenToServer(storeId: storeId);
    } catch (e) {
      AppLog.d('❌ خطأ في إرسال FCM Token بعد تغيير المتجر: $e');
    }
  }
}

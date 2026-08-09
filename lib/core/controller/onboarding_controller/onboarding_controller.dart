import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/onboarding_model.dart';
import 'package:store_go_app/utils/prefer.dart';

class OnboardingController extends GetxController {
  // PageController للتنقل بين الصفحات
  final PageController pageController = PageController();
  
  // الصفحة الحالية
  RxInt currentPage = 0.obs;
  
  // قائمة شاشات OnBoarding
  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: 'onboarding_title_1'.tr,
      description: 'onboarding_desc_1'.tr,
      image: 'assets/svg/onboarding_1.svg',
      backgroundColor: '#00B4D8',
    ),
    OnboardingModel(
      title: 'onboarding_title_2'.tr,
      description: 'onboarding_desc_2'.tr,
      image: 'assets/svg/onboarding_2.svg',
      backgroundColor: '#1E293B',
    ),
    OnboardingModel(
      title: 'onboarding_title_3'.tr,
      description: 'onboarding_desc_3'.tr,
      image: 'assets/svg/onboarding_3.svg',
      backgroundColor: '#172C4E',
    ),
  ];
  
  @override
  void onInit() {
    super.onInit();
    // تحميل حالة OnBoarding المحفوظة
    _loadOnboardingStatus();
  }
  
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
  
  /// التحقق هل المستخدم رأى OnBoarding من قبل
  bool get isOnboardingCompleted => Prefs.getBool('onboarding_completed');
  
  /// حفظ حالة OnBoarding كمكتملة
  void completeOnboarding() {
    Prefs.setBool('onboarding_completed', true);
    print('✅ تم حفظ حالة OnBoarding كمكتملة');
  }
  
  /// إعادة تعيين OnBoarding (للاختبار)
  void resetOnboarding() {
    Prefs.setBool('onboarding_completed', false);
    print('🔄 تم إعادة تعيين OnBoarding');
  }
  
  /// تحميل حالة OnBoarding
  void _loadOnboardingStatus() {
    final completed = Prefs.getBool('onboarding_completed');
    print('🔍 حالة OnBoarding: ${completed ?? false}');
  }
  
  /// الانتقال للصفحة التالية
  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // الوصول للصفحة الأخيرة - إنهاء OnBoarding
      completeOnboarding();
      Get.offAllNamed('/login');
    }
  }
  
  /// الانتقال للصفحة السابقة
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// الانتقال لصفحة محددة
  void goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  /// تخطي OnBoarding
  void skipOnboarding() {
    completeOnboarding();
    Get.offAllNamed('/login');
  }
  
  /// تحديث الصفحة الحالية
  void updatePage(int page) {
    currentPage.value = page;
  }
}

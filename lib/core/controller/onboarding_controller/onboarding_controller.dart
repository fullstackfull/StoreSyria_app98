import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/onboarding_model.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/prefer.dart';

class
OnboardingController extends GetxController {
  // PageController للتنقل بين الصفحات
  final PageController pageController = PageController();

  // الصفحة الحالية
  RxInt currentPage = 0.obs;

  // قائمة شاشات OnBoarding

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: 'onboarding_title_1',
      description: 'onboarding_desc_1',
      lottiePath: 'assets/lottie/onboarding_1.json',
      backgroundColor: '#00B4D8',
    ),
    OnboardingModel(
      title: 'onboarding_title_2',
      description: 'onboarding_desc_2',
      lottiePath: 'assets/lottie/onboarding_2.json',
      backgroundColor: '#1E293B',
    ),
    OnboardingModel(
      title: 'onboarding_title_3',
      description: 'onboarding_desc_3',
      lottiePath: 'assets/lottie/onboarding_3.json',
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
  }

  /// إعادة تعيين OnBoarding (للاختبار)
  void resetOnboarding() {
    Prefs.setBool('onboarding_completed', false);
  }

  /// تحميل حالة OnBoarding
  void _loadOnboardingStatus() {
    Prefs.getBool('onboarding_completed');
  }

  /// الانتقال للصفحة التالية
  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// الانتقال للصفحة السابقة
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// الانتقال لصفحة محددة
  void goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// تخطي OnBoarding
  void skipOnboarding() {
    completeOnboarding();
    Get.offAllNamed(AppRoutes.login);
  }

  /// تحديث الصفحة الحالية
  void updatePage(int page) {
    currentPage.value = page;
  }
}
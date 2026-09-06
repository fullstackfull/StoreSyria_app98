import 'package:get/get.dart';
import 'package:store_go_app/bindings/customer_binding.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/view/screen/customers/customer_screen.dart';
import 'package:store_go_app/view/screen/setting_screen/app_settings.dart';
import 'package:store_go_app/view/screen/setting_screen/language_screen.dart';
import 'package:store_go_app/view/screen/welcome_screen.dart';
import '../bindings/coupon_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../bindings/shipping_binding.dart';
import '../bindings/statistics_binding.dart';
import '../bindings/tax_binding.dart';
import '../view/screen/auth/login_widget.dart';
import '../view/screen/coupon_screen/coupon_screen.dart';
import '../view/screen/dashboard_manager/dashboard_manager.dart';
import '../view/screen/home_screen/shipping_screen.dart';
import '../view/screen/home_screen/tax_screen.dart';
import '../view/screen/statistics_screen/statistics_screen.dart';
import '../view/screen/onboarding_screen/onboarding_screen.dart';
import '../view/screen/notification_screen/notification_screen.dart';

class AppRoutes {
  // =========================
  // Route Constants
  // =========================
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const editProfile = '/editProfile';
  static const plan = '/my_plan';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const aboutUs = '/aboutUs';
  static const subplans = '/subplans';
  static const paymentHistory = '/payHistory';
  static const orders = '/orders';
  static const products = '/products';
  static const categories = '/categories';
  static const statistics = '/statistics';
  static const settings = '/settings';
  static const appSettings = '/appSettings';
  static const shipping = '/shipping';
  static const tax = '/tax';
  static const coupon = '/coupon';
  static const notifications = '/notifications';
  static const lang = '/lang';
  static const customers = '/customers';

  // =========================
  // Pages
  // =========================
  static final pages = [

    //Auth & Onboarding
   GetPage(name: splash, page: () => const WelComeScreen()),

    GetPage(
      name: onboarding,
      page: () => OnboardingScreen(),
      binding: OnboardingBinding(),
    ),

    GetPage(
        name: login,
        page: () => NormalLoginWidget()
    ),

    // Dashboard
    GetPage(
      name: dashboard,
      page: () => const DashBoardManagerScreen(),
      binding: DashboardBinding(),
    ),

    GetPage(
      name: AppRoutes.tax,
      page: ()=> const TaxScreen(),
      binding: TaxBinding(),
    ),

    GetPage(
      name: AppRoutes.coupon,
      page: ()=> const CouponScreen(),
      binding: CouponBinding(),
    ),

    GetPage(
      name: AppRoutes.lang,
      page: ()=> const LanguageCurrenciesScreen(),
    ),

    GetPage(
      name: AppRoutes.shipping,
      page: ()=> const ShippingScreen(),
      binding: ShippingBinding(),
    ),

    GetPage(
      name: AppRoutes.statistics,
      page: ()=> StatisticsScreen(),
      binding: StatisticsBinding(),
    ),

    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationScreen(isBack: true),
    ),

    GetPage(
      name: AppRoutes.appSettings,
      page: () => AppSettingsScreen(),
    ),

    GetPage(
      name: AppRoutes.customers,
      page: () => CustomerScreen(),
      binding: CustomerBinding()
    ),
  ];
}

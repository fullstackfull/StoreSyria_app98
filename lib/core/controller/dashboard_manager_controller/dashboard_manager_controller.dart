// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen.dart';
import 'package:store_go_app/view/screen/order_screen/order_screen.dart';
import 'package:store_go_app/view/screen/setting_screen/setting_screen.dart';
import 'package:store_go_app/view/screen/product_screen/products_screen.dart';
import 'package:store_go_app/view/screen/category_screen/category_screen.dart';

class DashboardManagerController extends GetxController {
  RxInt currantIndex = 0.obs;
  /// P2.5-B-11. RESOLVED ON EVERY READ, not once at construction.
  ///
  /// This was an `RxList` field initialiser, so `.tr` ran exactly once -- when the controller
  /// was built -- and the five labels stayed in whatever language the merchant was in at that
  /// moment. A later switch could not reach them: `Get.updateLocale` only reassembles the widget
  /// tree (get-4.7.3 extension_navigation.dart:1040-1060) and constructs no controller, and
  /// `Get.put` DISCARDS the instance it is handed when a live, non-dirty registration already
  /// exists (get-4.7.3 get_instance.dart:157-186, guard at :168), so re-running
  /// `DashboardBinding.dependencies()` could not replace the frozen one either.
  ///
  /// MOVING THIS INTO `onInit()` IS NOT A FIX, for that same reason: `onInit` runs only on the
  /// instance actually inserted, which is the frozen one. It has to re-resolve on READ.
  ///
  /// THE TYPE IS `Map<String, dynamic>` AND MUST STAY THAT WAY. Narrowing it to
  /// `Map<String, String>` looks tidier and is a COMPILE ERROR: indexing it yields `String?`,
  /// while `SvgPicture.asset` (dashboard_manager.dart:120, :129) and `Text` (:138) take a
  /// non-nullable `String`.
  ///
  /// No longer an `Rx`: the one consumer reads it inside the `Obx` at dashboard_manager.dart:54,
  /// which the reassemble re-runs anyway, and `StylishBottomBar` re-reads `widget.items` from
  /// `build()` every frame -- it only re-runs `_state()` when `items.length` changes, so a fresh
  /// same-length list per build is what it already received.
  List<Map<String, dynamic>> get naviBarItemList => [
        {'icon': DefaultImages.dashboardIcn, 'title': 'Home'.tr},
        {'icon': DefaultImages.ordersIcn, 'title': 'Orders'.tr},
        {'icon': DefaultImages.productIcn, 'title': 'Products'.tr},
        {'icon': DefaultImages.categoriesIcn, 'title': 'Categories'.tr},
        {'icon': DefaultImages.moreIcn, 'title': 'More'.tr},
      ];

  // Create screens once and keep them alive
  late final List<Widget> screens;

  @override
  void onInit() {
    super.onInit();
    currantIndex.value = 0;
    // Initialize screens once
    screens = [
      HomeScreen(key: const ValueKey('dashboard')),
      OrderScreen(key: const ValueKey('orders')),
      ProductsScreen(key: const ValueKey('products'), isBack: false),
      CategoriesScreen(key: const ValueKey('category'), isBack: false,),
      SettingScreen(key: const ValueKey('settings'), isBack: false),
    ];
  }

  void updateIndex(int index) {
    if (currantIndex.value != index) {
      currantIndex.value = index;
    }
  }
}




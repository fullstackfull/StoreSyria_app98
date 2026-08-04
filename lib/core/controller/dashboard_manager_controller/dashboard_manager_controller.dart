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
  RxList naviBarItemList = [
    {'icon': DefaultImages.dashboardIcn, 'title': 'Home'.tr},
    {'icon': DefaultImages.ordersIcn, 'title': 'Orders'.tr},
    {'icon': DefaultImages.productIcn, 'title': 'Products'.tr},
    {'icon': DefaultImages.moreIcn, 'title': 'More'.tr},
  ].obs;

  // Create screens once and keep them alive
  late final List<Widget> screens;

  @override
  void onInit() {
    super.onInit();
    currantIndex.value = 0;
    // Initialize screens once
    screens = [
      HomeScreen(key: const ValueKey('dashboard')),
      OrderScreen(key: const ValueKey('orders'), isBack: false),
      ProductsScreen(key: const ValueKey('products'), isBack: false),
      SettingScreen(key: const ValueKey('settings'), isBack: false),
    ];
  }

  void updateIndex(int index) {
    if (currantIndex.value != index) {
      currantIndex.value = index;
    }
  }
}




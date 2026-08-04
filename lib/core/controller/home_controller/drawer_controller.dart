// ignore_for_file: prefer_const_constructors

import 'package:get/get.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/screen/home_screen/coupon_screen/coupon_screen.dart';
import 'package:store_go_app/view/screen/home_screen/tax_screen.dart';
import 'package:store_go_app/view/screen/order_screen/order_screen.dart';
import 'package:store_go_app/view/screen/setting_screen/plan_screen.dart';
import 'package:store_go_app/view/screen/home_screen/shipping_screen.dart';
import 'package:store_go_app/view/screen/setting_screen/setting_screen.dart';
import 'package:store_go_app/view/screen/product_screen/products_screen.dart';
import 'package:store_go_app/view/screen/category_screen/category_screen.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen.dart';

import '../../../routes/routes.dart';

class MyDrawerController extends GetxController {
  RxInt currantIndex = 0.obs;

  RxList drawerItem = [
  {
  "title": "Dashboard",
  "icon": DefaultImages.dashboardIcn,
  "route": AppRoutes.dashboard,
  },
  {
  "title": "Orders",
  "icon": DefaultImages.ordersIcn,
  "route": AppRoutes.orders,
  },
  {
  "title": "Products",
  "icon": DefaultImages.productIcn,
  "route": AppRoutes.products,
  },
  {
  "title": "Categories",
  "icon": DefaultImages.categoriesIcn,
  "route": AppRoutes.categories,
  },
  {
  "title": "Statistics",
  "icon": DefaultImages.statisticIcn,
  "route": AppRoutes.statistics,
  },
  {
  "title": "Settings",
  "icon": DefaultImages.settingIcn,
  "route": AppRoutes.settings,
  },
  {
  "title": "Shipping",
  "icon": DefaultImages.shippingIcn,
  "route": AppRoutes.shipping,
  },
  {
  "title": "Tax",
  "icon": DefaultImages.taxIcn,
  "route": AppRoutes.tax,
  },
  {
  "title": "Coupon",
  "icon": DefaultImages.couponIcn,
  "route": AppRoutes.coupon,
  },
  ].obs;
}

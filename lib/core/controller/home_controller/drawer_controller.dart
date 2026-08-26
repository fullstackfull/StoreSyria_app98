// ignore_for_file: prefer_const_constructors

import 'package:get/get.dart';
import 'package:store_go_app/utils/images.dart';
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

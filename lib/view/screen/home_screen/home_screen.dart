// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/home_screen/coupon_screen/new_coupon_bottomsheet.dart';
import 'package:store_go_app/view/screen/order_screen/order_detail_screen.dart';
import 'package:store_go_app/view/screen/product_screen/add_new_product_screen.dart';
import 'package:store_go_app/view/screen/product_screen/product_detail_screen.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/core/controller/home_controller/home_controller.dart';
import 'package:store_go_app/core/controller/dashboard_manager_controller/dashboard_manager_controller.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../core/controller/home_controller/category_controller.dart';
import '../../../core/model/dashboard_model.dart';
import '../../../core/model/static_model.dart';
import '../../new_widgets/category_widget.dart';
import '../../new_widgets/header_widget.dart';
import '../../new_widgets/top_orders.dart';
import '../../widget/common_snak_bar_widget.dart';
import '../statistics_screen/statistics_screen_widget.dart';
import 'add_category_bottomsheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final HomeController homeController = Get.put(HomeController());
  final CategoryController categoryController = Get.put(CategoryController());
  final ProductController productController = Get.put(ProductController(),permanent: true);
  final OrderController orderController = Get.put(OrderController());
  final NotificationController notificationController = Get.put(NotificationController());
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
  }

  Future<void> getData() async {
    await homeController.getDashboardData();
    await homeController.getImageBaseUrl();
    homeController.imageBaseUrl.value = Prefs.getString(AppConstant.imageUrl);
    // جلب الإشعارات عند فتح التطبيق
    await notificationController.getNotifications();
    // جلب الكاتيجوري
    await categoryController.getCategoryData(1);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<ThemeController>(
        builder: (themeController) {
          final bool isDark = themeController.isDark.value;
          final Color bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cLight;

          return GetBuilder<HomeController>(
              builder: (controller) {
                if (controller.dashboardData == null) {
                  return const LoadingWidget();
                }
                return SafeArea(
                  child: Scaffold(
                    backgroundColor: bgColor,
                    resizeToAvoidBottomInset: false,
                    body: LiquidPullToRefresh(
                      key: _refreshIndicatorKey,
                      onRefresh: getData,
                      showChildOpacityTransition: false,
                      backgroundColor: AppColor.themeGreenColor,
                      color: AppColor.cWhite,
                      springAnimationDurationInMilliseconds: 500,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildAppTitleRow(
                              dateFormatted(date: DateTime.now().toString(),
                                  formatType: formatForDateTime(FormatType.date)),
                            ),
                            verticalSpace(22),

                            buildProfileTitle(
                              profileImage: '${homeController.imageBaseUrl
                                  .value}${homeController.dashboardData?.user
                                  ?.image ?? ''}',
                              name: homeController.dashboardData?.user?.name ??
                                  "StoreSyria Admin",
                              onValue: (_) => getData(),
                            ),
                            verticalSpace(16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? DarkThemeColor.cCardBackground
                                    : AppColor.themeGreenColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.lightbulb_outline_rounded,
                                      size: 18, color: AppColor.themeGreenColor),
                                  horizontalSpace(10),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Have a nice day! '.tr,
                                        style: pBold12.copyWith(color: AppColor.cDarkGreyFont),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'Did you know that you can quickly add your favorite product or category to the store?'
                                                .tr,
                                            style: pRegular12.copyWith(
                                                color: AppColor.cDarkGreyFont),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            verticalSpace(16),

                            Obx(() {
                              final isStoreOpen = homeController.isStore
                                  .value;
                              final storeName = homeController.dashboardData?.qrcode
                                  ?.name ?? "My Store";

                              return GestureDetector(
                                onTap: () => homeController.isStore.toggle(),
                                child: Container(
                                  width: double.infinity,
                                  height: 68.h,
                                  decoration: BoxDecoration(
                                    color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.cShadow,
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          assetSvdImageWidget(
                                              image: DefaultImages.sLogoIcn,
                                              height: 25.h),
                                          horizontalSpace(15.h),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(storeName, style: pMedium14),
                                              Text(Prefs.getString(
                                                  AppConstant.emailId) ?? "",
                                                  style: pRegular8),
                                            ],
                                          ),
                                        ],
                                      ),
                                      assetSvdImageWidget(
                                        image: DefaultImages.dropDownIcn,
                                        colorFilter: ColorFilter.mode(
                                            AppColor.cLabel, BlendMode.srcIn),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),

                            Obx(() =>
                            homeController.isStore.value
                                ? Container(
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
                                border: Border.all(color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.cShadow,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: ListView.builder(
                                itemCount: homeController.dashboardData?.store
                                    ?.length ?? 0,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final store = homeController.dashboardData!
                                      .store![index];
                                  return InkWell(
                                    onTap: () {
                                      Prefs.setStoreID(store.id.toString());
                                      homeController.setStoreIdData(
                                          storeId: store.id.toString());
                                      homeController.isStore.value = false;
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Text(store.name?.trim() ?? "",
                                          style: pSemiBold12),
                                    ),
                                  );
                                },
                              ),
                            )
                                : const SizedBox.shrink()
                            ),
                            // verticalSpace(25),
                            // CommonIconButton(
                            //   title: 'Quick Add'.tr,
                            //   iconData: DefaultImages.addCircleIcn,
                            //   onPressed: () => homeController.isQuickAdd.toggle(),
                            //   height: 51,
                            // ),

                            if (homeController.isQuickAdd.value) ...[
                              verticalSpace(10),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColor.themeGreenColor,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.themeGreenColor.withOpacity(0.3),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    buildListTile(
                                      image: DefaultImages.newProductIcn,
                                      text: "Add new product".tr,
                                      onPressed: () => Get.to(() => const AddNewProductScreen(isUpdate: false)),
                                    ),
                                    buildListTile(
                                      image: DefaultImages.newCategoryIcn,
                                      text: "Add new category".tr,
                                      onPressed: () => showModalBottomSheet(
                                        context: context,
                                        backgroundColor: AppColor.cBackGround,
                                        barrierColor: AppColor.cGreyOpacity,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                        ),
                                        builder: (_) => AddNewCategoriesWidget(isUpdate: false),
                                      ),
                                    ),
                                    buildListTile(
                                      image: DefaultImages.newProductIcn,
                                      text: "Add new coupon".tr,
                                      onPressed: () => showModalBottomSheet(
                                        context: context,
                                        backgroundColor: AppColor.cBackGround,
                                        barrierColor: AppColor.cGreyOpacity,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                        ),
                                        builder: (_) => AddNewCouponWidget(isUpdate: false),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            verticalSpace(25),

                            HeaderWidget(
                              context: context,
                              title: "Statistics".tr,
                              label: "Show more statistics".tr,
                              onNewLabelTap: () => Get.to(() => StatisticsScreen()),
                            ),
                            verticalSpace(15),
                            qrCodeWidget(
                                qrString: homeController.dashboardData?.qrcode?.url ??
                                    "",
                                title: homeController.dashboardData?.qrcode?.name ??
                                    ""),
                            verticalSpace(15),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: totalProductWidget(image: DefaultImages.gridIcn,
                                      title: "Total".tr,
                                      subTitle: "Products".tr,
                                      total: homeController.dashboardData?.products
                                          ?.toString() ?? "0"),
                                ),
                                horizontalSpace(12),
                                Expanded(
                                  child: totalProductWidget(image: DefaultImages.listIcn,
                                      title: "Total".tr,
                                      subTitle: "Sales".tr,
                                      total: homeController.dashboardData?.sales
                                          ?.toString() ?? "0"),
                                ),
                                horizontalSpace(12),
                                Expanded(
                                  child: totalProductWidget(image: DefaultImages.cartIcn,
                                      title: "Total".tr,
                                      subTitle: "Orders".tr,
                                      total: homeController.dashboardData?.order
                                          ?.toString() ?? "0"),
                                ),
                              ],
                            ),
                            verticalSpace(30),

                            // Text("Orders".tr,
                            //     style: pMedium16.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                            // verticalSpace(10),
                            // OrderGraph(
                            //     list: homeController.dashboardData?.orderchart ?? []),
                            // verticalSpace(25),

                            StatisticsCard(
                              title: "Orders".tr,
                              subtitle: "Orders overview",
                              child: OrderGraph(
                                list: homeController.dashboardData?.orderchart ?? [],
                              ),
                            ),
                            verticalSpace(18),

                            HeaderWidget(
                              context: context,
                              title: "Categories".tr,
                              label: "add_category".tr,
                              onNewLabelTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  barrierColor: Colors.black54,
                                  isScrollControlled: true,
                                  useSafeArea: false,
                                  transitionAnimationController: AnimationController(
                                    vsync: Navigator.of(context),
                                    duration: const Duration(milliseconds: 400),
                                  ),
                                  builder: (context) {
                                    return AddNewCategoriesWidget(
                                      isUpdate: false,
                                    );
                                  },
                                );
                              },
                            ),
                            verticalSpace(15),
                            Obx(() {
                              if (categoryController.isLoading.value && categoryController.categoriesList.isEmpty) {
                                return const Center(child: LoadingWidget());
                              }
                              if (categoryController.categoriesList.isEmpty) {
                                return Container(
                                  height: 150,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "no_categories_found".tr,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey.shade400 : AppColor.cDarkGreyFont,
                                    ),
                                  ),
                                );
                              }
                              return GridView.builder(
                                itemCount: categoryController.categoriesList.take(6).length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220.w,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  mainAxisExtent: 225.h,
                                ),
                                itemBuilder: (context, index) {
                                  final category = categoryController.categoriesList[index];
                                  return buildCategoryWidget(
                                    context: context,
                                    category: category,
                                    categoryController: categoryController,
                                  );
                                },
                              );
                            }),
                            verticalSpace(25),


                            HeaderWidget(
                              context: context,
                              title: "Recent orders".tr,
                              label: "new_order".tr,
                              onNewLabelTap: () {},
                            ),
                            verticalSpace(15),
                            ListView.builder(
                              itemCount: homeController.recentOrderList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final order = homeController.recentOrderList[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: allOrdersListItemWidget(
                                    context: context,
                                    orderId: order.productOrderId ?? '',
                                    date: order.orderDate ?? '',
                                    maskedName: order.userName ?? '',
                                    price: "${order.finalPrice ?? '0.00'}",
                                    //primaryBadgeLabel: order.paymentStatus,
                                    secondaryBadgeLabel: "paid".tr,
                                    onTap: () => Get.to(() => OrderDetailScreen(orderId: order.id?.toString() ?? "")),
                                    viewFun: () => Get.to(() => OrderDetailScreen(orderId: order.id?.toString() ?? "")),
                                    deleteFun: () {
                                      if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                                        commonToast(AppConstant.demoString);
                                      } else {
                                        orderController.deleteOrderData(orderId: order.id?.toString() ?? "");
                                        getData();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                            verticalSpace(10),

                            StatisticsVisitorGraph(
                              visitorChart:
                              homeController.dashboardData?.visitorchart ??
                                  <VisitorChartData>[],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  Widget buildListTile({String? image, String? text, Function()? onPressed}) {
    return ListTile(
      leading: assetSvdImageWidget(image: image!),
      title: Text(text!, style: pMedium12.copyWith(color: AppColor.cWhite)),
      onTap: onPressed,
    );
  }

  Widget myStoreDropDown(
      {Function()? function, String? emailId, String? storeName}) {
    return GestureDetector(
      onTap: function,
      child: Container(
        width: double.infinity,
        height: 68.h,
        decoration: BoxDecoration(
          color: AppColor.cWhite,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColor.cBorder, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                assetSvdImageWidget(
                    image: DefaultImages.sLogoIcn, height: 25.h),
                horizontalSpace(15.h),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(storeName ?? "My Store".tr, style: pMedium14),
                    Text(emailId ?? "", style: pRegular8),
                  ],
                ),
              ],
            ),
            assetSvdImageWidget(
              image: DefaultImages.dropDownIcn,
              colorFilter: ColorFilter.mode(AppColor.cLabel, BlendMode.srcIn),
            )
          ],
        ),
      ),
    );
  }
}
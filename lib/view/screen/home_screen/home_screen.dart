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
import 'package:store_go_app/view/screen/home_screen/coupon_screen/coupon_screen.dart';
import 'package:store_go_app/view/screen/home_screen/coupon_screen/new_coupon_bottomsheet.dart';
import 'package:store_go_app/view/screen/order_screen/order_detail_screen.dart';
import 'package:store_go_app/view/screen/product_screen/add_new_product_screen.dart';
import 'package:store_go_app/view/screen/product_screen/product_detail_screen.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/core/controller/home_controller/home_controller.dart';
import 'package:store_go_app/core/controller/dashboard_manager_controller/dashboard_manager_controller.dart';
import 'package:store_go_app/core/controller/notification_controller/notification_controller.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../widget/common_snak_bar_widget.dart';
import 'add_category_bottomsheet.dart';
import 'coupon_screen/coupon_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final HomeController homeController = Get.put(HomeController());
  final ProductController productController = Get.put(ProductController());
  final NewCouponController couponController = Get.put(NewCouponController());
  final OrderController orderController = Get.put(OrderController());
  final NotificationController notificationController = Get.put(NotificationController());
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<
      LiquidPullToRefreshState>();

  @override
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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final bool isDark = themeController.isDark.value;
        final Color bgColor = isDark ? DarkThemeColor.cBackGround : LightThemeColor.cBackGround;

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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildAppTitleRow(
                            () => showPopup(context),
                        dateFormatted(date: DateTime.now().toString(),
                            formatType: formatForDateTime(FormatType.date)),
                      ),
                      verticalSpace(20),

                      buildProfileTitle(
                        profileImage: '${homeController.imageBaseUrl
                            .value}${homeController.dashboardData?.user
                            ?.image ?? ''}',
                        name: homeController.dashboardData?.user?.name ??
                            "StoreSyria Admin",
                        onValue: (_) => getData(),
                      ),
                      verticalSpace(16),

                      Text.rich(
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
                              color: AppColor.cWhite,
                              borderRadius: BorderRadius.circular(35),
                              border: Border.all(
                                  color: AppColor.cBorder, width: 1),
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
                          border: Border.all(color: AppColor.cBorder),
                          borderRadius: BorderRadius.circular(15),
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
                      verticalSpace(25),
                      CommonIconButton(
                        title: 'Quick Add'.tr,
                        iconData: DefaultImages.addCircleIcn,
                        onPressed: () => homeController.isQuickAdd.toggle(),
                        height: 51,
                      ),

                      if (homeController.isQuickAdd.value) ...[
                        verticalSpace(10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.themeGreenColor,
                            borderRadius: BorderRadius.circular(12),
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

                      titleShowMoreWidget(title: "Statistics".tr,
                          btnName: "Show more statistics".tr,
                          onPresses: () => Get.to(() => StatisticsScreen())),
                      verticalSpace(15),
                      qrCodeWidget(
                          qrString: homeController.dashboardData?.qrcode?.url ??
                              "",
                          title: homeController.dashboardData?.qrcode?.name ??
                              ""),
                      totalProductWidget(image: DefaultImages.gridIcn,
                          title: "Total".tr,
                          subTitle: "Products".tr,
                          total: homeController.dashboardData?.products
                              ?.toString() ?? "0"),
                      totalProductWidget(image: DefaultImages.listIcn,
                          title: "Total".tr,
                          subTitle: "Sales".tr,
                          total: homeController.dashboardData?.sales
                              ?.toString() ?? "0"),
                      totalProductWidget(image: DefaultImages.cartIcn,
                          title: "Total".tr,
                          subTitle: "Orders".tr,
                          total: homeController.dashboardData?.order
                              ?.toString() ?? "0"),
                      verticalSpace(40),

                      Text("Orders".tr,
                          style: pRegular10.copyWith(fontSize: 20)),
                      verticalSpace(10),
                      OrderGraph(
                          list: homeController.dashboardData?.orderchart ?? []),
                      verticalSpace(25),

                      titleShowMoreWidget(title: "Top Products".tr,
                          btnName: "Go to Products".tr,
                          onPresses: () {
                            final dashboardController = Get.find<DashboardManagerController>();
                            dashboardController.updateIndex(1);
                          }),
                      verticalSpace(15),
                      ListView.builder(
                        itemCount: homeController.topProductList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final product = homeController.topProductList[index];
                          return GestureDetector(
                            onTap: () =>
                                Get.to(() =>
                                    ProductDetailScreen(
                                        categoryId: product.categoryId
                                            ?.toString() ?? "",
                                        productId: product.id?.toString() ??
                                            "", id: product.id.toString(),
                                    )),
                            child: topProductWidget(
                              image: '${homeController.imageBaseUrl
                                  .value}${product.coverImagePath ?? ''}',
                              title: product.categoryName ?? "Uncategorized",
                              subTitle: product.name ?? "No Name",
                              amount: product.finalPrice ?? "0",
                              digit: (index + 1).toString(),
                              qty: product.productStock?.toString() ?? "0",
                              index: index,
                              deleteFun: () {
                                if (Prefs.getBool(AppConstant.isDemoMode) ==
                                    true) {
                                  commonToast(AppConstant.demoString);
                                } else {
                                  productController.deleteProductData(
                                      productId: product.id?.toString() ?? "");
                                  getData();
                                }
                              },
                              changeFun: () =>
                                  Get.to(() =>
                                      AddNewProductScreen(
                                        isUpdate: true,
                                        productId: product.id?.toString(),
                                        productName: product.name,
                                        qty: product.productStock?.toString(),
                                        priceController: product.finalPrice,
                                        productCategories: product.categoryName,
                                        trending: product.trending?.toString(),
                                        disAmountController: product
                                            .discountPrice,
                                        productTax: product.retuenText,
                                        variantName: product.variantAttribute
                                            ?.toString(),
                                        productDescription: product.description,
                                      )),
                              viewFun: () =>
                                  Get.to(() =>
                                      ProductDetailScreen(
                                          id: product.id.toString(),
                                          categoryId: product.categoryId
                                              ?.toString() ?? "",
                                          productId: product.id?.toString() ??
                                              "")),
                            ),
                          );
                        },
                      ),
                      verticalSpace(25),

                      titleShowMoreWidget(title: "Recent orders".tr,
                          btnName: "Go to Orders".tr,
                          onPresses: () {
                            final dashboardController = Get.find<DashboardManagerController>();
                            dashboardController.updateIndex(0);
                          }),
                      verticalSpace(15),
                      ListView.builder(
                        itemCount: homeController.recentOrderList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final order = homeController.recentOrderList[index];
                          return GestureDetector(
                            onTap: () =>
                                Get.to(() =>
                                    OrderDetailScreen(
                                        orderId: order.id?.toString() ?? "")),
                            child: recentOrdersWidget(
                              index: index,
                              status: order.deliveryStatus,
                              orderId: order.productOrderId,
                              name: order.userName,
                              date: order.orderDate,
                              usd: order.finalPrice?.toString() ?? "0",
                              viewFun: () =>
                                  Get.to(() =>
                                      OrderDetailScreen(
                                          orderId: order.id?.toString() ?? "")),
                              deleteFun: () {
                                if (Prefs.getBool(AppConstant.isDemoMode) ==
                                    true) {
                                  commonToast(AppConstant.demoString);
                                } else {
                                  orderController.deleteOrderData(
                                      orderId: order.id?.toString() ?? "");
                                  getData();
                                }
                              },
                            ),
                          );
                        },
                      ),
                      verticalSpace(10),

                      Text("Visitors".tr,
                          style: pRegular10.copyWith(fontSize: 20)),
                      verticalSpace(10),
                      VisitorChart(visitorChart: homeController.dashboardData
                          ?.visitorchart ?? []),
                      verticalSpace(25),

                      titleShowMoreWidget(title: "Product coupons".tr,
                          btnName: "Go to Coupons".tr,
                          onPresses: () => Get.to(() => const CouponScreen())),
                      verticalSpace(15),
                      ListView.builder(
                        itemCount: homeController.couponsList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final coupon = homeController.couponsList[index];
                          return GestureDetector(
                            onTap: () =>
                            coupon.id != null
                                ? Get.to(() =>
                                CouponDetailScreen(couponId: coupon.id!))
                                : null,
                            child: productCouponWidget(
                              index: index,
                              discount: "${coupon.discountAmount}${coupon
                                  .couponType == "percentage" ? "%" : ""}",
                              name: coupon.couponName,
                              code: coupon.couponCode,
                              date: '',
                              viewFun: () =>
                              coupon.id != null
                                  ? Get.to(() =>
                                  CouponDetailScreen(couponId: coupon.id!))
                                  : null,
                              deleteFun: () {
                                if (Prefs.getBool(AppConstant.isDemoMode) ==
                                    true) {
                                  commonToast(AppConstant.demoString);
                                } else {
                                  couponController.deleteCouponData(
                                      couponId: coupon.id?.toString() ?? "");
                                  getData();
                                }
                              },
                              changeFun: () =>
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: AppColor.cBackGround,
                                    barrierColor: AppColor.cGreyOpacity,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(30))),
                                    constraints: BoxConstraints(
                                        maxHeight: Get.height,
                                        minHeight: Get.height / 1.5),
                                    builder: (_) =>
                                        AddNewCouponWidget(
                                          isUpdate: true,
                                          couponId: coupon.id?.toString(),
                                          name: coupon.couponName,
                                          flat: coupon.couponType,
                                          code: coupon.couponCode,
                                          discount: coupon.discountAmount
                                              ?.toString(),
                                        ),
                                  ).then((_) => getData()),
                            ),
                          );
                        },
                      ),
                      verticalSpace(20),
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


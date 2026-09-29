// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/product_screen/add_new_product_screen.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/core/controller/home_controller/home_controller.dart';
import '../../../core/controller/home_controller/category_controller.dart';
import '../../../core/model/static_model.dart';
import '../../new_widgets/shimmer.dart';
import '../coupon_screen/new_coupon_bottomsheet.dart';
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
  //final NotificationController notificationController = Get.put(NotificationController());
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();  @override
  bool get wantKeepAlive => true;
  late final AnimationController _visitorChartController;
  late final AnimationController _visitorLineOpacityController;

  @override
  void initState() {
    super.initState();

    _visitorChartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _visitorLineOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
      _startVisitorChartAnimation();
    });
  }


  Future<void> getData() async {
    await homeController.getDashboardData();
    await homeController.getImageBaseUrl();
    homeController.imageBaseUrl.value = Prefs.getString(AppConstant.imageUrl);
    //await notificationController.getNotifications();
    //await categoryController.getCategoryData(1);
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
                  return Scaffold(
                    backgroundColor: bgColor,
                    body: const SafeArea(child: ShimmerDashboard()),
                  );
                }
                return Scaffold(
                  backgroundColor: bgColor,
                  resizeToAvoidBottomInset: false,
                  body: LiquidPullToRefresh(
                    key: _refreshIndicatorKey,
                    onRefresh: getData,
                    showChildOpacityTransition: false,
                    backgroundColor: AppColor.themeNavyBlueColor,
                    color: bgColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 40, 18, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildAppTitleRow(
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

                          Obx(() {
                            final isStoreOpen = homeController.isStore
                                .value;
                            final storeName = homeController.dashboardData?.qrcode
                                ?.name ?? "My Store";

                            return GestureDetector(
                              onTap: () => homeController.isStore.toggle(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: isStoreOpen
                                          ? AppColor.themeGreenColor.withOpacity(0.6)
                                          : (isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
                                      width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.cShadow,
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44.w,
                                      height: 44.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColor.themeGreenColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: assetSvdImageWidget(
                                          image: DefaultImages.sLogoIcn,
                                          height: 22.h),
                                    ),
                                    horizontalSpace(12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(storeName,
                                              style: pSemiBold14.copyWith(
                                                  color: isDark ? Colors.white : AppColor.cLabel),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          verticalSpace(2),
                                          Text(Prefs.getString(
                                              AppConstant.emailId) ?? "",
                                              style: pRegular10.copyWith(
                                                  color: isDark ? Colors.white60 : AppColor.cDarkGreyFont),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    horizontalSpace(8),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      width: 34.w,
                                      height: 34.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isStoreOpen
                                            ? AppColor.themeGreenColor.withOpacity(0.12)
                                            : (isDark
                                            ? DarkThemeColor.cBorder
                                            : AppColor.cLight),
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: isStoreOpen
                                              ? AppColor.themeGreenColor.withOpacity(0.35)
                                              : Colors.transparent,
                                          width: 1,
                                        ),
                                      ),
                                      child: AnimatedRotation(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOutBack,
                                        turns: isStoreOpen ? 0.5 : 0,
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 23.sp,
                                          color: isStoreOpen
                                              ? AppColor.themeGreenColor
                                              : (isDark
                                              ? Colors.white
                                              : AppColor.cLabel),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          Obx(() =>
                          homeController.isStore.value
                              ? Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
                              border: Border.all(color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.cShadow,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                                  borderRadius: BorderRadius.circular(14),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColor.themeGreenColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        horizontalSpace(12),
                                        Expanded(
                                          child: Text(store.name?.trim() ?? "",
                                              style: pSemiBold12.copyWith(
                                                  color: isDark ? Colors.white : AppColor.cLabel),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
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
                                      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
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
                                      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
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
                          verticalSpace(15),
                          qrCodeWidget(
                              qrString: homeController.dashboardData?.qrcode?.url ??
                                  "",
                              title: homeController.dashboardData?.qrcode?.name ??
                                  ""),
                          verticalSpace(24),
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColor.themeGreenColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              horizontalSpace(8),
                              Text(
                                'Overview'.tr,
                                style: pBold16.copyWith(
                                    color: isDark ? Colors.white : AppColor.themeNavyBlueColor),
                              ),
                            ],
                          ),
                          verticalSpace(12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: totalProductWidget(image: DefaultImages.gridIcn,
                                    title: "Total".tr,
                                    subTitle: "Products".tr,
                                    accentColor: AppColor.themeGreenColor,
                                    total: homeController.dashboardData?.products
                                        ?.toString() ?? "0"),
                              ),
                              horizontalSpace(10),
                              Expanded(
                                child: totalProductWidget(image: DefaultImages.listIcn,
                                    title: "Total".tr,
                                    subTitle: "Sales".tr,
                                    accentColor: AppColor.blueColor,
                                    total: homeController.dashboardData?.sales
                                        ?.toString() ?? "0"),
                              ),
                              horizontalSpace(10),
                              Expanded(
                                child: totalProductWidget(image: DefaultImages.cartIcn,
                                    title: "Total".tr,
                                    subTitle: "Orders".tr,
                                    accentColor: AppColor.cRed,
                                    total: homeController.dashboardData?.order
                                        ?.toString() ?? "0"),
                              ),
                            ],
                          ),

                          verticalSpace(24),
                          GlassVisitorChart(
                            visitorChart: homeController.dashboardData?.visitorchart ??
                                <VisitorChartData>[],
                            animation: _visitorChartController,
                            lineOpacity: _visitorLineOpacityController,
                          ),
                          verticalSpace(18),

                          // simpleAppBar(
                          //   title: "Categories".tr,
                          //   label: "add_category".tr,
                          //   onNewLabelTap: () {
                          //     showModalBottomSheet(
                          //       context: context,
                          //       backgroundColor: Colors.transparent,
                          //       barrierColor: Colors.black54,
                          //       isScrollControlled: true,
                          //       useSafeArea: false,
                          //       transitionAnimationController: AnimationController(
                          //         vsync: Navigator.of(context),
                          //         duration: const Duration(milliseconds: 400),
                          //       ),
                          //       builder: (context) {
                          //         return AddNewCategoriesWidget(
                          //           isUpdate: false,
                          //         );
                          //       },
                          //     );
                          //   },
                          // ),
                          // verticalSpace(15),
                          // Obx(() {
                          //   if (categoryController.isLoading.value && categoryController.categoriesList.isEmpty) {
                          //     return const Center(child: LoadingWidget());
                          //   }
                          //   if (categoryController.categoriesList.isEmpty) {
                          //     return Container(
                          //       height: 150,
                          //       alignment: Alignment.center,
                          //       child: Text(
                          //         "no_categories_found".tr,
                          //         style: TextStyle(
                          //           color: isDark ? Colors.grey.shade400 : AppColor.cDarkGreyFont,
                          //         ),
                          //       ),
                          //     );
                          //   }
                          //   return GridView.builder(
                          //     itemCount: categoryController.categoriesList.take(6).length,
                          //     shrinkWrap: true,
                          //     physics: const NeverScrollableScrollPhysics(),
                          //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          //       maxCrossAxisExtent: 220.w,
                          //       crossAxisSpacing: 12.w,
                          //       mainAxisSpacing: 12.h,
                          //       mainAxisExtent: 285.h,
                          //     ),
                          //     itemBuilder: (context, index) {
                          //       final category = categoryController.categoriesList[index];
                          //       return buildCategoryWidget(
                          //         context: context,
                          //         category: category,
                          //         categoryController: categoryController,
                          //       );
                          //     },
                          //   );
                          // }),
                          // verticalSpace(25),
                          //
                          // simpleAppBar(
                          //   title: "Recent orders".tr,
                          //   label: "new_order".tr,
                          //   onNewLabelTap: () {},
                          // ),
                          // verticalSpace(15),
                          // ListView.builder(
                          //   itemCount: homeController.recentOrderList.length,
                          //   shrinkWrap: true,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   itemBuilder: (context, index) {
                          //     final order = homeController.recentOrderList[index];
                          //     return Padding(
                          //       padding: EdgeInsets.only(bottom: 12.h),
                          //       child: allOrdersListItemWidget(
                          //         context: context,
                          //         orderId: order.productOrderId ?? '',
                          //         date: order.orderDate ?? '',
                          //         maskedName: order.userName ?? '',
                          //         price: "${order.finalPrice ?? '0.00'}",
                          //         //paymentStatusLabel:order.paymentStatus,
                          //         //orderStatusLabel: order.deliveredStatusString,
                          //         onTap: () => Get.to(() => OrderDetailScreen(orderId: order.id?.toString() ?? "")),
                          //         viewFun: () => Get.to(() => OrderDetailScreen(orderId: order.id?.toString() ?? "")),
                          //         deleteFun: () {
                          //           if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                          //             commonToast(AppConstant.demoString.tr);
                          //           } else {
                          //             orderController.deleteOrderData(orderId: order.id?.toString() ?? "");
                          //             getData();
                          //           }
                          //         },
                          //       ),
                          //     );
                          //   },
                          // ),
                          // verticalSpace(10),
                        ],
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
  Future<void> _startVisitorChartAnimation() async {
    if (!mounted) return;

    await _visitorChartController.forward(from: 0);

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    await _visitorLineOpacityController.reverse();

    if (!mounted) return;

    _visitorChartController.value = 0;

    await _visitorLineOpacityController.forward();

    if (!mounted) return;

    _startVisitorChartAnimation();
  }
  @override
  void dispose() {
    _visitorChartController.dispose();
    _visitorLineOpacityController.dispose();

    super.dispose();
  }
}
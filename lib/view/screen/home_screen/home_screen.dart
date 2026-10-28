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
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/core/controller/home_controller/home_controller.dart';
import '../../../core/controller/home_controller/category_controller.dart';
import '../../../core/model/static_model.dart';
import '../../new_widgets/shimmer.dart';
import '../statistics_screen/statistics_screen_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';

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
    //await homeController.getImageBaseUrl();
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
                /* P2-07-14. THIS WAS AN INFINITE SHIMMER ON ANY DASHBOARD FAILURE, on the
                   first screen a merchant sees. `dashboardData` is only assigned on success, so
                   a failed request left it null and this branch animated a loading skeleton
                   forever -- no error, no retry, and the toast that fired gone within seconds.

                   Now the three states are distinguished. `dashboardLoadedOnce` is what tells
                   "still loading" from "loaded and empty", which a null model alone cannot. */
                if (!controller.dashboardLoadedOnce.value ||
                    (controller.dashboardData == null &&
                        controller.dashboardError.value.isEmpty)) {
                  return Scaffold(
                    backgroundColor: bgColor,
                    body: const SafeArea(child: ShimmerDashboard()),
                  );
                }

                // Error before empty: a failed request also leaves the model null.
                if (controller.dashboardError.value.isNotEmpty &&
                    controller.dashboardData == null) {
                  return Scaffold(
                    backgroundColor: bgColor,
                    body: SafeArea(
                      child: ErrorState(
                        message: controller.dashboardError.value,
                        onRetry: controller.getDashboardData,
                      ),
                    ),
                  );
                }

                if (controller.dashboardData == null) {
                  return Scaffold(
                    backgroundColor: bgColor,
                    body: SafeArea(
                      child: EmptyState(
                        message: 'no_dashboard_data_yet'.tr,
                        icon: Icons.dashboard_outlined,
                      ),
                    ),
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
                            context,
                          ),
                          verticalSpace(20),

                          buildProfileTitle(
                            context,
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
                                          ? AppColor.themeGreenColor.withValues(alpha: 0.6)
                                          : (isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withValues(alpha: 0.5)),
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
                                        color: AppColor.themeGreenColor.withValues(alpha: 0.12),
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
                                            ? AppColor.themeGreenColor.withValues(alpha: 0.12)
                                            : (isDark
                                            ? DarkThemeColor.cBorder
                                            : AppColor.cLight),
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: isStoreOpen
                                              ? AppColor.themeGreenColor.withValues(alpha: 0.35)
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

                    Obx(
                          () => homeController.isStore.value
                          ? Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? DarkThemeColor.cCardBackground
                              : AppColor.cWhite,
                          border: Border.all(
                            color: isDark
                                ? DarkThemeColor.cBorder
                                : AppColor.cBorder.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.cShadow,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ListView.separated(
                          itemCount:
                          homeController.dashboardData?.store?.length ?? 0,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.8,
                            indent: 28,
                            endIndent: 8,
                            color: isDark
                                ? DarkThemeColor.cBorder
                                : AppColor.cBorder.withValues(alpha: 0.5),
                          ),
                          itemBuilder: (context, index) {
                            final store =
                            homeController.dashboardData!.store![index];

                            return InkWell(
                              onTap: () {
                                Prefs.setStoreID(store.id.toString());
                                homeController.setStoreIdData(
                                  storeId: store.id.toString(),
                                );
                                homeController.isStore.value = false;
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: AppColor.themeGreenColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    horizontalSpace(12),
                                    Expanded(
                                      child: Text(
                                        store.name?.trim() ?? "",
                                        style: pSemiBold14.copyWith(
                                          color: isDark
                                              ? Colors.white
                                              : AppColor.cLabel,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                          : const SizedBox.shrink(),
                          ),

                          verticalSpace(15),
                          qrCodeWidget(
                            context,
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
                                child: totalProductWidget(context,image: DefaultImages.gridIcn,
                                    title: "Total".tr,
                                    subTitle: "Products".tr,
                                    accentColor: AppColor.themeGreenColor,
                                    total: homeController.dashboardData?.products
                                        ?.toString() ?? "0"),
                              ),
                              horizontalSpace(10),
                              Expanded(
                                child: totalProductWidget(context,image: DefaultImages.listIcn,
                                    title: "Total".tr,
                                    subTitle: "Sales".tr,
                                    accentColor: AppColor.blueColor,
                                    total: homeController.dashboardData?.sales
                                        ?.toString() ?? "0"),
                              ),
                              horizontalSpace(10),
                              Expanded(
                                child: totalProductWidget(context,image: DefaultImages.cartIcn,
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
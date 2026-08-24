// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';
import 'package:store_go_app/core/model/coupon_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/screen/home_screen/coupon_screen/coupon_detail_screen.dart';
import 'package:store_go_app/view/screen/home_screen/coupon_screen/new_coupon_bottomsheet.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../new_widgets/coupon_widget.dart';
import '../../../new_widgets/header_widget.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen>
    with AutomaticKeepAliveClientMixin {
  final NewCouponController couponController =
  Get.put(NewCouponController());

  late final ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();

    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        couponController.refreshCoupons();
      }
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    if (!couponController.hasMore.value) return;

    if (couponController.isLoading.value) return;

    if (couponController.isLoadingMore.value) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      couponController.loadNextPage();
    }
  }


  Future<void> _fetchInitialData() async {
    await couponController.refreshCoupons();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();

    super.dispose();
  }

  void _addCoupon() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.cBackGround,
      barrierColor: AppColor.cGreyOpacity,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: Get.height,
        minHeight: Get.height / 1.5,
      ),
      builder: (context) {
        return AddNewCouponWidget(
          isUpdate: false,
        );
      },
    );
  }

  void _editCoupon(CouponData coupon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.cBackGround,
      barrierColor: AppColor.cGreyOpacity,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: Get.height,
        minHeight: Get.height / 1.5,
      ),
      builder: (context) {
        return AddNewCouponWidget(
          isUpdate: true,
          couponId: coupon.id.toString(),
          status: coupon.status.toString(),
          name: coupon.couponName,
          flat: coupon.couponType,
          date: coupon.couponExpiryDate,
          discount: coupon.discountAmount.toString(),
          code: coupon.couponCode,
          limit: coupon.couponLimit.toString(),
        );
      },
    );
  }

  void _viewCoupon(CouponData coupon) {
    Get.to(
          () => CouponDetailScreen(
        couponId: coupon.id!,
      ),
    );
  }

  void _deleteCoupon(CouponData coupon) {
    AppDialog.showCustomDialog(
      message: "deleteCupon",
      lottieAsset: 'assets/lottie/delete_icon.json',
      iconColor: AppColor.cRedText,
      confirmColor: AppColor.cRedText,
      context: context,
      onConfirm: () =>
        couponController.deleteCouponData(
          couponId: coupon.id.toString(),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: isDark
            ? DarkThemeColor.cBackGround
            : const Color(0xFFF5F6F8),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [

                // ==================================================
                // HEADER
                // ==================================================

                HeaderWidget(
                  showBackButton: true,
                  onBackTap: () => Get.back(),
                  context: context,
                  title: "Coupon",
                  label: "Add Coupon",
                  onNewLabelTap: _addCoupon,
                ),

                verticalSpace(16.h),

                // ==================================================
                // CONTENT
                // ==================================================

                Expanded(
                  child: Obx(() {

                    // ==================================================
                    // FIRST PAGE LOADING
                    // ==================================================

                    if (couponController.isLoading.value &&
                        couponController.couponsList.isEmpty) {
                      return const Center(
                        child: LoadingWidget(),
                      );
                    }

                    // ==================================================
                    // ERROR
                    // ==================================================

                    if (couponController.errorMessage.isNotEmpty &&
                        couponController.couponsList.isEmpty) {
                      return RefreshIndicator(
                        backgroundColor: isDark
                            ? DarkThemeColor.cCardBackground
                            : Colors.white,
                        onRefresh: _fetchInitialData,
                        child: ListView(
                          physics:
                          const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height:
                              MediaQuery.of(context).size.height *
                                  .6,
                              child: Center(
                                child: ErrorState(
                                  message: couponController
                                      .errorMessage.value,
                                  onRetry: _fetchInitialData,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ==================================================
                    // EMPTY
                    // ==================================================

                    if (couponController.couponsList.isEmpty) {
                      return RefreshIndicator(
                        backgroundColor: isDark
                            ? DarkThemeColor.cCardBackground
                            : Colors.white,
                        onRefresh: _fetchInitialData,
                        child: ListView(
                          physics:
                          const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height:
                              MediaQuery.of(context).size.height *
                                  .6,
                              child: Center(
                                child: EmptyState(
                                  message:
                                  "no_coupons_found".tr,
                                  icon:
                                  Icons.local_offer_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ==================================================
                    // COUPON LIST
                    // ==================================================

                    return RefreshIndicator(
                      backgroundColor: isDark
                          ? DarkThemeColor.cCardBackground
                          : Colors.white,
                      onRefresh: _fetchInitialData,
                      child: CustomScrollView(
                        controller: scrollController,
                        physics:
                        const AlwaysScrollableScrollPhysics(),
                        slivers: [

                          // ==================================================
                          // TOTAL COUPONS
                          // ==================================================

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 15.h,
                              ),
                              child: Row(
                                children: [

                                  Text(
                                    "${couponController.couponModel?.data?.total ?? 0} ${'items'.tr}",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : AppColor.cDarkGreyFont,
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),

                          // ==================================================
                          // COUPONS
                          // ==================================================

                          SliverPadding(
                            padding: EdgeInsets.only(
                              bottom: 20.h,
                            ),
                            sliver: SliverList(
                              delegate:
                              SliverChildBuilderDelegate(
                                    (context, index) {

                                  final CouponData coupon =
                                  couponController
                                      .couponsList[index];

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 12.h,
                                    ),
                                    child:
                                    productCouponWidget(
                                      context: context,
                                      index: index,

                                      // ==================================================
                                      // DISCOUNT
                                      // ==================================================

                                      discount: coupon
                                          .discountAmount
                                          .toString(),

                                      // ==================================================
                                      // NAME
                                      // ==================================================

                                      name: coupon.couponName,

                                      // ==================================================
                                      // CODE
                                      // ==================================================

                                      code: coupon.couponCode,

                                      // ==================================================
                                      // DATE
                                      // ==================================================

                                      date: coupon
                                          .couponExpiryDate,

                                      // ==================================================
                                      // TYPE
                                      // ==================================================

                                      couponType:
                                      coupon.couponType,

                                      // ==================================================
                                      // STATUS
                                      // ==================================================

                                      status:
                                      coupon.status ?? 0,

                                      // ==================================================
                                      // VIEW
                                      // ==================================================

                                      viewFun: () {
                                        _viewCoupon(coupon);
                                      },

                                      // ==================================================
                                      // EDIT
                                      // ==================================================

                                      showChangeAction: true,

                                      changeFun: () {
                                        _editCoupon(coupon);
                                      },

                                      // ==================================================
                                      // DELETE
                                      // ==================================================

                                      deleteFun: () {
                                        _deleteCoupon(coupon);
                                      },

                                      // ==================================================
                                      // CARD TAP
                                      // ==================================================

                                      onTap: () {
                                        _viewCoupon(coupon);
                                      },
                                    ),
                                  );
                                },
                                childCount:
                                couponController
                                    .couponsList.length,
                              ),
                            ),
                          ),

                          // ==================================================
                          // PAGINATION LOADER
                          // ==================================================

                          if (couponController.hasMore.value)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                EdgeInsets.symmetric(
                                  vertical: 20.h,
                                ),
                                child: Center(
                                  child: couponController
                                      .isLoadingMore.value
                                      ? CircularProgressIndicator(
                                    color: AppColor
                                        .themeNavyBlueColor,
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
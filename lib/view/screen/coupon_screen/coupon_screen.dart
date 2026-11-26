import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';
import 'package:store_go_app/core/model/coupon_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import '../../../utils/helper.dart';
import '../../new_widgets/coupon_widget.dart';
import '../../new_widgets/shimmer.dart';
import '../../widget/common_appbar_widget.dart';
import 'coupon_detail_screen.dart';
import 'new_coupon_bottomsheet.dart';
import 'package:store_go_app/utils/plural.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen>
    with AutomaticKeepAliveClientMixin {
  final NewCouponController couponController = Get.find<NewCouponController>();

  late final ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (couponController.couponsList.isEmpty &&
          !couponController.isLoading.value) {
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
      shape: const RoundedRectangleBorder(
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
        return const AddNewCouponWidget(
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
      shape: const RoundedRectangleBorder(
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
        appBar: simpleAppBar(
          isBack: true,
          // P06-WS8-I18N. BOTH OF THESE WERE HARD-CODED ENGLISH LITERALS, found by rendering the
          // screen: `coupons-screen.dark-rtl.png` showed "Coupon" and "Add Coupon" in Latin
          // script above an otherwise Arabic page. `simpleAppBar` renders what it is given
          // verbatim, so neither string ever reached GetX. Every sibling screen already passes a
          // key -- `customer_screen.dart:95` is `"customers".tr`, `products_screen.dart:493` is
          // `"products".tr` -- so this screen was the odd one out.
          //
          // The keys ALREADY EXISTED with copy in both maps, so no copy is written here. That is
          // the governing rule `test/translations/converted_labels_render_arabic_test.dart`
          // records: convert a call site only if its key already has copy on both sides AND the
          // existing English value is BYTE-IDENTICAL to the literal being replaced. `coupon` is
          // "Coupon" and `add_coupon` is "Add Coupon", so the English screen does not move by a
          // single character.
          title: "coupon".tr,
          isBold: true,
          label: "add_coupon".tr,
          onNewLabelTap: _addCoupon,
        ),
        backgroundColor: isDark
            ? DarkThemeColor.cBackGround
            : const Color(0xFFF5F6F8),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
                child: Obx(() {

                  if (couponController.isLoading.value &&
                      couponController.couponsList.isEmpty) {
                    return const ShimmerList(
                      leading: ShimmerLeading.square,
                    );
                  }

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

                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: 15.h,
                            ),
                            child: Row(
                              children: [

                                Text(
                                  // P06-WS8-I18N -- see utils/plural.dart.
                                  itemCountLabel(
                                      couponController.couponModel?.data?.total ?? 0),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : AppColor.cDarkGreyFont,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),

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
                                  child: productCouponWidget(
                                    context: context,
                                    index: index,
                                    discount: coupon.discountAmount.toString(),
                                    name: coupon.couponName,
                                    code: coupon.couponCode,
                                    date: dateFormatted(
                                        date: coupon.couponExpiryDate ?? '',
                                        formatType: formatForDateTime(
                                          FormatType.date,
                                        )),
                                    couponType: coupon.couponType,
                                    status: coupon.status ?? 0,
                                    viewFun: () {
                                      _viewCoupon(coupon);
                                    },

                                    showChangeAction: true,
                                    changeFun: () {
                                      _editCoupon(coupon);
                                    },
                                    deleteFun: () {
                                      _deleteCoupon(coupon);
                                    },
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
            ),
          ],
        ),
      ),
    );
  }
}
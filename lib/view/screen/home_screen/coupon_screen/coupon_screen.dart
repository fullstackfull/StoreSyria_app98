// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:get/get.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/screen/home_screen/coupon_screen/coupon_detail_screen.dart';
import 'package:store_go_app/view/screen/home_screen/coupon_screen/new_coupon_bottomsheet.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import '../../../widget/app_dialog.dart';
import '../../../widget/error_empty_state.dart';
import '../../../widget/loading_widget.dart';
import '../home_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/core/model/coupon_model.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({
    super.key,
  });

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  NewCouponController couponController = Get.put(NewCouponController());
  ScrollController? scrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    couponController.couponsList.clear();
    couponController.currantPage.value = 1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
    scrollController = ScrollController();
    scrollController!.addListener(() {
      if (couponController.isScroll.value == true &&
          scrollController!.offset >=
              scrollController!.position.maxScrollExtent &&
          !scrollController!.position.outOfRange) {
        couponController.currantPage.value += 1;
        couponController.getCouponData(couponController.currantPage.value);
        print(
            "currantPage................-> ${couponController.currantPage.value}");
      }
    });
  }

  @override
  void dispose() {
    scrollController!.dispose();
    super.dispose();
  }

  getData() {
    couponController.getCouponData(couponController.currantPage.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cBackGround,
      appBar: simpleAppBar(title: "Coupon"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              children: [
              CommonIconButton(
                    title: 'Add Coupon',
                    iconData: DefaultImages.addCircleIcn,
                    onPressed: () {
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
                            maxHeight: Get.height, minHeight: Get.height / 1.5),
                        builder: (context) {
                          return AddNewCouponWidget(
                            isUpdate: false,
                          );
                        },
                      );
                    },
                    height: 51,
                  ),
                verticalSpace(20),
Expanded(
child: Obx(() {
  /// First Loading
  if (couponController.isLoading.value &&
      couponController.currantPage.value == 1) {
    return const Center(child: LoadingWidget());
  }

  /// Error
  if (couponController.errorMessage.isNotEmpty &&
      couponController.couponsList.isEmpty) {
    return RefreshIndicator(
      onRefresh: () async => getData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * .6,
            child: Center(
                child: ErrorState(
                  message: couponController.errorMessage.value,
                  onRetry: getData,
                )
            ),
          ),
        ],
      ),
    );
  }

  /// Empty
  if (couponController.couponsList.isEmpty) {
    return RefreshIndicator(
      onRefresh: () async => getData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * .6,
            child: Center(
              child: EmptyState(
                message: "no_orders_found".tr,
                icon: Icons.receipt_long_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Data
  return RefreshIndicator(
    backgroundColor: Colors.white,
    onRefresh: () async => getData(),
    child: ListView.builder(
      key: UniqueKey(),
      controller: scrollController,
      itemCount: couponController.couponsList.length,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        CouponData coupons =
        couponController.couponsList[index];
        return GestureDetector(
          onTap: () {
            Get.to(() => CouponDetailScreen(couponId: coupons.id!,));
          },
          child: productCouponWidget(
              index: index,
              discount:
              "${coupons.discountAmount}${coupons.couponType == "percentage"
                  ? "%"
                  : ""}",
              name: coupons.couponName,
              code: coupons.couponCode,
              viewFun: () {
                Get.to(() => CouponDetailScreen(couponId: coupons.id!,));
              },
              deleteFun: () {
                AppDialog.showCustomDialog(
                  message: "deleteCupon",
                    iconColor: AppColor.cRedText,
                    confirmColor: AppColor.cRedText,
                    context: context,
                    onConfirm: () =>
                        couponController.deleteCouponData(
                            couponId: coupons.id.toString())
                );
              },
              changeFun: () {
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
                      minHeight: Get.height / 1.5),
                  builder: (context) {
                    return AddNewCouponWidget(
                      isUpdate: true,
                      couponId: coupons.id.toString(),
                      name: coupons.couponName,
                      flat: coupons.couponType,
                      date: coupons.couponExpiryDate,
                      discount:
                      coupons.discountAmount.toString(),
                      code: coupons.couponCode,
                      limit: coupons.couponLimit.toString(),
                    );
                  },
                );
              },
              date: coupons.couponExpiryDate),
        );
      },
    ),
  );
})),
            ])
          ),
        ),
    );
  }
}





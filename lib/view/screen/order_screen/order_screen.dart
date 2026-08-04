// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables, avoid_print

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/core/model/order_model.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/screen/order_screen/order_detail_screen.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import '../../widget/error_empty_state.dart';
import '../../widget/loading_widget.dart';


class OrderScreen extends StatefulWidget {
  final bool isBack;

  OrderScreen({super.key, required this.isBack});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with AutomaticKeepAliveClientMixin {
  OrderController orderController = Get.put(OrderController());
  ScrollController scrollController = ScrollController();
  bool _isFirstLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        orderController.currantPage.value = 1;
        orderController.isScroll.value = true;
        orderController.orderList.clear();
        getData();
      }
    });

    scrollController.addListener(() {
      if (orderController.isScroll.value == true &&
          scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        orderController.currantPage.value += 1;
        orderController.getOrderData(orderController.currantPage.value);
      }
    });
  }

  getData() {
    orderController.getOrderData(orderController.currantPage.value);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
        appBar: simpleAppBar(isBack: widget.isBack, title: "orders".tr),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchFieldWidget(
                    controller: orderController.searchController,
                    hint: 'search_order_hint'.tr,
                    onChanged: (value) {
                      if (value.length > 2) {
                        orderController.searchOrderData(name: value);
                      } else if (value.isEmpty) {
                        getData();
                      }
                    },
                    onTap: () {
                      getData();
                      orderController.searchController.clear();
                    },
                    keyboardType: TextInputType.text,
                  ),

                  verticalSpace(20.h),

                  Text(
                    "recent_orders".tr,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColor.themeNavyBlueColor,
                    ),
                  ),

                  verticalSpace(15.h),

                  Expanded(
                    child: Obx(() {
                      /// First Loading
                      if (orderController.isLoading.value &&
                          orderController.currantPage.value == 1) {
                        return const Center(child: LoadingWidget());
                      }

                      /// Error
                      if (orderController.errorMessage.isNotEmpty &&
                          orderController.orderList.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async => getData(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * .6,
                                child: Center(
                                  child: ErrorState(
                                    message: orderController.errorMessage.value,
                                    onRetry: getData,
                                  )
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      /// Empty
                      if (orderController.orderList.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async => getData(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * .6,
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
                          controller: scrollController,
                          itemCount: orderController.orderList.length +
                              (orderController.isScroll.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == orderController.orderList.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  child: Center(child: CircularProgressIndicator(
                                      color: AppColor.themeNavyBlueColor)),
                                );
                              }

                              OrderData order = orderController.orderList[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(() => OrderDetailScreen(orderId: order.id.toString()));
                                  },
                                  child: recentOrdersWidget(
                                      index: index,
                                      status: order.paymentStatus!,
                                      orderId: order.productOrderId,
                                      name: order.userName,
                                      date: dateFormatted(date: order.orderDate!,
                                          formatType: formatForDateTime(FormatType.date)),
                                      usd: order.finalPrice.toString(),
                                      downloadFun: () {},
                                      shareFun: () {},
                                      viewFun: () {
                                        Get.to(() =>
                                            OrderDetailScreen(orderId: order.id.toString()));
                                      },
                                      deleteFun: () {
                                        AppDialog.showCustomDialog(
                                            iconColor: AppColor.cRedText,
                                            confirmColor: AppColor.cRedText,
                                            context: context,
                                            onConfirm: () =>
                                                orderController.deleteOrderData(
                                                    orderId: order.id.toString())
                                        );
                                      }
                                  ),
                                ),
                              );
                          })
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

Widget searchFieldWidget({
  String? hint,
  Function(String)? onChanged,
  TextEditingController? controller,
  Function()? onTap,
  TextInputType? keyboardType
}) {
  final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final hintColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;
  final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder;

  return Container(
    height: 55.h,
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: borderColor.withOpacity(0.5)),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textColor),
      cursorColor: AppColor.themeGreenColor,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        prefixIcon: Padding(
          padding: EdgeInsets.all(12.w),
          child: assetSvdImageWidget(image: DefaultImages.searchIcn),
        ),
        suffixIcon: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(Icons.arrow_circle_right_rounded, color: AppColor.themeGreenColor, size: 25.sp),
          ),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: hintColor),
      ),
    ),
  );
}

Widget dataNotFoundTextWidget() => Text(
  "Data not found",
  style: pRegular14.copyWith(color: AppColor.cFont),
);

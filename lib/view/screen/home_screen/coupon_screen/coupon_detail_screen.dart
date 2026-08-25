// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';
import 'package:store_go_app/core/model/view_used_coupon_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../widget/common_appbar_widget.dart';

class CouponDetailScreen extends StatefulWidget {
  final int couponId;

  const CouponDetailScreen({
    super.key,
    required this.couponId,
  });

  @override
  State<CouponDetailScreen> createState() => _CouponDetailScreenState();
}

class _CouponDetailScreenState extends State<CouponDetailScreen> {
  final NewCouponController couponController =
  Get.find<NewCouponController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        couponController.getUsedCouponData(widget.couponId);
      }
    });
  }

  Future<void> _fetchData() async {
    await couponController.getUsedCouponData(widget.couponId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark
            ? DarkThemeColor.cBackGround
            : const Color(0xFFF5F6F8),
        appBar: simpleAppBar(
          title: "Coupon Details".tr,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            child:Obx(() {
              final list = couponController.viewCouponsList;

              // 1. Loading
              if (couponController.isUsedCouponLoading.value &&
                  list.isEmpty) {
                return const Center(
                  child: LoadingWidget(),
                );
              }

              // 2. Data Not Found
              if (couponController.usedCouponEmptyMessage.isNotEmpty &&
                  list.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .6,
                        child: Center(
                          child: EmptyState(
                            message: couponController
                                .usedCouponEmptyMessage
                                .value,
                            icon: Icons.receipt_long_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 3. Real Error
              if (couponController.usedCouponErrorMessage.isNotEmpty &&
                  list.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .6,
                        child: Center(
                          child: ErrorState(
                            message: couponController
                                .usedCouponErrorMessage
                                .value,
                            onRetry: _fetchData,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 4. Data
              return RefreshIndicator(
                onRefresh: _fetchData,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final data = list[index];

                    return _buildUsageCard(
                      data: data,
                      isDark: isDark,
                    );
                  },
                ),
              );
            })
          ),
        ),
      ),
    );
  }

  // ============================================================
  // USAGE CARD
  // ============================================================

  Widget _buildUsageCard({
    required ViewUsedCouponData data,
    required bool isDark,
  }) {
    final green = AppColor.themeGreenColor;

    final cardColor = isDark
        ? DarkThemeColor.cCardBackground
        : Colors.white;

    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFE7E9ED);

    String formattedDate = '-';

    if (data.dateUsed != null &&
        data.dateUsed!.isNotEmpty) {
      try {
        formattedDate = dateFormatted(
          date: data.dateUsed!,
          formatType:
          formatForDateTime(FormatType.date),
        );
      } catch (_) {
        formattedDate = data.dateUsed!;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.couponName ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13.sp,
                          color: green,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Used Successfully",
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w500,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // =================================================
              // AMOUNT
              // =================================================

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "AMOUNT",
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    data.amount != null
                        ? data.amount!.toStringAsFixed(2)
                        : '0.00',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // =====================================================
          // DIVIDER
          // =====================================================

          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : const Color(0xFFEDEEF1),
          ),

          SizedBox(height: 15.h),

          // =====================================================
          // INFO
          // =====================================================

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.receipt_long_outlined,
                  title: "Order ID",
                  value:
                  "#${data.productOrderId ?? data.orderId ?? '-'}",
                  green: green,
                  isDark: isDark,
                ),
              ),

              Container(
                width: 1,
                height: 38.h,
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : const Color(0xFFEDEEF1),
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  title: "Date",
                  value: formattedDate,
                  green: green,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color green,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: green,
          ),
        ),

        SizedBox(width: 8.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.grey.shade900
                      : Colors.grey.shade500,
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
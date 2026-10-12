import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/controller/order_controller/order_controller.dart';
import '../../utils/colors.dart';
import '../widget/app_dialog.dart';
import '../widget/common_space_divider_widget.dart';
import 'order_status_badge.dart';

void showPaymentStatusBottomSheet<T>(
    BuildContext context,
    T model, {
      required String Function(T model) getPaymentStatus,
      required String Function(T model) getProductOrderId,
      required int Function(T model) getDeliveredStatus,
      required void Function(T model, String newPaymentStatus) setPaymentStatus,
      VoidCallback? onUpdated,
    }) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  OrderController orderController = Get.find<OrderController>();

  final currentPaymentStatus = getPaymentStatus(model);

  final currentIsPaid =
      currentPaymentStatus.toLowerCase().trim() == 'paid';

  bool tempIsPaid = currentIsPaid;

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? DarkThemeColor.cBackGround
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? DarkThemeColor.cBorder
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'update_payment_status'.tr,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColor.cText,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? DarkThemeColor.cCardBackground
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 18.sp,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        verticalSpace(24.h),

                        // Paid
                        _PaymentOptionCard(
                          title: 'paid'.tr,
                          subtitle: 'payment_paid_desc'.tr,
                          icon: Icons.check_circle,
                          bgColor: const Color(0xFFE8F5E9),
                          textColor: const Color(0xFF2E7D32),
                          isSelected: tempIsPaid,
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              tempIsPaid = true;
                            });
                          },
                        ),

                        verticalSpace(12.h),

                        // Unpaid
                        _PaymentOptionCard(
                          title: 'unpaid'.tr,
                          subtitle: 'payment_unpaid_desc'.tr,
                          icon: Icons.cancel,
                          bgColor: const Color(0xFFFFEBEE),
                          textColor: const Color(0xFFC62828),
                          isSelected: !tempIsPaid,
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              tempIsPaid = false;
                            });
                          },
                        ),

                        verticalSpace(24.h),

                        // Confirm Button
                        Obx(
                              () => SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed:
                              orderController
                                  .isUpdatingOrderStatus
                                  .value
                                  ? null
                                  : () async {
                                // لم يتغير شيء
                                if (tempIsPaid ==
                                    currentIsPaid) {
                                  Get.back();
                                  return;
                                }

                                final newPaymentStatus =
                                tempIsPaid
                                    ? 'Paid'
                                    : 'Unpaid';

                                // أغلق الـ BottomSheet
                                Get.back();

                                final success =
                                await orderController
                                    .updateOrderStatus(
                                  productOrderId:
                                  getProductOrderId(model)
                                      .replaceAll('#', ''),
                                  deliveredStatus:
                                  getDeliveredStatus(model),
                                  paymentStatus:
                                  newPaymentStatus,
                                  note: null,
                                );

                                if (success) {
                                  // تحديث الـ model محلياً
                                  setPaymentStatus(
                                    model,
                                    newPaymentStatus,
                                  );

                                  // تحديث الواجهة
                                  onUpdated?.call();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                AppColor.themeNavyBlueColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14.r),
                                ),
                              ),
                              child:
                              orderController
                                  .isUpdatingOrderStatus
                                  .value
                                  ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child:
                                const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                                  : Text(
                                'confirm_update'.tr,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enterBottomSheetDuration:
    const Duration(milliseconds: 300),
    exitBottomSheetDuration:
    const Duration(milliseconds: 250),
  );
}

class _PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? bgColor.withValues(alpha: isDark ? 0.15 : 1)
              : (isDark ? DarkThemeColor.cCardBackground : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? textColor : (isDark ? DarkThemeColor.cBorder : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: isDark ? 0.3 : 1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: textColor, size: 24.sp),
            ),
            horizontalSpace(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColor.cText,
                    ),
                  ),
                  verticalSpace(2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey.shade400 : AppColor.cFont,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1 : 0,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 18.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderStatusBottomSheet {
  static void show<T>(
      BuildContext context,
      T model, {
        required int Function(T model) getOrderStatus,
        required String Function(T model) getProductOrderId,
        required String Function(T model) getPaymentStatus,
        required void Function(T model, int newStatus) setOrderStatus,
        required void Function(T model, String newStatusText)
        setOrderStatusText,
        VoidCallback? onUpdated,
      }) {
    final OrderController orderController =
    Get.find<OrderController>();

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    int tempStatus = getOrderStatus(model);

    final noteController = TextEditingController();

    const statusIds = [0, 1, 2, 3, 4, 5, 6];

    Get.bottomSheet(
      _BouncyBottomSheet(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight:
                MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? DarkThemeColor.cBackGround
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? DarkThemeColor.cBorder
                          : Colors.grey.shade300,
                      borderRadius:
                      BorderRadius.circular(2.r),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      16.h,
                      20.w,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'update_order_status'.tr,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColor.cText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? DarkThemeColor
                                  .cCardBackground
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18.sp,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  verticalSpace(16.h),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          ...statusIds.map(
                                (statusId) {
                              final isSelected =
                                  tempStatus == statusId;

                              final config =
                              StatusBadgeHelper
                                  .getOrderConfig(
                                statusId,
                              );

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    tempStatus = statusId;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom: 8.h,
                                  ),
                                  padding:
                                  EdgeInsets.all(14.w),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark
                                        ? config
                                        .backgroundColor
                                        .withValues(alpha: 0.15)
                                        : config
                                        .backgroundColor)
                                        : (isDark
                                        ? DarkThemeColor
                                        .cCardBackground
                                        : Colors
                                        .grey.shade50),
                                    borderRadius:
                                    BorderRadius.circular(
                                        14.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? config.textColor
                                          : (isDark
                                          ? DarkThemeColor
                                          .cBorder
                                          : Colors.grey
                                          .shade200),
                                      width:
                                      isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CommonStatusBadge(
                                        type:
                                        StatusBadgeType.order,
                                        orderStatus: statusId,
                                        showArrow: false,
                                        isCard: true,
                                      ),

                                      SizedBox(width: 12.w),

                                      Expanded(
                                        child: Text(
                                          StatusBadgeHelper
                                              .getOrderDescription(
                                            statusId,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: isDark
                                                ? Colors
                                                .grey.shade400
                                                : AppColor.cFont,
                                          ),
                                        ),
                                      ),

                                      AnimatedOpacity(
                                        duration:
                                        const Duration(
                                          milliseconds: 200,
                                        ),
                                        opacity:
                                        isSelected ? 1 : 0,
                                        child: Container(
                                          width: 26.w,
                                          height: 26.w,
                                          decoration:
                                          BoxDecoration(
                                            color:
                                            config.textColor,
                                            shape:
                                            BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          verticalSpace(16.h),

                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? DarkThemeColor
                                  .cCardBackground
                                  : Colors.grey.shade50,
                              borderRadius:
                              BorderRadius.circular(14.r),
                              border: Border.all(
                                color: isDark
                                    ? DarkThemeColor.cBorder
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'status_note'.tr,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight:
                                    FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppColor.cText,
                                  ),
                                ),

                                verticalSpace(8.h),

                                TextField(
                                  controller: noteController,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: isDark
                                        ? Colors.white
                                        : AppColor.cText,
                                  ),
                                  decoration:
                                  InputDecoration(
                                    hintText:
                                    'add_status_note'.tr,
                                    hintStyle: TextStyle(
                                      fontSize: 12.sp,
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : AppColor.cFont
                                          .withValues(alpha: 0.6),
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? DarkThemeColor
                                        .cBackGround
                                        : Colors.white,
                                    border:
                                    OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          10.r),
                                      borderSide:
                                      BorderSide.none,
                                    ),
                                    contentPadding:
                                    EdgeInsets.all(12.w),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          verticalSpace(20.h),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20.w,
                      0,
                      20.w,
                      20.h +
                          MediaQuery.of(context)
                              .padding
                              .bottom,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? DarkThemeColor.cBackGround
                          : Colors.white,
                    ),
                    child: Obx(
                          () => AppButton(
                        text: 'confirm_update'.tr,
                        isLoading: orderController
                            .isUpdatingOrderStatus.value,
                        onPressed: orderController
                            .isUpdatingOrderStatus.value
                            ? null
                            : () async {
                          final selectedStatus =
                              tempStatus;

                          Get.back();

                          final success =
                          await orderController
                              .updateOrderStatus(
                            productOrderId:
                            getProductOrderId(model)
                                .replaceAll('#', ''),
                            deliveredStatus:
                            selectedStatus,
                            paymentStatus:
                            getPaymentStatus(model),
                            note: noteController.text
                                .trim()
                                .isEmpty
                                ? null
                                : noteController.text
                                .trim(),
                          );

                          if (success) {
                            setOrderStatus(
                              model,
                              selectedStatus,
                            );

                            setOrderStatusText(
                              model,
                              StatusBadgeHelper
                                  .getOrderName(
                                selectedStatus,
                              ),
                            );

                            onUpdated?.call();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration:
      const Duration(milliseconds: 1),
      exitBottomSheetDuration:
      const Duration(milliseconds: 250),
    );
  }
}

class _BouncyBottomSheet extends StatelessWidget {
  final Widget child;

  const _BouncyBottomSheet({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, height * value),
          child: child,
        );
      },
      child: child,
    );
  }
}
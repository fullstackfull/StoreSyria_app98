import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/order_screen/invoice_pdf_view.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import '../../../core/controller/delivery_boy/delivery_boy_controller.dart';
import '../../../core/model/order_detail_model.dart';
import '../../new_widgets/customer_contact.dart';
import '../../new_widgets/delivery_boy_bottom_sheet.dart';
import '../../new_widgets/order_status_badge.dart';
import '../../new_widgets/payment_status_bottom_sheet.dart';
import '../../new_widgets/shimmer.dart';
import '../../widget/app_dialog.dart';
import '../../widget/common_snak_bar_widget.dart';
import '../../widget/error_empty_state.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderController orderController = Get.find<OrderController>();
  final DeliveryBoyController deliveryBoyController =
  Get.isRegistered<DeliveryBoyController>()
      ? Get.find<DeliveryBoyController>()
      : Get.put(DeliveryBoyController());

  @override
  void initState() {
    super.initState();
    orderController.extTax.value = 0.0;
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
    if (deliveryBoyController.deliveryBoyList.isEmpty) {
      deliveryBoyController.getDeliveryBoysData();
    }
  }

  void getData() {
    orderController.getOrderDetailData(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    final bgColor =
    isDark ? DarkThemeColor.cBackGround : const Color(0xFFF7F8FA);

    final cardBg =
    isDark ? DarkThemeColor.cCardBackground : Colors.white;

    final borderColor = isDark
        ? DarkThemeColor.cBorder
        : const Color(0xFFE8EAF0);

    final primaryText =
    isDark ? Colors.white : AppColor.cText;

    final secondaryText =
    isDark ? Colors.grey.shade400 : const Color(0xFF7B8190);

    final accentColor = AppColor.cGreenFont;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: simpleAppBar(
        title: "order_details".tr,
        isBack: true,
        label: null,
        onNewLabelTap: () {},
      ),
      body: SafeArea(
        child: Obx(() {
          if (orderController.isLoadingOrderDetails.value) {
            return const ShimmerDetails(sections: 4, rowsPerSection: 4);
          }

          if (orderController.orderNotFound.value) {
            return EmptyState(
              message: "order_not_found_desc".tr,
              icon: Icons.receipt_long_outlined,
              actionWidget: TextButton.icon(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back,
                  size: 24.sp,
                  color: AppColor.themeNavyBlueColor,
                ),
                label: Text(
                  "back".tr,
                  style: pSemiBold14.copyWith(fontSize: 18.sp),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.themeNavyBlueColor,
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 12.h),
                ),
              ),
            );
          }

          if (orderController.errorMessage.isNotEmpty &&
              orderController.orderDetail == null) {
            return ErrorState(
              message: orderController.errorMessage.value,
              onRetry: getData,
            );
          }

          if (orderController.orderDetail == null) {
            return EmptyState(
              message: "no_details_found".tr,
              icon: Icons.info_outline,
            );
          }

          final detail = orderController.orderDetail!;

          return RefreshIndicator(
            onRefresh: () async {
              await orderController.getOrderDetailData(widget.orderId);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                30.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
// ─────────────────────────────
// ORDER HEADER
// ─────────────────────────────
                  _buildOrderHeader(
                    detail: detail,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    accentColor: accentColor,
                  ),

                  verticalSpace(14.h),

// ─────────────────────────────
// INVOICE BUTTON
// ─────────────────────────────
                  _buildInvoiceButton(
                    context: context,
                    detail: detail,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    accentColor: accentColor,
                  ),

                  verticalSpace(26.h),

// ─────────────────────────────
// PRODUCTS
// ─────────────────────────────
                  _sectionTitle(
                    title: "order_items".tr,
                    icon: Icons.shopping_bag_outlined,
                    color: accentColor,
                  ),

                  verticalSpace(12.h),

                  _buildProductsCard(
                    detail: detail,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    accentColor: accentColor,
                  ),

                  verticalSpace(26.h),

// ─────────────────────────────
// PAYMENT SUMMARY
// ─────────────────────────────
                  _buildPaymentSummary(
                    detail: detail,
                    accentColor: accentColor,
                  ),

                  verticalSpace(26.h),

// ─────────────────────────────
// SHIPPING & BILLING
// ─────────────────────────────
                  _sectionTitle(
                    title: "shipping_info".tr,
                    icon: Icons.local_shipping_outlined,
                    color: accentColor,
                  ),

                  verticalSpace(12.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: infoSectionCard(
                          title: "shipping_info".tr,
                          icon: Icons.local_shipping_outlined,
                          data: {
                            "name".tr:
                            detail.deliveryInformations?.name ?? "",
                            "phone".tr:
                            detail.deliveryInformations?.phone ?? "",
                            "city".tr:
                            detail.deliveryInformations?.city ?? "",
                            "address".tr:
                            "${detail.deliveryInformations?.state ??
                                ""} - ${detail.deliveryInformations?.country ??
                                ""}",
                          },
                          isDark: isDark,
                          secondaryText: secondaryText,
                          primaryText: primaryText,
                          accentColor: accentColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                        ),
                      ),
                      horizontalSpace(12.w),
                      Expanded(
                        child: infoSectionCard(
                          title: "billing_info".tr,
                          icon: Icons.receipt_long_outlined,
                          data: {
                            "Name":
                            detail.billingInformations?.name ?? "",
                            "Email":
                            detail.billingInformations?.email ?? "",
                            "City":
                            detail.billingInformations?.state ?? "",
                            "Address":
                            detail.billingInformations?.address ?? "",
                          },
                          isDark: isDark,
                          secondaryText: secondaryText,
                          primaryText: primaryText,
                          accentColor: accentColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                        ),
                      ),
                    ],
                  ),

                  verticalSpace(14.h),

                  CustomerContactActions(
                    phone: detail.deliveryInformations?.phone,
                    email: detail.billingInformations?.email,
                    isDark: isDark,
                  ),

                  verticalSpace(26.h),

// ─────────────────────────────
// NOTES
// ─────────────────────────────
                  _buildNotesSection(
                    context,
                    detail,
                    isDark,
                    secondaryText,
                    primaryText,
                    accentColor,
                    borderColor,
                    cardBg,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

// ═══════════════════════════════════════════
// ORDER HEADER
// ═══════════════════════════════════════════

  Widget _buildOrderHeader({
    required OrderDetailData detail,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
  }) {
    final deliveryId = detail.deliveryId?.toString().trim();
    final isAssigned = deliveryId != null && deliveryId.isNotEmpty &&
        deliveryId != '0';
    const unassignedColor = Color(0xFFE65100);
    final assignedId = isAssigned ? int.tryParse(deliveryId) : null;
    final assignedName = deliveryBoyController.deliveryBoyList
        .firstWhereOrNull((d) => d.id == assignedId)
        ?.name;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: borderColor.withOpacity(.75),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─────────────────────────────
          // TOP
          // ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(.16),
                      accentColor.withOpacity(.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: accentColor,
                  size: 24.sp,
                ),
              ),

              horizontalSpace(12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "order_id".tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            detail.orderId ?? "-",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: primaryText,
                              height: 1.25,
                              letterSpacing: .1,
                            ),
                          ),
                        ),

                        SizedBox(width: 6.w),

                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: detail.orderId ?? "",
                                ),
                              );

                              commonToast(
                                'order_id_copied'.tr,
                                type: AppSnackBarType.info,
                              );
                            },
                            borderRadius:
                            BorderRadius.circular(9.r),
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color:
                                accentColor.withOpacity(.08),
                                borderRadius:
                                BorderRadius.circular(9.r),
                                border: Border.all(
                                  color:
                                  accentColor.withOpacity(.12),
                                ),
                              ),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 16.sp,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ─────────────────────────────
          // ORDER STATUS
          // ─────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(.045),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: accentColor.withOpacity(.09),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(.09),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 16.sp,
                    color: accentColor,
                  ),
                ),

                SizedBox(width: 9.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "delivery_status".tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: secondaryText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        detail.orderStatusText ?? "-",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                CommonStatusBadge(
                  type: StatusBadgeType.order,
                  orderStatus: detail.orderStatus,
                  customLabel: detail.orderStatusText,
                  showArrow: true,
                  onTap: () {
                    OrderStatusBottomSheet.show<OrderDetailData>(
                      context,
                      detail,
                      getOrderStatus: (model) =>
                      model.orderStatus ?? 0,
                      getProductOrderId: (model) =>
                      model.orderId ?? '',
                      getPaymentStatus: (model) =>
                      model.paymentStatus ?? 'Unpaid',
                      setOrderStatus: (model, newStatus) {
                        model.orderStatus = newStatus;
                      },
                      setOrderStatusText: (model, newStatusText) {
                        model.orderStatusText = newStatusText;
                      },
                      onUpdated: () {
                        setState(() {});
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(.045),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: accentColor.withOpacity(.09),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(.09),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 16.sp,
                    color: accentColor,
                  ),
                ),

                SizedBox(width: 9.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        "delivery_boy".tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: secondaryText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isAssigned ? (assignedName ?? '#$deliveryId') : "not_assigned".tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isAssigned ? primaryText : unassignedColor,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                    onTap: () async {
                      if (orderController.isAssigningDelivery.value) return;

                      final picked = await DeliveryBoyPickerBottomSheet.show(
                        context,
                        selectedId: assignedId,
                      );
                      if (picked?.id == null || picked!.id == assignedId) return;

                      final ok = await orderController.assignOrderToDelivery(
                        deliveryBoyId: picked.id.toString(),
                        orderId: detail.id.toString(),
                      );
                      if (ok) getData();
                    },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: (isAssigned ? accentColor : unassignedColor)
                          .withOpacity(.10),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: (isAssigned ? accentColor : unassignedColor)
                            .withOpacity(.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAssigned ? Icons.swap_horiz_rounded : Icons
                              .person_add_alt_1_rounded,
                          size: 14.sp,
                          color: isAssigned ? accentColor : unassignedColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isAssigned ? "change".tr : "assign".tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isAssigned ? accentColor : unassignedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // ─────────────────────────────
          // DIVIDER
          // ─────────────────────────────
          Container(
            height: 1.h,
            color: borderColor.withOpacity(.7),
          ),

          SizedBox(height: 14.h),

          // ─────────────────────────────
          // ORDER INFO
          // ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: _headerInfoItem(
                  icon: Icons.inventory_2_outlined,
                  label: "order_items".tr,
                  value: "${detail.product?.length ?? 0}",
                  color: accentColor,
                  secondaryText: secondaryText,
                  primaryText: primaryText,
                ),
              ),

              Container(
                width: 1.w,
                height: 34.h,
                margin: EdgeInsets.symmetric(horizontal: 14.w),
                color: borderColor.withOpacity(.8),
              ),

              Expanded(
                child: _headerInfoItem(
                  icon: Icons.payment_outlined,
                  label: "payment".tr,
                  value: detail.paymentStatus ?? "-",
                  color: accentColor,
                  secondaryText: secondaryText,
                  primaryText: primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color secondaryText,
    required Color primaryText,
  }) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: color.withOpacity(.07),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 17.sp,
            color: color,
          ),
        ),

        SizedBox(width: 9.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


// ═══════════════════════════════════════════
// INVOICE BUTTON
// ═══════════════════════════════════════════

  Widget _buildInvoiceButton({
    required BuildContext context,
    required OrderDetailData detail,
    required Color cardBg,
    required Color borderColor,
    required Color accentColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Get.to(
                () =>
                InvoicePdfViewScreen(
                  productList: detail.product!,
                  orderDetailData: detail,
                  tax: orderController.extTax.value.toString(),
                  deliveryCharge:
                  parsePriceSafe(detail.deliveredCharge),
                  couponAmount:
                  parsePriceSafe(
                    detail.couponInfo?.discountAmount,
                  ),
                ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 15.h,
          ),
          decoration: BoxDecoration(
            color: AppColor.themeNavyBlueColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.themeNavyBlueColor.withOpacity(.20),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 7),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 21.sp,
                ),
              ),
              horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "view_invoice".tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "invoice".tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(.75),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Get.locale?.languageCode == 'ar'
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ═══════════════════════════════════════════
// PRODUCTS
// ═══════════════════════════════════════════

  Widget _buildProductsCard({
    required OrderDetailData detail,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              14.h,
              16.w,
              10.h,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "product".tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "qty".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "price".tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1.h,
            color: borderColor,
          ),

          ListView.separated(
            itemCount: detail.product?.length ?? 0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final product = detail.product![index];

              final total =
                  parsePriceSafe(product.qty) *
                      parsePriceSafe(product.finalPrice);

              return _productRow(
                index: index + 1,
                name: product.name ?? "-",
                quantity: product.qty?.toString() ?? "0",
                price:
                '${product.finalPrice ?? "0"} ${orderController.currencySymbol
                    .value}',
                total:
                '${total.toStringAsFixed(2)} ${orderController.currencySymbol
                    .value}',
                secondaryText: secondaryText,
                primaryText: primaryText,
                accentColor: accentColor,
              );
            },
            separatorBuilder: (_, __) =>
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Divider(
                    height: 1.h,
                    color: borderColor,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _productRow({
    required int index,
    required String name,
    required String quantity,
    required String price,
    required String total,
    required Color secondaryText,
    required Color primaryText,
    required Color accentColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 13.h,
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              "$index",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),

          horizontalSpace(9.w),

          Expanded(
            flex: 3,
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Text(
              quantity,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: secondaryText,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  total,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ═══════════════════════════════════════════
// PAYMENT SUMMARY
// ═══════════════════════════════════════════

  Widget _buildPaymentSummary({
    required OrderDetailData detail,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColor.themeNavyBlueColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.themeNavyBlueColor.withOpacity(.15),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.10),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              horizontalSpace(10.w),
              Expanded(
                child: Text(
                  "payment_summary".tr,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              CommonStatusBadge(
                type: StatusBadgeType.payment,
                paymentStatus: detail.paymentStatus,
                showArrow: true,
                onTap: () {
                  showPaymentStatusBottomSheet<OrderDetailData>(
                    context,
                    detail,
                    getPaymentStatus: (model) =>
                    model.paymentStatus ?? 'Unpaid',
                    getProductOrderId: (model) =>
                    model.orderId ?? '',
                    getDeliveredStatus: (model) =>
                    model.orderStatus ?? 0,
                    setPaymentStatus: (model, newStatus) {
                      model.paymentStatus = newStatus;
                    },
                    onUpdated: () {
                      setState(() {});
                    },
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 18.h),

          _summaryRow(
            "sub_total".tr,
            '${detail.subTotal ?? "0"} ${orderController.currencySymbol.value}',
          ),
          _summaryRow(
            "shipping".tr,
            '${detail.deliveredCharge ?? "0"} ${orderController.currencySymbol
                .value}',
          ),
          _summaryRow(
            "tax".tr,
            '${detail.taxPrice ?? "0"} ${orderController.currencySymbol.value}',
          ),
          _summaryRow(
            "coupon".tr,
            '- ${detail.couponInfo?.discountAmount ?? "0"} ${orderController
                .currencySymbol.value}',
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(
              color: Colors.white.withOpacity(.15),
              height: 1.h,
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "grand_total".tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${detail.finalPrice ?? "0"} ${orderController
                          .currencySymbol.value}',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.09),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "${"paid_by".tr} ${detail.paymnetType ?? "-"}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label,
      String value,) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

// ═══════════════════════════════════════════
// SECTION TITLE
// ═══════════════════════════════════════════

  Widget _sectionTitle({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color.withOpacity(.09),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 17.sp,
            color: color,
          ),
        ),
        horizontalSpace(9.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

// ═══════════════════════════════════════════
// INFO CARD
// ═══════════════════════════════════════════

  Widget infoSectionCard({
    required String title,
    required IconData icon,
    required Map<String, String> data,
    required bool isDark,
    required Color secondaryText,
    required Color primaryText,
    required Color accentColor,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(.09),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: accentColor,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
          ),

          SizedBox(height: 13.h),

          ...data.entries.map(
                (e) =>
                Padding(
                  padding: EdgeInsets.only(bottom: 9.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: secondaryText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        e.value.isEmpty ? "-" : e.value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

// ═══════════════════════════════════════════
// NOTES
// ═══════════════════════════════════════════

  Widget _buildNotesSection(BuildContext context,
      OrderDetailData detail,
      bool isDark,
      Color secondaryText,
      Color primaryText,
      Color accentColor,
      Color borderColor,
      Color cardBg,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionTitle(
                title: "order_notes".tr,
                icon: Icons.notes_rounded,
                color: accentColor,
              ),
            ),
            GestureDetector(
              onTap: () =>
                  _showAddNoteBottomSheet(context, detail),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 11.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 15.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'add_note'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        verticalSpace(12.h),

        if (detail.notes == null || detail.notes!.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 28.h),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.note_alt_outlined,
                    size: 25.sp,
                    color: accentColor.withOpacity(.65),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'no_notes_yet'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: detail.notes!.length,
            separatorBuilder: (_, __) =>
                verticalSpace(10.h),
            itemBuilder: (context, index) {
              final note = detail.notes![index];

              return _NoteCard(
                note: note,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                accentColor: accentColor,
                onDelete: () =>
                    AppDialog.showCustomDialog(
                      context: context,
                      title: 'delete'.tr,
                      message: 'deleteCategory'.tr,
                      lottieAsset:
                      'assets/lottie/delete_icon.json',
                      confirmColor: AppColor.cRedText,
                      onConfirm: () async {
                        Get.back();

                        final success =
                        await orderController.deleteOrderNote(
                          orderId: detail.id!,
                          noteId: note.id!,
                        );

                        if (success) {
                          getData();
                        }
                      },
                    ),
              );
            },
          ),
      ],
    );
  }

// ═══════════════════════════════════════════
// ADD NOTE
// ═══════════════════════════════════════════

  void _showAddNoteBottomSheet(BuildContext context,
      OrderDetailData detail,) {
    final isDark =
        Theme
            .of(context)
            .brightness == Brightness.dark;

    final noteController = TextEditingController();
    String selectedType = 'private_note';

    final noteTypes = [
      {
        'value': 'private_note',
        'label': 'private_note'.tr,
        'icon': Icons.lock_outline_rounded,
      },
      {
        'value': 'to_customer',
        'label': 'public_note'.tr,
        'icon': Icons.public_rounded,
      },
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight:
              MediaQuery
                  .of(context)
                  .size
                  .height * .7,
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
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'add_new_note'.tr,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColor.cText,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? DarkThemeColor
                                      .cCardBackground
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 17.sp,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        verticalSpace(22.h),

                        Text(
                          'note_type'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppColor.cText,
                          ),
                        ),

                        verticalSpace(10.h),

                        Row(
                          children: noteTypes.map((type) {
                            final isSelected =
                                selectedType ==
                                    type['value'];

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(
                                        () =>
                                    selectedType =
                                    type['value'] as String,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 180,
                                  ),
                                  margin: EdgeInsets.only(
                                    right: 8.w,
                                  ),
                                  padding:
                                  EdgeInsets.symmetric(
                                    vertical: 13.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColor
                                        .themeNavyBlueColor
                                        .withOpacity(
                                        isDark
                                            ? .18
                                            : .07)
                                        : isDark
                                        ? DarkThemeColor
                                        .cCardBackground
                                        : Colors.grey
                                        .shade50,
                                    borderRadius:
                                    BorderRadius.circular(
                                        14.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColor
                                          .themeNavyBlueColor
                                          : isDark
                                          ? DarkThemeColor
                                          .cBorder
                                          : Colors.grey
                                          .shade200,
                                      width:
                                      isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        type['icon']
                                        as IconData,
                                        size: 23.sp,
                                        color: isSelected
                                            ? AppColor
                                            .themeNavyBlueColor
                                            : Colors.grey,
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        type['label'] as String,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppColor
                                              .themeNavyBlueColor
                                              : isDark
                                              ? Colors.white70
                                              : AppColor
                                              .cFont,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        verticalSpace(20.h),

                        Text(
                          'note_content'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppColor.cText,
                          ),
                        ),

                        verticalSpace(10.h),

                        TextField(
                          controller: noteController,
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? Colors.white
                                : AppColor.cText,
                          ),
                          decoration: InputDecoration(
                            hintText:
                            'write_note_here'.tr,
                            hintStyle: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : AppColor.cFont
                                  .withOpacity(.5),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? DarkThemeColor
                                .cCardBackground
                                : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(14.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                            EdgeInsets.all(16.w),
                          ),
                        ),

                        verticalSpace(24.h),

                        Obx(
                              () =>
                              AppButton(
                                text: 'add_note'.tr,
                                isLoading: orderController
                                    .isCreatingOrderNote.value,
                                onPressed: orderController
                                    .isCreatingOrderNote.value
                                    ? null
                                    : () async {
                                  if (noteController.text
                                      .trim()
                                      .isEmpty) {
                                    commonToast(
                                      type:
                                      AppSnackBarType.info,
                                      'note_cannot_be_empty'
                                          .tr,
                                    );
                                    return;
                                  }

                                  Get.back();

                                  final success =
                                  await orderController
                                      .createOrderNote(
                                    orderId: detail.id!,
                                    noteType: selectedType,
                                    note: noteController.text
                                        .trim(),
                                  );

                                  if (success) {
                                    getData();
                                  }
                                },
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height:
                  MediaQuery
                      .of(context)
                      .padding
                      .bottom,
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ═══════════════════════════════════════════════
// NOTE CARD
// ═══════════════════════════════════════════════

class _NoteCard extends StatelessWidget {
  final Note note;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;
  final Color accentColor;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.primaryText,
    required this.secondaryText,
    required this.accentColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSystemNote =
        note.noteType == null || note.status != null;

    final bool isPrivate =
        note.noteType == 'private_note';

    final noteColor = isSystemNote
        ? const Color(0xFF1565C0)
        : isPrivate
        ? const Color(0xFFE65100)
        : const Color(0xFF2E7D32);

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: noteColor.withOpacity(.09),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  isSystemNote
                      ? Icons.info_outline_rounded
                      : isPrivate
                      ? Icons.lock_outline_rounded
                      : Icons.public_rounded,
                  size: 112.sp,
                  color: noteColor,
                ),
              ),

              horizontalSpace(10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSystemNote
                          ? (note.status ??
                          'system_note'.tr)
                          : isPrivate
                          ? 'private_note'.tr
                          : 'public_note'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      dateFormatted(
                        date: note.createdAt ?? '',
                        formatType: formatForDateTime(
                          FormatType.dateTime,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isSystemNote)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFFFFEBEE),
                      borderRadius:
                      BorderRadius.circular(9.r),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 17.sp,
                      color:
                      const Color(0xFFC62828),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark
                  ? DarkThemeColor.cBackGround
                  : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Text(
              note.note ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: primaryText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

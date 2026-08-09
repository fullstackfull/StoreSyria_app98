// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/view/screen/order_screen/invoice_pdf_view.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../widget/error_empty_state.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderController orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    orderController.extTax.value = 0.0;
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
  }

  void getData() => orderController.getOrderDetailData(widget.orderId);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround;
    final cardBg = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5);
    final primaryText = isDark ? Colors.white : AppColor.cText;
    final secondaryText = isDark ? Colors.grey.shade400 : AppColor.cFont;
    final dividerColor = isDark ? DarkThemeColor.cBorder : AppColor.cDivider;
    final accentColor = AppColor.cGreenFont;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: simpleAppBar(title: "order_details".tr),
      body: SafeArea(
        child: Obx(() {
          if (orderController.isDataAvailable.value) {
            return const Center(child: LoadingWidget());
          }

          if (orderController.errorMessage.isNotEmpty && orderController.orderDetail == null) {
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("order_id_label".tr, style: TextStyle(fontSize: 12.sp, color: secondaryText)),
                          verticalSpace(4.h),
                          Text(
                            orderController.orderDetail!.orderId!,
                            style: TextStyle(fontSize: 18.sp, color: accentColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      statusButton(orderController.orderDetail!.orderStatusText),
                    ],
                  ),
                ),

                verticalSpace(20.h),

                // Action Button
                CommonIconButton(
                  iconData: DefaultImages.categoriesIcn,
                  title: 'view_invoice'.tr,
                  height: 45.h,
                  textColor: accentColor,
                  btnColor: cardBg,
                  bColor: borderColor,
                  onPressed: () {
                    Get.to(() => InvoicePdfViewScreen(
                      productList: orderController.orderDetail!.product!,
                      orderDetailData: orderController.orderDetail!,
                      tax: orderController.extTax.value.toString(),
                      deliveryCharge: double.parse(orderController.orderDetail!.deliveredCharge.toString()),
                      couponAmount: double.parse(
                        orderController.orderDetail!.couponInfo?.discountAmount.toString() ?? '0.0',
                      ),
                    ));
                  },
                ),

                verticalSpace(25.h),

                // Order Items Table
                Text("order_items".tr, style: TextStyle(fontSize: 18.sp, color: accentColor, fontWeight: FontWeight.bold)),
                verticalSpace(15.h),
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: Row(
                          children: [
                            SizedBox(width: 30.w, child: Text('#', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText))),
                            Expanded(flex: 3, child: Text('product'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText))),
                            Expanded(flex: 1, child: Text('qty'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.center)),
                            Expanded(flex: 2, child: Text('price'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.right)),
                            Expanded(flex: 2, child: Text('total'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      Divider(height: 1.h, color: dividerColor),
                      ListView.separated(
                        itemCount: orderController.orderDetail!.product!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final product = orderController.orderDetail!.product![index];
                          final total = double.parse(product.qty!.toString()) * double.parse(product.finalPrice!.toString());
                          return orderItemWidget(
                            index: index + 1,
                            name: product.name!,
                            quantity: product.qty.toString(),
                            price: product.finalPrice!,
                            totals: total.toStringAsFixed(2),
                            secondaryText: secondaryText,
                            primaryText: primaryText,
                            accentColor: accentColor,
                          );
                        },
                        separatorBuilder: (_, __) => Divider(height: 1.h, color: dividerColor, indent: 16.w, endIndent: 16.w),
                      ),
                    ],
                  ),
                ),

                verticalSpace(25.h),

                // Payment Summary
                Text("payment_summary".tr, style: TextStyle(fontSize: 18.sp, color: accentColor, fontWeight: FontWeight.bold)),
                verticalSpace(15.h),
                grandTotalsWidget(
                  grandTotal: orderController.orderDetail!.finalPrice!,
                  extTax: orderController.extTax.value.toString(),
                  applyCoupon: orderController.orderDetail!.couponInfo?.discountAmount ?? "0",
                  shippingPrice: orderController.orderDetail!.deliveredCharge!,
                  subTotal: orderController.orderDetail!.subTotal!,
                  paymentType: orderController.orderDetail!.paymnetType!,
                  accentColor: accentColor,
                ),

                verticalSpace(25.h),

                // Shipping & Billing Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: infoSectionCard(
                        title: "shipping_info".tr,
                        icon: Icons.local_shipping_outlined,
                        data: {
                          "Name": orderController.orderDetail!.deliveryInformations!.name!,
                          "Phone": orderController.orderDetail!.deliveryInformations!.phone!,
                          "City": orderController.orderDetail!.deliveryInformations!.city!,
                          "Address": "${orderController.orderDetail!.deliveryInformations!.state!} - ${orderController.orderDetail!.deliveryInformations!.country!}",
                        },
                        isDark: isDark,
                        secondaryText: secondaryText,
                        primaryText: primaryText,
                        accentColor: accentColor,
                      ),
                    ),
                    horizontalSpace(15.w),
                    Expanded(
                      child: infoSectionCard(
                        title: "billing_info".tr,
                        icon: Icons.receipt_long_outlined,
                        data: {
                          "Name": orderController.orderDetail!.billingInformations!.name!,
                          "Email": orderController.orderDetail!.billingInformations!.email!,
                          "City": orderController.orderDetail!.billingInformations!.city!,
                          "Zip": orderController.orderDetail!.billingInformations!.postCode!,
                        },
                        isDark: isDark,
                        secondaryText: secondaryText,
                        primaryText: primaryText,
                        accentColor: accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget infoSectionCard({
    required String title,
    required IconData icon,
    required Map<String, String> data,
    required bool isDark,
    required Color secondaryText,
    required Color primaryText,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
        children: [
        Icon(
        icon,
        size: 18.sp,
        color: accentColor,
      ),

      horizontalSpace(8.w),

      Expanded(
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
      ),
      ],
    ),
          verticalSpace(15.h),
          ...data.entries.map((e) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.key, style: TextStyle(fontSize: 10.sp, color: secondaryText)),
                verticalSpace(2.h),
                Text(e.value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: primaryText)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget orderItemWidget({
    required int index,
    required String name,
    required String quantity,
    required String price,
    required String totals,
    required Color secondaryText,
    required Color primaryText,
    required Color accentColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          SizedBox(width: 30.w, child: Text(index.toString(), style: TextStyle(fontSize: 12.sp, color: secondaryText))),
          Expanded(flex: 3, child: Text(name, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: primaryText), maxLines: 2, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 1, child: Text(quantity, style: TextStyle(fontSize: 12.sp, color: secondaryText), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('\$$price', style: TextStyle(fontSize: 12.sp, color: secondaryText), textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('\$$totals', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: accentColor), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget grandTotalsWidget({
    required String grandTotal,
    required String extTax,
    required String applyCoupon,
    required String shippingPrice,
    required String subTotal,
    required String paymentType,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.themeNavyBlueColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _totalRow("sub_total".tr, "\$ $subTotal"),
          _totalRow("shipping".tr, "\$ $shippingPrice"),
          _totalRow("tax".tr, "\$ $extTax"),
          _totalRow("coupon".tr, "- \$ $applyCoupon", color: accentColor),
          Divider(color: Colors.white.withOpacity(0.2), height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("grand_total".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              Text("\$ $grandTotal", style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          verticalSpace(15.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text("${"paid_via".tr} $paymentType", style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
          Text(value, style: TextStyle(fontSize: 14.sp, color: color ?? Colors.white)),
        ],
      ),
    );
  }
}
// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/screen/order_screen/invoice_pdf_view.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../core/model/order_detail_model.dart';
import '../../widget/common_snak_bar_widget.dart';
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
      body: Obx(() {
        if (orderController.isDetailLoading.value) {
          return const Center(child: LoadingWidget());
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("order_id_label".tr,
                                  style: TextStyle(fontSize: 12.sp, color: secondaryText)),
                              verticalSpace(4.h),
                              Text(
                                detail.orderId!,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: accentColor,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        horizontalSpace(8.w),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _StatusBadge(
                              status: detail.orderStatus ?? 0,
                              statusText: detail.orderStatusText ?? 'Pending',
                              onTap: () => _showStatusBottomSheet(context, detail),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    productList: detail.product!,
                    orderDetailData: detail,
                    tax: orderController.extTax.value.toString(),
                    deliveryCharge: double.parse(detail.deliveredCharge.toString()),
                    couponAmount: double.parse(
                      detail.couponInfo?.discountAmount.toString() ?? '0.0',
                    ),
                  ));
                },
              ),

              verticalSpace(25.h),

              // Order Items Table
              Text("order_items".tr,
                  style: TextStyle(fontSize: 18.sp, color: accentColor, fontWeight: FontWeight.bold)),
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
                          SizedBox(width: 30.w,
                              child: Text('#', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText))),
                          Expanded(flex: 3,
                              child: Text('product'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText))),
                          Expanded(flex: 1,
                              child: Text('qty'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.center)),
                          Expanded(flex: 2,
                              child: Text('price'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.right)),
                          Expanded(flex: 2,
                              child: Text('total'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    Divider(height: 1.h, color: dividerColor),
                    ListView.separated(
                      itemCount: detail.product!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final product = detail.product![index];
                        final total = double.parse(product.qty!.toString()) *
                            double.parse(product.finalPrice!.toString());
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
                      separatorBuilder: (_, __) => Divider(
                          height: 1.h,
                          color: dividerColor,
                          indent: 16.w,
                          endIndent: 16.w),
                    ),
                  ],
                ),
              ),

              verticalSpace(25.h),

              // Payment Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("payment_summary".tr,
                      style: TextStyle(fontSize: 18.sp, color: accentColor, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _PaymentStatusBadge(
                        isPaid: (detail.paymentStatus ?? 'Unpaid').toLowerCase() == 'paid',
                        onTap: () => _showPaymentStatusBottomSheet(context, detail),
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpace(15.h),
              grandTotalsWidget(
                grandTotal: detail.finalPrice!,
                extTax: orderController.extTax.value.toString(),
                applyCoupon: detail.couponInfo?.discountAmount ?? "0",
                shippingPrice: detail.deliveredCharge!,
                subTotal: detail.subTotal!,
                paymentType: detail.paymnetType!,
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
                        "Name": detail.deliveryInformations!.name!,
                        "Phone": detail.deliveryInformations!.phone!,
                        "City": detail.deliveryInformations!.city!,
                        "Address": "${detail.deliveryInformations!.state!} - ${detail.deliveryInformations!.country!}",
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
                        "Name": detail.billingInformations!.name!,
                        "Email": detail.billingInformations!.email!,
                        "City": detail.billingInformations!.city!,
                        "Zip": detail.billingInformations!.postCode!,
                      },
                      isDark: isDark,
                      secondaryText: secondaryText,
                      primaryText: primaryText,
                      accentColor: accentColor,
                    ),
                  ),
                ],
              ),
              verticalSpace(25.h),

              // Notes Section
              _buildNotesSection(context, detail, isDark, secondaryText, primaryText, accentColor, borderColor, cardBg),
            ],
          ),
        );
      }),
    );
  }

  // ⭐⭐⭐ Bottom Sheet لاختيار الحالة ⭐⭐⭐
  void _showStatusBottomSheet(BuildContext context, OrderDetailData detail) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int tempStatus = detail.orderStatus ?? 0;
    final noteController = TextEditingController();

    final statuses = [
      _StatusItem(0, 'Pending', 'الطلب قيد الانتظار', Icons.hourglass_empty, const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      _StatusItem(1, 'Delivered', 'تم التوصيل بنجاح', Icons.check_circle_outline, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      _StatusItem(2, 'Cancel', 'تم إلغاء الطلب', Icons.cancel_outlined, const Color(0xFFFFEBEE), const Color(0xFFC62828)),
      _StatusItem(3, 'Return', 'طلب إرجاع', Icons.undo, const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
      _StatusItem(4, 'Confirmed', 'تم تأكيد الطلب', Icons.verified, const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      _StatusItem(5, 'Picked Up', 'تم الاستلام من المتجر', Icons.inventory_2_outlined, const Color(0xFFE0F7FA), const Color(0xFF00838F)),
      _StatusItem(6, 'Shipped', 'تم الشحن', Icons.local_shipping_outlined, const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85, // ⭐ تحديد أقصى ارتفاع
            ),
            decoration: BoxDecoration(
              color: isDark ? DarkThemeColor.cBackGround : Colors.white,
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
                    color: isDark ? DarkThemeColor.cBorder : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Header (ثابت)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'update_order_status'.tr,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColor.cText,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: isDark ? DarkThemeColor.cCardBackground : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 18.sp, color: isDark ? Colors.white70 : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),

                verticalSpace(16.h),

                // ⭐⭐⭐ المحتوى القابل للتمرير ⭐⭐⭐
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // قائمة الحالات
                        ...statuses.map((s) => GestureDetector(
                          onTap: () => setState(() => tempStatus = s.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: tempStatus == s.id
                                  ? s.bgColor.withOpacity(isDark ? 0.15 : 1)
                                  : (isDark ? DarkThemeColor.cCardBackground : Colors.grey.shade50),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: tempStatus == s.id ? s.textColor : (isDark ? DarkThemeColor.cBorder : Colors.grey.shade200),
                                width: tempStatus == s.id ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: BoxDecoration(
                                    color: s.bgColor.withOpacity(isDark ? 0.3 : 1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(s.icon, color: s.textColor, size: 22.sp),
                                ),
                                horizontalSpace(14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : AppColor.cText,
                                        ),
                                      ),
                                      verticalSpace(2.h),
                                      Text(
                                        s.desc,
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
                                  opacity: tempStatus == s.id ? 1 : 0,
                                  child: Container(
                                    width: 26.w,
                                    height: 26.w,
                                    decoration: BoxDecoration(
                                      color: s.textColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),

                        verticalSpace(16.h),

                        // حقل الملاحظة
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark ? DarkThemeColor.cCardBackground : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: isDark ? DarkThemeColor.cBorder : Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'status_note'.tr,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColor.cText,
                                ),
                              ),
                              verticalSpace(8.h),
                              TextField(
                                controller: noteController,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark ? Colors.white : AppColor.cText,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'add_status_note'.tr,
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark ? Colors.grey.shade500 : AppColor.cFont.withOpacity(0.6),
                                  ),
                                  filled: true,
                                  fillColor: isDark ? DarkThemeColor.cBackGround : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(12.w),
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

                // ⭐ زر التأكيد (ثابت في الأسفل)
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: isDark ? DarkThemeColor.cBackGround : Colors.white,
                  ),
                  child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: orderController.isUpdatingStatus.value
                          ? null
                          : () async {
                        Get.back();
                        final success = await orderController.updateOrderStatus(
                          productOrderId: detail.orderId!,
                          deliveredStatus: tempStatus,
                          paymentStatus: detail.paymentStatus ?? 'Unpaid',  // ✅ صحيح
                          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                        );
                        if (success) {
                          getData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.themeNavyBlueColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: orderController.isUpdatingStatus.value
                          ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'confirm_update'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
    );
  }

  // ⭐⭐⭐ شارة الحالة القابلة للنقر ⭐⭐⭐
  Widget _StatusBadge({
    required int status,
    required String statusText,
    required VoidCallback onTap,
  }) {
    final config = _getStatusConfig(status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: config.bgColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: config.borderColor),
        ),
        child: Wrap(  // ⭐ Wrap بدلاً من Row
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4.w,
          children: [
            Icon(config.icon, size: 14.sp, color: config.textColor),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: config.textColor,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14.sp,
              color: config.textColor.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ إعدادات كل حالة
  _StatusConfig _getStatusConfig(int status) {
    switch (status) {
      case 0:
        return _StatusConfig(
          bgColor: const Color(0xFFFFF3E0),
          textColor: const Color(0xFFE65100),
          borderColor: const Color(0xFFFFE0B2),
          icon: Icons.hourglass_empty,
        );
      case 1:
        return _StatusConfig(
          bgColor: const Color(0xFFE8F5E9),
          textColor: const Color(0xFF2E7D32),
          borderColor: const Color(0xFFC8E6C9),
          icon: Icons.check_circle_outline,
        );
      case 2:
        return _StatusConfig(
          bgColor: const Color(0xFFFFEBEE),
          textColor: const Color(0xFFC62828),
          borderColor: const Color(0xFFFFCDD2),
          icon: Icons.cancel_outlined,
        );
      case 3:
        return _StatusConfig(
          bgColor: const Color(0xFFF3E5F5),
          textColor: const Color(0xFF7B1FA2),
          borderColor: const Color(0xFFE1BEE7),
          icon: Icons.undo,
        );
      case 4:
        return _StatusConfig(
          bgColor: const Color(0xFFE3F2FD),
          textColor: const Color(0xFF1565C0),
          borderColor: const Color(0xFFBBDEFB),
          icon: Icons.verified,
        );
      case 5:
        return _StatusConfig(
          bgColor: const Color(0xFFE0F7FA),
          textColor: const Color(0xFF00838F),
          borderColor: const Color(0xFFB2EBF2),
          icon: Icons.inventory_2_outlined,
        );
      case 6:
        return _StatusConfig(
          bgColor: const Color(0xFFFFF8E1),
          textColor: const Color(0xFFF57F17),
          borderColor: const Color(0xFFFFECB3),
          icon: Icons.local_shipping_outlined,
        );
      default:
        return _StatusConfig(
          bgColor: Colors.grey.shade100,
          textColor: Colors.grey.shade700,
          borderColor: Colors.grey.shade300,
          icon: Icons.help_outline,
        );
    }
  }

  // ... باقي الدوال المساعدة (infoSectionCard, orderItemWidget, grandTotalsWidget, _totalRow) تبقى كما هي
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
              Icon(icon, size: 18.sp, color: accentColor),
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

  // ⭐⭐⭐ قسم الملاحظات ⭐⭐⭐
  Widget _buildNotesSection(
      BuildContext context,
      OrderDetailData detail,
      bool isDark,
      Color secondaryText,
      Color primaryText,
      Color accentColor,
      Color borderColor,
      Color cardBg,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header مع زر الإضافة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "order_notes".tr,
              style: TextStyle(
                fontSize: 18.sp,
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddNoteBottomSheet(context, detail),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16.sp, color: Colors.white),
                    horizontalSpace(4.w),
                    Text(
                      'add_note'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        verticalSpace(15.h),

        // قائمة الملاحظات
        if (detail.notes == null || detail.notes!.isEmpty)
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.note_alt_outlined, size: 40.sp, color: secondaryText.withOpacity(0.5)),
                  verticalSpace(8.h),
                  Text(
                    'no_notes_yet'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: detail.notes!.length,
            separatorBuilder: (_, __) => verticalSpace(10.h),
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
                onDelete: () => _showDeleteNoteConfirm(context, detail, note),
              );
            },
          ),
      ],
    );
  }

  // ⭐⭐⭐ شارة حالة الدفع القابلة للنقر ⭐⭐⭐
  Widget _PaymentStatusBadge({
    required bool isPaid,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isPaid ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2),
          ),
          boxShadow: [
            BoxShadow(
              color: (isPaid ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة متحركة
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.cancel,
                key: ValueKey<bool>(isPaid),
                size: 18.sp,
                color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
            ),
            horizontalSpace(6.w),
            Text(
              isPaid ? 'paid'.tr : 'unpaid'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
            ),
            horizontalSpace(4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: (isPaid ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐⭐⭐ Bottom Sheet لإضافة ملاحظة ⭐⭐⭐
  void _showAddNoteBottomSheet(BuildContext context, OrderDetailData detail) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteController = TextEditingController();
    String selectedType = 'private_note';

    final noteTypes = [
      {'value': 'private_note', 'label': 'private_note'.tr, 'icon': Icons.lock_outline},
      {'value': 'public_note', 'label': 'public_note'.tr, 'icon': Icons.public},
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: isDark ? DarkThemeColor.cBackGround : Colors.white,
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
                    color: isDark ? DarkThemeColor.cBorder : Colors.grey.shade300,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'add_new_note'.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColor.cText,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: isDark ? DarkThemeColor.cCardBackground : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, size: 18.sp, color: isDark ? Colors.white70 : Colors.grey),
                            ),
                          ),
                        ],
                      ),

                      verticalSpace(20.h),

                      // نوع الملاحظة
                      Text(
                        'note_type'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColor.cText,
                        ),
                      ),
                      verticalSpace(10.h),

                      Row(
                        children: noteTypes.map((type) {
                          final isSelected = selectedType == type['value'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedType = type['value'] as String),
                              child: Container(
                                margin: EdgeInsets.only(right: 8.w),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColor.themeNavyBlueColor.withOpacity(isDark ? 0.2 : 0.1)
                                      : (isDark ? DarkThemeColor.cCardBackground : Colors.grey.shade50),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected ? AppColor.themeNavyBlueColor : (isDark ? DarkThemeColor.cBorder : Colors.grey.shade200),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      type['icon'] as IconData,
                                      size: 24.sp,
                                      color: isSelected ? AppColor.themeNavyBlueColor : Colors.grey,
                                    ),
                                    verticalSpace(6.h),
                                    Text(
                                      type['label'] as String,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: isSelected ? AppColor.themeNavyBlueColor : (isDark ? Colors.white70 : AppColor.cFont),
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

                      // حقل الملاحظة
                      Text(
                        'note_content'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColor.cText,
                        ),
                      ),
                      verticalSpace(10.h),

                      TextField(
                        controller: noteController,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : AppColor.cText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'write_note_here'.tr,
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: isDark ? Colors.grey.shade500 : AppColor.cFont.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: isDark ? DarkThemeColor.cCardBackground : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(16.w),
                        ),
                      ),

                      verticalSpace(24.h),

                      // زر الإضافة
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: orderController.isUpdatingStatus.value
                              ? null
                              : () async {
                            if (noteController.text.trim().isEmpty) {
                              commonToast('note_cannot_be_empty'.tr);
                              return;
                            }
                            Get.back();
                            final success = await orderController.createOrderNote(
                              orderId: detail.id!,
                              noteType: selectedType,
                              note: noteController.text.trim(),
                            );
                            if (success) {
                              getData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.themeNavyBlueColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: orderController.isUpdatingStatus.value
                              ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            'add_note'.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ⭐⭐⭐ تأكيد حذف الملاحظة ⭐⭐⭐
  void _showDeleteNoteConfirm(BuildContext context, OrderDetailData detail, Note note) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? DarkThemeColor.cBackGround : Colors.white,
        title: Text(
          'delete_note'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColor.cText,
          ),
        ),
        content: Text(
          'delete_note_confirm'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : AppColor.cFont,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.cFont,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await orderController.deleteOrderNote(
                orderId: detail.id!,
                noteId: note.id!,
              );
              if (success) {
                getData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(
              'delete'.tr,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐⭐⭐ Bottom Sheet لتغيير حالة الدفع ⭐⭐⭐
  void _showPaymentStatusBottomSheet(BuildContext context, OrderDetailData detail) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIsPaid = (detail.paymentStatus ?? 'Unpaid').toLowerCase() == 'paid';
    bool tempIsPaid = currentIsPaid;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              color: isDark ? DarkThemeColor.cBackGround : Colors.white,
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
                    color: isDark ? DarkThemeColor.cBorder : Colors.grey.shade300,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'update_payment_status'.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColor.cText,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: isDark ? DarkThemeColor.cCardBackground : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, size: 18.sp, color: isDark ? Colors.white70 : Colors.grey),
                            ),
                          ),
                        ],
                      ),

                      verticalSpace(24.h),

                      // خيار Paid
                      _PaymentOptionCard(
                        title: 'paid'.tr,
                        subtitle: 'payment_paid_desc'.tr,
                        icon: Icons.check_circle,
                        bgColor: const Color(0xFFE8F5E9),
                        textColor: const Color(0xFF2E7D32),
                        isSelected: tempIsPaid,
                        isDark: isDark,
                        onTap: () => setState(() => tempIsPaid = true),
                      ),

                      verticalSpace(12.h),

                      // خيار Unpaid
                      _PaymentOptionCard(
                        title: 'unpaid'.tr,
                        subtitle: 'payment_unpaid_desc'.tr,
                        icon: Icons.cancel,
                        bgColor: const Color(0xFFFFEBEE),
                        textColor: const Color(0xFFC62828),
                        isSelected: !tempIsPaid,
                        isDark: isDark,
                        onTap: () => setState(() => tempIsPaid = false),
                      ),

                      verticalSpace(24.h),

                      // زر التأكيد
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: orderController.isUpdatingStatus.value
                              ? null
                              : () async {
                            // ⭐ لا نغير شيء إذا لم يتغير الاختيار
                            if (tempIsPaid == currentIsPaid) {
                              Get.back();
                              return;
                            }
                            Get.back();
                            final success = await orderController.updateOrderStatus(
                              productOrderId: detail.orderId!.replaceAll('#', ''),
                              deliveredStatus: detail.orderStatus ?? 0, // ⭐ ثابت
                              paymentStatus: tempIsPaid ? 'Paid' : 'Unpaid', // ⭐ المتغير
                              note: null, // ⭐ لا حاجة للملاحظة هنا
                            );
                            if (success) {
                              getData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.themeNavyBlueColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: orderController.isUpdatingStatus.value
                              ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            'confirm_update'.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
    );
  }
}

// ⭐⭐⭐ Classes مساعدة ⭐⭐⭐
class _StatusItem {
  final int id;
  final String name;
  final String desc;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  _StatusItem(this.id, this.name, this.desc, this.icon, this.bgColor, this.textColor);
}

class _StatusConfig {
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final IconData icon;

  _StatusConfig({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
  });
}

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
    final bool isSystemNote = note.noteType == null || note.status != null;
    final bool isPrivate = note.noteType == 'private_note';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey.shade200).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: نوع الملاحظة + التاريخ + زر الحذف
          Row(
            children: [
              // أيقونة نوع الملاحظة
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSystemNote
                      ? const Color(0xFFE3F2FD)
                      : isPrivate
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isSystemNote
                      ? Icons.info_outline
                      : isPrivate
                      ? Icons.lock_outline
                      : Icons.public,
                  size: 18.sp,
                  color: isSystemNote
                      ? const Color(0xFF1565C0)
                      : isPrivate
                      ? const Color(0xFFE65100)
                      : const Color(0xFF2E7D32),
                ),
              ),
              horizontalSpace(10.w),

              // نوع الملاحظة + التاريخ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSystemNote
                          ? (note.status ?? 'system_note'.tr)
                          : isPrivate
                          ? 'private_note'.tr
                          : 'public_note'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    verticalSpace(2.h),
                    Text(
                      _formatDate(note.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // زر الحذف (فقط للملاحظات غير النظامية)
              if (!isSystemNote)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18.sp,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ),
            ],
          ),

          verticalSpace(12.h),

          // محتوى الملاحظة
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? DarkThemeColor.cBackGround : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              note.note ?? '',
              style: TextStyle(
                fontSize: 13.sp,
                color: primaryText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
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
              ? bgColor.withOpacity(isDark ? 0.15 : 1)
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
                color: bgColor.withOpacity(isDark ? 0.3 : 1),
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
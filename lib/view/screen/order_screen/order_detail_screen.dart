import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/screen/order_screen/invoice_pdf_view.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../core/model/order_detail_model.dart';
import '../../new_widgets/order_status_badge.dart';
import '../../new_widgets/payment_status_bottom_sheet.dart';
import '../../widget/app_dialog.dart';
import '../../widget/common_snak_bar_widget.dart';
import '../../widget/error_empty_state.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

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
    final bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cLight;
    final cardBg = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5);
    final primaryText = isDark ? Colors.white : AppColor.cText;
    final secondaryText = isDark ? Colors.grey.shade400 : AppColor.cFont;
    final dividerColor = isDark ? DarkThemeColor.cBorder : AppColor.cDivider;
    final accentColor = AppColor.cGreenFont;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: simpleAppBar(
          title: "order_details".tr,
          isBack : true,
          label: null,
          onNewLabelTap: () {  }
      ),
      body: SafeArea(
        child: Obx(() {
          if (orderController.isLoadingOrderDetails.value) {
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
                                Text(
                                    "order_id_label".tr,
                                    style: TextStyle(fontSize: 12.sp, color: secondaryText)),
                                verticalSpace(4.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      detail.orderId!,
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: accentColor,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: CommonStatusBadge(
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
                                    ),
                                  ],
                                )
                              ],
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
                        deliveryCharge: parsePriceSafe(detail.deliveredCharge),
                        couponAmount: parsePriceSafe(detail.couponInfo?.discountAmount),
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
                                child: Text('#', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: secondaryText))),
                            Expanded(flex: 3,
                                child: Text('product'.tr, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: secondaryText))),
                            Expanded(flex: 2,
                                child: Text('qty'.tr, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.center)),
                            Expanded(flex: 2,
                                child: Text('price'.tr, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.right)),
                            Expanded(flex: 2,
                                child: Text('total'.tr, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: secondaryText), textAlign: TextAlign.right)),
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
                          final total = parsePriceSafe(product.qty) * parsePriceSafe(product.finalPrice);
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
                  ],
                ),
                verticalSpace(15.h),
                grandTotalsWidget(
                  grandTotal: detail.finalPrice!,
                  extTax: detail.taxPrice ?? "",
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
          Expanded(flex: 2, child: Text(price, style: TextStyle(fontSize: 12.sp, color: secondaryText), textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text(totals, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: accentColor), textAlign: TextAlign.right)),
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
          _totalRow("sub_total".tr, subTotal),
          _totalRow("shipping".tr,shippingPrice),
          _totalRow("tax".tr, extTax),
          _totalRow("coupon".tr, "- $applyCoupon", color: accentColor),
          Divider(color: Colors.white.withOpacity(0.2), height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("grand_total".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(grandTotal, style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          verticalSpace(15.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text("${"paid_by".tr} $paymentType", style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
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
                onDelete: () => AppDialog.showCustomDialog(
                  context: context,
                  title: 'delete'.tr,
                  message: 'deleteCategory'.tr,
                  lottieAsset:
                  'assets/lottie/delete_icon.json',
                  confirmColor: AppColor.cRedText,
                  onConfirm: () async {
                    Get.back();
                    final success = await orderController.deleteOrderNote(
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

  void _showAddNoteBottomSheet(BuildContext context, OrderDetailData detail) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteController = TextEditingController();
    String selectedType = 'private_note';

    final noteTypes = [
      {'value': 'private_note', 'label': 'private_note'.tr, 'icon': Icons.lock_outline},
      {'value': 'to_customer', 'label': 'public_note'.tr, 'icon': Icons.public},
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

                          Obx(() => AppButton(
                            text: 'add_note'.tr,
                            isLoading: orderController.isCreatingOrderNote.value,
                            onPressed: orderController.isCreatingOrderNote.value
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
    );
  }
}


class _StatusItem {
  final int id;
  final String name;
  final String desc;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  _StatusItem(this.id, this.name, this.desc, this.icon, this.bgColor, this.textColor);
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
          Row(
            children: [
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
                      dateFormatted(
                        date: note.createdAt ?? '',
                        formatType: formatForDateTime(
                          FormatType.dateTime,
                        ),
                          ),
                      style: TextStyle(
                        fontSize: 11.sp,
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
}
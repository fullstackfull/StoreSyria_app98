import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../core/controller/customers/customer_controller.dart';
import '../../../core/controller/order_controller/order_controller.dart';
import '../../../core/model/customer_orders_model.dart';
import '../../../utils/helper.dart';
import '../../../utils/images.dart';
import '../../new_widgets/app_snackbar.dart';
import '../../new_widgets/payment_status_bottom_sheet.dart';
import '../../new_widgets/top_orders.dart';
import '../../widget/app_dialog.dart';
import '../../widget/common_button.dart';
import '../order_screen/order_detail_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailsScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final CustomerController customerController = Get.find<CustomerController>();
  final OrderController orderController = Get.find<OrderController>();
  final order = CustomerOrder();
  bool _isOrdersExpanded = false;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    customerController.clearCustomerOrders();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      customerController.getCustomerOrdersData(
        customerId: widget.customerId,
        page: 1,
      );
    });
  }
  void _onScroll() {
    if (!scrollController.hasClients) return;

    if (!customerController.isCustomerOrdersScroll.value) {
      return;
    }

    if (customerController.isCustomerOrdersPageLoading.value) {
      return;
    }

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      customerController.getCustomerOrdersData(
        customerId: widget.customerId,
        page: customerController.customerOrdersCurrentPage.value + 1,
      );
    }
  }

  Future<void> _refresh() async {
    customerController.clearCustomerOrders();

    await customerController.getCustomerOrdersData(
      customerId: widget.customerId,
      page: 1,
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DarkThemeColor.cBackGround : const Color(0xFFF5F6F8);

    return Scaffold(
      appBar: simpleAppBar(
        isBack: true,
        isBold: false,
        title: 'customer_details'.tr,
        label: "new_order".tr,
        onNewLabelTap: () {
          AppSnackBar.success(
            title: 'success',
            message: "Standardize Dates");
          Get.toNamed(
            AppRoutes.addOrder,
            arguments: {
              'customerId': int.tryParse(widget.customerId),
              'isFromCustomerDetails': true,
            },
          );
        },
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          if (customerController.isCustomerOrdersLoading.value &&
              customerController.customerOrdersList.isEmpty) {
            return const Center(
              child: LoadingWidget(),
            );
          }
        
          if (customerController.customerOrdersErrorMessage.isNotEmpty &&
              customerController.customerOrdersList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .6,
                    child: Center(
                      child: ErrorState(
                        message: customerController.customerOrdersErrorMessage.value,
                        onRetry: _refresh,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        
          final customer = customerController.customerProfile.value;
        
          if (customerController.customerOrdersList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (customer != null)
                    _customerHeader(
                      customer: customer,
                      isDark: isDark,
                    ),
        
                  SizedBox(height: 20.h),
        
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .4,
                    child: Center(
                      child: EmptyState(
                        message: 'no_orders_found'.tr,
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (customer != null)
                  SliverToBoxAdapter(
                    child: _customerHeader(
                      customer: customer,
                      isDark: isDark,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () {
                        setState(() {
                          _isOrdersExpanded = !_isOrdersExpanded;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.themeNavyBlueColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      '${customerController.customerOrdersModel?.data?.pagination?.total ?? customerController.customerOrdersList.length}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.themeNavyBlueColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'orders'.tr,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColor.cDarkGreyFont,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _isOrdersExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 28.sp,
                              color: isDark
                                  ? Colors.white
                                  : AppColor.cDarkGreyFont,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        
                if (_isOrdersExpanded)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final order =
                          customerController.customerOrdersList[index];
        
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: allOrdersListItemWidget(
                              showChangeAction: true,
                              showChangeAction2: true,
                              context: context,
        
                              changeText: "change_payment_status".tr,
                              changeText2: "change_order_status".tr,
        
                              changeFun2: () {
                                OrderStatusBottomSheet.show<CustomerOrder>(
                                  context,
                                  order,
        
                                  getOrderStatus: (model) =>
                                  model.orderStatus as int,
        
                                  getProductOrderId: (model) =>
                                      model.orderId.toString(),
        
                                  getPaymentStatus: (model) =>
                                  model.paymentStatus ?? 'unpaid'.tr,
        
                                  setOrderStatus: (model, newStatus) {
                                    model.orderStatus = newStatus.toString();
                                  },
        
                                  setOrderStatusText: (model, newStatusText) {},
        
                                  onUpdated: () {
                                    orderController.orderList.refresh();
                                  },
                                );
                              },
        
                              changeFun: () {
                                showPaymentStatusBottomSheet<CustomerOrder>(
                                  context,
                                  order,
        
                                  getPaymentStatus: (model) =>
                                  model.paymentStatus ?? 'unpaid'.tr,
        
                                  getProductOrderId: (model) =>
                                      model.orderId.toString(),
        
                                  getDeliveredStatus: (model) =>
                                  model.orderStatus as int,
        
                                  setPaymentStatus: (model, newStatus) {
                                    model.paymentStatus = newStatus;
                                  },
        
                                  onUpdated: () {
                                    orderController.orderList.refresh();
                                  },
                                );
                              },
        
                              orderId: order.orderId.toString(),
        
                              date: dateFormatted(
                                date: order.createdAt ?? "",
                                formatType: formatForDateTime(
                                  FormatType.dateTime2,
                                ),
                              ),
        
                              maskedName: order.customerName.toString(),
        
                              price: "${order.total}",
        
                              secondaryBadgeLabel: order.paymentStatus,
        
                              primaryBadgeLabel: 0,
        
                              onTap: () => Get.to(
                                    () => OrderDetailScreen(
                                  orderId: order.id.toString(),
                                ),
                              ),
        
                              viewFun: () => Get.to(
                                    () => OrderDetailScreen(
                                  orderId: order.id.toString(),
                                ),
                              ),
        
                              deleteFun: () {
                                AppDialog.showCustomDialog(
                                  message: "delete_order".tr,
                                  lottieAsset:
                                  'assets/lottie/delete_icon.json',
                                  iconColor: AppColor.cRedText,
                                  confirmColor: AppColor.cRedText,
                                  context: context,
                                  onConfirm: () =>
                                      orderController.deleteOrderData(
                                        orderId: order.id.toString(),
                                      ),
                                );
                              },
                            ),
                          );
                        },
                        childCount:
                        customerController.customerOrdersList.length,
                      ),
                    ),
                  ),
        
                if (customerController.isCustomerOrdersScroll.value)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: customerController.isCustomerOrdersPageLoading.value
                            ? CircularProgressIndicator(
                          color: AppColor.themeNavyBlueColor,
                          strokeWidth: 2.w,
                        )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
        
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: AppButton(
                      backgroundColor: AppColor.cRedText,
                      text: 'delete_Customer'.tr,
                      radius: 20.r,
                      onPressed: () => AppDialog.showCustomDialog(
                        context: context,
                        title: 'delete'.tr,
                        message: 'deleteCustomer'.tr,
                        lottieAsset: 'assets/lottie/delete_icon.json',
                        confirmColor: Colors.red,
                        onConfirm: () async {
                          await customerController.deleteCustomerData(
                            customerId: widget.customerId.toString(),
                          );
                          Get.back();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _customerHeader({
    required CustomerProfile customer,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColor.cCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColor.themeNavyBlueColor.withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 26.sp,
              color: AppColor.themeNavyBlueColor,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name ?? 'customer_name'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (customer.email != null && customer.email!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    customer.email!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (customer.mobile != null && customer.mobile!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    customer.mobile!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
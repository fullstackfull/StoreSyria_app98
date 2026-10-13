import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/routes/routes.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import '../../../core/controller/customers/customer_controller.dart';
import '../../../core/controller/order_controller/order_controller.dart';
import '../../../core/model/customer_orders_model.dart';
import '../../new_widgets/customer_contact.dart';
import '../../new_widgets/payment_status_bottom_sheet.dart';
import '../../new_widgets/shimmer.dart';
import '../../new_widgets/top_orders.dart';
import '../../widget/app_dialog.dart';
import '../order_screen/order_detail_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailsScreen({super.key, required this.customerId});
  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final CustomerController customerController = Get.find<CustomerController>();
  final OrderController orderController = Get.find<OrderController>();
  late final ScrollController scrollController;
  bool _isOrdersExpanded = false;
  final GlobalKey _firstOrderKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    customerController.clearCustomerOrders();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      customerController.getCustomerOrdersData(customerId: widget.customerId, page: 1);
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (!_isOrdersExpanded) return;
    if (!customerController.isCustomerOrdersScroll.value) return;
    if (customerController.isCustomerOrdersPageLoading.value) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 250) {
      final nextPage = customerController.customerOrdersCurrentPage.value + 1;
      customerController.getCustomerOrdersData(customerId: widget.customerId, page: nextPage);
    }
  }

  Future<void> _refresh() async {
    customerController.clearCustomerOrders();
    await customerController.getCustomerOrdersData(customerId: widget.customerId, page: 1);
  }

  void _openAllOrders() {
    setState(() {
      _isOrdersExpanded = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final anchorContext = _firstOrderKey.currentContext;
      if (anchorContext != null) {
        Scrollable.ensureVisible(anchorContext, duration: const Duration(milliseconds: 300), curve: Curves.easeOut, alignment: 0.05);
      }
      if (customerController.isCustomerOrdersScroll.value && !customerController.isCustomerOrdersPageLoading.value && scrollController.hasClients && scrollController.position.maxScrollExtent - scrollController.position.pixels < 400) {
        final nextPage = customerController.customerOrdersCurrentPage.value + 1;
        customerController.getCustomerOrdersData(customerId: widget.customerId, page: nextPage);
      }
    });
  }

  void _closeAllOrders() {
    setState(() {
      _isOrdersExpanded = false;
    });
  }

  Widget _orderItem(CustomerOrder order, CustomerProfile? customer) {
    return allOrdersListItemWidget(
      showChangeAction: true,
      showChangeAction2: true,
      context: context,
      changeText: "change_payment_status".tr,
      changeText2: "change_order_status".tr,
      changeFun2: () {
        OrderStatusBottomSheet.show<CustomerOrder>(
          context,
          order,
          getOrderStatus: (model) => model.orderStatus ?? 0,
          getProductOrderId: (model) => model.orderId.toString(),
          getPaymentStatus: (model) => model.paymentStatus ?? 'unpaid'.tr,
          setOrderStatus: (model, newStatus) {
            model.orderStatus = newStatus;
          },
          setOrderStatusText: (model, newStatusText) {},
          onUpdated: () {
            orderController.orderList.refresh();
            customerController.customerOrdersList.refresh();
          },
        );
      },
      changeFun: () {
        showPaymentStatusBottomSheet<CustomerOrder>(
          context,
          order,
          getPaymentStatus: (model) => model.paymentStatus ?? 'unpaid'.tr,
          getProductOrderId: (model) => model.orderId.toString(),
          getDeliveredStatus: (model) => model.orderStatus ?? 0,
          setPaymentStatus: (model, newStatus) {
            model.paymentStatus = newStatus;
          },
          onUpdated: () {
            orderController.orderList.refresh();
            customerController.customerOrdersList.refresh();
          },
        );
      },
      orderId: order.orderId.toString(),
      date: "",
      maskedName: customer?.name ?? "",
      price: "${order.finalPrice} ${orderController.currencySymbol.value}",
      secondaryBadgeLabel: order.paymentStatus,
      primaryBadgeLabel: 0,
      onTap: () {
        Get.to(() => OrderDetailScreen(orderId: order.id.toString()));
      },
      viewFun: () {
        Get.to(() => OrderDetailScreen(orderId: order.id.toString()));
      },
      deleteFun: () {
        AppDialog.showCustomDialog(
          message: "delete_order".tr,
          lottieAsset: 'assets/lottie/delete_icon.json',
          iconColor: AppColor.cRedText,
          confirmColor: AppColor.cRedText,
          context: context,
          onConfirm: () async {
            await orderController.deleteOrderData(orderId: order.id.toString());
            customerController.customerOrdersList.removeWhere((item) => item.id == order.id);
            customerController.customerOrdersList.refresh();
          },
        );
      },
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
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
          Get.toNamed(AppRoutes.addOrder, arguments: {
            'customerId': int.tryParse(widget.customerId),
            'isFromCustomerDetails': true,
          });
        },
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          if (customerController.isCustomerOrdersLoading.value && customerController.customerOrdersList.isEmpty) {
            return const ShimmerDetails(sections: 2);
          }
          if (customerController.customerOrdersErrorMessage.isNotEmpty && customerController.customerOrdersList.isEmpty) {
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
          final hasOrders = customerController.customerOrdersList.isNotEmpty;

          if (customer == null) {
            return const ShimmerDetails(sections: 2);
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _customerHeader(customer: customer, isDark: isDark, showOrdersSection: hasOrders)),

                if (_isOrdersExpanded && hasOrders)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final currentOrder = customerController.customerOrdersList[index];
                          return Padding(
                            key: index == 0 ? _firstOrderKey : null,
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _orderItem(currentOrder, customer),
                          );
                        },
                        childCount: customerController.customerOrdersList.length,
                      ),
                    ),
                  ),

                if (_isOrdersExpanded && hasOrders && customerController.isCustomerOrdersScroll.value && customerController.isCustomerOrdersPageLoading.value)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: SizedBox(width: 24.w, height: 24.w, child: CircularProgressIndicator(color: AppColor.themeNavyBlueColor, strokeWidth: 2.w)),
                      ),
                    ),
                  ),

                if (!hasOrders)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 150.h,
                      child: Center(
                        child: EmptyState(
                            message: 'no_orders_found'.tr,
                            iconSize: 50.w,
                            icon: Icons.shopping_bag_outlined),
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                    child: _personalDataSection(customer: customer, isDark: isDark)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: AppButton(
                      backgroundColor: AppColor.cRedText,
                      text: 'delete_Customer'.tr,
                      radius: 20.r,
                      onPressed: () {
                        AppDialog.showCustomDialog(
                          context: context,
                          title: 'delete'.tr,
                          message: 'deleteCustomer'.tr,
                          lottieAsset: 'assets/lottie/delete_icon.json',
                          confirmColor: Colors.red,
                          onConfirm: () async {
                            await customerController.deleteCustomerData(customerId: widget.customerId.toString());
                            Get.back();
                          },
                        );
                      },
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

  Widget _customerHeader({required CustomerProfile customer, required bool isDark, required bool showOrdersSection}) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final latestOrder = customerController.customerOrdersList.isNotEmpty ? customerController.customerOrdersList.first : null;
    return Column(
      children: [
        _card(
          isDark: isDark,
          margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.name ?? 'no_name'.tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Icon(Icons.trending_up_rounded, size: 16.sp, color: subColor),
                  SizedBox(width: 6.w),
                  Text('total_payments'.tr, style: TextStyle(fontSize: 13.sp, color: subColor)),
                ],
              ),
              SizedBox(height: 4.h),
              Text(customer.totalSpend ?? '0', style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(child: _summaryStat(icon: Icons.shopping_bag_outlined, label: 'orders'.tr, value: '${customer.orders ?? customerController.customerOrdersList.length}', textColor: textColor, subColor: subColor)),
                  Expanded(flex: 2,child: _summaryStat(icon: Icons.bar_chart_rounded, label: 'order_cost_avg'.tr, value: customer.aov ?? '0', textColor: textColor, subColor: subColor)),
                ],
              ),
            ],
          ),
        ),
        if (latestOrder != null && showOrdersSection) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
            child: Align(alignment: Alignment.centerLeft, child: Text('latest_order'.tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: textColor))),
          ),
          if (!_isOrdersExpanded) Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: _orderItem(latestOrder, customer)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: GestureDetector(
                onTap: _isOrdersExpanded ? _closeAllOrders : _openAllOrders,
                child: Text(
                    _isOrdersExpanded ?
                    'hide_orders'.tr :
                    '${'view_all_orders'.tr} (${customerController.customerOrdersModel?.data?.pagination?.total ?? customerController.customerOrdersList.length})',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColor.themeNavyBlueColor)
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _personalDataSection({required CustomerProfile customer, required bool isDark}) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
          child: Align(alignment: Alignment.centerLeft, child: Text('personal_data'.tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: textColor))),
        ),
        _card(
          isDark: isDark,
          margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hasValue(customer.name)) _dataRow(label: 'name'.tr, value: customer.name!, textColor: textColor, subColor: subColor),
              if(_hasValue(customer.defaultAddress?.stateName)) _dataRow(label: 'city'.tr, value: customer.defaultAddress!.stateName!, textColor: textColor, subColor: subColor),
              if (_hasValue(customer.defaultAddress?.address)) _dataRow(label: 'address'.tr, value: customer.defaultAddress!.address!, textColor: textColor, subColor: subColor),
              if (_hasValue(customer.mobile)) _dataRow(label: 'phone'.tr, value: customer.mobile!, textColor: textColor, subColor: subColor),
              if (_hasValue(customer.email)) _dataRow(label: 'email'.tr, value: customer.email!, textColor: textColor, subColor: subColor),
              if (_hasValue(customer.mobile) || _hasValue(customer.email)) ...[
                SizedBox(height: 14.h),
                CustomerContactActions(
                  phone: customer.mobile,
                  email: customer.email,
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _card({required bool isDark, required Widget child, EdgeInsetsGeometry? margin, VoidCallback? onTap}) {
    final content = Container(
      margin: margin ?? EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkThemeColor.cCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(borderRadius: BorderRadius.circular(16.r), onTap: onTap, child: content);
  }

  Widget _summaryStat({required IconData icon, required String label, required String value, required Color textColor, required Color subColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          margin: EdgeInsets.only(top: 2.h),
          decoration: BoxDecoration(color: AppColor.themeNavyBlueColor.withValues(alpha: .1), borderRadius: BorderRadius.circular(8.r)),
          child: Icon(icon, size: 16.sp, color: AppColor.themeNavyBlueColor),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,style: TextStyle(fontSize: 12.sp ,color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 2.h),
              Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dataRow({required String label, required String value, required Color textColor, required Color subColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100.w, child: Text(label, style: TextStyle(fontSize: 13.sp, color: subColor))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: textColor))),
        ],
      ),
    );
  }
}
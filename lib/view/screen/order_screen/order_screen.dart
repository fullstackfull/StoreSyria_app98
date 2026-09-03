import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/order_screen/order_detail_screen.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import '../../../core/model/order_model.dart';
import '../../new_widgets/filter_tabs.dart';
import '../../new_widgets/header_widget.dart';
import '../../new_widgets/payment_status_bottom_sheet.dart';
import '../../new_widgets/search_widget.dart';
import '../../new_widgets/top_orders.dart';
import '../../widget/error_empty_state.dart';
import '../../widget/loading_widget.dart';
import '../../new_widgets/date_filter.dart';

class OrderScreen extends StatefulWidget {

  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with AutomaticKeepAliveClientMixin {
  final OrderController orderController = Get.find<OrderController>();
  late ScrollController scrollController;

  bool _isFirstLoad = true;
  DateTimeRange? selectedDateRange;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        _fetchInitialData();
      }
    });

    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!orderController.isScroll.value) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {

      if (orderController.isLoadingMoreOrders.value) return;

      final nextPage = orderController.currantPage.value + 1;

      orderController.getOrderData(
        nextPage,
        deliveredStatus: orderController.selectedStatus.value == 0
            ? null
            : orderController.selectedStatus.value - 1,
        fromDate: selectedDateRange?.start,
        toDate: selectedDateRange?.end,
      );
    }
  }

  Future<void> _fetchInitialData({int? deliveredStatus, bool useDateFilter = true}) async {
    orderController.currantPage.value = 1;
    orderController.isScroll.value = true;
    orderController.orderList.clear();

    await orderController.getOrderData(
      1,
      deliveredStatus: deliveredStatus,
      fromDate: useDateFilter ? selectedDateRange?.start : null,
      toDate: useDateFilter ? selectedDateRange?.end : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.cLight,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // add order
              HeaderWidget(
                context: context,
                title: "orders".tr,
                label: "new_order".tr,
                onNewLabelTap: () {},
              ),

              verticalSpace(10.h),

              Obx(() {
                return orderStatusTabsWidget(
                  context: context,
                  selectedIndex: orderController.selectedStatus.value,
                  onChanged: (index) {
                    orderController.selectedStatus.value = index;

                    setState(() {
                      selectedDateRange = null;
                    });

                    if (index == 0) {
                      _fetchInitialData(deliveredStatus: null,useDateFilter: false);
                    } else {
                      _fetchInitialData(deliveredStatus: index - 1, useDateFilter: false);
                    }
                  },
                );
              }),
              verticalSpace(20.h),

              SizedBox(
                width: double.infinity,
                child: SearchRowWidget(
                  context: context,
                  controller: orderController.searchController,
                  hint: 'search'.tr,
                  onChanged: (value) {
                    if (value.length > 2) {
                      orderController.searchOrderData(name: value);
                    } else if (value.isEmpty) {
                      _fetchInitialData();
                    }
                  },
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (orderController.isLoadingOrders.value && orderController.currantPage.value == 1) {
                    return const Center(child: LoadingWidget());
                  }

                  if (orderController.errorMessage.isNotEmpty && orderController.orderList.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => _fetchInitialData(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .6,
                            child: Center(
                              child: ErrorState(
                                message: orderController.errorMessage.value,
                                onRetry: () => _fetchInitialData(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (orderController.orderList.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => _fetchInitialData(),
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

                  // TODO :: top order api
                  final topOrders = orderController.orderList.take(5).toList();

                  return RefreshIndicator(
                    backgroundColor: Colors.white,
                    onRefresh: () => _fetchInitialData(),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: orderController.orderList.length + (orderController.isScroll.value ? 1 : 0) + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 15.h),
                            child: sectionHeaderWithFilterWidget(
                              isFilter: true,
                              num: orderController.orderModel?.data?.total ?? 0,
                              context: context,
                              title: "all_orders".tr,
                              filterLabel: selectedDateRange != null
                                  ? "${dateFormatted(
                                date: selectedDateRange!.start.toString(),
                                formatType: formatForDateTime(FormatType.date),
                              )} - ${dateFormatted(
                                date: selectedDateRange!.end.toString(),
                                formatType: formatForDateTime(FormatType.date),
                              )}"
                                  : "filter_by_date".tr,
                              onFilterTap: () async {
                                final range = await showDateRangeBottomSheet(
                                  context: context,
                                  initialRange: selectedDateRange,
                                );

                                if (range != null) {
                                  setState(() {
                                    selectedDateRange = range;
                                  });

                                  await _fetchInitialData(
                                    deliveredStatus:
                                    orderController.selectedStatus.value == 0
                                        ? null
                                        : orderController.selectedStatus.value - 1,
                                  );
                                }
                              },
                            ),
                          );
                        }

                        // ==================== ORDERS PAGINATION LOADER ====================
                        final listIndex = index - 1;

                        if (listIndex == orderController.orderList.length) {
                          return Obx(() => Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: orderController.isLoadingMoreOrders.value
                                  ? CircularProgressIndicator(
                                color: AppColor.themeNavyBlueColor,
                              )
                                  : const SizedBox.shrink(),
                            ),
                          ));
                        }

                        // ==================== ORDER ITEM ====================
                        final order = orderController.orderList[listIndex];

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: allOrdersListItemWidget(
                            showChangeAction: true,
                            showChangeAction2: true,
                            context: context,
                            changeText: "change_payment_status".tr,
                            changeText2: "change_order_status".tr,
                            changeFun2: () {
                              OrderStatusBottomSheet.show<OrderData>(
                                context,
                                order,

                                getOrderStatus: (model) =>
                                model.deliveredStatus ?? 0,

                                getProductOrderId: (model) =>
                                model.productOrderId ?? '',

                                getPaymentStatus: (model) =>
                                model.paymentStatus ?? 'Unpaid',

                                setOrderStatus: (model, newStatus) {
                                  model.deliveredStatus = newStatus;
                                },

                                setOrderStatusText: (model, newStatusText) {
                                },

                                onUpdated: () {
                                  orderController.orderList.refresh();
                                },
                              );
                            },
                            changeFun: () {
                              showPaymentStatusBottomSheet<OrderData>(
                                context,
                                order,
                                getPaymentStatus: (model) => model.paymentStatus ?? '',
                                getProductOrderId: (model) => model.productOrderId ?? '',
                                getDeliveredStatus: (model) => model.deliveredStatus ?? 0,
                                setPaymentStatus: (model, newStatus) {
                                  model.paymentStatus = newStatus;
                                },
                                onUpdated: () {
                                  orderController.orderList.refresh();
                                },
                              );
                            },
                            orderId: order.productOrderId ?? '',
                            date: dateFormatted(
                              date: order.orderDate!,
                              formatType: formatForDateTime(FormatType.date),
                            ),
                            maskedName: (order.userName?.isEmpty ?? true) ? 'no_name'.tr : order.userName ?? "",
                            price: "${order.finalPrice}",
                            secondaryBadgeLabel:order.paymentStatus,
                            primaryBadgeLabel: order.deliveredStatus,
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
                                message: "deleteOrder",
                                lottieAsset: 'assets/lottie/delete_icon.json',
                                iconColor: AppColor.cRedText,
                                confirmColor: AppColor.cRedText,
                                context: context,
                                onConfirm: () => orderController.deleteOrderData(
                                  orderId: order.id.toString(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
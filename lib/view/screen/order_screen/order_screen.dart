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
import '../../new_widgets/payment_status_bottom_sheet.dart';
import '../../new_widgets/search_widget.dart';
import '../../new_widgets/top_orders.dart';
import '../../widget/common_appbar_widget.dart';
import '../../widget/error_empty_state.dart';
import '../../widget/loading_widget.dart';
import '../../new_widgets/date_filter.dart';
import 'create_order_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with AutomaticKeepAliveClientMixin {
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

    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isFirstLoad) {
        _isFirstLoad = false;

        await Future.wait([
          _fetchInitialData(),
          orderController.getTopOrderData(),
        ]);
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // Scroll / Pagination
  // ============================================================

  void _onScroll() {
    if (!orderController.isScroll.value) return;

    if (!scrollController.hasClients) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (orderController.isLoadingMoreOrders.value) return;

      final nextPage =
          orderController.currantPage.value + 1;

      orderController.getOrderData(
        nextPage,
        deliveredStatus:
        orderController.selectedStatus.value == 0
            ? null
            : orderController.selectedStatus.value - 1,
        fromDate: selectedDateRange?.start,
        toDate: selectedDateRange?.end,
      );
    }
  }

  // ============================================================
  // Initial / Refresh Data
  // ============================================================

  Future<void> _fetchInitialData({
    int? deliveredStatus,
    bool useDateFilter = true,
  }) async {
    orderController.currantPage.value = 1;
    orderController.isScroll.value = true;

    orderController.orderList.clear();

    await orderController.getOrderData(
      1,
      deliveredStatus: deliveredStatus,
      fromDate:
      useDateFilter ? selectedDateRange?.start : null,
      toDate:
      useDateFilter ? selectedDateRange?.end : null,
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: simpleAppBar(
          title: "orders".tr,
          isBold: true,
          label: "new_order".tr,
          onNewLabelTap: () {
         Get.to(() => const CreateOrderScreen());
      },
        ),
        backgroundColor: AppColor.cLight,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 10.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // STATUS TABS
              // ==================================================

              Obx(() {
                return orderStatusTabsWidget(
                  context: context,
                  selectedIndex:
                  orderController.selectedStatus.value,
                  onChanged: (index) {
                    orderController.selectedStatus.value =
                        index;

                    setState(() {
                      selectedDateRange = null;
                    });

                    if (index == 0) {
                      _fetchInitialData(
                        deliveredStatus: null,
                        useDateFilter: false,
                      );
                    } else {
                      _fetchInitialData(
                        deliveredStatus: index - 1,
                        useDateFilter: false,
                      );
                    }
                  },
                );
              }),

              verticalSpace(16.h),

              // ==================================================
              // SEARCH
              // ==================================================

              SizedBox(
                width: double.infinity,
                child: SearchRowWidget(
                  context: context,
                  controller:
                  orderController.searchController,
                  hint: 'search'.tr,
                  onChanged: (value) {
                    if (value.length > 2) {
                      orderController.searchOrderData(
                        name: value,
                      );
                    } else if (value.isEmpty) {
                      _fetchInitialData();
                    }
                  },
                ),
              ),

              verticalSpace(16.h),

              // ==================================================
              // ORDERS
              // ==================================================

              Expanded(
                child: Obx(() {
                  final orderList =
                      orderController.orderList;

                  final topOrders =
                      orderController.topOrderList;

                  final isLoadingOrders =
                      orderController.isLoadingOrders.value;

                  final isLoadingTopOrders =
                      orderController
                          .isLoadingTopOrders
                          .value;

                  final hasTopOrders =
                      topOrders.isNotEmpty;

                  // ==================================================
                  // MAIN LOADING
                  // ==================================================

                  if (isLoadingOrders &&
                      orderController.currantPage.value == 1 &&
                      orderList.isEmpty) {
                    return const Center(
                      child: LoadingWidget(),
                    );
                  }

                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (orderController
                      .errorMessage
                      .isNotEmpty &&
                      orderList.isEmpty &&
                      !isLoadingOrders) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          _fetchInitialData(),
                          orderController
                              .getTopOrderData(),
                        ]);
                      },
                      child: ListView(
                        physics:
                        const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height:
                            MediaQuery.of(context)
                                .size
                                .height *
                                .6,
                            child: Center(
                              child: ErrorState(
                                message: orderController
                                    .errorMessage
                                    .value,
                                onRetry: () {
                                  _fetchInitialData();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // ==================================================
                  // EMPTY STATE
                  // ==================================================

                  if (orderList.isEmpty &&
                      !isLoadingOrders) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([
                          _fetchInitialData(),
                          orderController
                              .getTopOrderData(),
                        ]);
                      },
                      child: ListView(
                        physics:
                        const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height:
                            MediaQuery.of(context)
                                .size
                                .height *
                                .6,
                            child: Center(
                              child: EmptyState(
                                message:
                                "no_orders_found".tr,
                                icon: Icons
                                    .receipt_long_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final itemCount =
                      (hasTopOrders ? 1 : 0) + // Top Orders
                          1 + // All Orders Header
                          orderList.length +
                          (orderController.isScroll.value ? 1 : 0);

                  return RefreshIndicator(
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await Future.wait([
                        _fetchInitialData(),
                        orderController.getTopOrderData(),
                      ]);
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        // ==================================================
                        // TOP ORDERS
                        // ==================================================

                        if (hasTopOrders && index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: Text(
                                  "top_orders".tr,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: 173.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: topOrders.length,
                                  separatorBuilder: (context, index) {
                                    return SizedBox(width: 10.w);
                                  },
                                  itemBuilder: (context, topIndex) {
                                    final order = topOrders[topIndex];

                                    return topOrderCardWidget(
                                      context: context,
                                      orderId: order.productOrderId ?? '',
                                      date: dateFormatted(
                                        date: order.orderDate ?? '',
                                        formatType: formatForDateTime(
                                          FormatType.dateTime2,
                                        ),
                                      ),
                                      maskedName:
                                      (order.userName?.isEmpty ?? true)
                                          ? 'no_name'.tr
                                          : order.userName ?? '',
                                      price: '${order.finalPrice}',
                                      primaryBadgeLabel: order.deliveredStatus,
                                      secondaryBadgeLabel: order.paymentStatus,
                                      onTap: () {
                                        Get.to(
                                              () => OrderDetailScreen(
                                            orderId: order.id.toString(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),

                              verticalSpace(16.h),
                            ],
                          );
                        }

                        // ==================================================
                        // ALL ORDERS HEADER
                        // ==================================================

                        final headerIndex = hasTopOrders ? 1 : 0;

                        if (index == headerIndex) {
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
                                formatType: formatForDateTime(
                                  FormatType.date,
                                ),
                              )} - ${dateFormatted(
                                date: selectedDateRange!.end.toString(),
                                formatType: formatForDateTime(
                                  FormatType.date,
                                ),
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

                        // ==================================================
                        // ORDER LIST INDEX
                        // ==================================================

                        final orderStartIndex = hasTopOrders ? 2 : 1;
                        final listIndex = index - orderStartIndex;

                        // ==================================================
                        // PAGINATION LOADER
                        // ==================================================

                        if (listIndex == orderList.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: orderController.isLoadingMoreOrders.value
                                  ? CircularProgressIndicator(
                                color: AppColor.themeNavyBlueColor,
                              )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }

                        // حماية إضافية من RangeError
                        if (listIndex < 0 || listIndex >= orderList.length) {
                          return const SizedBox.shrink();
                        }

                        // ==================================================
                        // ORDER ITEM
                        // ==================================================

                        final order = orderList[listIndex];

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
                              formatType: formatForDateTime(FormatType.dateTime2),
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

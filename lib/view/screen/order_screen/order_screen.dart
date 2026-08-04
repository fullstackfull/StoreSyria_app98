import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/core/model/order_model.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/order_screen/order_detail_screen.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import '../../../utils/images.dart';
import '../../new_widgets/header_widget.dart';
import '../../new_widgets/search_widget.dart';
import '../../widget/error_empty_state.dart';
import '../../widget/icon_and_image.dart';
import '../../widget/loading_widget.dart';
import 'order_widgets.dart';

class OrderScreen extends StatefulWidget {
  final bool isBack;

  const OrderScreen({super.key, required this.isBack});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with AutomaticKeepAliveClientMixin {
  final OrderController orderController = Get.find<OrderController>();
  late ScrollController scrollController;
  bool _isFirstLoad = true;

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
    // لا تقم بعمل dispose للـ searchController هنا إذا كان تابعاً للـ Controller
    // لأنه قد يُستخدم في أماكن أخرى، الـ GetX سيتولى أمره
    super.dispose();
  }

  void _onScroll() {
    if (orderController.isScroll.value &&
        scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      // إضافة عتبة 200 لتحميل مبكر ومنع الوصول الحرفي للقاع
      orderController.currantPage.value += 1;
      orderController.getOrderData(
        orderController.currantPage.value,
        status: orderController.selectedStatus.value, // استخدام الحالة المحفوظة في الكونترولر
      );
    }
  }

  Future<void> _fetchInitialData({int status = 0}) async {
    orderController.currantPage.value = 1;
    orderController.isScroll.value = true;
    orderController.orderList.clear();
    await orderController.getOrderData(1, status: status);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.cLight,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderWidget(
                  context: context,
                  title: "orders".tr,
                  label: "new_order".tr,
                  onNewLabelTap: () {
                    // TODO: توجيه لشاشة إنشاء طلب جديد
                  },
                ),

                verticalSpace(16.h),

                /// تبويبات الحالات - تم تحسين الأداء باستخدام Obx منفصل
                Obx(() {
                  final list = orderController.orderList;
                  // يفضل نقل هذه الحسابات للـ Controller كـ Getters
                  final allCount = list.length;
                  final newCount = list.where((o) => (o.paymentStatus ?? '').toLowerCase() == 'new').length;
                  final preparingCount = list.where((o) => (o.deliveredStatus ?? '') == '0').length;

                  return orderStatusTabsWidget(
                    context: context,
                    allCount: allCount,
                    newCount: newCount,
                    preparingCount: preparingCount,
                    allLabel: "all_orders".tr,
                    newLabel: "new".tr,
                    preparingLabel: "preparing".tr,
                    selectedIndex: orderController.selectedStatus.value, // ربط مباشر بالكونترولر
                    onChanged: (index) {
                      orderController.selectedStatus.value = index;
                      _fetchInitialData(status: index); // تصفير الصفحة وتطبيق الفلتر الصحيح
                    },
                  );
                }),

                verticalSpace(20.h),

                SearchRowWidget(
                  context: context,
                  controller: orderController.searchController,
                  hint: 'search'.tr,
                  onChanged: (value) {
                    if (value.length > 2) {
                      orderController.searchOrderData(name: value);
                    } else if (value.isEmpty) {
                      // عند مسح البحث، نعود للصفحة الأولى بالحالة الحالية
                      _fetchInitialData(status: orderController.selectedStatus.value);
                    }
                  },
                  onSortTap: () {},
                  onFilterTap: () {},
                ),

                verticalSpace(24.h),

                Expanded(
                  child: Obx(() {
                    if (orderController.isLoading.value && orderController.currantPage.value == 1) {
                      return const Center(child: LoadingWidget());
                    }

                    if (orderController.errorMessage.isNotEmpty && orderController.orderList.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => _fetchInitialData(status: orderController.selectedStatus.value),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .6,
                              child: Center(
                                child: ErrorState(
                                  message: orderController.errorMessage.value,
                                  onRetry: () => _fetchInitialData(status: orderController.selectedStatus.value),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (orderController.orderList.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => _fetchInitialData(status: orderController.selectedStatus.value),
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

                    // ملاحظة: Top Orders يجب أن تأتي من API منفصل أو تكون محفوظة بشكل مستقل
                    // حالياً نأخذ أول 5 كحل مؤقت لكن لن تتغير مع الباجينيشن بسبب take(5)
                    final topOrders = orderController.orderList.take(5).toList();

                    return RefreshIndicator(
                      backgroundColor: Colors.white,
                      onRefresh: () => _fetchInitialData(status: orderController.selectedStatus.value),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: orderController.orderList.length + (orderController.isScroll.value ? 1 : 0) + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sectionHeaderWithFilterWidget(
                                    context: context,
                                    title: "top_orders".tr,
                                    filterLabel: "last_30_days".tr,
                                    onFilterTap: () {},
                                  ),
                                  verticalSpace(14.h),
                                  SizedBox(
                                    height: 150.h,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: topOrders.length,
                                      itemBuilder: (context, i) {
                                        final order = topOrders[i];
                                        return topOrderCardWidget(
                                          context: context,
                                          orderId: order.productOrderId ?? '',
                                          date: dateFormatted(date: order.orderDate!, formatType: formatForDateTime(FormatType.date)),
                                          maskedName: order.userName ?? '',
                                          price: "${order.finalPrice} ${"sar".tr}",
                                          isHot: i == 0,
                                          primaryBadgeLabel: order.paymentStatus,
                                          secondaryBadgeLabel: "paid".tr,
                                          onTap: () => Get.to(() => OrderDetailScreen(orderId: order.id.toString())),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (index == 1) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 15.h),
                              child: Text(
                                "all_orders".tr,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            );
                          }

                          final listIndex = index - 2;

                          if (listIndex == orderController.orderList.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Center(child: CircularProgressIndicator(color: AppColor.themeNavyBlueColor)),
                            );
                          }

                          final order = orderController.orderList[listIndex];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: allOrdersListItemWidget(
                              context: context,
                              orderId: order.productOrderId ?? '',
                              date: dateFormatted(date: order.orderDate!, formatType: formatForDateTime(FormatType.date)),
                              maskedName: order.userName ?? '',
                              price: "${order.finalPrice} ${"sar".tr}",
                              primaryBadgeLabel: order.paymentStatus,
                              secondaryBadgeLabel: "paid".tr,
                              onTap: () => Get.to(() => OrderDetailScreen(orderId: order.id.toString())),
                              viewFun: () => Get.to(() => OrderDetailScreen(orderId: order.id.toString())),
                              shareFun: () {},
                              downloadFun: () {},
                              deleteFun: () {
                                AppDialog.showCustomDialog(
                                  iconColor: AppColor.cRedText,
                                  confirmColor: AppColor.cRedText,
                                  context: context,
                                  onConfirm: () => orderController.deleteOrderData(orderId: order.id.toString()),
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
      ),
    );
  }
}

// تم تعديل الدالة لاستقبال BuildContext بدلاً من الاعتماد على Get.context!
Widget searchFieldWidget({
  required BuildContext context,
  String? hint,
  Function(String)? onChanged,
  TextEditingController? controller,
  Function()? onTap,
  TextInputType? keyboardType,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
  final textColor = isDark ? DarkThemeColor.cText : AppColor.cText;
  final hintColor = isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;
  final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder;

  return Container(
    height: 55.h,
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: borderColor.withOpacity(0.5)),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textColor),
      cursorColor: AppColor.themeGreenColor,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        prefixIcon: Padding(
          padding: EdgeInsets.all(12.w),
          child: assetSvdImageWidget(image: DefaultImages.searchIcn),
        ),
        suffixIcon: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(Icons.arrow_circle_right_rounded, color: AppColor.themeGreenColor, size: 25.sp),
          ),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: hintColor),
      ),
    ),
  );
}
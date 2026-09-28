import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../../core/controller/customers/customer_controller.dart';
import '../../new_widgets/search_widget.dart';
import 'customer_bottom_sheet.dart';
import '../../new_widgets/customer_widget.dart';
import '../../widget/app_dialog.dart';
import '../../widget/common_appbar_widget.dart';
import 'customers_details.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen>
    with AutomaticKeepAliveClientMixin {

  final CustomerController customerController = Get.find<CustomerController>();
  late final ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (customerController.customerList.isEmpty &&
          !customerController.isLoading.value) {
        customerController.getCustomersData(1);
      }
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (customerController.isCustomerSearchActive.value) {
      return;
    }

    if (!customerController.isScroll.value) return;

    if (customerController.isLoading.value) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      customerController.getCustomersData(
        customerController.currantPage.value + 1,
      );
    }
  }

  Future<void> _fetchInitialData() async {
    customerController.currantPage.value = 1;
    customerController.isScroll.value = true;

    await customerController.getCustomersData(1);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: simpleAppBar(
          isBack: true,
          isBold: true,
          title: "customers".tr,
          label: 'add_customer'.tr,
          onNewLabelTap: () {
                 showModalBottomSheet(
                 context: context,
                 backgroundColor: Colors.transparent,
                 barrierColor: Colors.black54,
                 isScrollControlled: true,
                 useSafeArea: false,
                 transitionAnimationController: AnimationController(
                 vsync: Navigator.of(context),
                 duration: const Duration(milliseconds: 700),
                 ),
                 builder: (context) {
                 return const AddNewCustomerWidget(
                 isUpdate: false,
                 );
            }
             );
          },
        ),
        backgroundColor: isDark
            ? DarkThemeColor.cBackGround
            : const Color(0xFFF5F6F8),
      body: Padding(
      padding: EdgeInsets.symmetric(
      horizontal: 20.w,
      vertical: 16.h,
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: SearchRowWidget(
              context: context,
              controller: customerController.searchController,
              hint: 'search'.tr,
              onChanged: customerController.onCustomerSearchChanged,
              onClear: customerController.resetCustomerSearch,
            ),
          ),

          SizedBox(height: 12.h),

          Expanded(
            child: Obx(() {
              final isSearchMode =
                  customerController.isCustomerSearchActive.value;

              final customers = isSearchMode
                  ? customerController.searchResults
                  : customerController.customerList;

              if (customerController.isSearchingCustomers.value &&
                  customers.isEmpty) {
                return const Center(
                  child: LoadingWidget(),
                );
              }

              if (!isSearchMode &&
                  customerController.isLoading.value &&
                  customerController.customerList.isEmpty) {
                return const Center(
                  child: LoadingWidget(),
                );
              }

              if (customers.isEmpty) {
                return RefreshIndicator(
                  backgroundColor: isDark
                      ? DarkThemeColor.cCardBackground
                      : Colors.white,
                  onRefresh: _fetchInitialData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height:
                        MediaQuery.of(context).size.height * .5,
                        child: Center(
                          child: EmptyState(
                            message: 'no_customers_found'.tr,
                            icon: Icons.people_outline_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                backgroundColor: isDark
                    ? DarkThemeColor.cCardBackground
                    : Colors.white,
                onRefresh: isSearchMode
                    ? () async {}
                    : _fetchInitialData,
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 15.h,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "${isSearchMode ? customers.length : (customerController.customerModel?.data?.pagination?.total ?? customers.length)} ${'items'.tr}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : AppColor.cDarkGreyFont,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: 20.h,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final customer = customers[index];

                            final fullName =
                                customer.customerInfo?.name?.trim() ?? '';

                            final parts =
                            fullName.split(RegExp(r'\s+'));

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: 12.h,
                              ),
                              child: customerWidget(
                                changeFun: () {
                                  Get.bottomSheet(
                                    AddNewCustomerWidget(
                                      isUpdate: true,
                                      customerId:
                                      customer.id.toString(),
                                      firstName:
                                      parts.isNotEmpty
                                          ? parts.first
                                          : '',
                                      lastName:
                                      parts.length > 1
                                          ? parts
                                          .sublist(1)
                                          .join(' ')
                                          : '',
                                      email: customer.email,
                                      mobile:
                                      customer.customerInfo?.mobile,
                                      status:
                                      customer.status.toString(),
                                    ),
                                    isScrollControlled: true,
                                  );
                                },

                                deleteFun: () {
                                  AppDialog.showCustomDialog(
                                    context: context,
                                    title: 'delete'.tr,
                                    message: 'deleteCustomer'.tr,
                                    lottieAsset:
                                    'assets/lottie/delete_icon.json',
                                    confirmColor: Colors.red,
                                    onConfirm: () async {
                                      await customerController
                                          .deleteCustomerData(
                                        customerId:
                                        customer.id.toString(),
                                      );
                                    },
                                  );
                                },

                                viewFun: () {
                                  Get.to(
                                        () => CustomerDetailsScreen(
                                      customerId:
                                      customer.id.toString(),
                                    ),
                                  );
                                },

                                onTap: () {
                                  Get.to(
                                        () => CustomerDetailsScreen(
                                      customerId:
                                      customer.id.toString(),
                                    ),
                                  );
                                },

                                context: context,
                                customer: customer,
                              ),
                            );
                          },

                          childCount: customers.length,
                        ),
                      ),
                    ),

                    if (!isSearchMode &&
                        customerController.isScroll.value)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20.h,
                          ),
                          child: Center(
                            child:
                            customerController.isPageLoading.value
                                ? CircularProgressIndicator(
                              color: AppColor
                                  .themeNavyBlueColor,
                            )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ),
                  ],
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
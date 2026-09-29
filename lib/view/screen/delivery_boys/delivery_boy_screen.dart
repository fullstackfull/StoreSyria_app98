import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import '../../../core/controller/delivery_boy/delivery_boy_controller.dart';
import '../../new_widgets/delivery_boy_widget.dart';
import '../../new_widgets/shimmer.dart';
import 'delivery_boy_bottom_sheet.dart';
import '../../widget/app_dialog.dart';
import '../../widget/common_appbar_widget.dart';

class DeliveryBoyScreen extends StatefulWidget {
  const DeliveryBoyScreen({super.key});

  @override
  State<DeliveryBoyScreen> createState() => _DeliveryBoyScreenState();
}

class _DeliveryBoyScreenState extends State<DeliveryBoyScreen>
    with AutomaticKeepAliveClientMixin {

  final DeliveryBoyController deliveryBoyController = Get.find<DeliveryBoyController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (deliveryBoyController.deliveryBoyList.isEmpty &&
          !deliveryBoyController.isLoading.value) {
        deliveryBoyController.getDeliveryBoysData();
      }
    });
  }

  Future<void> _fetchInitialData() async {
    await deliveryBoyController.getDeliveryBoysData();
  }

  @override
  void dispose() {
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
          title: "delivery_men".tr,
          label: 'add_delivery_man'.tr,
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
                  return const AddNewDeliveryBoyWidget(
                    isUpdate: false,
                  );
                }
            );
          },
        ),
        backgroundColor: isDark
            ? DarkThemeColor.cBackGround
            : const Color(0xFFF5F6F8),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    final deliveryBoys = deliveryBoyController.deliveryBoyList;

                    if (deliveryBoyController.isLoading.value &&
                        deliveryBoyController.deliveryBoyList.isEmpty) {
                      return const ShimmerList();
                    }

                    if (deliveryBoys.isEmpty) {
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
                                  message: 'no_delivery_men_found'.tr,
                                  icon: Icons.delivery_dining_outlined,
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
                      onRefresh: _fetchInitialData,
                      child: CustomScrollView(
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
                                    "${deliveryBoys.length} ${'items'.tr}",
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
                                  final deliveryBoy = deliveryBoys[index];

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 12.h,
                                    ),
                                    child: deliveryBoyWidget(
                                      changeText2: "change_password".tr,
                                      changeFun2: () {
                                        Get.bottomSheet(
                                          AddNewDeliveryBoyWidget(
                                            isChangePassword: true,
                                            deliveryBoyId: deliveryBoy.id.toString(),
                                          ),
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                        );
                                      },
                                      changeFun: () {
                                        Get.bottomSheet(
                                          AddNewDeliveryBoyWidget(
                                            isUpdate: true,
                                            deliveryBoyId:
                                            deliveryBoy.id.toString(),
                                            name: deliveryBoy.name,
                                            email: deliveryBoy.email,
                                            contact: deliveryBoy.contact,
                                            commissionPercentage: deliveryBoy.commissionPercentage,
                                            isCommissionEnabled: deliveryBoy.isCommissionEnabled.toString(),
                                          ),
                                          isScrollControlled: true,
                                        );
                                      },

                                      deleteFun: () {
                                        AppDialog.showCustomDialog(
                                          context: context,
                                          title: 'delete'.tr,
                                          message: 'delete_delivery_man'.tr,
                                          lottieAsset:
                                          'assets/lottie/delete_icon.json',
                                          confirmColor: Colors.red,
                                          onConfirm: () async {
                                            await deliveryBoyController
                                                .deleteDeliveryBoyData(
                                              deliveryBoyId:
                                              deliveryBoy.id.toString(),
                                            );
                                          },
                                        );
                                      },

                                      context: context,
                                      deliveryBoy: deliveryBoy,
                                    ),
                                  );
                                },

                                childCount: deliveryBoys.length,
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
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/payment_setting_controller/payment_setting_controller.dart';
import 'package:store_go_app/core/model/payment_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import '../../../new_widgets/shimmer.dart';

class PaymentSettingScreen extends StatefulWidget {
  const PaymentSettingScreen({super.key});

  @override
  State<PaymentSettingScreen> createState() =>
      _PaymentSettingScreenState();
}

class _PaymentSettingScreenState
    extends State<PaymentSettingScreen> {

  final PaymentSettingController paymentSettingController =
  Get.put(PaymentSettingController());


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      paymentSettingController.getPaymentTypesData();
    });
  }

  Future<void> _fetchPaymentMethods() async {
    await paymentSettingController.getPaymentTypesData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkThemeColor.cBackGround
          : const Color(0xFFF5F6F8),

      appBar: simpleAppBar(
        title: 'store_payment_methods'.tr,
        label: null,
        isBack: true,
        onNewLabelTap: () {},
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
          child: Obx(() {
            if (paymentSettingController.isLoading.value &&
                paymentSettingController.paymentMethods.isEmpty) {
              return const ShimmerList(
                itemCount: 5,
                leading: ShimmerLeading.square,
                lines: 1,
              );
            }
            if (paymentSettingController.errorMessage.isNotEmpty &&
                paymentSettingController.paymentMethods.isEmpty) {
              return RefreshIndicator(
                backgroundColor: isDark
                    ? DarkThemeColor.cCardBackground
                    : Colors.white,
                onRefresh: _fetchPaymentMethods,
                child: ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height:
                      MediaQuery.of(context).size.height * 0.65,
                      child: Center(
                        child: ErrorState(
                          message: paymentSettingController
                              .errorMessage.value,

                          onRetry: _fetchPaymentMethods,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (paymentSettingController.paymentMethods.isEmpty) {
              return RefreshIndicator(
                backgroundColor: isDark
                    ? DarkThemeColor.cCardBackground
                    : Colors.white,
                onRefresh: _fetchPaymentMethods,
                child: ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height:
                      MediaQuery.of(context).size.height * 0.65,
                      child: Center(
                        child: EmptyState(
                          message:
                          'No_payment_methods_available'.tr,
                          icon: Icons.credit_card_off_outlined,
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
              onRefresh: _fetchPaymentMethods,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      '${paymentSettingController.paymentMethods.length} '
                          '${'payment_methods'.tr}',
                      style: pRegular14.copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : AppColor.cDarkGreyFont,
                      ),
                    ),
                  ),
                  ...paymentSettingController.paymentMethods.map(
                        (method) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _paymentCard(
                        method: method,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _paymentCard({
    required PaymentMethod method,
    required bool isDark,
  }) {
    final Color cardColor = isDark
        ? DarkThemeColor.cCardBackground
        : Colors.white;

    final Color titleColor = isDark
        ? AppColor.cWhite
        : AppColor.cBlack;

    final Color subtitleColor = isDark
        ? Colors.grey.shade400
        : AppColor.cDarkGreyFont;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 15.h,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDark ? 0.12 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColor.themeNavyBlueColor.withOpacity(
                isDark ? 0.14 : 0.08,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: assetSvdImageWidget(
                image: DefaultImages.cardIcn,

                colorFilter: ColorFilter.mode(
                  AppColor.themeNavyBlueColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  method.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: pMedium14.copyWith(
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  method.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pRegular10.copyWith(
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          statusPill(
              label: "active".tr,
              isActive: true
          )
        ],
      ),
    );
  }
}
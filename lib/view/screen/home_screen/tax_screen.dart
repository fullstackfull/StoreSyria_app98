// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_go_app/core/controller/home_controller/tax_controller.dart';
import 'package:store_go_app/core/model/tax_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/home_screen/add_tax_bottomsheet.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import '../../new_widgets/shimmer.dart';
import '../../widget/app_dialog.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final TaxController taxController = Get.put(TaxController());
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    taxController.taxList.clear();
    taxController.currantPage.value = 1;
    taxController.isScroll.value = true;

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  void _onScroll() {
    if (taxController.isScroll.value &&
        scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      taxController.currantPage.value += 1;
      taxController.getTaxData(taxController.currantPage.value);
    }
  }

  Future<void> _getData() async {
    await taxController.getTaxData(taxController.currantPage.value);
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
    final textColor = isDark ? Colors.white : AppColor.cLabel;

    return Scaffold(
      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
      appBar: simpleAppBar(
          title: "tax".tr,
          isBack: true,
          label: null,
          onNewLabelTap: () {  }),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonIconButton(
              title: 'Add Tax'.tr,
              iconData: DefaultImages.addCircleIcn,
              onPressed: () {
                taxController.clearTaxFields();
                _showTaxBottomSheet(isUpdate: false);
              },
              height: 51.h,
            ),
            SizedBox(height: 20.h),
            Text("tax".tr, style: pRegular20.copyWith(color: textColor)),
            SizedBox(height: 25.h),

            // Table Header (Static)
            _buildTableHeader(isDark),
            SizedBox(height: 10.h),
            horizontalDivider(),

            // List Content (Reactive)
            Expanded(child: Obx(() => _buildBody(isDark))),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(bool isDark) {
    final headerColor = isDark ? Colors.white70 : AppColor.cDarkGreyFont;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            "Name".tr,
            style: pBold12.copyWith(
                color: headerColor, fontSize: 10.sp),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            "Amount".tr,
            style: pBold12.copyWith(
                color: headerColor, fontSize: 10.sp),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            "Action".tr,
            style: pBold12.copyWith(
                color: headerColor, fontSize: 10.sp),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(bool isDark) {
    /// First Loading
    if (taxController.isLoading.value && taxController.currantPage.value == 1) {
      return const ShimmerTable();
    }

    /// Error State
    if (taxController.errorMessage.isNotEmpty &&
        taxController.taxList.isEmpty) {
      return RefreshIndicator(
        backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
        onRefresh: _getData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * .6,
              child: Center(
                child: ErrorState(
                  message: taxController.errorMessage.value,
                  onRetry: _getData,
                ),
              ),
            ),
          ],
        ),
      );
    }

    /// Empty State
    if (taxController.taxList.isEmpty) {
      return RefreshIndicator(
        backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
        onRefresh: _getData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * .6,
              child: Center(
                child: EmptyState(
                  message: "no_taxs_found".tr,
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ),
          ],
        ),
      );
    }

    /// Data List
    return RefreshIndicator(
      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
      onRefresh: _getData,
      child: ListView.separated(
        physics: AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        itemCount: taxController.taxList.length,
        separatorBuilder: (_, __) => horizontalDivider(),
        itemBuilder: (context, index) {
          final tax = taxController.taxList[index];
          return _TaxItemWidget(
            tax: tax,
            onEdit: () => _showTaxBottomSheet(isUpdate: true, tax: tax),
            onDelete: () {
              AppDialog.showCustomDialog(
                  message: "deleteTax".tr,
                  lottieAsset: 'assets/lottie/delete_icon.json',
                  iconColor: AppColor.cRedText,
                  confirmColor: AppColor.cRedText,
                  context: context,
                  onConfirm: () =>
                      taxController.deleteTaxData(
                          taxId: tax.id.toString())
              );
            },
          );
        },
      ),
    );
  }

  void _showTaxBottomSheet({required bool isUpdate, Tax? tax}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
      barrierColor: AppColor.cGreyOpacity,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      builder: (_) =>
          AddTaxWidget(
            isUpdate: isUpdate,
            taxId: tax?.id.toString(),
            name: tax?.taxName,
            status: tax?.status.toString(),
            amount: tax?.taxAmount.toString(),
            chargeType: tax?.taxType,
          ),
    );
  }
}
/// Extracted Tax Item Widget for better performance and readability
class _TaxItemWidget extends StatelessWidget {
  final Tax tax;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaxItemWidget({
    required this.tax,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemTextColor = isDark ? Colors.white70 : AppColor.cDarkGreyFont;
    final String amountText = tax.taxType == "percentage"
        ? "${tax.taxAmount}% ${'Discount'.tr}"
        : "\$${tax.taxAmount} ${'Discount'.tr}";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              tax.taxName,
              style: pMedium16.copyWith(color: itemTextColor, fontSize: 10.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amountText,
              style: pBold12.copyWith(color: itemTextColor, fontSize: 10.sp),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    height: 33.w,
                    width: 33.w,
                    decoration: BoxDecoration(
                      color: AppColor.themeGreenColor,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.edit, color: AppColor.cWhite, size: 16.sp),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    height: 33.w,
                    width: 33.w,
                    decoration: BoxDecoration(
                      color: AppColor.cRedText,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    alignment: Alignment.center,
                    child: assetSvdImageWidget(
                      image: DefaultImages.deleteIcn,
                      width: 18.w,
                      height: 18.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
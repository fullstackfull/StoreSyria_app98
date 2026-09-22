import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/wallet/wallet_controller.dart';
import '../../utils/colors.dart';
import '../../utils/images.dart';
import '../widget/icon_and_image.dart';
import 'balance_bottomsheet.dart';

Widget balanceCard({
  required bool isDark,
  required WalletController controller,
  required BuildContext context,
}) {
  String balance =  controller.availableBalance.value;
  return Obx(() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.themeNavyBlueColor.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.themeNavyBlueColor,
            AppColor.themeNavyBlueColor,
            AppColor.themeGreenColor,
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color : AppColor.cBlack.withOpacity(0.2),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'current_balance'.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              assetSvdImageWidget(
                image: DefaultImages.walletImg,
                width: 27.w,
                height: 27.h,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: balance.isEmpty || balance == null ?
                CircularProgressIndicator(color: Colors.grey,strokeWidth: 2.w,) :
                Text(
                  controller.availableBalance.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  controller.currencySymbol.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          Row(
            children: [
              Expanded(
                child: cardButton(
                  label: 'withdraw'.tr,
                  filled: false,
                  onTap: () {
                    showBalanceSheet(
                        isAdd: false,
                        isDark: isDark,
                        context: context,
                        controller: controller);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: cardButton(
                  label: 'add_funds'.tr,
                  filled: true,
                  onTap: () {
                    showBalanceSheet(
                        isAdd: true,
                        isDark: isDark,
                        context: context,
                        controller: controller
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });
}

Widget cardButton({
  required String label,
  required bool filled,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 46.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled
              ? AppColor.themeGreenColor.withOpacity(0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: filled ? AppColor.themeNavyBlueColor : AppColor.cBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: filled
                    ? AppColor.themeNavyBlueColor
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

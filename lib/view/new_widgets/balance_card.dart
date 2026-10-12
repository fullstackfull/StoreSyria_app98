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
  return Obx(() {
    // R7-N3. `balance` used to be read HERE, outside the Obx builder, which
    // broke it twice over. GetX only registers an observable as a dependency
    // when it is read inside the builder, and a local captured outside the
    // closure is never re-evaluated when the closure re-runs -- so this was a
    // snapshot taken once, at widget-construction time, and frozen.
    final String balance = controller.availableBalance.value;

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
                // `balance == null` was dead: `balance` is a non-nullable
                // String, so the analyzer reported `unnecessary_null_comparison`.
                // The surviving `isEmpty` test never fired either, because
                // availableBalance is seeded with '0' (wallet_controller.dart:21),
                // which is not empty -- so the spinner was unreachable and a
                // merchant was shown a hard "0" balance while the wallet was
                // still loading. A zero balance the merchant does not actually
                // have is worse than a spinner, so the load state now drives it.
                child: controller.isLoading.value || balance.isEmpty ?
                CircularProgressIndicator(color: Colors.grey,strokeWidth: 2.w,) :
                Text(
                  balance,
                  style:  TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  controller.currencySymbol.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
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

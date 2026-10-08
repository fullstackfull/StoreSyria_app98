import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/controller/setting_controller/store_setting_controller.dart';
import '../../core/model/currency_model.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import '../widget/common_button.dart';

String formatExchangeRate(double rate) {
  if (rate == rate.roundToDouble()) {
    return rate.toInt().toString();
  }
  String str = rate.toStringAsFixed(4);
  while (str.contains('.') && (str.endsWith('0') || str.endsWith('.'))) {
    str = str.substring(0, str.length - 1);
  }
  return str;
}

Widget exchangeRatesSection({
  required StoreSettingController controller,
  required bool isDark,
  required BuildContext context,
}) {
  if (controller.isLoadingCurrencyRates.value && controller.currencyRates.isEmpty) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColor.themeGreenColor,
            ),
          ),
        ),
      ),
    );
  }

  if (controller.currencyRates.isEmpty) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Text(
          'no_exchange_rates_found'.tr,
          style: pRegular14.copyWith(
            color: isDark
                ? DarkThemeColor.cText.withOpacity(0.5)
                : AppColor.cDarkGreyFont,
          ),
        ),
      ),
    );
  }

  final String baseCode = controller.currentCurrency.value?.code ??
      (controller.defaultRatesCurrency.value.isNotEmpty
          ? controller.defaultRatesCurrency.value
          : 'USD');

  CurrencyRateItem? baseRateItem;
  for (final item in controller.currencyRates) {
    if (item.currencyCode.toUpperCase() == baseCode.toUpperCase()) {
      baseRateItem = item;
      break;
    }
  }

  final double baseRatePerUsd =
  (baseRateItem != null && baseRateItem.ratePerUsd > 0)
      ? baseRateItem.ratePerUsd
      : 1.0;

  final displayRates = controller.currencyRates
      .where((item) => item.currencyCode.toUpperCase() != baseCode.toUpperCase())
      .toList();

  if (displayRates.isEmpty) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Text(
          'no_exchange_rates_found'.tr,
          style: pRegular14.copyWith(
            color: isDark
                ? DarkThemeColor.cText.withOpacity(0.5)
                : AppColor.cDarkGreyFont,
          ),
        ),
      ),
    );
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: isDark
          ? DarkThemeColor.cCardBackground
          : AppColor.cBackGround,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark
            ? DarkThemeColor.cBorder.withOpacity(0.7)
            : Colors.transparent,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColor.themeGreenColor.withOpacity(
            isDark ? 0.07 : 0.12,
          ),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Column(
      children: List.generate(displayRates.length, (index) {
        final item = displayRates[index];
        final double displayRate = item.ratePerUsd / baseRatePerUsd;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == displayRates.length - 1 ? 0 : 6,
          ),
          child: exchangeRateItemCard(
            context: context,
            controller: controller,
            item: item,
            baseCode: baseCode,
            baseRatePerUsd: baseRatePerUsd,
            displayRate: displayRate,
            isDark: isDark,
          ),
        );
      }),
    ),
  );
}

Widget exchangeRateItemCard({
  required BuildContext context,
  required StoreSettingController controller,
  required CurrencyRateItem item,
  required String baseCode,
  required double baseRatePerUsd,
  required double displayRate,
  required bool isDark,
}) {
  return Material(
    color: Colors.transparent,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? (item.isActive ? Colors.transparent : Colors.black.withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? DarkThemeColor.cBorder.withOpacity(0.3)
              : AppColor.cBorder.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              width: 45.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: item.isActive
                    ? AppColor.themeGreenColor.withOpacity(0.1)
                    : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04)),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Center(
                child: Text(
                  item.symbol.isNotEmpty ? item.symbol : item.currencyCode,
                  style: pMedium14.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: item.isActive
                        ? AppColor.themeGreenColor
                        : (isDark
                        ? DarkThemeColor.cText.withOpacity(0.4)
                        : AppColor.cDarkGreyFont),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      baseCode,
                      style: pSemiBold14.copyWith(
                        color: isDark ? DarkThemeColor.cText : AppColor.cText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColor.themeGreenColor,
                      ),
                    ),
                    Text(
                      item.currencyCode,
                      style: pSemiBold14.copyWith(
                        color: isDark ? DarkThemeColor.cText : AppColor.cText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.currencyName,
                  style: pMedium10.copyWith(
                    color: isDark
                        ? DarkThemeColor.cText.withOpacity(0.5)
                        : AppColor.cDarkGreyFont,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '1 $baseCode = ${formatExchangeRate(displayRate)} ${item.symbol.isNotEmpty ? item.symbol : item.currencyCode}',
                  style: pMedium12.copyWith(
                    color: AppColor.themeGreenColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          InkWell(
            onTap: () {
              showEditExchangeRateSheet(
                context: context,
                controller: controller,
                item: item,
                baseCode: baseCode,
                baseRatePerUsd: baseRatePerUsd,
                currentDisplayRate: displayRate,
                isDark: isDark,
              );
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: AppColor.themeGreenColor.withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16.sp,
                color: AppColor.themeGreenColor,
              ),
            ),
          ),

          const SizedBox(width: 6),

          Obx(() {
            final isToggling = controller.togglingCurrencyCode.value == item.currencyCode;

            if (isToggling) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.themeGreenColor,
                    ),
                  ),
                ),
              );
            }

            return CupertinoSwitch(
              value: item.isActive,
              activeColor: AppColor.themeGreenColor,
              onChanged: (val) async {
                await controller.toggleCurrencyStatus(
                  currencyCode: item.currencyCode,
                  isActive: val,
                );
              },
            );
          }),
        ],
      ),
    ),
  );
}

void showEditExchangeRateSheet({
  required BuildContext context,
  required StoreSettingController controller,
  required CurrencyRateItem item,
  required String baseCode,
  required double baseRatePerUsd,
  required double currentDisplayRate,
  required bool isDark,
}) {
  final TextEditingController rateController = TextEditingController(
    text: formatExchangeRate(currentDisplayRate),
  );
  final formKey = GlobalKey<FormState>();

  final Color cardColor = isDark ? DarkThemeColor.cCardBackground : Colors.white;
  final Color surfaceColor = isDark ? const Color(0xFF213252) : const Color(0xFFF7F8FA);
  final Color primaryText = isDark ? DarkThemeColor.cText : AppColor.cText;
  final Color secondaryText = isDark ? const Color(0xFFA9B8D0) : const Color(0xFF777D87);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(22.r),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
        ),
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: AppColor.themeGreenColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Text(
                          item.symbol.isNotEmpty ? item.symbol : item.currencyCode,
                          style: pSemiBold16.copyWith(
                            color: AppColor.themeGreenColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'edit_exchange_rate'.tr,
                            style: pSemiBold16.copyWith(
                              color: primaryText,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '$baseCode → ${item.currencyCode} (${item.currencyName})',
                            style: pRegular12.copyWith(
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.sp,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColor.themeGreenColor.withOpacity(isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColor.themeGreenColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1 $baseCode =',
                        style: pMedium14.copyWith(color: primaryText),
                      ),
                      Text(
                        '${formatExchangeRate(currentDisplayRate)} ${item.symbol.isNotEmpty ? item.symbol : item.currencyCode}',
                        style: pSemiBold14.copyWith(color: AppColor.themeGreenColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'rate'.tr,
                  style: pMedium12.copyWith(color: primaryText),
                ),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  style: pMedium14.copyWith(color: primaryText),
                  decoration: InputDecoration(
                    hintText: 'enter_exchange_rate'.tr,
                    hintStyle: pRegular14.copyWith(color: secondaryText),
                    suffixText: item.symbol.isNotEmpty ? item.symbol : item.currencyCode,
                    suffixStyle: pMedium14.copyWith(color: AppColor.themeGreenColor),
                    filled: true,
                    fillColor: surfaceColor,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: isDark ? DarkThemeColor.cBorder : Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: isDark ? DarkThemeColor.cBorder : Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.themeGreenColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'enter_exchange_rate'.tr;
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'please_enter_valid_rate'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                Obx(() {
                  final bool isUpdating =
                      controller.updatingRateCurrencyCode.value == item.currencyCode;

                  return CommonButton(
                    title: 'save'.tr,
                    isLoading: isUpdating,
                    textColor: Colors.white,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final double newDisplayRate =
                      double.parse(rateController.text.trim());

                      final double newRatePerUsd = newDisplayRate * baseRatePerUsd;

                      final success = await controller.updateCurrencyRate(
                        currencyCode: item.currencyCode,
                        ratePerUsd: newRatePerUsd,
                      );

                      if (success && ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
  );
}
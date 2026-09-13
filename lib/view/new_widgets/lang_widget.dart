import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import '../../core/controller/setting_controller/store_setting_controller.dart';
import '../../core/model/currency_model.dart';
import '../../translations/translation_service.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import '../widget/common_button.dart';

Widget languageOption({
  required String title,
  required Image flag,
  required bool selected,
  required bool isDark,
  required VoidCallback onTap,
  bool isLoading = false,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.themeGreenColor.withOpacity(
            isDark ? 0.12 : 0.08,
          )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColor.themeGreenColor.withOpacity(
              isDark ? 0.35 : 0.30,
            )
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            flag,

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: pRegular14.copyWith(
                  color: selected
                      ? AppColor.themeGreenColor
                      : isDark
                      ? DarkThemeColor.cText
                      : AppColor.cText,
                ),
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (selected && !isLoading)
                    ? AppColor.themeGreenColor
                    : Colors.transparent,
                border: Border.all(
                  color: (selected && !isLoading)
                      ? AppColor.themeGreenColor
                      : isDark
                      ? Colors.white.withOpacity(0.25)
                      : AppColor.cFont.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: isLoading
                    ? Padding(
                  key: ValueKey('loading'),
                  padding: EdgeInsets.all(3),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.themeGreenColor,
                    ),
                  ),
                )
                    : selected
                    ? const Icon(
                  Icons.check,
                  key: ValueKey('checked'),
                  size: 15,
                  color: Colors.white,
                )
                    : const SizedBox.shrink(key: ValueKey('unchecked')),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget languageSelector({
  required bool isArabic,
  required bool isDark,
  required bool isLocalLanguage,
  required StoreSettingController controller,
  required VoidCallback onLanguageChanged,
}) {
  final String? selectedLanguageCode =
      controller.currentLanguage.value?.code;

  final bool isUpdatingEn =
      !isLocalLanguage &&
          controller.updatingLanguageCode.value == 'en';

  final bool isUpdatingAr =
      !isLocalLanguage &&
          controller.updatingLanguageCode.value == 'ar';

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
      children: [
        // ================= ENGLISH =================
        languageOption(
          title: 'english'.tr,
          flag: Image.asset(
            "assets/images/en.png",
            width: 22.w,
          ),

          // إذا Local Language نستخدم لغة التطبيق
          // إذا Store Language نستخدم اللغة القادمة من API
          selected: isLocalLanguage
              ? !isArabic
              : selectedLanguageCode == 'en',

          isDark: isDark,
          isLoading: isUpdatingEn,

          onTap: () async {
            if (isLocalLanguage) {
              if (isArabic) {
                TranslationService.changeLocale('en');
                onLanguageChanged();
              }
              return;
            }

            // Store language
            if (selectedLanguageCode == 'en') return;

            if (controller.updatingLanguageCode.value != null) {
              return;
            }

            controller.updatingLanguageCode.value = 'en';

            await controller.changeStoreLanguage(
              data: {
                "default_language": "English",
              },
            );

            onLanguageChanged();
          },
        ),

        const SizedBox(height: 6),

        // ================= ARABIC =================
        languageOption(
          title: 'arabic'.tr,
          flag: Image.asset(
            "assets/images/sy.png",
            width: 20.w,
          ),

          selected: isLocalLanguage
              ? isArabic
              : selectedLanguageCode == 'ar',

          isDark: isDark,
          isLoading: isUpdatingAr,

          onTap: () async {
            if (isLocalLanguage) {
              if (!isArabic) {
                TranslationService.changeLocale('ar');
                onLanguageChanged();
              }
              return;
            }

            // Store language
            if (selectedLanguageCode == 'ar') return;

            if (controller.updatingLanguageCode.value != null) {
              return;
            }

            controller.updatingLanguageCode.value = 'ar';

            await controller.changeStoreLanguage(
              data: {
                "default_language": "Arabic",
              },
            );

            onLanguageChanged();
          },
        ),
      ],
    ),
  );
}


Widget currencySelector({
  required StoreSettingController controller,
  required VoidCallback onCurrencyChanged,
  required bool isDark,
}) {
  if (controller.currencies.isEmpty) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Text(
          'no_currencies_found'.tr,
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
      children: List.generate(controller.currencies.length, (index) {
        final currency = controller.currencies[index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == controller.currencies.length - 1 ? 0 : 6,
          ),
          child: Obx(() {
            final bool isSelected =
                controller.currentCurrency.value?.code == currency.code;

            final bool isUpdating =
                controller.updatingCurrencyCode.value == currency.code;

            return currencyOption(
              title: currency.name,
              code: currency.code,
              symbol: currency.symbol,
              selected: isSelected,
              isLoading: isUpdating,
              isDark: isDark,
              onTap: () async {
                if (controller.updatingCurrencyCode.value != null) {
                  return;
                }

                if (controller.currentCurrency.value?.code == currency.code) {
                  return;
                }

                controller.updatingCurrencyCode.value = currency.code;

                await controller.changeStoreCurrency(
                  data: {
                    "defult_currancy": currency.code,
                    "defult_currancy_symbol": currency.symbol,
                    "site_currency_symbol_position": "pre",
                  },
                );

                onCurrencyChanged();
              },
            );
          }),
        );
      }),
    ),
  );
}

Widget currencyOption({
  required String title,
  required String code,
  required String symbol,
  required bool selected,
  required bool isDark,
  required VoidCallback onTap,
  bool isLoading = false,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.themeGreenColor.withOpacity(
                  isDark ? 0.12 : 0.08,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColor.themeGreenColor.withOpacity(
                    isDark ? 0.45 : 0.35,
                  )
                : isDark
                    ? DarkThemeColor.cBorder.withOpacity(0.3)
                    : AppColor.cBorder.withOpacity(0.4),
            width: selected ? 1.5 : 1.0,
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
                  color: selected
                      ? AppColor.themeGreenColor.withOpacity(0.12)
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.04)),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Center(
                  child: Text(
                    symbol.isNotEmpty ? symbol : code,
                    style: pMedium14.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? AppColor.themeGreenColor
                          : (isDark
                              ? DarkThemeColor.cText
                              : AppColor.cText),
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
                  Text(
                    code,
                    style: pSemiBold14.copyWith(
                      color: selected
                          ? AppColor.themeGreenColor
                          : (isDark ? DarkThemeColor.cText : AppColor.cText),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    title,
                    style: pMedium10.copyWith(
                      color: isDark
                          ? DarkThemeColor.cText.withOpacity(0.5)
                          : AppColor.cDarkGreyFont,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (selected && !isLoading)
                    ? AppColor.themeGreenColor
                    : Colors.transparent,
                border: Border.all(
                  color: (selected && !isLoading)
                      ? AppColor.themeGreenColor
                      : isDark
                          ? Colors.white.withOpacity(0.25)
                          : AppColor.cFont.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: isLoading
                    ? Padding(
                        key: const ValueKey('loading'),
                        padding: const EdgeInsets.all(3),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.themeGreenColor,
                          ),
                        ),
                      )
                    : selected
                        ? const Icon(
                            Icons.check,
                            key: ValueKey('checked'),
                            size: 15,
                            color: Colors.white,
                          )
                        : const SizedBox.shrink(key: ValueKey('unchecked')),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget mainCard({
  required String icon,
  required String title,
  required String value,
  required bool isExpanded,
  required bool isDark,
  required VoidCallback onTap,
}) {
  final Color cardColor = isDark
      ? DarkThemeColor.cCardBackground
      : AppColor.cBackGround;

  final Color primaryText = isDark
      ? DarkThemeColor.cText
      : AppColor.cText;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: isExpanded
                ? AppColor.themeGreenColor.withOpacity(
              isDark ? 0.40 : 0.30,
            )
                : isDark
                ? DarkThemeColor.cBorder.withOpacity(0.7)
                : Colors.transparent,
          ),

          boxShadow: [
            BoxShadow(
              color : AppColor.cBlack.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            assetSvdImageWidget(
              image: icon,
              width: 30.w,
              height: 30.h
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pRegular14.copyWith(
                      color: primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.themeGreenColor.withOpacity(
                        isDark ? 0.12 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      value,
                      style: pMedium10.copyWith(
                        color: isDark
                            ? AppColor.themeGreenColor
                            : AppColor.cLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                key: ValueKey(isExpanded),
                size: 26,
                color: isDark
                    ? Colors.white.withOpacity(0.45)
                    : AppColor.cFont.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

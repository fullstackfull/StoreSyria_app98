import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import '../../../translations/translation_service.dart';
import '../../new_widgets/lang_widget.dart';
import '../../widget/common_appbar_widget.dart';

class LanguageCurrenciesScreen extends StatefulWidget {
  const LanguageCurrenciesScreen({super.key});

  @override
  State<LanguageCurrenciesScreen> createState() =>
      _LanguageCurrenciesScreenState();
}

class _LanguageCurrenciesScreenState
    extends State<LanguageCurrenciesScreen> {
  bool isLanguageExpanded = false;
  bool isCurrencyExpanded = false;

  String selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        TranslationService.currentLocale.languageCode == 'ar';

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection:
      isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColor.cBackGround,
        appBar: simpleAppBar(
          title: 'language_and_currency'.tr,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              30,
            ),
            child: Column(
              children: [

                mainCard(
                  icon: Icons.language_rounded,
                  title: 'languages'.tr,
                  value: isArabic
                      ? 'arabic'.tr
                      : 'english'.tr,
                  isExpanded: isLanguageExpanded,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      isLanguageExpanded =
                      !isLanguageExpanded;

                      if (isLanguageExpanded) {
                        isCurrencyExpanded = false;
                      }
                    });
                  },
                ),

                AnimatedSize(
                  duration:
                  const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isLanguageExpanded
                      ? Padding(
                    padding:
                    const EdgeInsets.only(top: 12),
                    child: languageSelector(
                      isArabic: isArabic,
                      isDark: isDark,
                      onLanguageChanged: () {
                        setState(() {
                          isLanguageExpanded = false;
                        });
                      },
                    ),
                  )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 18),

                mainCard(
                  icon: Icons.payments_outlined,
                  title: 'currencies'.tr,
                  value: selectedCurrency == 'USD'
                      ? '\$ USD'
                      : 'ل.س SYP',
                  isExpanded: isCurrencyExpanded,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      isCurrencyExpanded =
                      !isCurrencyExpanded;

                      if (isCurrencyExpanded) {
                        isLanguageExpanded = false;
                      }
                    });
                  },
                ),

                AnimatedSize(
                  duration:
                  const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isCurrencyExpanded
                      ? Padding(
                    padding:
                    const EdgeInsets.only(top: 12),
                    child: _currencySelector(
                      isDark: isDark,
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _currencySelector({
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColor.cBackGround,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColor.cFont.withOpacity(0.06)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.themeGreenColor.withOpacity(
              isDark ? 0.10 : 0.2,
            ),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _currencyOption(
            title: 'us_dollar'.tr,
            code: 'USD',
            symbol: '\$',
            selected: selectedCurrency == 'USD',
            isDark: isDark,
            onTap: () {
              setState(() {
                selectedCurrency = 'USD';
                isCurrencyExpanded = false;
              });
            },
          ),

          const SizedBox(height: 6),

          _currencyOption(
            title: 'syrian_pound'.tr,
            code: 'SYP',
            symbol: 'ل.س',
            selected: selectedCurrency == 'SYP',
            isDark: isDark,
            onTap: () {
              setState(() {
                selectedCurrency = 'SYP';
                isCurrencyExpanded = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _currencyOption({
    required String title,
    required String code,
    required String symbol,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 200),
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColor.cLabel.withOpacity(0.08)
                : isDark
                ? AppColor.cFont.withOpacity(0.025)
                : Colors.transparent,
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColor.cLabel
                  .withOpacity(0.30)
                  : isDark
                  ? AppColor.cFont
                  .withOpacity(0.05)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColor.cLabel
                      .withOpacity(0.08)
                      : isDark
                      ? AppColor.cFont
                      .withOpacity(0.05)
                      : Colors.white,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Text(
                  symbol,
                  style: pMedium14.copyWith(
                    color: selected
                        ? AppColor.cLabel
                        : AppColor.cFont,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pRegular14.copyWith(
                        color: AppColor.cFont,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      code,
                      style: pMedium10.copyWith(
                        color: AppColor
                            .cDarkGreyFont,
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedContainer(
                duration:
                const Duration(milliseconds: 200),
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColor.cLabel
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? AppColor.cLabel
                        : AppColor.cFont
                        .withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                  Icons.check,
                  size: 15,
                  color: Colors.white,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
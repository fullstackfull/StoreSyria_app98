import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import '../../../core/controller/setting_controller/store_setting_controller.dart';
import '../../../translations/translation_service.dart';
import '../../new_widgets/exchange_currency_widget.dart';
import '../../new_widgets/lang_widget.dart';
import '../../widget/common_appbar_widget.dart';

class LanguageCurrenciesScreen extends StatefulWidget {
  const LanguageCurrenciesScreen({super.key});

  @override
  State<LanguageCurrenciesScreen> createState() =>
      _LanguageCurrenciesScreenState();
}

class _LanguageCurrenciesScreenState extends State<LanguageCurrenciesScreen> {
  final StoreSettingController controller = Get.find<StoreSettingController>();
  bool isLanguageExpanded = false;
  bool isCurrencyExpanded = false;
  bool isExchangeRatesExpanded = false;

  @override
  void initState() {
    super.initState();
    controller.getCurrenciesData();
    controller.getStoreCurrencyLangData();
    controller.getCurrencyRatesData();
  }

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
            title: 'store_language_and_currency'.tr,
            label: null,
            onNewLabelTap: () {  },
            isBack: true
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
            child: Column(
              children: [
                Obx(
                      () => mainCard(
                    icon: DefaultImages.language2Icn,
                    title: 'languages'.tr,

                    value: _getLocalizedLanguageName(),

                    isExpanded: isLanguageExpanded,
                    isDark: isDark,

                    onTap: () {
                      setState(() {
                        isLanguageExpanded = !isLanguageExpanded;

                        if (isLanguageExpanded) {
                          isCurrencyExpanded = false;
                          isExchangeRatesExpanded = false;
                        }
                      });

                      if (controller.currentLanguage.value == null) {
                        controller.getStoreCurrencyLangData();
                      }
                    },
                  ),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isLanguageExpanded
                      ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Obx(() => languageSelector(
                      isArabic: isArabic,
                      isDark: isDark,
                      isLocalLanguage: false,
                      controller: controller,
                      onLanguageChanged: () {},
                    )),
                  )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 18),

                Obx(() =>
                    mainCard(
                      icon: DefaultImages.currencyIcn,
                      title: 'currencies'.tr,
                      value: _selectedCurrencyText(),
                      isExpanded: isCurrencyExpanded,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          isCurrencyExpanded = !isCurrencyExpanded;
                          if (isCurrencyExpanded) {
                            isLanguageExpanded = false;
                            isExchangeRatesExpanded = false;
                          }
                        });

                        if (isCurrencyExpanded && controller.currencies.isEmpty) {
                          controller.getCurrenciesData();
                        }
                      },
                    ),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 10),
                  curve: Curves.easeInOut,
                  child: isCurrencyExpanded
                      ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: currencySelector(
                      onCurrencyChanged: () {},
                      controller: controller,
                      isDark: isDark,
                    ))
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 18),

                Obx(() =>
                    mainCard(
                      icon: DefaultImages.currencyExIcn,
                      title: 'exchange_rates'.tr,
                      value: _exchangeRatesSummaryText(),
                      isExpanded: isExchangeRatesExpanded,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          isExchangeRatesExpanded = !isExchangeRatesExpanded;
                          if (isExchangeRatesExpanded) {
                            isLanguageExpanded = false;
                            isCurrencyExpanded = false;
                          }
                        });

                        if (isExchangeRatesExpanded && controller.currencyRates.isEmpty) {
                          controller.getCurrencyRatesData();
                        }
                      },
                    ),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isExchangeRatesExpanded
                      ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Obx(() => exchangeRatesSection(
                      controller: controller,
                      isDark: isDark,
                      context: context,
                    )),
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

  String _exchangeRatesSummaryText() {
    if (controller.isLoadingCurrencyRates.value) {
      return '...';
    }
    if (controller.currencyRates.isEmpty) {
      return '---';
    }
    final active = controller.currencyRates.where((r) => r.isActive).length;
    final total = controller.currencyRates.length;
    return '$active / $total';
  }

  String _selectedCurrencyText() {
    final currency = controller.currentCurrency.value;

    if (currency == null) {
      return '---';
    }

    return '${currency.symbol} ${currency.code}';
  }

  String _getLocalizedLanguageName() {
    final code = controller.currentLanguage.value?.name;

    if (code == null) return '---';

    switch (code) {
      case 'Arabic':
        return 'arabic'.tr;
      case 'English':
        return 'english'.tr;
      default:
        return controller.currentLanguage.value?.name ?? '---';
    }
  }
}

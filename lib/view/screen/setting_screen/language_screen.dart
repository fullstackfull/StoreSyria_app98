import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import '../../../core/controller/setting_controller/store_setting_controller.dart';
import '../../../translations/translation_service.dart';
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

  @override
  void initState() {
    super.initState();
    controller.getCurrenciesData();
    controller.getStoreCurrencyLangData();
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
            title: 'language_and_currency'.tr,
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
                    icon: Icons.language_rounded,
                    title: 'languages'.tr,

                    value: _getLocalizedLanguageName(),

                    isExpanded: isLanguageExpanded,
                    isDark: isDark,

                    onTap: () {
                      setState(() {
                        isLanguageExpanded = !isLanguageExpanded;

                        if (isLanguageExpanded) {
                          isCurrencyExpanded = false;
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
                      onLanguageChanged: () {
                        setState(() {
                          isLanguageExpanded = false;
                        });
                      },
                    )),
                  )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 18),

                Obx(() =>
                    mainCard(
                      icon: Icons.payments_outlined,
                      title: 'currencies'.tr,
                      value: _selectedCurrencyText(),
                      isExpanded: isCurrencyExpanded,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          isCurrencyExpanded = !isCurrencyExpanded;
                          if (isCurrencyExpanded) {
                            isLanguageExpanded = false;
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
                      onCurrencyChanged: () {
                        setState(() {
                          isCurrencyExpanded = false;
                        });
                      },
                      controller: controller,
                      isDark: isDark,
                    ))
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
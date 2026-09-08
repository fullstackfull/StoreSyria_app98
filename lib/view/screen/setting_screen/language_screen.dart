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
                mainCard(
                  icon: Icons.language_rounded,
                  title: 'languages'.tr,
                  value: isArabic ? 'arabic'.tr : 'english'.tr,
                  isExpanded: isLanguageExpanded,
                  isDark: isDark,
                  onTap: () {
                    setState(() {
                      isLanguageExpanded = !isLanguageExpanded;
                      if (isLanguageExpanded) {
                        isCurrencyExpanded = false;
                      }
                    });
                  },
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
    return controller.currentCurrency.value != null
        ? '${controller.currentCurrency.value!.symbol} ${controller.currentCurrency.value!.code}'
        : 'USD';
  }
}
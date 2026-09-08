import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../config/repository/store_settings_repository.dart';
import '../../model/currency_model.dart';
import '../../model/language_model.dart';
import '../../model/store_info_model.dart';

class StoreSettingController extends GetxController {
  StoreSettingRepository settingRepository = StoreSettingRepository();
  final GetStorage _box = GetStorage();

  static const String _currenciesCacheKey = 'cached_currencies';
  static const String _currentCurrencyCacheKey = 'cached_current_currency';
  static const String _currenciesCacheTimeKey = 'cached_currencies_time';
  static const Duration _cacheDuration = Duration(hours: 24);

  RxBool isLoading = false.obs;
  RxBool isLoadingLanguages = false.obs;
  RxBool isLoadingCurrencies = false.obs;

  RxString errorMessage = ''.obs;

  RxList<Currency> currencies = <Currency>[].obs;
  RxList<Language> languages = <Language>[].obs;
  RxnString updatingCurrencyCode = RxnString();
  RxnString updatingLanguageCode = RxnString();
  Rxn<Currency> currentCurrency = Rxn<Currency>();

  RxString currentLanguage = ''.obs;

  // ==================== Store Info (عدّل هذا) ====================
  Rxn<StoreInfoData> storeInfoData = Rxn<StoreInfoData>();

// ==================== Store Controllers ====================

  final TextEditingController storeNameController = TextEditingController();

  final TextEditingController storeUrlController = TextEditingController();

  final TextEditingController storeEmailController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final TextEditingController stateController = TextEditingController();

  final TextEditingController zipcodeController = TextEditingController();

  final TextEditingController countryController = TextEditingController();

  final TextEditingController facebookController = TextEditingController();

  final TextEditingController twitterController = TextEditingController();

  final TextEditingController instagramController = TextEditingController();


// ==================== Owner ====================

  final TextEditingController ownerNameController = TextEditingController();

  final TextEditingController ownerEmailController = TextEditingController();



// ==================== Store Extra ====================

  final TextEditingController storeIdController = TextEditingController();

  final TextEditingController slugController = TextEditingController();

  final TextEditingController defaultLanguageController = TextEditingController();

  final TextEditingController storeCreatedAtController = TextEditingController();


// ==================== Address Extra ====================

  final TextEditingController fullAddressController = TextEditingController();


// ==================== Media ====================

  final TextEditingController invoiceLogoController = TextEditingController();

  final TextEditingController storeImageController = TextEditingController();


// ==================== Settings ====================

  final TextEditingController currencyNameController = TextEditingController();

  final TextEditingController currencyFormatController = TextEditingController();

  final TextEditingController siteRtlController = TextEditingController();

  final TextEditingController dateFormatController = TextEditingController();

  final TextEditingController timezoneController = TextEditingController();


// ==================== Social ====================

  final TextEditingController whatsappController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadFromCacheIfValid();
    if (currencies.isEmpty) {
      getCurrenciesData();
    }
  }

  @override
  void onClose() {
    storeIdController.dispose();
    slugController.dispose();
    defaultLanguageController.dispose();
    storeCreatedAtController.dispose();

    ownerNameController.dispose();
    ownerEmailController.dispose();

    fullAddressController.dispose();

    invoiceLogoController.dispose();
    storeImageController.dispose();

    currencyNameController.dispose();
    currencyFormatController.dispose();
    siteRtlController.dispose();
    dateFormatController.dispose();
    timezoneController.dispose();

    whatsappController.dispose();
    super.onClose();
  }

  // ==================== Get Store Info ====================

  Future<void> getStoreInfoData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await settingRepository.getStoreInfoData();

      response.fold(
        onSuccess: (data) {
          print("Store Info Response =====> $data");

          final status = data['status'];

          if (status == 'success' || status == 1) {
            storeInfoData.value = StoreInfoData.fromJson(data['data']);

            _fillControllers();

            print(
              "Store Name =====> ${storeInfoData.value?.store?.name}",
            );
          } else {
            commonToast(
              data['message'] ?? 'Failed to get store information',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error getting store information';

          commonToast(
            message ?? 'Error getting store information',
          );
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _fillControllers() {
    final d = storeInfoData.value;

    if (d == null) return;

    // =========================
    // Store
    // =========================
    storeIdController.text =
        d.store?.id?.toString() ?? '';

    storeNameController.text = d.store?.name ?? '';

    slugController.text = d.store?.slug ?? '';

    storeEmailController.text =
        d.store?.email ?? '';

    defaultLanguageController.text =
        d.store?.defaultLanguage ?? '';

    storeUrlController.text =
        d.store?.storeUrl ?? '';

    ownerNameController.text =
        d.owner?.name ?? '';

    ownerEmailController.text =
        d.owner?.email ?? '';

    mobileController.text =
        d.owner?.mobile ?? '';

    storeCreatedAtController.text =
        d.store?.createdAt?.split(' ').first ?? '';


    // =========================
    // Address
    // =========================
    addressController.text =
        d.address?.storeAddress ?? '';

    cityController.text =
        d.address?.storeCity ?? '';

    stateController.text =
        d.address?.storeState ?? '';

    zipcodeController.text =
        d.address?.storeZipcode ?? '';

    countryController.text =
        d.address?.storeCountry ?? '';

    fullAddressController.text =
        d.address?.fullAddress ?? '';

    // =========================
    // Social Media
    // =========================
    facebookController.text =
        d.socialMedia?.facebook?.link ?? '';

    twitterController.text =
        d.socialMedia?.twitter?.link ?? '';

    instagramController.text =
        d.socialMedia?.instagram?.link ?? '';

    whatsappController.text =
        d.socialMedia?.whatsapp?.link ?? '';

    // =========================
    // Media
    // =========================
    invoiceLogoController.text =
        d.media?.invoiceLogo ?? '';

    storeImageController.text =
        d.media?.storeImage ?? '';

    // =========================
    // Settings
    // =========================
    currencyNameController.text =
        d.settings?.currencyName ?? '';

    currencyFormatController.text =
        d.settings?.currencyFormat ?? '';

    siteRtlController.text =
        d.settings?.siteRtl ?? '';

    dateFormatController.text =
        d.settings?.dateFormat ?? '';

    timezoneController.text =
        d.settings?.timezone ?? '';
  }


  // TODO: لاحقاً - updateStoreInfoData() لما تجهز الـ endpoint
  Future<void> changeStoreLanguage({
    required Map<String, dynamic> data,
  }) async {
    isLoadingLanguages.value = true;
    errorMessage.value = '';

    try {
      final response = await settingRepository.changeStoreLanguage(
        data: data,
      );

      response.fold(
        onSuccess: (data) {
          print("Change Language Response =====> $data");

          if (data['status'] == 1) {
            commonToast(
              data['message'] ?? 'Language changed successfully',
            );

            if (data['data'] != null &&
                data['data']['current_language'] != null) {
              currentLanguage.value =
                  data['data']['current_language'].toString();
            } else if (data['lang'] != null) {
              currentLanguage.value =
                  data['lang'].toString();
            }

            print(
              "Current Language =====> ${currentLanguage.value}",
            );
          } else {
            commonToast(
              data['message'] ?? 'Failed to change language',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error changing language';

          commonToast(
            message ?? 'Error changing language',
          );
        },
      );
    } finally {
      isLoadingLanguages.value = false;
      updatingLanguageCode.value = null;
    }
  }

  Future<void> changeStoreCurrency({
    required Map<String, dynamic> data,
  }) async {
    isLoadingCurrencies.value = true;
    errorMessage.value = '';

    try {
      final response = await settingRepository.changeStoreCurrency(
        data: data,
      );

      response.fold(
        onSuccess: (data) {
          print("Change Currency Response =====> $data");

          if (data['status'] == 1) {
            commonToast(
              data['message'] ?? 'Currency changed successfully',
            );

            if (data['data'] != null &&
                data['data']['current_currency'] != null) {
              currentCurrency.value = Currency.fromJson(
                data['data']['current_currency'],
              );
            }

            print(
              "Current Currency =====> ${currentCurrency.value?.code}",
            );
          } else {
            commonToast(
              data['message'] ?? 'Failed to change currency',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error changing currency';

          commonToast(
            message ?? 'Error changing currency',
          );
        },
      );
    } finally {
      isLoadingCurrencies.value = false;
      updatingCurrencyCode.value = null;
    }
  }

  Future<void> getLanguagesData() async {
    isLoadingLanguages.value = true;

    try {
      final response =
      await settingRepository.getLanguagesData();

      response.fold(
        onSuccess: (data) {
          print("Languages Response =====> $data");

          if (data['status'] == 1) {
            final languageResponse =
            LanguageResponse.fromJson(data);

            languages.assignAll(
              languageResponse.data.languages,
            );

            currentLanguage.value =
                languageResponse.data.currentLanguage;

            print(
              "Languages Length =====> ${languages.length}",
            );

            print(
              "Current Language =====> ${currentLanguage.value}",
            );
          } else {
            commonToast(
              data['message'] ?? 'Failed to get languages',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error getting languages';

          commonToast(
            message ?? 'Error getting languages',
          );
        },
      );
    } finally {
      isLoadingLanguages.value = false;
    }
  }

  bool _isCacheValid() {
    final cachedTime = _box.read(_currenciesCacheTimeKey);
    if (cachedTime == null) return false;

    final cachedDateTime = DateTime.tryParse(cachedTime.toString());
    if (cachedDateTime == null) return false;

    return DateTime.now().difference(cachedDateTime) < _cacheDuration;
  }

  void _loadFromCacheIfValid() {
    if (!_isCacheValid()) {
      _box.remove(_currenciesCacheKey);
      _box.remove(_currentCurrencyCacheKey);
      _box.remove(_currenciesCacheTimeKey);
      return;
    }

    final cachedList = _box.read(_currenciesCacheKey);
    final cachedCurrent = _box.read(_currentCurrencyCacheKey);

    if (cachedList != null) {
      try {
        final decoded = jsonDecode(cachedList) as List;
        currencies.assignAll(
          decoded.map((e) => Currency.fromJson(e)).toList(),
        );
        print("✅ Loaded ${currencies.length} currencies from cache");
      } catch (e) {
        print("Error decoding cached currencies: $e");
      }
    }

    if (cachedCurrent != null) {
      try {
        currentCurrency.value =
            Currency.fromJson(jsonDecode(cachedCurrent));
      } catch (e) {
        print("Error decoding cached current currency: $e");
      }
    }
  }

  void _saveToCache(List<Currency> list, Currency? current) {
    _box.write(
      _currenciesCacheKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    if (current != null) {
      _box.write(_currentCurrencyCacheKey, jsonEncode(current.toJson()));
    }
    _box.write(_currenciesCacheTimeKey, DateTime.now().toIso8601String());
  }


  Future<void> getCurrenciesData({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && currencies.isNotEmpty) {
      print("📦 Using cached currencies (still valid < 24h)");
      return;
    }

    isLoadingCurrencies.value = true;

    try {
      final response = await settingRepository.getCurrenciesData();

      response.fold(
        onSuccess: (data) {
          print("Currencies Response =====> $data");

          if (data['status'] == 1) {
            final currencyResponse = CurrencyResponse.fromJson(data);

            currencies.assignAll(currencyResponse.data.currencies);
            currentCurrency.value = currencyResponse.data.currentCurrency;

            _saveToCache(
              currencyResponse.data.currencies,
              currencyResponse.data.currentCurrency,
            );

            print("Currencies Length =====> ${currencies.length}");
          } else {
            commonToast(data['message'] ?? 'Failed to get currencies');
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value = message ?? 'Error getting currencies';
          commonToast(message ?? 'Error getting currencies');
        },
      );
    } finally {
      isLoadingCurrencies.value = false;
    }
  }

  Future<void> deleteStoreData() async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await settingRepository.deleteStoreData();

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          commonToast(data['data']['message'] ?? 'Success');

          print(
            "StoreID----->${data['data']['user_info']['current_store']}",
          );

          Prefs.setStoreID(
            data['data']['user_info']['current_store'].toString(),
          );

          print(
            "StoreID----->--${Prefs.getStoreID()}",
          );
        } else {
          commonToast(data['data']['message'] ?? 'Failed');
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value =
            message ?? 'Error deleting store';

        commonToast(
          message ?? 'Error deleting store',
        );
      },
    );
  }
}
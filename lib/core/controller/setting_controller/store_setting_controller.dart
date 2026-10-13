import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/prefer.dart';
import '../home_controller/cahe.dart';
import '../home_controller/store_change_service.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../config/repository/store_settings_repository.dart';
import '../../../utils/pick_file.dart';
import '../../model/currency_model.dart';
import '../../model/language_model.dart';
import '../../model/store_info_model.dart';
import 'package:store_go_app/utils/app_log.dart';

/// NEW-CURRENCY-CACHE-CROSS-STORE.
///
/// This controller cached STORE-SCOPED data in a container of its own and was
/// never told when the store changed, so a merchant who switched stores kept
/// seeing the previous store's currency list and, worse, its CURRENT
/// CURRENCY -- the symbol and format every price on the screen is rendered
/// with -- for up to 24 hours.
///
/// It was not a brief flash before the real data landed, either.
/// getCurrenciesData() returns early while the cache is valid, so the correct
/// data was deliberately not requested:
///
///   if (!forceRefresh && _isCacheValid() && currencies.isNotEmpty) return;
///
/// The server leaves no doubt that this is tenant data: getCurrenciesApi
/// requires store_id and checks `->where('created_by', $user->id)` before it
/// answers (repo A Api/DashboardController::getCurrenciesApi, 6985-7010). So
/// the app was displaying one tenant's money format under another tenant's
/// name, decided entirely on the device, where no server-side scope can
/// reach.
///
/// Two things were wrong and both are fixed here:
///
///   1. It was not StoreAware. Eight controllers already implement that
///      interface, register with StoreChangeService in onInit and clear their
///      cache in resetForStoreChange; this one did not, so
///      notifyStoreChanged() (home_controller.dart:149) never reached it.
///
///   2. It persisted through its OWN `GetStorage()` handle rather than
///      CacheService. `GetStorage()` with no container name returns the SAME
///      default container Prefs and CacheService use, so nothing was isolated
///      by it -- it only put these three keys outside the one mechanism an
///      audit of the cache would look at. They now go through it,
///      which also means they pick up its `cache_` prefix. Existing installs
///      therefore miss once and refetch, which is the desired outcome anyway:
///      whatever is cached under the old keys may belong to the wrong store.
class StoreSettingController extends GetxController implements StoreAware {
  StoreSettingRepository settingRepository = StoreSettingRepository();
  static const String _currenciesCacheKey = 'cached_currencies';
  static const String _currentCurrencyCacheKey = 'cached_current_currency';
  static const String _currenciesCacheTimeKey = 'cached_currencies_time';
  static const Duration _cacheDuration = Duration(hours: 24);
  RxBool isLoading = false.obs;
  RxBool isLoadingLanguages = false.obs;
  RxBool isUpLoading = false.obs;
  RxBool isLoadingCurrencies = false.obs;
  RxString errorMessage = ''.obs;
  RxString selectedInvoiceLogo = ''.obs;
  RxString selectedStoreImage = ''.obs;
  RxList<Currency> currencies = <Currency>[].obs;
  RxList<Language> languages = <Language>[].obs;
  RxnString updatingCurrencyCode = RxnString();
  RxnString updatingLanguageCode = RxnString();
  Rxn<Currency> currentCurrency = Rxn<Currency>();
  Rxn<Language> currentLanguage = Rxn<Language>();
  // ==================== Exchange Rates State ====================
  RxBool isLoadingCurrencyRates = false.obs;
  RxnString updatingRateCurrencyCode = RxnString();
  RxnString togglingCurrencyCode = RxnString();
  RxList<CurrencyRateItem> currencyRates = <CurrencyRateItem>[].obs;
  RxString defaultRatesCurrency = ''.obs;

  Rxn<StoreInfoData> storeInfoData = Rxn<StoreInfoData>();

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
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerEmailController = TextEditingController();
  final TextEditingController storeIdController = TextEditingController();
  final TextEditingController slugController = TextEditingController();
  final TextEditingController defaultLanguageController = TextEditingController();
  final TextEditingController storeCreatedAtController = TextEditingController();
  final TextEditingController fullAddressController = TextEditingController();
  final TextEditingController invoiceLogoController = TextEditingController();
  final TextEditingController storeImageController = TextEditingController();
  final TextEditingController currencyNameController = TextEditingController();
  final TextEditingController currencyFormatController = TextEditingController();
  final TextEditingController siteRtlController = TextEditingController();
  final TextEditingController dateFormatController = TextEditingController();
  final TextEditingController timezoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController telegramController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadFromCacheIfValid();
    if (currencies.isEmpty) {
      getCurrenciesData();
    }

    // Registered the same way the other eight store-scoped controllers are:
    // a closure, so the service always reaches the live instance even if this
    // one is disposed and recreated in between.
    StoreChangeService.instance.register(() => this);
  }

  /// Called by StoreChangeService once a store change has SUCCEEDED.
  ///
  /// Clears the in-memory state and the persisted copy, then refetches with
  /// forceRefresh so the 24-hour validity window cannot suppress the new
  /// store's currencies -- without the flag this method would clear the cache
  /// and then immediately be short-circuited by a stale timestamp if one
  /// survived.
  @override
  void resetForStoreChange() {
    currencies.clear();
    currentCurrency.value = null;
    currentLanguage.value = null;
    languages.clear();
    currencyRates.clear();
    defaultRatesCurrency.value = '';
    storeInfoData.value = null;

    _clearCurrencyCache();

    getCurrenciesData(forceRefresh: true);
  }

  void _clearCurrencyCache() {
    CacheService.clear(_currenciesCacheKey);
    CacheService.clear(_currentCurrencyCacheKey);
    CacheService.clear(_currenciesCacheTimeKey);
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

    currencyNameController.dispose();
    currencyFormatController.dispose();
    siteRtlController.dispose();
    dateFormatController.dispose();
    timezoneController.dispose();

    whatsappController.dispose();
    telegramController.dispose();
    super.onClose();
  }

  Future<void> pickInvoiceLogo() async {
    final path = await FileHelper.pickImage();

    if (path != null) {
      selectedInvoiceLogo.value = path;
    }
  }

  Future<void> pickStoreImage() async {
    final path = await FileHelper.pickImage();

    if (path != null) {
      selectedStoreImage.value = path;
    }
  }

  // ==================== Get Store Info ====================

  Future<void> getStoreInfoData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await settingRepository.getStoreInfoData();

      response.fold(
        onSuccess: (data) {
          AppLog.d("Store Info Response =====> $data");

          final status = data['status'];

          if (status == 'success' || status == 1) {
            storeInfoData.value = StoreInfoData.fromJson(jsonMap(data['data']));

            _fillControllers();

            AppLog.d(
              "Store Name =====> ${storeInfoData.value?.store?.name}",
            );
          } else {
            commonToast(type: AppSnackBarType.error, 
              data['message'] ?? 'Failed to get store information',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error getting store information';

          commonToast(type: AppSnackBarType.error, 
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

    ownerNameController.text = d.owner?.name ?? '';

    ownerEmailController.text = d.owner?.email ?? '';

    mobileController.text = d.owner?.mobile ?? '';

    storeCreatedAtController.text = d.store?.createdAt?.split(' ').first ?? '';


    // =========================
    // Address
    // =========================
    addressController.text = d.address?.storeAddress ?? '';

    cityController.text = d.address?.storeCity ?? '';

    stateController.text = d.address?.storeState ?? '';

    zipcodeController.text = d.address?.storeZipcode ?? '';

    countryController.text = d.address?.storeCountry ?? '';

    fullAddressController.text = d.address?.fullAddress ?? '';

    // =========================
    // Social Media
    // =========================
    facebookController.text = d.socialMedia?.facebook?.link ?? '';

    twitterController.text = d.socialMedia?.twitter?.link ?? '';

    instagramController.text = d.socialMedia?.instagram?.link ?? '';

    whatsappController.text = d.socialMedia?.whatsapp?.link ?? '';

    telegramController.text = d.socialMedia?.telegram?.link ?? '';

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
    currencyNameController.text = d.settings?.currencyName ?? '';

    currencyFormatController.text = d.settings?.currencyFormat ?? '';

    siteRtlController.text = d.settings?.siteRtl ?? '';

    dateFormatController.text = d.settings?.dateFormat ?? '';

    timezoneController.text = d.settings?.timezone ?? '';
  }


  Future<void> updateStoreInfo() async {
    isUpLoading.value = true;
    errorMessage.value = '';

    try {
      final request = UpdateStoreRequest(
        storeName: storeNameController.text.trim(),
        storeEmail: storeEmailController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        storeSlug: slugController.text.trim(),
        ownerMobile: mobileController.text.trim(),
        storeAddress: addressController.text.trim(),
        storeCity: cityController.text.trim(),
        storeState: stateController.text.trim(),
        storeZipcode: zipcodeController.text.trim(),
        storeCountry: countryController.text.trim(),
        customStoreUrl: storeUrlController.text.trim(),

        invoiceLogo: selectedInvoiceLogo.value,
        storeImage: selectedStoreImage.value,

        socialMedia: [
          if (facebookController.text.trim().isNotEmpty)
            SocialMediaRequest(
              platform: 'facebook',
              link: facebookController.text.trim(),
              icon: 'fab fa-facebook-f',
            ),

          if (twitterController.text.trim().isNotEmpty)
            SocialMediaRequest(
              platform: 'twitter',
              link: twitterController.text.trim(),
              icon: 'fab fa-x-twitter',
            ),

          if (instagramController.text.trim().isNotEmpty)
            SocialMediaRequest(
              platform: 'instagram',
              link: instagramController.text.trim(),
              icon: 'fab fa-instagram',
            ),

          if (whatsappController.text.trim().isNotEmpty)
            SocialMediaRequest(
              platform: 'whatsapp',
              link: whatsappController.text.trim(),
              icon: 'fab fa-whatsapp',
            ),

          if (telegramController.text.trim().isNotEmpty)
            SocialMediaRequest(
              platform: 'telegram',
              link: telegramController.text.trim(),
              icon: 'fab fa-telegram',
            ),
        ],
      );

      final response =
      await settingRepository.updateStoreInfoData(
        request: request,
      );

      response.fold(
        onSuccess: (data) async {
          AppLog.d("Update Store Response =====> $data");

          if (data['status'] == 1 ||
              data['status'] == '1' ||
              data['status'] == 'success') {

            commonToast(type: AppSnackBarType.success, 
              data['message'] ??
                  'Store information updated successfully',
            );

            selectedInvoiceLogo.value = '';
            selectedStoreImage.value = '';

            await getStoreInfoData();
          } else {
            commonToast(type: AppSnackBarType.error, 
              data['message'] ??
                  'Failed to update store information',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value = message;

          commonToast(type: AppSnackBarType.error, message);
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();

      AppLog.d("Update Store Error =====> $e");

      commonToast(type: AppSnackBarType.error, 
        'Error updating store information',
      );
    } finally {
      isUpLoading.value = false;
    }
  }

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
          AppLog.d("Change Language Response =====> $data");

          if (data['status'] == 1) {
            commonToast(type: AppSnackBarType.success, 
              data['message'] ?? 'Language changed successfully',
            );

            final responseData = data['data'];

            if (responseData != null &&
                responseData['saved_language_code'] != null) {
              currentLanguage.value = Language(
                code: responseData['saved_language_code'],
                name: responseData['saved_language_name'] ??
                    responseData['saved_language_code'],
                flag: currentLanguage.value?.flag ?? '',
              );
            }

            AppLog.d(
              "Current Language =====> ${currentLanguage.value?.code}",
            );
          } else {
            commonToast(type: AppSnackBarType.error, 
              data['message'] ?? 'Failed to change language',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error changing language';

          commonToast(type: AppSnackBarType.error, 
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
          AppLog.d("Change Currency Response =====> $data");

          if (data['status'] == 1) {
            commonToast(type: AppSnackBarType.success, 
              data['message'] ?? 'Currency changed successfully',
            );

            final responseData = data['data'];

            if (responseData != null &&
                responseData['currency_name'] != null) {
              final String updatedCode = responseData['currency_name'];
              final String updatedSymbol =
                  responseData['currency_symbol'] ?? '';

              Currency? matched;
              for (final c in currencies) {
                if (c.code == updatedCode) {
                  matched = c;
                  break;
                }
              }

              if (matched != null) {
                currentCurrency.value = matched;
              } else {
                currentCurrency.value = Currency.fromJson({
                  'code': updatedCode,
                  'symbol': updatedSymbol,
                  'name': updatedCode,
                  'rate_per_usd': 1,
                  'is_active': true,
                });
              }
            }

            AppLog.d(
              "Current Currency =====> ${currentCurrency.value?.code}",
            );

            getCurrencyRatesData(forceRefresh: true);
          } else {
            commonToast(type: AppSnackBarType.error, 
              data['message'] ?? 'Failed to change currency',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error changing currency';

          commonToast(type: AppSnackBarType.error, 
            message ?? 'Error changing currency',
          );
        },
      );
    } finally {
      isLoadingCurrencies.value = false;
      updatingCurrencyCode.value = null;
    }
  }
  Future<void> getStoreCurrencyLangData() async {
    isLoadingLanguages.value = true;
    errorMessage.value = '';

    try {
      final response = await settingRepository.getStoreCurrencyLang();

      response.fold(
        onSuccess: (data) {
          AppLog.d("Languages & Currency Response =====> $data");

          if (data['status'] == 1) {
            // `data['data']` reaches a subscript through a LOCAL, which is
            // the one shape the two-adjacent-subscript ratchet in
            // test/controllers/no_unguarded_nested_subscript_test.dart cannot
            // see: `responseData['current_language']` throws on a
            // `{"status": 1}` or `{"data": []}` body exactly as
            // `data['data']['current_language']` would.
            final responseData = jsonMap(data['data']);

            if (responseData['current_language'] is Map) {
              currentLanguage.value = Language.fromJson(
                jsonMap(responseData['current_language']),
              );
            }
            if (responseData['current_currency'] is Map) {
              currentCurrency.value = Currency.fromJson(
                jsonMap(responseData['current_currency']),
              );
            }

          } else {
            commonToast(type: AppSnackBarType.error, 
              data['message'] ??
                  'Failed to get languages and currency',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error getting languages and currency';

          commonToast(type: AppSnackBarType.error, 
            message ?? 'Error getting languages and currency',
          );
        },
      );
    } finally {
      isLoadingLanguages.value = false;
    }
  }

  bool _isCacheValid() {
    final cachedTime = CacheService.get<String>(_currenciesCacheTimeKey);
    if (cachedTime == null) return false;

    final cachedDateTime = DateTime.tryParse(cachedTime.toString());
    if (cachedDateTime == null) return false;

    return DateTime.now().difference(cachedDateTime) < _cacheDuration;
  }

  void _loadFromCacheIfValid() {
    if (!_isCacheValid()) {
      _clearCurrencyCache();
      return;
    }

    final cachedList = CacheService.get<String>(_currenciesCacheKey);
    final cachedCurrent =
        CacheService.get<String>(_currentCurrencyCacheKey);

    if (cachedList != null) {
      try {
        final decoded = jsonDecode(cachedList) as List;
        currencies.assignAll(
          decoded.map((e) => Currency.fromJson(e)).toList(),
        );
        AppLog.d("✅ Loaded ${currencies.length} currencies from cache");
      } catch (e) {
        AppLog.d("Error decoding cached currencies: $e");
      }
    }

    if (cachedCurrent != null) {
      try {
        currentCurrency.value =
            Currency.fromJson(jsonDecode(cachedCurrent));
      } catch (e) {
        AppLog.d("Error decoding cached current currency: $e");
      }
    }
  }

  void _saveToCache(List<Currency> list, Currency? current) {
    CacheService.save(
      _currenciesCacheKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    if (current != null) {
      CacheService.save(
        _currentCurrencyCacheKey,
        jsonEncode(current.toJson()),
      );
    }
    CacheService.save(
      _currenciesCacheTimeKey,
      DateTime.now().toIso8601String(),
    );
  }


  Future<void> getCurrenciesData({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && currencies.isNotEmpty) {
      AppLog.d("📦 Using cached currencies (still valid < 24h)");
      return;
    }

    isLoadingCurrencies.value = true;

    try {
      final response = await settingRepository.getCurrenciesData();

      response.fold(
        onSuccess: (data) {
          AppLog.d("Currencies Response =====> $data");

          if (data['status'] == 1) {
            final currencyResponse = CurrencyResponse.fromJson(data);

            currencies.assignAll(currencyResponse.data.currencies);
            currentCurrency.value = currencyResponse.data.currentCurrency;

            _saveToCache(
              currencyResponse.data.currencies,
              currencyResponse.data.currentCurrency,
            );

            AppLog.d("Currencies Length =====> ${currencies.length}");
          } else {
            commonToast(type: AppSnackBarType.error, data['message'] ?? 'Failed to get currencies');
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value = message ?? 'Error getting currencies';
          commonToast(type: AppSnackBarType.error, message ?? 'Error getting currencies');
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
          commonToast(type: AppSnackBarType.success, apiMessage(data, fallback: 'Success'));

          // Three levels deep, and the two levels above `current_store` were
          // both unguarded. Worse than the message reads around it: when the
          // index threw, the Prefs.setStoreID below it never ran, so the app
          // stayed pointed at the store the server had just deleted.
          //
          // The `.toString()` was the second half of it -- on a response that
          // HAD user_info but a null current_store it wrote the four-character
          // string "null" into the cached store id, which then went out as
          // `?store_id=null` on every later request.
          final currentStore =
              apiText(data, ['data', 'user_info', 'current_store']);

          AppLog.d("StoreID----->$currentStore");

          if (currentStore.isEmpty) {
            AppLog.d(
              'deleteStoreData: the response carried no '
              'data.user_info.current_store; keeping the cached store id',
            );
          } else {
            Prefs.setStoreID(currentStore);
          }

          AppLog.d(
            "StoreID----->--${Prefs.getStoreID()}",
          );
        } else {
          commonToast(type: AppSnackBarType.error, apiMessage(data, fallback: 'Failed'));
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value =
            message ?? 'Error deleting store';

        commonToast(type: AppSnackBarType.error, 
          message ?? 'Error deleting store',
        );
      },
    );
  }

  // ==================== Exchange Rates ====================

  Future<void> getCurrencyRatesData({bool forceRefresh = false}) async {
    isLoadingCurrencyRates.value = true;

    try {
      final response = await settingRepository.getCurrencyRatesData();

      response.fold(
        onSuccess: (data) {

          if (data['status'] == 1) {
            final currencyRatesResponse = CurrencyRatesResponse.fromJson(data);

            if (currencyRatesResponse.data != null) {
              currencyRates.assignAll(currencyRatesResponse.data!.currencyRates);
              defaultRatesCurrency.value = currencyRatesResponse.data!.defaultCurrency;
            }
          } else {
            commonToast(type: AppSnackBarType.error, data['message'] ?? 'Failed to get currency rates');
          }
        },
        onFailure: (reason, message, errors) {
          commonToast(type: AppSnackBarType.error, message ?? 'Error getting currency rates');
        },
      );
    } finally {
      isLoadingCurrencyRates.value = false;
    }
  }

  Future<bool> toggleCurrencyStatus({
    required String currencyCode,
    required bool isActive,
  }) async {
    togglingCurrencyCode.value = currencyCode;

    try {
      final response = await settingRepository.toggleCurrencyStatus(
        data: {
          'currency_code': currencyCode,
          'is_active': isActive,
        },
      );

      bool success = false;

      response.fold(
        onSuccess: (data) {

          if (data['status'] == 1) {
            success = true;
            commonToast(type: AppSnackBarType.success, 
              data['message'] ?? 'Currency status updated successfully.',
            );

            final index = currencyRates.indexWhere((c) => c.currencyCode == currencyCode);
            if (index != -1) {
              currencyRates[index].isActive = isActive;
              currencyRates.refresh();
            }

            final currIndex = currencies.indexWhere((c) => c.code == currencyCode);
            if (currIndex != -1) {
              currencies[currIndex] = Currency(
                code: currencies[currIndex].code,
                name: currencies[currIndex].name,
                symbol: currencies[currIndex].symbol,
                ratePerUsd: currencies[currIndex].ratePerUsd,
                isActive: isActive,
              );
            }
          } else {
            commonToast(type: AppSnackBarType.error, 
              data['message'] ?? 'Failed to update currency status',
            );
          }
        },
        onFailure: (reason, message, errors) {
          commonToast(type: AppSnackBarType.error, 
            message ?? 'Error updating currency status',
          );
        },
      );

      return success;
    } finally {
      togglingCurrencyCode.value = null;
    }
  }

  Future<bool> updateCurrencyRate({
    required String currencyCode,
    required double ratePerUsd,
  }) async {
    updatingRateCurrencyCode.value = currencyCode;

    try {
      final response = await settingRepository.updateCurrencyRate(
        data: {
          'currency_code': currencyCode,
          'rate_per_usd': ratePerUsd,
        },
      );

      bool success = false;

      response.fold(
        onSuccess: (data) {

          if (data['status'] == 1) {
            success = true;
            commonToast(type: AppSnackBarType.success, 
              data['message'] ?? 'Currency rate updated successfully.',
            );

            final index = currencyRates.indexWhere((c) => c.currencyCode == currencyCode);
            if (index != -1) {
              currencyRates[index].ratePerUsd = ratePerUsd;
              currencyRates.refresh();
            }

            final currIndex = currencies.indexWhere((c) => c.code == currencyCode);
            if (currIndex != -1) {
              currencies[currIndex] = Currency(
                code: currencies[currIndex].code,
                name: currencies[currIndex].name,
                symbol: currencies[currIndex].symbol,
                ratePerUsd: ratePerUsd,
                isActive: currencies[currIndex].isActive,
              );
            }
          } else {
            commonToast(type: AppSnackBarType.error, 
              data['message'] ?? 'Failed to update currency rate',
            );
          }
        },
        onFailure: (reason, message, errors) {
          commonToast(type: AppSnackBarType.error, 
            message ?? 'Error updating currency rate',
          );
        },
      );

      return success;
    } finally {
      updatingRateCurrencyCode.value = null;
    }
  }
}
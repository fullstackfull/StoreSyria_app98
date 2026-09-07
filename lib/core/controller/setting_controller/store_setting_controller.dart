// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../config/repository/store_settings_repository.dart';
import '../../model/currency_model.dart';
import '../../model/language_model.dart';

class StoreSettingController extends GetxController {
  StoreSettingRepository settingRepository = StoreSettingRepository();

  RxBool isLoading = false.obs;
  RxBool isLoadingLanguages = false.obs;
  RxBool isLoadingCurrencies = false.obs;

  RxString errorMessage = ''.obs;

  RxList<Currency> currencies = <Currency>[].obs;
  RxList<Language> languages = <Language>[].obs;

  RxString currentLanguage = ''.obs;

  // ============================================================
  // DELETE STORE
  // ============================================================

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

  // ============================================================
  // GET LANGUAGES
  // ============================================================

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

  // ============================================================
  // GET CURRENCIES
  // ============================================================

  Future<void> getCurrenciesData() async {
    isLoadingCurrencies.value = true;

    try {
      final response =
      await settingRepository.getCurrenciesData();

      response.fold(
        onSuccess: (data) {
          print("Currencies Response =====> $data");

          if (data['status'] == 1) {
            final currencyResponse =
            CurrencyResponse.fromJson(data);

            currencies.assignAll(
              currencyResponse.data.currencies,
            );

            print(
              "Currencies Length =====> ${currencies.length}",
            );
          } else {
            commonToast(
              data['message'] ?? 'Failed to get currencies',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error getting currencies';

          commonToast(
            message ?? 'Error getting currencies',
          );
        },
      );
    } finally {
      isLoadingCurrencies.value = false;
    }
  }

  // ============================================================
  // GET LANGUAGES + CURRENCIES
  // ============================================================

  Future<void> getStoreSettingsData() async {
    await Future.wait([
      getLanguagesData(),
      getCurrenciesData(),
    ]);
  }

  @override
  void onInit() {
    super.onInit();

    getStoreSettingsData();
  }
}
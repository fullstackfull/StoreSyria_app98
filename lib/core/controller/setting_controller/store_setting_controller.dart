// ignore_for_file: avoid_print
import 'package:get/get.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/config/repository/setting_repository.dart';

class StoreSettingController extends GetxController {
  SettingRepository settingRepository = SettingRepository();
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  deleteStoreData() async {
    isLoading.value = true;
    errorMessage.value = '';
    final response = await settingRepository.deleteStoreData();
    isLoading.value = false;
    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          commonToast(data['data']['message'] ?? 'Success');
          print("StoreID----->${data['data']['user_info']['current_store']}");
          Prefs.setStoreID(data['data']['user_info']['current_store'].toString());
          print("StoreID----->--${Prefs.getStoreID()}");
        } else {
          commonToast(data['data']['message'] ?? 'Failed');
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value = message ?? 'Error deleting store';
        commonToast(message ?? 'Error deleting store');
      },
    );
  }
}
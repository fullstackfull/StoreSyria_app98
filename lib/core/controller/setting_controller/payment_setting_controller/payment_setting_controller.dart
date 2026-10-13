import 'package:get/get.dart';
import 'package:store_go_app/config/repository/payment_setting_repository.dart';
import 'package:store_go_app/core/model/payment_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/network/result.dart';

class PaymentSettingController extends GetxController {
  final PaymentSettingRepository paymentSettingRepository =
  PaymentSettingRepository();

  RxString errorMessage = ''.obs;

  final RxList<PaymentMethod> paymentMethods = <PaymentMethod>[].obs;

  RxBool isLoading = false.obs;

  Future<void> getPaymentTypesData() async {
    try {
      isLoading.value = true;

      errorMessage.value = '';

      final response =
      await paymentSettingRepository.getPaymentTypesData();

      response.fold(
        onSuccess: (data) {
          if (data['status'] == 1) {
            // Three bare casts on a decoded body: `as Map<String, dynamic>`
            // throws on `"data": []`, `as List<dynamic>?` throws on a Map or
            // a scalar BEFORE its `?? []` is consulted, and
            // `item as Map<String, dynamic>` throws on a scalar element.
            final responseData = jsonMap(data['data']);

            paymentMethods.value =
                jsonList(responseData['active_methods'])
                    .whereType<Map<String, dynamic>>()
                    .map(PaymentMethod.fromJson)
                    .toList();
          } else {
            errorMessage.value =
                data['message'] ?? 'Something went wrong';

            commonToast(type: AppSnackBarType.error, errorMessage.value);
          }
        },

        onFailure: (
            reason,
            message,
            validationErrors,
            ) {
          errorMessage.value = message;
          commonToast(type: AppSnackBarType.error, message);
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      commonToast(type: AppSnackBarType.error, errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
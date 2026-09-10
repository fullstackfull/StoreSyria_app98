import 'package:get/get.dart';
import 'package:store_go_app/config/repository/payment_setting_repository.dart';
import 'package:store_go_app/core/model/payment_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

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
            final responseData =
            data['data'] as Map<String, dynamic>;

            final activeMethods =
                responseData['active_methods']
                as List<dynamic>? ??
                    [];

            paymentMethods.value = activeMethods
                .map(
                  (item) => PaymentMethod.fromJson(
                item as Map<String, dynamic>,
              ),
            )
                .toList();
          } else {
            errorMessage.value =
                data['message'] ?? 'Something went wrong';

            commonToast(errorMessage.value);
          }
        },

        onFailure: (
            reason,
            message,
            validationErrors,
            ) {
          errorMessage.value = message;
          commonToast(message);
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      commonToast(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
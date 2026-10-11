import 'package:get/get.dart';
import 'package:store_go_app/config/repository/plan_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../model/my_plan_model.dart';

class PlanController extends GetxController {
  final PlanRepository planRepository = PlanRepository();

  CurrentPlanResponse? currentPlanResponse;

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> getMyPlanData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    Loader.showLoader();

    final response = await planRepository.getMyPlanData();

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          currentPlanResponse = CurrentPlanResponse.fromJson(data);

          update();
        } else {
          final message =
              data['message'] ??
                  data['data']?['message'] ??
                  'Something went wrong';

          errorMessage.value = message;
          commonToast(type: AppSnackBarType.error, message);
        }
      },
      onFailure: (reason, message, errors) {
        errorMessage.value = message;
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }
}
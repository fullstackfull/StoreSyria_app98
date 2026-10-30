
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/statistics_repository.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class StatisticsController extends GetxController {
  StatisticRepository statisticRepository = StatisticRepository();
  StaticsDataModel? staticsDataModel;
  RxList<VisitorChartData> visitorChartList = <VisitorChartData>[].obs;
  RxList<TopUrl> topUrlList = <TopUrl>[].obs;
  RxList<PlatformData> platformList = <PlatformData>[].obs;
  RxList<BrowserData> browserList = <BrowserData>[].obs;
  RxList<DeviceData> deviceList = <DeviceData>[].obs;
  /// NOTE: `isDataAvailable` is the LOADING flag despite its name -- it is set true while the
  /// request is in flight and false when it settles, either way. Renaming it would touch every
  /// caller, so it is documented here instead of quietly reinterpreted.
  RxBool isDataAvailable = false.obs;

  /// P2-07-14. A toast is all the merchant got, and a toast disappears: afterwards the screen
  /// showed empty charts with no way to tell a failed request from a store with no visitors,
  /// and no way to retry without leaving the screen.
  RxString errorMessage = ''.obs;

  /// True once a response has settled, so "no data" can be distinguished from "not asked yet".
  RxBool hasLoadedOnce = false.obs;

  getStaticData() async {
    isDataAvailable.value = true;
    errorMessage.value = '';

    final response = await statisticRepository.getStatisticData();

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          staticsDataModel = StaticsDataModel.fromJson(data);

          visitorChartList.value = staticsDataModel?.data?.visitorchart ?? [];
          topUrlList.value = staticsDataModel?.data?.topurl ?? [];
          platformList.value = staticsDataModel?.data?.platform ?? [];
          browserList.value = staticsDataModel?.data?.browser ?? [];
          deviceList.value = staticsDataModel?.data?.device ?? [];
        } else {
          commonToast(type: AppSnackBarType.error, data['message'] ?? '');
          errorMessage.value = data['message'] ?? '';
        }

        isDataAvailable.value = false;
        hasLoadedOnce.value = true;
      },
      onFailure: (reason, message, errors) {
        isDataAvailable.value = false;
        hasLoadedOnce.value = true;
        // The toast stays -- it is the immediate feedback -- and the message is also kept so
        // the screen can show a retry once the toast has gone.
        commonToast(type: AppSnackBarType.error, message);
        errorMessage.value = message;
      },
    );
  }
}

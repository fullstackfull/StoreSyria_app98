
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
  RxBool isDataAvailable = false.obs;

  getStaticData() async {
    isDataAvailable.value = true;

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
        }

        isDataAvailable.value = false;
      },
      onFailure: (reason, message, errors) {
        isDataAvailable.value = false;
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }
}

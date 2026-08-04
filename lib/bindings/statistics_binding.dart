import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/statistic_controller.dart';

class StatisticsBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<StatisticsController>(
          () => StatisticsController(),
    );
  }
}

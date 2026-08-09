import 'package:get/get.dart';
import '../core/controller/dashboard_manager_controller/dashboard_manager_controller.dart';
import '../core/controller/notification_controller/notification_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardManagerController());
    Get.put(NotificationController());
  }
}

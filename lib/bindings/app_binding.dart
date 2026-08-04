import 'package:get/get.dart';

import '../core/controller/auth/auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
  //  Get.put(PlanController(),permanent: true);
  }
}


import 'package:get/get.dart';
import 'package:store_go_app/core/controller/delivery_boy/delivery_boy_controller.dart';

class DeliveryBoyBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<DeliveryBoyController>(
          () => DeliveryBoyController(),
    );
  }
}

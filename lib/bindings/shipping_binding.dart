import 'package:get/get.dart';
import '../core/controller/home_controller/shipping_controller.dart';

class ShippingBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<ShippingController>(
          () => ShippingController(),
    );
  }

}
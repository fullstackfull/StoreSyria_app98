import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';

class CouponBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<NewCouponController>(
          () => NewCouponController(),
    );
  }
}
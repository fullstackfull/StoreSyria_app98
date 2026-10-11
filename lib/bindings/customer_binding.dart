import 'package:get/get.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';

class CustomerBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<CustomerController>(
          () => CustomerController(),
    );
  }
}
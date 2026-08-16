import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/tax_controller.dart';

class TaxBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<TaxController>(() => TaxController());
  }
}
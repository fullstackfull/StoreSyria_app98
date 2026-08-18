import 'package:get/get.dart';
import 'package:store_go_app/config/repository/product_repository.dart';
import 'package:store_go_app/core/model/product_detail_model.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

class ProductDetailController extends GetxController {
  RxString colorType = ''.obs;
  RxString sizeType = ''.obs;

  List colorList = ["Red", "Blue", "Green", "Yellow"];
  List sizeList = ["S", "M", "L", "XL", "XXL"];

  RxString productImage = ''.obs;

  ProductDetailModel? productDetailModel;
  ProductData? product;

  final ProductRepository productRepository = ProductRepository();

  Future<void> getProductDetail(String productId) async {
    //Loader.showLoader();

    final response =
    await productRepository.getProductDetailData(productId);

    //Loader.hideLoader();

    response.fold(
        onSuccess: (data) {
          if (data['status'] == 1) {
            productDetailModel = ProductDetailModel.fromJson(data);

            product = productDetailModel?.data?.product;

            productImage.value = product?.coverImageUrl ?? "";

            update();
          } else {
            commonToast(
              data['data']?['message'] ??
                  data['message'] ??
                  "Error",
            );
          }
        },
      onFailure: (reason, message, validationErrors) {
       // commonToast(message);
      },
    );
  }
}
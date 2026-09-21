import 'package:get/get.dart';
import 'package:store_go_app/config/repository/product_repository.dart';
import 'package:store_go_app/core/model/product_detail_model.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class ProductDetailController extends GetxController {
  RxString colorType = ''.obs;
  RxString sizeType = ''.obs;

  RxString productImage = ''.obs;

  ProductDetailModel? productDetailModel;

  ProductData? product;

  final ProductRepository productRepository =
  ProductRepository();

  Future<void> getProductDetail(String productId) async {
    productDetailModel = null;

    update();

    final response =
    await productRepository.getProductDetailData(productId);

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          productDetailModel =
              ProductDetailModel.fromJson(data);

          update();
        } else {
          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );
        }
      },
      onFailure: (reason, message, validationErrors) {},
    );
  }

  List<String> getProductImages() {
    final images = <String>[];

    if (product == null) {
      return images;
    }

    // ----------------------------------------------------------
    // 1. COVER IMAGE
    // ----------------------------------------------------------

    try {
      final coverUrl = product?.coverImageUrl;

      if (coverUrl != null && coverUrl.toString().trim().isNotEmpty) {
        final fullUrl = coverUrl;

        if (fullUrl.isNotEmpty) {
          images.add(fullUrl);
        }
      }
    } catch (_) {}

    // ----------------------------------------------------------
    // 2. SUB IMAGES
    // ----------------------------------------------------------

    final subImages = productDetailModel?.data?.subImages;

    if (subImages != null && subImages.isNotEmpty) {
      for (final image in subImages) {
        try {
          String? imageUrl;

          if (image.imagePathFullUrl != null &&
              image.imagePathFullUrl!.trim().isNotEmpty) {
            imageUrl = image.imagePathFullUrl;
          } else if (image.imagePath != null &&
              image.imagePath!.trim().isNotEmpty) {
            imageUrl = image.imagePath;
          }

          if (imageUrl != null && imageUrl.trim().isNotEmpty) {
            final fullUrl = imageUrl;

            if (fullUrl.isNotEmpty && !images.contains(fullUrl)) {
              images.add(fullUrl);
            }
          }
        } catch (_) {}
      }
    }

    return images;
  }

  void setProduct(ProductData value) {
    product = value;

    productImage.value =
        value.coverImageUrl ?? '';

    update();
  }

}
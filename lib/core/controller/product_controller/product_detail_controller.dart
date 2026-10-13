import 'package:get/get.dart';
import 'package:store_go_app/config/repository/product_repository.dart';
import 'package:store_go_app/core/model/product_detail_model.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/network/result.dart';

class ProductDetailController extends GetxController {
  RxString colorType = ''.obs;
  RxString sizeType = ''.obs;

  RxString productImage = ''.obs;
  RxString currencySymbol = ''.obs;
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
          currencySymbol.value =
              productDetailModel?.data?.currencySymbol ?? '';

          update();
        } else {
          commonToast(type: AppSnackBarType.error, 
            apiMessage(data, fallback: 'Error'),
          );
        }
      },
      // Was `{}` -- an empty closure, so every failure was discarded.
      //
      // `/viewproduct` carries `?store_id=` (product_repository.dart:28-32),
      // one of the admin-API sites repo A now answers 403 on for a store the
      // caller does not own. The screen does NOT go blank when that happens:
      // `controller.product` was already populated from the list row by
      // setProduct() (product_detail_screen.dart:55), so the page kept
      // rendering with the list's fields and silently omitted everything this
      // request supplies -- the sub-images and the currency symbol. A denial
      // therefore looked like a product that merely has one image, with no
      // error anywhere. Toast, and deliberately no logout: `message` is
      // already action_not_permitted for a 403.
      onFailure: (reason, message, validationErrors) {
        commonToast(type: AppSnackBarType.error, message);
      },
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
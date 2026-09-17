import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_go_app/config/repository/product_repository.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/core/model/create_product_model.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../utils/pick_file.dart';

class AddProductController extends GetxController {
  ProductController productController = Get.find();
  ProductRepository productRepository = ProductRepository();

  RxBool isTrending = true.obs;
  RxBool isStatus = true.obs;
  RxBool isVariant = false.obs;

  var productName = TextEditingController().obs;
  var stockQtyController = TextEditingController().obs;
  var productCategoriesController = TextEditingController().obs;
  var productTaxController = TextEditingController().obs;
  var variantName = TextEditingController().obs;
  var productDescriptionController = TextEditingController().obs;
  var otherDescriptionController = TextEditingController().obs;
  var moreInfoController = TextEditingController().obs;
  var priceController = TextEditingController().obs;
  var costPriceController = TextEditingController().obs;
  var salePriceController = TextEditingController().obs;

  RxString lastPrice = ''.obs;
  RxString trending = '1'.obs;
  RxString status = '1'.obs;
  RxString category = ''.obs;
  RxString variantType = ''.obs;

  List variantTypeList = [
    "Collection Horizontal",
    "DropDown",
  ];

  RxList<Category> categoryTypeList = <Category>[].obs;
  RxList<Category> variantList = <Category>[].obs;
  RxList selectedVariantList = [].obs;
  RxList variantTextFieldList = [].obs;
  RxList controllerList = [].obs;
  RxList chipList = [].obs;

  RxString filePath = ''.obs;
  RxString otherDescriptionImage = ''.obs;
  RxString moreInformationImage = ''.obs;
  RxString coverImage = ''.obs;

  RxString newTag = 'new'.obs;
  RxString bestSeller = 'best seller'.obs;
  RxString none = 'none'.obs;
  RxString groupValue = 'none'.obs;

  RxList<String> selectedSubImages = <String>[].obs;

  RxString categoryId = ''.obs;

  RxString discountType = 'Flat'.obs;

  List discountTypeList = [
    'Flat',
    "Percentage",
  ];

  RxString existingCoverImageUrl = ''.obs;
  RxList<String> existingSubImages = <String>[].obs;

  CreateProductModel? createProductModel;

  String _cleanPlaceholderText(String? text) {
    if (text == null || text.isEmpty) {
      return "";
    }

    return text;
  }

  Future<void> getImages() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickMultiImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    if (pickedFile.isNotEmpty) {
      for (var i = 0; i < pickedFile.length; i++) {
        selectedSubImages.add(
          pickedFile[i].path,
        );
      }

      selectedSubImages.refresh();
    } else {
      commonToast("Nothing is selected");
    }
  }

  Future<String?> pickImage() async {
    return await FileHelper.pickImage();
  }

  Future<void> getCreateProductData({
    required bool isUpdate,
  }) async {
    final response =
    await productRepository.getCreateProductData();

    response.fold(
      onSuccess: (data) {
        categoryTypeList.clear();

        if (data['status'] == 1) {
          createProductModel =
              CreateProductModel.fromJson(data);

          if (createProductModel?.data?.category != null &&
              createProductModel!
                  .data!
                  .category!
                  .isNotEmpty) {
            categoryTypeList.assignAll(
              createProductModel!.data!.category!,
            );

            category.value =
            categoryTypeList.first.name!;

            categoryId.value =
                categoryTypeList.first.id.toString();
          } else {
            category.value = "No Categories";
            categoryId.value = "";
          }

          variantList.assignAll(
            createProductModel?.data?.variant ?? [],
          );

          final details = createProductModel
              ?.data
              ?.details
              ?.productOtherDescription;

          if (isUpdate) {
            otherDescriptionController.value.text =
                details
                    ?.productOtherDescriptionOtherDescription ??
                    '';

            moreInfoController.value.text =
                details
                    ?.productOtherDescriptionMoreInformations ??
                    '';
          } else {
            otherDescriptionController.value.clear();
            moreInfoController.value.clear();
          }
        } else {
// commonToast(
//   data['data']?['message'] ?? "Error",
// );
        }
      },
      onFailure: (
          reason,
          message,
          validationErrors,
          ) {
// commonToast(message);
      },
    );
  }

  Future<void> addProductData({
    required String name,
    required bool isUpdate,
    required String status,
    required String categoryId,
    required String productId,
    required String description,
    required String price,
    required String costPrice,
    required String salePrice,
    required String tag,
    required String discountType,
    required String discountAmount,
    required String productStock,
    required String trending,
    required String productOtherDescription,
    required String productMoreDescription,
    required String coverImage,
    required String otherDescriptionImage,
    required String moreInformationImage,
    required List<String> selectedSubImages,
  }) async {
    final fields = <String, String>{
      'store_id': Prefs.getStoreID(),
      'name': name,
      'category_id': categoryId,
      'description': description,
      'price': price,
      'sale_price': salePrice,
      'discount_type': discountType,
      'discount_amount': discountAmount,
      'product_stock': productStock,
      'trending': trending,
      "cost_price" : costPrice,

// TODO :: variant_product
      'variant_product': '0',

      'status': status,
      'tag': tag,

      'array[0][section_name]':
      'Product - Other Description',

      'array[0][section_slug]':
      'product-other-description',

      'array[0][inner-list][0][field_name]':
      'Other Description',

      'array[0][inner-list][0][field_slug]':
      'product-other-description-other-description',

      'array[0][inner-list][0][field_help_text]':
      'Please add your description text here',

      'array[0][inner-list][0][field_default_text]':
      _cleanPlaceholderText(
        createProductModel
            ?.data
            ?.details
            ?.productOtherDescription
            ?.productOtherDescriptionOtherDescription,
      ),

      'array[0][inner-list][0][field_type]':
      'text area',

      'array[0][inner-list][0][value]':
      _cleanPlaceholderText(
        productOtherDescription,
      ),

      'array[0][inner-list][1][field_name]':
      'Other Description Image',

      'array[0][inner-list][1][field_slug]':
      'product-other-description-other-description-image',

      'array[0][inner-list][1][field_help_text]':
      'Upload image here',

      'array[0][inner-list][1][field_default_text]':
      'Upload image here',

      'array[0][inner-list][1][field_type]':
      'photo upload',

      'array[0][inner-list][2][field_name]':
      'More informations',

      'array[0][inner-list][2][field_slug]':
      'product-other-description-more-informations',

      'array[0][inner-list][2][field_help_text]':
      'Please add your description text here',

      'array[0][inner-list][2][field_default_text]':
      _cleanPlaceholderText(
        createProductModel
            ?.data
            ?.details
            ?.productOtherDescription
            ?.productOtherDescriptionMoreInformations,
      ),

      'array[0][inner-list][2][field_type]':
      'text area',

      'array[0][inner-list][2][value]':
      _cleanPlaceholderText(
        productMoreDescription,
      ),

      'array[0][inner-list][3][field_name]':
      'More information Image',

      'array[0][inner-list][3][field_slug]':
      'product-other-description-more-information-image',

      'array[0][inner-list][3][field_help_text]':
      'Upload image here',

      'array[0][inner-list][3][field_default_text]':
      'Upload image here',

      'array[0][inner-list][3][field_type]':
      'photo upload',
    };

    if (isUpdate) {
      fields['product_id'] = productId;
    }

    final files = <String, String>{};

    if (coverImage.isNotEmpty) {
      files['cover_image'] = coverImage;
    }

    if (otherDescriptionImage.isNotEmpty) {
      files[
      'array[0][inner-list][1][value]'] =
          otherDescriptionImage;
    }

    if (moreInformationImage.isNotEmpty) {
      files[
      'array[0][inner-list][3][value]'] =
          moreInformationImage;
    }

    final response =
    await productRepository.addProduct(
      isUpdate: isUpdate,
      fields: fields,
      files: files,
      multiFiles: selectedSubImages,
    );

    response.fold(
      onSuccess: (data) {
        commonToast(
          data['data']?['message'] ??
              data['message'] ??
              "Success",
        );

        productController.getProductData(1);

        clear();

        Get.back();
      },
      onFailure: (
          reason,
          message,
          validationErrors,
          ) {
        commonToast(message);
      },
    );
  }

  void clear() {
    productName.value.clear();
    stockQtyController.value.clear();
    productCategoriesController.value.clear();
    productTaxController.value.clear();
    variantName.value.clear();
    productDescriptionController.value.clear();
    otherDescriptionController.value.clear();
    moreInfoController.value.clear();
    priceController.value.clear();
    costPriceController.value.clear();
    salePriceController.value.clear();

    selectedSubImages.clear();

    coverImage.value = '';
    otherDescriptionImage.value = '';
    moreInformationImage.value = '';

    category.value = '';
    categoryId.value = '';

    groupValue.value = 'none';

    existingCoverImageUrl.value = '';
    existingSubImages.clear();

    isTrending.value = true;
  }
}

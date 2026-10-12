import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_go_app/config/repository/product_repository.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_detail_controller.dart';
import 'package:store_go_app/core/model/create_product_model.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../utils/pick_file.dart';

class AddProductController extends GetxController {
  ProductController productController = Get.find();
  ProductRepository productRepository = ProductRepository();

  static const _taxOptions = ['none', 'taxable', 'shipping'];

  RxBool isTrending = true.obs;
  RxBool isStatus = true.obs;
  RxBool isStock = true.obs;
  RxBool isVariant = false.obs;
  RxBool isAddLoading = false.obs;
  RxBool isDetailLoading = false.obs;

  var productName = TextEditingController().obs;
  var stockQtyController = TextEditingController().obs;
  var productCategoriesController = TextEditingController().obs;
  var productTaxController = TextEditingController().obs;
  var variantName = TextEditingController().obs;
  var productDescriptionController = TextEditingController().obs;
  var discountAmountController = TextEditingController().obs;
  var otherDescriptionController = TextEditingController().obs;
  var moreInfoController = TextEditingController().obs;
  var priceController = TextEditingController().obs;
  var costPriceController = TextEditingController().obs;
  var salePriceController = TextEditingController().obs;
  var taxIdController = TextEditingController().obs;
  var shippingIdController = TextEditingController().obs;
  var productWeightController = TextEditingController().obs;

  RxString taxStatus = 'none'.obs;
  RxString trackStock = '1'.obs;
  RxString lastPrice = ''.obs;
  RxString trending = '1'.obs;
  RxString status = '1'.obs;
  RxString stockStatus = 'in_stock'.obs;
  RxString category = ''.obs;
  RxString variantType = '0'.obs;

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
  RxString existingCoverImageUrl = ''.obs;
  RxList<String> existingSubImages = <String>[].obs;

  CreateProductModel? createProductModel;

  Future<void> getImages() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickMultiImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    if (pickedFile.isNotEmpty) {
      for (var i = 0; i < pickedFile.length; i++) {
        selectedSubImages.add(pickedFile[i].path);
      }
      selectedSubImages.refresh();
    } else {
      commonToast(type: AppSnackBarType.info, "Nothing is selected");
    }
  }

  Future<String?> pickImage() async {
    return await FileHelper.pickImage();
  }

  Future<void> fetchProductDetailForUpdate(String productId) async {
    if (productId.isEmpty) return;

    isDetailLoading.value = true;

    try {
      final detailController = Get.put(ProductDetailController());
      await detailController.getProductDetail(productId);

      final product = detailController.productDetailModel?.data?.product;
      final subImages = detailController.productDetailModel?.data?.subImages ?? [];

      // الصور الفرعية
      final urls = subImages
          .map((img) {
        final fullUrl = img.imagePathFullUrl?.trim() ?? '';
        if (fullUrl.isNotEmpty) return fullUrl;
        return img.imagePath?.trim() ?? '';
      })
          .where((url) => url.isNotEmpty)
          .toList();
      existingSubImages.assignAll(urls);

      // الوزن
      productWeightController.value.text =
          product?.productWeight?.toString() ?? '';

      // حالة الضريبة والحقول المرتبطة بيها
      final fetchedTaxStatus = product?.taxStatus;
      taxStatus.value = (fetchedTaxStatus != null &&
          _taxOptions.contains(fetchedTaxStatus))
          ? fetchedTaxStatus
          : 'none';
      taxIdController.value.text = product?.taxId?.toString() ?? '';
      shippingIdController.value.text = product?.shippingId?.toString() ?? '';

      trackStock.value = product?.trackStock?.toString() ?? '1';
      stockStatus.value = product?.stockStatus.toString() ?? 'in_stock';

    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> getCreateProductData({required bool isUpdate}) async {
    final response = await productRepository.getCreateProductData();

    response.fold(
      onSuccess: (data) {
        categoryTypeList.clear();

        if (data['status'] == 1) {
          createProductModel = CreateProductModel.fromJson(data);

          final cats = createProductModel?.data?.category;
          if (cats != null && cats.isNotEmpty) {
            categoryTypeList.assignAll(cats);

            Category? selected;
            if (isUpdate) {
              selected = cats.firstWhereOrNull(
                    (c) => c.id.toString() == categoryId.value,
              ) ??
                  cats.firstWhereOrNull((c) => c.name == category.value);
            }
            selected ??= cats.first;

            category.value = selected.name ?? '';
            categoryId.value = selected.id.toString();
          } else {
            category.value = "No Categories";
            categoryId.value = "";
          }

          variantList.assignAll(createProductModel?.data?.variant ?? []);

          final details =
              createProductModel?.data?.details?.productOtherDescription;

          if (isUpdate) {
            otherDescriptionController.value.text =
                details?.productOtherDescriptionOtherDescription ?? '';
            moreInfoController.value.text =
                details?.productOtherDescriptionMoreInformations ?? '';
          } else {
            otherDescriptionController.value.clear();
            moreInfoController.value.clear();
          }
        }
      },
      onFailure: (reason, message, validationErrors) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }

  Future<String?> _downloadToTemp(String url, String name) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      final response =
      await request.close().timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) return null;

      final bytes = await consolidateHttpClientResponseBytes(response)
          .timeout(const Duration(seconds: 60));
      final ext = url.split('?').first.split('.').last;
      final safeExt = (ext.isNotEmpty && ext.length <= 4) ? ext : 'jpg';
      final file = File('${Directory.systemTemp.path}/$name.$safeExt');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> addProductData({
    required String name,
    required bool isUpdate,
    required String status,
    required String variant,
    required String categoryId,
    required String productId,
    required String description,
    required String price,
    required String costPrice,
    required String salePrice,
    required String existingCoverImageUrl,
    required String productStock,
    required String trending,
    required String coverImage,
    required List<String> selectedSubImages,
    required String taxId,
    required String taxStatus,
    required String shippingId,
    required String productWeight,
    required String trackStock,
    required String stockStatus,
  }) async {
    if (isAddLoading.value) return;

    isAddLoading.value = true;

    // أي return أو exception جوّا الـ try بيمرّ على finally وبيوقف اللودر
    try {
      final fields = <String, String>{
        'store_id': Prefs.getStoreID(),
        'name': name,
        'category_id': categoryId,
        'description': description,
        'price': price,
        'sale_price': salePrice,
        'product_stock': productStock.isEmpty ? '0' : productStock,
        'trending': trending,
        'cost_price': costPrice,
        'status': status,
        'tax_id': taxId,
        'tax_status': taxStatus,
        'shipping_id': shippingId,
        'product_weight': productWeight,
        'track_stock': trackStock,
        'stock_status': stockStatus,
        'variant_product': variant,
      };

      if (isUpdate) {
        fields['product_id'] = productId;
      }

      final files = <String, String>{};

      if (coverImage.isNotEmpty) {
        files['cover_image'] = coverImage;
      } else if (existingCoverImageUrl.isNotEmpty) {
        // ما اختار صورة جديدة → نبعت القديمة كملف
        final path = await _downloadToTemp(
          existingCoverImageUrl,
          'cover_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (path == null) {
          commonToast(type: AppSnackBarType.error, 
              "Failed to load the current cover image, please check your internet or pick it again");
          return;
        }
        files['cover_image'] = path;
      }

      final response = await productRepository
          .addProduct(
        isUpdate: isUpdate,
        fields: fields,
        files: files,
        multiFiles: selectedSubImages,
      )
          .timeout(const Duration(seconds: 60));

      var success = false;
      String? successMessage;
      String? errorMessage;

      response.fold(
        onSuccess: (data) {
          success = true;
          successMessage =
              (data['data']?['message'] ?? data['message'] ?? 'Success')
                  .toString();
        },
        onFailure: (reason, message, validationErrors) {
          errorMessage = message.toString();
        },
      );

      if (success) {
        productController.getProductData(1);


        if (Get.isSnackbarOpen) {
          await Get.closeCurrentSnackbar();
        }
        Get.back(result: true);
        commonToast(type: AppSnackBarType.success, successMessage ?? 'Success');
      } else {
        commonToast(type: AppSnackBarType.error, errorMessage ?? 'Something went wrong');
      }
    } on TimeoutException {
      commonToast(type: AppSnackBarType.error, 'Request timed out, please check your internet connection');
    } on SocketException {
      commonToast(type: AppSnackBarType.error, 'No internet connection');
    } catch (_) {
      commonToast(type: AppSnackBarType.error, 'Something went wrong, please try again');
    } finally {
      isAddLoading.value = false;
    }
  }

  void clear() {
    productName.value.clear();
    stockQtyController.value.clear();
    productCategoriesController.value.clear();
    productTaxController.value.clear();

    taxIdController.value.clear();
    shippingIdController.value.clear();
    productWeightController.value.clear();

    variantName.value.clear();
    productDescriptionController.value.clear();
    otherDescriptionController.value.clear();
    moreInfoController.value.clear();
    priceController.value.clear();
    costPriceController.value.clear();
    salePriceController.value.clear();

    selectedSubImages.clear();
    existingSubImages.clear();

    coverImage.value = '';
    existingCoverImageUrl.value = '';
    otherDescriptionImage.value = '';
    moreInformationImage.value = '';

    category.value = '';
    categoryId.value = '';
    status.value = '1';
    trending.value = '1';
    variantType.value = '0';

    taxStatus.value = 'none';
    trackStock.value = '1';
    stockStatus.value = 'in_stock';
    groupValue.value = 'none';

    isTrending.value = true;
    isStatus.value = true;
    isVariant.value = false;

    isAddLoading.value = false;
    isDetailLoading.value = false;
  }
}
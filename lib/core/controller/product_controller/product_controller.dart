import 'dart:io';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import 'package:store_go_app/config/repository/product_repository.dart';
import 'package:store_go_app/core/controller/home_controller/cahe.dart';
import 'package:store_go_app/core/controller/home_controller/store_change_service.dart';

class ProductController extends GetxController implements StoreAware {
  static const String _cacheProductKey = 'home_product_list_data';

  ProductRepository productRepository = ProductRepository();

  ProductModel? productModel;

  RxList<ProductData> productList = <ProductData>[].obs;

  List<File> selectedSubImages = [];

  RxInt currantPage = 1.obs;
  RxBool isScroll = true.obs;
  RxBool isDataAvailable = false.obs;
  RxBool isLoading = false.obs;
  RxString imageBaseUrl = ''.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // نحمّل آخر بيانات محفوظة محلياً (صفحة ١) فوراً عشان الشاشة
    // تفتح مباشرة بدون ما تنتظر السيرفر. الطلب الحقيقي (اللي
    // بتستدعيه الشاشة عادة بـ initState) بيصير بعدها بالخلفية.
    _loadCachedProducts();

    // نسجل هاد الكنترولر بالسيرفيس المركزي عشان ينعمله reset
    // تلقائياً لما يتغير المتجر.
    StoreChangeService.instance.register(() => this);
  }

  void _loadCachedProducts() {
    final cached = CacheService.get<Map<String, dynamic>>(_cacheProductKey);
    if (cached == null) return;
    try {
      productModel = ProductModel.fromJson(cached);
      productList.value = productModel?.data?.data ?? [];

      isScroll.value =
          productModel?.data?.currentPage != productModel?.data?.lastPage;
    } catch (_) {
      productModel = null;
    }
  }

  /// بتنستدعى تلقائياً من StoreChangeService لما يتغير المتجر:
  /// بتمسح القائمة + الكاش المحلي وترجع تجيب صفحة ١ من جديد.
  @override
  void resetForStoreChange() {
    productModel = null;
    productList.clear();

    currantPage.value = 1;
    isScroll.value = true;

    CacheService.clear(_cacheProductKey);

    getProductData(1);
  }

  Future<void> getProductData(int page) async {
    isLoading.value = true;
    Loader.showLoader();

    final response = await productRepository.getProductData(page);

    Loader.hideLoader();

    response.fold(
      onSuccess: (data) {
        isLoading.value = false;
        if (data['status'] == 1) {
          productModel = ProductModel.fromJson(data);

          if (page == 1) {
            productList.clear();

            // نخزن آخر رد ناجح لصفحة ١ محلياً عشان يستخدم كبيانات
            // فورية بالمرة الجاية اللي المستخدم يفتح فيها الشاشة.
            CacheService.save(_cacheProductKey, data);
          }

          productList.addAll(productModel?.data?.data ?? []);

          isScroll.value =
              currantPage.value != productModel?.data?.lastPage;
        } else {
          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );
        }
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
        commonToast(message);
      },
    );
  }

  Future<void> searchProductData(String categoryId) async {
    isDataAvailable.value = true;

    final response = await productRepository.searchProductData(
      categoryId: categoryId,
    );

    isDataAvailable.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          productList.clear();

          final List products = data['data'] ?? [];

          productList.assignAll(
            products
                .map((e) => ProductData.fromJson(e))
                .toList(),
          );
        } else {
          commonToast(
            data['data']?['message'] ??
                data['message'] ??
                'Error',
          );
        }
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
        commonToast(message);
      },
    );
  }

  Future<void> deleteProductData({
    required String productId,
  }) async {
    //Loader.showLoader();

    final response =
    await productRepository.deleteProductData(productId);


    //Loader.hideLoader();

    response.fold(
      onSuccess: (data) async {
        commonToast(
          data['data']?['message'] ??
              data['message'] ??
              'Deleted',
        );

        productList.clear();
        currantPage.value = 1;

        await getProductData(1);
      },
      onFailure: (reason, message, validationErrors) {
        errorMessage.value = message;
        commonToast(message);
      },
    );
  }
}

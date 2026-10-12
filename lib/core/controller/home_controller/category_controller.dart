// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/config/repository/search_repository.dart';
import 'package:store_go_app/config/repository/category_repository.dart';
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import 'package:store_go_app/core/model/categories_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../utils/pick_file.dart';
import 'cahe.dart';
import 'store_change_service.dart';

class CategoryController extends GetxController
    implements StoreAware {
  static const String _cacheCategoryKey = 'home_category_list_data';

  TextEditingController categoryName = TextEditingController();

  TextEditingController searchController = TextEditingController();

  RxString filePath = ''.obs;
  RxString imagePath = ''.obs;
  RxString iconPath = ''.obs;

  RxString trending = '1'.obs;

  RxBool isTrending = true.obs;
  RxBool isActive = true.obs;

  RxInt currantPage = 1.obs;

  RxBool isScroll = true.obs;
  RxBool isLoading = false.obs;

  RxString errorMessage = ''.obs;

  CategoryRepository categoryRepository = CategoryRepository();

  SearchRepository searchRepository = SearchRepository();

  CategoriesModel? categoriesModel;

  CategoryData? categoryData;

  RxList<CategoryData> categoriesList = <CategoryData>[].obs;

  @override
  void onInit() {
    super.onInit();

    _loadCachedCategories();

    StoreChangeService.instance.register(() => this);
  }

  void _loadCachedCategories() {
    final cached =
    CacheService.get<Map<String, dynamic>>(
      _cacheCategoryKey,
    );

    if (cached == null) return;

    try {
      categoriesModel =
          CategoriesModel.fromJson(cached);

      categoriesList.value =
          categoriesModel?.data?.data ?? [];

      categoriesList.refresh();

      isScroll.value =
          categoriesModel?.data?.currentPage !=
              categoriesModel?.data?.lastPage;
    } catch (_) {
      categoriesModel = null;
    }
  }

  @override
  void resetForStoreChange() {
    categoriesModel = null;

    categoriesList.clear();
    categoriesList.refresh();

    currantPage.value = 1;
    isScroll.value = true;

    CacheService.clear(_cacheCategoryKey);

    getCategoryData(1);
  }

  Future<String?> pickFile() async {
    return await FileHelper.pickImage();
  }

  Future<void> getCategoryData(int page) async {
    if (isLoading.value) return;

    if (page > 1 && categoriesModel != null) {
      if (page > (categoriesModel?.data?.lastPage ?? 1)) {
        isScroll.value = false;
        return;
      }
    }

    isLoading.value = true;

    Loader.showLoader();

    final response = await categoryRepository.getCategoriesData(page);

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    isLoading.value = false;

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          categoriesModel =
              CategoriesModel.fromJson(data);

          final newItems =
              categoriesModel?.data?.data ?? [];

          if (page == 1) {
            categoriesList.value = newItems;

            CacheService.save(
              _cacheCategoryKey,
              data,
            );
          } else {
            categoriesList.addAll(newItems);
          }

          categoriesList.refresh();

          if (categoriesModel?.data?.currentPage ==
              categoriesModel?.data?.lastPage) {
            isScroll.value = false;
          } else {
            isScroll.value = true;
          }
        } else {
          commonToast(type: AppSnackBarType.error, 
            data['data']['message'] ?? '',
          );
        }
      },
      onFailure: (reason,
          message,
          errors,) {
        errorMessage.value = message;

        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }

  Future<void> searchCategoryData({
    required String name,
  }) async {
    Loader.showLoader();

    final response =
    await searchRepository.getSearchData(
      type: "category",
      name: name,
    );

    response.fold(
      onSuccess: (data) {
        categoriesList.clear();

        if (data['status'] == 1) {
          for (
          int i = 0;
          i < data['data'].length;
          i++
          ) {
            categoriesList.add(
              CategoryData.fromJson(
                data['data'][i],
              ),
            );
          }

          categoriesList.refresh();
        } else {
          commonToast(type: AppSnackBarType.error, 
            data['data']['message'] ?? '',
          );
        }
      },
      onFailure: (reason,
          message,
          errors,) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> addCategoriesData({
    required bool isUpdate,
    required int categoryId,
    required String name,
    required String trending,
    required String status,
    required String? imagePath,
    required String? iconImagePath,
  }) async {
    Loader.showLoader();

    final String url = isUpdate
        ? API.baseUrl + API.updateCategoryUrl
        : API.baseUrl + API.addCategoryUrl;

    final Map<String, String> data = isUpdate
        ? {
      'store_id': Prefs.getStoreID(),
      'category_id': categoryId.toString(),
      'name': name,
      'trending': trending,
      'status': status,
    }
        : {
      'store_id': Prefs.getStoreID(),
      'name': name,
      'trending': trending,
      'status': status,
    };

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.fields.addAll(data);

    if (imagePath != null &&
        imagePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ),
      );
    }

    if (iconImagePath != null &&
        iconImagePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'icon_image',
          iconImagePath,
        ),
      );
    }

    // R7-N1: was a hand-rolled Bearer map. NetworkHttps.authHeaders() is the
    // single construction site and already sends Cache-Control: no-cache.
    request.headers.addAll(NetworkHttps.authHeaders());

    final http.StreamedResponse response =
    await request.send();

    Loader.hideLoader();

    if (response.statusCode == 200) {
      getCategoryData(
        currantPage.value,
      );
    } else {
      commonToast(type: AppSnackBarType.error, 
        response.reasonPhrase ?? '',
      );
    }
  }

  Future<void> deleteCategoriesData({
    required int categoryId,
  }) async {
    final response =
    await categoryRepository.deleteCategoriesData(
      categoryId: categoryId,
    );

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          categoriesList.removeWhere(
                (category) =>
            category.id == categoryId,
          );

          if (categoriesModel?.data?.total != null &&
              categoriesModel!.data!.total! > 0) {
            categoriesModel!.data!.total =
                categoriesModel!.data!.total! - 1;
          }

          commonToast(type: AppSnackBarType.success, 
            data['data']['message'] ?? '',
          );
        } else {
          commonToast(type: AppSnackBarType.error, 
            data['data']['message'] ??
                'Delete failed',
          );
        }
      },
      onFailure: (reason,
          message,
          errors,) {
        commonToast(type: AppSnackBarType.error, message);
      },
    );
  }

  @override
  void onClose() {
    categoryName.dispose();
    searchController.dispose();

    super.onClose();
  }
}


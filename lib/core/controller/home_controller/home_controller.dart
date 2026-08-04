import 'package:store_go_app/config/repository/dashboard_repository.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/core/model/image_base_url_model.dart';
import 'package:store_go_app/core/model/dashboard_model.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:get/get.dart';


class HomeController extends GetxController {
  DashboardRepository dashboardRepository = DashboardRepository();
  RxList<ProductData> topProductList = <ProductData>[].obs;
  RxList<RecentOrder> recentOrderList = <RecentOrder>[].obs;
  RxList<Coupons> couponsList = <Coupons>[].obs;
  RxString imageBaseUrl = ''.obs;
  RxBool isStore = false.obs;
  RxBool isQuickAdd = false.obs;
  RxBool isDataAvailable = false.obs;
  DashboardData? dashboardData;
  ImageUrlData? imageUrlData;
  List<Store> myStoreList = [Store(name: 'Grocery', id: 3), Store(id: 7, name: "Babycare")];

  getImageBaseUrl() async {
    isDataAvailable.value = true;

    final response = await dashboardRepository.getImageBaseData();

    response.fold(
      onSuccess: (data) {
        imageUrlData = ImageUrlData.fromJson(data['data']);
        imageBaseUrl.value = imageUrlData!.imageUrl!;
        Prefs.setString(AppConstant.imageUrl, imageUrlData!.imageUrl!);
        Prefs.setString(AppConstant.paymentUrl, imageUrlData!.paymentUrl!);
      },
      onFailure: (reason, message, errors) {
        commonToast(message);
      },
    );

    isDataAvailable.value = false;
  }
  setStoreIdData({required String storeId}) async {
    isDataAvailable.value = true;

    final response =
    await dashboardRepository.setStoreIdData(storeId: storeId);

    response.fold(
      onSuccess: (data) {
        if (data['status'] == 1) {
          isStore.value = false;
          commonToast(data['data']['message']);
          getDashboardData();
        } else {
          commonToast(data['data']['message']);
        }
      },
      onFailure: (reason, message, errors) {
       // commonToast(message);
      },
    );

    isDataAvailable.value = false;
  }
  getDashboardData() async {
    isDataAvailable.value = true;

    final response = await dashboardRepository.getDashBoardData();

    response.fold(
      onSuccess: (data) {
        dashboardData = DashboardData.fromJson(data['data']);

        topProductList.value = dashboardData!.product ?? [];
        recentOrderList.value = dashboardData!.recentOrder ?? [];
        couponsList.value = dashboardData!.coupons ?? [];

        topProductList.refresh();
        recentOrderList.refresh();
        couponsList.refresh();

        update();
      },
      onFailure: (reason, message, errors) {
        commonToast(message);
      },
    );

    isDataAvailable.value = false;
  }
}

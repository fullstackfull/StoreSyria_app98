import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class ReviewRepository {

  // getReviewUserData() async {
  //   String endPoint = API.createReviewUrl + API.storeIdUrl + Prefs.getStoreID();
  //   var response = await NetworkHttps.getRequest(endPoint);
  //   return response;
  // }

  getReviewData(id) async {
    String endPoint = API.reviewListUrl + API.storeIdUrl + Prefs.getStoreID()+API.productIdUrl+id;
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  // changeReviewStatus(int reviewId) async {
  //   String endPoint = API.reviewStatusUrl;
  //   var response = await NetworkHttps.postRequest(
  //       endPoint, {
  //         "store_id": Prefs.getStoreID(),
  //         'id': reviewId,
  //       });
  //   return response;
  // }

  deleteReviewData(String reviewId) async {
    String endPoint = API.deleteReviewUrl + reviewId;
    var response = await NetworkHttps.deleteRequest(endPoint);
    return response;
  }

  addReviewData({
    required bool isUpdate,
    required String userId,
    required String reviewId,
    required String title,
    required String description,
    required String categoryId,
    required String productId,
    required String rating,
    required String status,
  }) async {
    String endPoint = isUpdate == true ? API.updateReviewUrl : API.addReviewUrl;
    Map data = isUpdate == true
        ? {
            'store_id': Prefs.getStoreID(),
            'user_id': userId,
            'id': reviewId,
            'title': title,
            'description': description,
            'category_id': categoryId,
            'product_id': productId,
            'rating': rating,
            'status': status,
          }
        : {
            'store_id': Prefs.getStoreID(),
            'user_id': userId,
            'title': title,
            'description': description,
            'category_id': categoryId,
            'product_id': productId,
            'rating': rating,
            'status': status,
          };
    var response = await NetworkHttps.postRequest(endPoint, data);
    return response;
  }
}
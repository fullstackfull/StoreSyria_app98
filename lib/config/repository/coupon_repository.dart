import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/utils/prefer.dart';

class CouponRepository {
  getCouponData(int page) async {
    String endPoint = "${API.couponListUrl}${API.storeIdUrl}${Prefs.getStoreID()}${API.andPageUrl}$page";
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }

  addCouponData({
    required bool isUpdate,
    required int status,
    required String couponId,
    required String couponName,
    required String couponType,
    required String disAmount,
    required String couponLimit,
    required String date,
    required String code,
  }) async {
    String endPoint = isUpdate == true ? API.updateCouponUrl : API.addCouponUrl;
    Map data = isUpdate == true
        ? {'store_id': Prefs.getStoreID(), 'coupon_id': couponId, 'coupon_name': couponName, 'coupon_type': couponType, 'discount_amount': disAmount, 'coupon_limit': couponLimit, 'coupon_expiry_date': date, 'coupon_code': code ,"status" : status}
        : {'store_id': Prefs.getStoreID(), 'coupon_name': couponName, 'coupon_type': couponType, 'discount_amount': disAmount, 'coupon_limit': couponLimit, 'coupon_expiry_date': date, 'coupon_code': code ,"status" : status};
    var response = await NetworkHttps.postRequest(endPoint, data);
    return response;
  }

  generateCodeData() async {
    String endPoint = API.generateCodeUrl;
    var response = await NetworkHttps.postRequest(endPoint, {"store_id": Prefs.getStoreID()});
    return response;
  }

  deleteCouponData(String couponId) async {
    String endPoint = API.deleteCouponUrl + API.storeIdUrl + Prefs.getStoreID() + API.couponIdUrl + couponId;
    var response = await NetworkHttps.deleteRequest(endPoint);
    return response;
  }

  getUsedCouponData(int couponId) async {
    String endPoint = "${API.viewUsedCouponUrl}${API.storeIdUrl}${Prefs.getStoreID()}${API.couponIdUrl}$couponId";
    var response = await NetworkHttps.getRequest(endPoint);
    return response;
  }
}

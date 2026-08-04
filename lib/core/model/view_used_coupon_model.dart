// ignore_for_file: unnecessary_this, prefer_collection_literals

class ViewUsedCouponModel {
  int ? status;
  String ? message;
  List<ViewUsedCouponData> ? data;

  ViewUsedCouponModel({this.status, this.message, this.data});

  ViewUsedCouponModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null && json['data'] is List) {
      data = <ViewUsedCouponData>[];
      json['data'].forEach((v) {
        data!.add(ViewUsedCouponData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ViewUsedCouponData {
  int ? id;
  int ? userId;
  int ? couponId;
  int ? amount;
  int ? orderId;
  String ? dateUsed;
  String ? themeId;
  String ? createdAt;
  String ? updatedAt;
  String ? couponName;
  String ? productOrderId;

  ViewUsedCouponData(
      {this.id,
        this.userId,
        this.couponId,
        this.amount,
        this.orderId,
        this.dateUsed,
        this.themeId,
        this.createdAt,
        this.updatedAt,
        this.couponName,
        this.productOrderId});

  ViewUsedCouponData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    couponId = json['coupon_id'];
    amount = json['amount'];
    orderId = json['order_id'];
    dateUsed = json['date_used'];
    themeId = json['theme_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    couponName = json['coupon_name'];
    productOrderId = json['product_order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['coupon_id'] = this.couponId;
    data['amount'] = this.amount;
    data['order_id'] = this.orderId;
    data['date_used'] = this.dateUsed;
    data['theme_id'] = this.themeId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['coupon_name'] = this.couponName;
    data['product_order_id'] = this.productOrderId;
    return data;
  }
}

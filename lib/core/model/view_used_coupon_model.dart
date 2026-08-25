// ignore_for_file: unnecessary_this, prefer_collection_literals

class ViewUsedCouponModel {
  int? status;
  String? message;
  List<ViewUsedCouponData>? data;

  ViewUsedCouponModel({
    this.status,
    this.message,
    this.data,
  });

  ViewUsedCouponModel.fromJson(Map<String, dynamic> json) {
    status = (json['status'] as num?)?.toInt();
    message = json['message']?.toString();

    if (json['data'] != null && json['data'] is List) {
      data = <ViewUsedCouponData>[];

      for (final item in json['data']) {
        if (item is Map<String, dynamic>) {
          data!.add(ViewUsedCouponData.fromJson(item));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['status'] = status;
    data['message'] = message;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class ViewUsedCouponData {
  int? id;
  int? userId;
  int? couponId;
  double? amount;
  int? orderId;
  String? dateUsed;
  String? themeId;
  String? createdAt;
  String? updatedAt;
  String? couponName;
  String? productOrderId;

  ViewUsedCouponData({
    this.id,
    this.userId,
    this.couponId,
    this.amount,
    this.orderId,
    this.dateUsed,
    this.themeId,
    this.createdAt,
    this.updatedAt,
    this.couponName,
    this.productOrderId,
  });

  ViewUsedCouponData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    couponId = json['coupon_id'];

    amount = (json['amount'] as num?)?.toDouble();

    orderId = json['order_id'];
    dateUsed = json['date_used'];
    themeId = json['theme_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    couponName = json['coupon_name'];
    productOrderId = json['product_order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['user_id'] = userId;
    data['coupon_id'] = couponId;
    data['amount'] = amount;
    data['order_id'] = orderId;
    data['date_used'] = dateUsed;
    data['theme_id'] = themeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['coupon_name'] = couponName;
    data['product_order_id'] = productOrderId;

    return data;
  }
}
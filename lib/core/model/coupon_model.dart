// ignore_for_file: unnecessary_this, prefer_collection_literals

class CouponModel {
  int ? status;
  String ? message;
  CouponModelData ? data;

  CouponModel({this.status, this.message, this.data});

  CouponModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ?  CouponModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CouponModelData {
  int ? currentPage;
  List<CouponData> ? data;
  String ? firstPageUrl;
  int ? from;
  int ? lastPage;
  String ? lastPageUrl;
  List<Links> ? links;
  String ? nextPageUrl;
  String ? path;
  int ? perPage;
  String ? prevPageUrl;
  int ? to;
  int ? total;

  CouponModelData(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  CouponModelData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null && json['data'] is List) {
      data =  <CouponData>[];
      json['data'].forEach((v) {
        data!.add(CouponData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null && json['links'] is List) {
      links =  <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}
class CouponData {
  int? id;
  String? couponName;
  String? couponCode;
  String? couponType;
  int? couponLimit;
  String? couponExpiryDate;
  int? discountAmount;
  int? status;
  String? themeId;
  int? storeId;
  String? createdAt;
  String? updatedAt;

  CouponData(
      {this.id,
        this.couponName,
        this.couponCode,
        this.couponType,
        this.couponLimit,
        this.couponExpiryDate,
        this.discountAmount,
        this.status,
        this.themeId,
        this.storeId,
        this.createdAt,
        this.updatedAt});

  CouponData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    couponName = json['coupon_name'];
    couponCode = json['coupon_code'];
    couponType = json['coupon_type'];
    couponLimit = json['coupon_limit'];
    couponExpiryDate = json['coupon_expiry_date'];
    discountAmount = json['discount_amount'];
    status = json['status'];
    themeId = json['theme_id'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['coupon_name'] = this.couponName;
    data['coupon_code'] = this.couponCode;
    data['coupon_type'] = this.couponType;
    data['coupon_limit'] = this.couponLimit;
    data['coupon_expiry_date'] = this.couponExpiryDate;
    data['discount_amount'] = this.discountAmount;
    data['status'] = this.status;
    data['theme_id'] = this.themeId;
    data['store_id'] = this.storeId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
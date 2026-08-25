// ignore_for_file: unnecessary_this, prefer_collection_literals

class CouponModel {
  int? status;
  String? message;
  CouponModelData? data;

  CouponModel({
    this.status,
    this.message,
    this.data,
  });

  CouponModel.fromJson(Map<String, dynamic> json) {
    status = (json['status'] as num?)?.toInt();
    message = json['message']?.toString();

    data = json['data'] is Map<String, dynamic>
        ? CouponModelData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['status'] = status;
    data['message'] = message;

    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }

    return data;
  }
}

class CouponModelData {
  int? currentPage;
  List<CouponData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  CouponModelData({
    this.currentPage,
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
    this.total,
  });

  CouponModelData.fromJson(Map<String, dynamic> json) {
    currentPage = (json['current_page'] as num?)?.toInt();

    if (json['data'] is List) {
      data = <CouponData>[];

      for (final item in json['data']) {
        if (item is Map<String, dynamic>) {
          data!.add(CouponData.fromJson(item));
        }
      }
    }

    firstPageUrl = json['first_page_url']?.toString();

    from = (json['from'] as num?)?.toInt();

    lastPage = (json['last_page'] as num?)?.toInt();

    lastPageUrl = json['last_page_url']?.toString();

    if (json['links'] is List) {
      links = <Links>[];

      for (final item in json['links']) {
        if (item is Map<String, dynamic>) {
          links!.add(Links.fromJson(item));
        }
      }
    }

    nextPageUrl = json['next_page_url']?.toString();

    path = json['path']?.toString();

    perPage = (json['per_page'] as num?)?.toInt();

    prevPageUrl = json['prev_page_url']?.toString();

    to = (json['to'] as num?)?.toInt();

    total = (json['total'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['current_page'] = currentPage;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;

    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }

    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;

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

  // مهم: خليها double
  double? discountAmount;

  int? status;
  String? themeId;
  int? storeId;
  String? createdAt;
  String? updatedAt;

  CouponData({
    this.id,
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
    this.updatedAt,
  });

  CouponData.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();

    couponName = json['coupon_name']?.toString();

    couponCode = json['coupon_code']?.toString();

    couponType = json['coupon_type']?.toString();

    couponLimit = (json['coupon_limit'] as num?)?.toInt();

    couponExpiryDate = json['coupon_expiry_date']?.toString();

    // يدعم int و double
    discountAmount =
        (json['discount_amount'] as num?)?.toDouble();

    status = (json['status'] as num?)?.toInt();

    themeId = json['theme_id']?.toString();

    storeId = (json['store_id'] as num?)?.toInt();

    createdAt = json['created_at']?.toString();

    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['coupon_name'] = couponName;
    data['coupon_code'] = couponCode;
    data['coupon_type'] = couponType;
    data['coupon_limit'] = couponLimit;
    data['coupon_expiry_date'] = couponExpiryDate;
    data['discount_amount'] = discountAmount;
    data['status'] = status;
    data['theme_id'] = themeId;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({
    this.url,
    this.label,
    this.active,
  });

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    label = json['label']?.toString();
    active = json['active'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['url'] = url;
    data['label'] = label;
    data['active'] = active;

    return data;
  }
}
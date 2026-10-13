// ignore_for_file: prefer_collection_literals, unnecessary_this

import '../../utils/helper.dart';
import 'package:store_go_app/network/result.dart';

class OrderModel {
  int? status;
  String? message;
  OrderModelData? data;

  OrderModel({this.status, this.message, this.data});

  OrderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] is Map ? OrderModelData.fromJson(jsonMap(json['data'])) : null;
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

class OrderModelData {
  int? currentPage;
  List<OrderData>? data;
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

  OrderModelData({
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
    this.total});

  OrderModelData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null && json['data'] is List) {
      data = <OrderData>[];
      json['data'].forEach((v) {
        if (v is! Map<String, dynamic>) return;
        data!.add(OrderData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null && json['links'] is List) {
      links = <Links>[];
      json['links'].forEach((v) {
        if (v is! Map<String, dynamic>) return;
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

class OrderData {
  int? id;
  String? productOrderId;
  String? orderDate;
  int? userId;
  int? isGuest;
  String? productJson;
  String? productId;
  String? paymentComment;
  String? paymentType;
  String? paymentStatus;
  int? deliveryId;
  String? productPrice;
  String? couponPrice;
  String? deliveryPrice;
  String? deliveryBoyId;
  String? taxPrice;
  String? finalPrice;
  String? currencySymbol;
  String? returnPrice;
  String? deliveryComment;
  int? deliveredStatus;
  String? deliveryDate;
  int? returnStatus;
  String? returnDate;
  String? cancelDate;
  double? rewardPoints;
  String? themeId;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  String? demoField;
  String? deliveredStatusString;
  String? deliveredImage;
  String? orderIdString;
  String? userName;

  OrderData(
      {this.id,
        this.productOrderId,
        this.orderDate,
        this.userId,
        this.currencySymbol,
        this.isGuest,
        this.productJson,
        this.productId,
        this.productPrice,
        this.couponPrice,
        this.deliveryPrice,
        this.taxPrice,
        this.finalPrice,
        this.returnPrice,
        this.paymentComment,
        this.paymentType,
        this.paymentStatus,
        this.deliveryId,
        this.deliveryComment,
        this.deliveredStatus,
        this.deliveryBoyId,
        this.deliveryDate,
        this.returnStatus,
        this.returnDate,
        this.cancelDate,
        this.rewardPoints,
        this.themeId,
        this.storeId,
        this.createdAt,
        this.updatedAt,
        this.demoField,
        this.deliveredStatusString,
        this.deliveredImage,
        this.orderIdString,
        this.userName});

  OrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productOrderId = json['product_order_id'];
    orderDate = json['order_date'];
    userId = json['user_id'];
    currencySymbol = json['currency_symbol'];
    isGuest = json['is_guest'];
    productJson = json['product_json'];
    productId = json['product_id'];
    productPrice = formatPriceRaw(json['product_price']);
    couponPrice = formatPriceRaw(json['coupon_price']);
    deliveryPrice = formatPriceRaw(json['delivery_price']);
    taxPrice = formatPriceRaw(json['tax_price']);
    finalPrice = formatPriceRaw(json['final_price']);
    returnPrice = formatPriceRaw(json['return_price']);
    paymentComment = json['payment_comment'];
    deliveryBoyId = json['deliveryboy_id']?.toString();
    paymentType = json['payment_type'];
    paymentStatus = json['payment_status'];
    deliveryId = json['delivery_id'];
    deliveryComment = json['delivery_comment'];
    deliveredStatus = json['delivered_status'];
    deliveryDate = json['delivery_date'];
    returnStatus = json['return_status'];
    returnDate = json['return_date'];
    cancelDate = json['cancel_date'];
    rewardPoints = json['reward_points'] != null ? double.tryParse(json['reward_points'].toString()) : null;
    themeId = json['theme_id'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    demoField = json['demo_field'];
    deliveredStatusString = json['delivered_status_string'];
    deliveredImage = json['delivered_image'];
    orderIdString = json['order_id_string'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['product_order_id'] = this.productOrderId;
    data['currency_symbol'] = this.currencySymbol;
    data['order_date'] = this.orderDate;
    data['user_id'] = this.userId;
    data['is_guest'] = this.isGuest;
    data['product_json'] = this.productJson;
    data['product_id'] = this.productId;
    data['deliveryboy_id'] = this.deliveryBoyId;
    data['product_price'] = this.productPrice;
    data['coupon_price'] = this.couponPrice;
    data['delivery_price'] = this.deliveryPrice;
    data['tax_price'] = this.taxPrice;
    data['final_price'] = this.finalPrice;
    data['return_price'] = this.returnPrice;
    data['payment_comment'] = this.paymentComment;
    data['payment_type'] = this.paymentType;
    data['payment_status'] = this.paymentStatus;
    data['delivery_id'] = this.deliveryId;
    data['delivery_comment'] = this.deliveryComment;
    data['delivered_status'] = this.deliveredStatus;
    data['delivery_date'] = this.deliveryDate;
    data['return_status'] = this.returnStatus;
    data['return_date'] = this.returnDate;
    data['cancel_date'] = this.cancelDate;
    data['reward_points'] = this.rewardPoints;
    data['theme_id'] = this.themeId;
    data['store_id'] = this.storeId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['demo_field'] = this.demoField;
    data['delivered_status_string'] = this.deliveredStatusString;
    data['delivered_image'] = this.deliveredImage;
    data['order_id_string'] = this.orderIdString;
    data['user_name'] = this.userName;
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

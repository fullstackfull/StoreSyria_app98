// ignore_for_file: prefer_collection_literals, unnecessary_this

import 'coupon_model.dart';

class ShippingModel {
  int? status;
  String? message;
  ShippingModelData? data;

  ShippingModel({this.status, this.message, this.data});

  ShippingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ShippingModelData.fromJson(json['data']) : null;
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

class ShippingModelData {
  int ? currentPage;
  List<ShippingData> ? data;
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

  ShippingModelData(
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

  ShippingModelData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null && json['data'] is List) {
      data = <ShippingData>[];
      json['data'].forEach((v) {
        data!.add(ShippingData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null && json['links'] is List) {
      links = <Links>[];
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

class ShippingData {
  int? id;
  String? name;
  String? description;
  String? imagePath;
  String? amount;
  int? returnOrderDutation;
  String? chargesType;
  String? themeId;
  String? status;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  String? expetedDelivery;
  String? imagePathFullUrl;

  ShippingData(
      {this.id,
        this.name,
        this.description,
        this.imagePath,
        this.amount,
        this.returnOrderDutation,
        this.chargesType,
        this.themeId,
        this.status,
        this.storeId,
        this.createdAt,
        this.updatedAt,
        this.expetedDelivery,
        this.imagePathFullUrl});

  ShippingData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imagePath = json['image_path'];
    amount = json['amount'];
    returnOrderDutation = json['return_order_dutation'];
    chargesType = json['charges_type'];
    themeId = json['theme_id'];
    status = json['status'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    expetedDelivery = json['expeted_delivery'];
    imagePathFullUrl = json['image_path_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image_path'] = this.imagePath;
    data['amount'] = this.amount;
    data['return_order_dutation'] = this.returnOrderDutation;
    data['charges_type'] = this.chargesType;
    data['theme_id'] = this.themeId;
    data['status'] = this.status;
    data['store_id'] = this.storeId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['expeted_delivery'] = this.expetedDelivery;
    data['image_path_full_url'] = this.imagePathFullUrl;
    return data;
  }
}

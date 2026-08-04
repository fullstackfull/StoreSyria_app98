// ignore_for_file: prefer_collection_literals, unnecessary_this

import 'coupon_model.dart';

class TaxModel {
  int status;
  String message;
  TaxModelData data;

  TaxModel({
    this.status = 0,
    this.message = '',
    TaxModelData? data,
  }) : data = data ?? TaxModelData();

  TaxModel.fromJson(Map<String, dynamic> json)
      : status = json['status'] ?? 0,
        message = json['message'] ?? '',
        data = json['data'] != null
            ? TaxModelData.fromJson(json['data'])
            : TaxModelData();

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}


class TaxModelData {
  int currentPage;
  List<Tax> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Links> links;
  String nextPageUrl;
  String path;
  int perPage;
  String prevPageUrl;
  int to;
  int total;


  TaxModelData({
    this.currentPage = 0,
    List<Tax>? data,
    this.firstPageUrl = '',
    this.from = 0,
    this.lastPage = 0,
    this.lastPageUrl = '',
    List<Links>? links,
    this.nextPageUrl = '',
    this.path = '',
    this.perPage = 0,
    this.prevPageUrl = '',
    this.to = 0,
    this.total = 0,
  })  : data = data ?? [],
        links = links ?? [];


  TaxModelData.fromJson(Map<String, dynamic> json)
      : currentPage = json['current_page'] ?? 0,
        firstPageUrl = json['first_page_url'] ?? '',
        from = json['from'] ?? 0,
        lastPage = json['last_page'] ?? 0,
        lastPageUrl = json['last_page_url'] ?? '',
        nextPageUrl = json['next_page_url'] ?? '',
        path = json['path'] ?? '',
        perPage = json['per_page'] ?? 0,
        prevPageUrl = json['prev_page_url'] ?? '',
        to = json['to'] ?? 0,
        total = json['total'] ?? 0,
        data = [],
        links = [] {

    if (json['data'] != null && json['data'] is List) {
      data = (json['data'] as List)
          .map((e) => Tax.fromJson(e))
          .toList();
    }

    if (json['links'] != null && json['links'] is List) {
      links = (json['links'] as List)
          .map((e) => Links.fromJson(e))
          .toList();
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((e) => e.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links.map((e) => e.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}


class Tax {
  int id;
  String taxName;
  String taxType;
  int taxAmount;
  int status;
  String themeId;
  int storeId;
  String createdAt;
  String updatedAt;
  String demoField;
  String taxString;

  Tax({
    this.id = 0,
    this.taxName = '',
    this.taxType = '',
    this.taxAmount = 0,
    this.status = 0,
    this.themeId = '',
    this.storeId = 0,
    this.createdAt = '',
    this.updatedAt = '',
    this.demoField = '',
    this.taxString = '',
  });


  Tax.fromJson(dynamic json)
      : id = json['id'] ?? 0,
        taxName = json['tax_name'] ?? json['name'] ?? '',
        taxType = json['tax_type'] ?? '',
        taxAmount = int.tryParse(
          json['tax_amount']?.toString() ?? '0',
        ) ??
            0,
        status = json['status'] ?? 0,
        themeId = json['theme_id']?.toString() ?? '',
        storeId = json['store_id'] ?? 0,
        createdAt = json['created_at'] ?? '',
        updatedAt = json['updated_at'] ?? '',
        demoField = json['demo_field'] ?? '',
        taxString = json['tax_string'] ?? '';


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tax_name': taxName,
      'tax_type': taxType,
      'tax_amount': taxAmount,
      'status': status,
      'theme_id': themeId,
      'store_id': storeId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'demo_field': demoField,
      'tax_string': taxString,
    };
  }
}
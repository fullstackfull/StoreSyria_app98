// ignore_for_file: unnecessary_this, prefer_collection_literals

class CreateProductModel {
  int? status;
  String? message;
  CreateProductData? data;

  CreateProductModel({this.status, this.message, this.data});

  CreateProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] as int?;
    message = json['message'] as String?;
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? CreateProductData.fromJson(json['data'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreateProductData {
  List<Category>? category;
  List<Category>? variant;
  Details? details;

  CreateProductData({this.category, this.variant, this.details});

  CreateProductData.fromJson(Map<String, dynamic> json) {
    if (json['category'] != null && json['category'] is List) {
      category = <Category>[];
      for (var v in json['category']) {
        if (v is Map<String, dynamic>) {
          category!.add(Category.fromJson(v));
        }
      }
    }

    if (json['variant'] != null && json['variant'] is List) {
      variant = <Category>[];
      for (var v in json['variant']) {
        if (v is Map<String, dynamic>) {
          variant!.add(Category.fromJson(v));
        }
      }
    }

    details = json['details'] != null && json['details'] is Map<String, dynamic>
        ? Details.fromJson(json['details'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    if (this.variant != null) {
      data['variant'] = this.variant!.map((v) => v.toJson()).toList();
    }
    if (this.details != null) {
      data['details'] = this.details!.toJson();
    }
    return data;
  }
}

class Category {
  int? id;
  String? name;

  Category({this.id, this.name});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class Details {
  ProductOtherDescription? productOtherDescription;

  Details({this.productOtherDescription});

  Details.fromJson(Map<String, dynamic> json) {
    productOtherDescription = json['product-other-description'] != null &&
        json['product-other-description'] is Map<String, dynamic>
        ? ProductOtherDescription.fromJson(
        json['product-other-description'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.productOtherDescription != null) {
      data['product-other-description'] = this.productOtherDescription!.toJson();
    }
    return data;
  }
}

class ProductOtherDescription {
  String productOtherDescriptionOtherDescription;
  String productOtherDescriptionOtherDescriptionImage;
  String productOtherDescriptionMoreInformations;
  String productOtherDescriptionMoreInformationImage;

  ProductOtherDescription({
    this.productOtherDescriptionOtherDescription = '',
    this.productOtherDescriptionOtherDescriptionImage = '',
    this.productOtherDescriptionMoreInformations = '',
    this.productOtherDescriptionMoreInformationImage = '',
  });

  ProductOtherDescription.fromJson(Map<String, dynamic> json)
      : productOtherDescriptionOtherDescription =
      json['product-other-description-other-description'] ?? '',
        productOtherDescriptionOtherDescriptionImage =
            json['product-other-description-other-description-image'] ?? '',
        productOtherDescriptionMoreInformations =
            json['product-other-description-more-informations'] ?? '',
        productOtherDescriptionMoreInformationImage =
            json['product-other-description-more-information-image'] ?? '';


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product-other-description-other-description'] =
        this.productOtherDescriptionOtherDescription;
    data['product-other-description-other-description-image'] =
        this.productOtherDescriptionOtherDescriptionImage;
    data['product-other-description-more-informations'] =
        this.productOtherDescriptionMoreInformations;
    data['product-other-description-more-information-image'] =
        this.productOtherDescriptionMoreInformationImage;
    return data;
  }
}
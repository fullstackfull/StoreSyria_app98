import 'package:store_go_app/core/model/product_model.dart';

class ProductDetailModel {
  int? status;
  String? message;
  ProductDetailData? data;

  ProductDetailModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] is Map
          ? ProductDetailData.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ProductDetailData {
  ProductData? product;
  String? currencySymbol;
  List<SubImage> subImages;

  ProductDetailData({
    this.product,
    this.currencySymbol,
    this.subImages = const [],
  });

  factory ProductDetailData.fromJson(Map<String, dynamic> json) {
    ProductData? product;
    String? currencySymbol;

    if (json['Product'] is Map) {
      final productJson =
      Map<String, dynamic>.from(json['Product']);

      product = ProductData.fromJson(productJson);

      currencySymbol = productJson['currency_symbol']?.toString();
    }

    final List<SubImage> subImages = [];

    if (json['Sub_Image'] is List) {
      for (final item in json['Sub_Image']) {
        if (item is Map) {
          subImages.add(
            SubImage.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return ProductDetailData(
      product: product,
      currencySymbol: currencySymbol,
      subImages: subImages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Product': product?.toJson(),
      'currency_symbol': currencySymbol,
      'Sub_Image': subImages
          .map((image) => image.toJson())
          .toList(),
    };
  }
}

class SubImage {
  int? id;
  int? productId;
  String? imagePath;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  String? demoField;
  String? imagePathFullUrl;

  SubImage({
    this.id,
    this.productId,
    this.imagePath,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.demoField,
    this.imagePathFullUrl,
  });

  factory SubImage.fromJson(Map<String, dynamic> json) {
    return SubImage(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),

      productId: json['product_id'] is int
          ? json['product_id'] as int
          : int.tryParse(
        json['product_id']?.toString() ?? '',
      ),

      imagePath: json['image_path']?.toString(),

      storeId: json['store_id'] is int
          ? json['store_id'] as int
          : int.tryParse(
        json['store_id']?.toString() ?? '',
      ),

      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      demoField: json['demo_field']?.toString(),

      imagePathFullUrl:
      json['image_path_full_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'image_path': imagePath,
      'store_id': storeId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'demo_field': demoField,
      'image_path_full_url': imagePathFullUrl,
    };
  }
}
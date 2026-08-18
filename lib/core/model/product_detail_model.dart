// ignore_for_file: prefer_collection_literals, unnecessary_this
// updated
import 'package:store_go_app/core/model/product_model.dart';

class ProductDetailModel {
  int? status;
  String? message;
  ProductDetailData? data;

  ProductDetailModel({this.status, this.message, this.data});

  ProductDetailModel.fromJson(Map<String, dynamic> json) {
    // ✅ استخدام as? بدلاً من التعيين المباشر لمنع الكراش إذا كان النوع مختلفاً
    status = json['status'] as int?;
    message = json['message'] as String?;
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? ProductDetailData.fromJson(json['data'] as Map<String, dynamic>)
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

class ProductDetailData {
  ProductData? product;
  List<SubImage>? subImage;

  ProductDetailData({this.product, this.subImage});

  ProductDetailData.fromJson(Map<String, dynamic> json) {
    // ✅ التحقق من النوع قبل التحويل
    product = json['Product'] != null && json['Product'] is Map<String, dynamic>
        ? ProductData.fromJson(json['Product'] as Map<String, dynamic>)
        : null;

    // ✅ التعامل الآمن مع القوائم التي قد تكون null أو أنواعها خاطئ
    if (json['Sub_Image'] != null && json['Sub_Image'] is List) {
      subImage = <SubImage>[];
      for (var v in json['Sub_Image']) {
        if (v is Map<String, dynamic>) {
          subImage!.add(SubImage.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.product != null) {
      data['Product'] = this.product!.toJson();
    }
    if (this.subImage != null) {
      data['Sub_Image'] = this.subImage!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  int? id;
  String? name;
  String? description;
  String? otherDescription;
  String? otherDescriptionApi;
  String? tag;
  String? tagApi;
  int? categoryId;
  int? subcategoryId;
  String? coverImagePath;
  String? coverImageUrl;
  double? price;
  String? discountType;
  int? discountAmount;
  int? productStock;
  int? variantProduct;
  dynamic variantId;
  dynamic variantAttribute;
  int? defaultVariantId;
  int? trending;
  int? averageRating;
  String? slug;
  String? themeId;
  int? status;
  dynamic productOption;
  dynamic productOptionApi;
  int? storeId;
  int? createdBy;
  dynamic isActive;
  String? createdAt;
  String? updatedAt;
  String? demoField;
  String? categoryName;
  int? maincategoryId;
  List<OtherDescriptionArray>? otherDescriptionArray;
  bool? inCart;
  bool? inWhishlist;
  String? defaultVariantPrice;
  String? defaultVariantName;
  String? originalPrice;
  String? discountPrice;
  String? finalPrice;
  int? isReview;
  String? retuenText;
  String? coverImagePathFullUrl;
  List<dynamic>? productOptionArray;

  Product({
    this.id, this.name, this.description, this.otherDescription,
    this.otherDescriptionApi, this.tag, this.tagApi, this.categoryId,
    this.subcategoryId, this.coverImagePath, this.coverImageUrl,
    this.price, this.discountType, this.discountAmount, this.productStock,
    this.variantProduct, this.variantId, this.variantAttribute,
    this.defaultVariantId, this.trending, this.averageRating, this.slug,
    this.themeId, this.status, this.productOption, this.productOptionApi,
    this.storeId, this.createdBy, this.isActive, this.createdAt,
    this.updatedAt, this.demoField, this.categoryName, this.maincategoryId,
    this.otherDescriptionArray, this.inCart, this.inWhishlist,
    this.defaultVariantPrice, this.defaultVariantName, this.originalPrice,
    this.discountPrice, this.finalPrice, this.isReview, this.retuenText,
    this.coverImagePathFullUrl, this.productOptionArray,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name'] as String?;
    description = json['description'] as String?;
    otherDescription = json['other_description'] as String?;
    otherDescriptionApi = json['other_description_api'] as String?;
    tag = json['tag'] as String?;
    tagApi = json['tag_api'] as String?;
    categoryId = json['category_id'] as int?;
    subcategoryId = json['subcategory_id'] as int?;
    coverImagePath = json['cover_image_path'] as String?;
    coverImageUrl = json['cover_image_url'] as String?;

    // ✅ الحماية من الكراش عند تحويل السعر: قد يأتي كـ String أو int أو null
    try {
      price = json['price'] != null ? double.parse(json['price'].toString()) : null;
    } catch (_) {
      price = null;
    }

    discountType = json['discount_type'] as String?;
    discountAmount = json['discount_amount'] as int?;
    productStock = json['product_stock'] as int?;
    variantProduct = json['variant_product'] as int?;
    variantId = json['variant_id'];
    variantAttribute = json['variant_attribute'];
    defaultVariantId = json['default_variant_id'] as int?;
    trending = json['trending'] as int?;
    averageRating = json['average_rating'] as int?;
    slug = json['slug'] as String?;
    themeId = json['theme_id'] as String?;
    status = json['status'] as int?;
    productOption = json['product_option'];
    productOptionApi = json['product_option_api'];
    storeId = json['store_id'] as int?;
    createdBy = json['created_by'] as int?;
    isActive = json['is_active'];
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    demoField = json['demo_field'] as String?;
    categoryName = json['category_name'] as String?;
    maincategoryId = json['maincategory_id'] as int?;

    if (json['other_description_array'] != null && json['other_description_array'] is List) {
      otherDescriptionArray = <OtherDescriptionArray>[];
      for (var v in json['other_description_array']) {
        if (v is Map<String, dynamic>) {
          otherDescriptionArray!.add(OtherDescriptionArray.fromJson(v));
        }
      }
    }

    inCart = json['in_cart'] as bool?;
    inWhishlist = json['in_whishlist'] as bool?;
    defaultVariantPrice = json['default_variant_price'] as String?;
    defaultVariantName = json['default_variant_name'] as String?;
    originalPrice = json['original_price'] as String?;
    discountPrice = json['discount_price'] as String?;
    finalPrice = json['final_price'] as String?;
    isReview = json['is_review'] as int?;
    retuenText = json['retuen_text'] as String?;
    coverImagePathFullUrl = json['cover_image_path_full_url'] as String?;

    // ✅ التعامل الآمن مع القوائم الديناميكية
    if (json['product_option_array'] != null && json['product_option_array'] is List) {
      productOptionArray = json['product_option_array'] as List<dynamic>;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['other_description'] = this.otherDescription;
    data['other_description_api'] = this.otherDescriptionApi;
    data['tag'] = this.tag;
    data['tag_api'] = this.tagApi;
    data['category_id'] = this.categoryId;
    data['subcategory_id'] = this.subcategoryId;
    data['cover_image_path'] = this.coverImagePath;
    data['cover_image_url'] = this.coverImageUrl;
    data['price'] = this.price;
    data['discount_type'] = this.discountType;
    data['discount_amount'] = this.discountAmount;
    data['product_stock'] = this.productStock;
    data['variant_product'] = this.variantProduct;
    data['variant_id'] = this.variantId;
    data['variant_attribute'] = this.variantAttribute;
    data['default_variant_id'] = this.defaultVariantId;
    data['trending'] = this.trending;
    data['average_rating'] = this.averageRating;
    data['slug'] = this.slug;
    data['theme_id'] = this.themeId;
    data['status'] = this.status;
    data['product_option'] = this.productOption;
    data['product_option_api'] = this.productOptionApi;
    data['store_id'] = this.storeId;
    data['created_by'] = this.createdBy;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['demo_field'] = this.demoField;
    data['category_name'] = this.categoryName;
    data['maincategory_id'] = this.maincategoryId;
    if (this.otherDescriptionArray != null) {
      data['other_description_array'] =
          this.otherDescriptionArray!.map((v) => v.toJson()).toList();
    }
    data['in_cart'] = this.inCart;
    data['in_whishlist'] = this.inWhishlist;
    data['default_variant_price'] = this.defaultVariantPrice;
    data['default_variant_name'] = this.defaultVariantName;
    data['original_price'] = this.originalPrice;
    data['discount_price'] = this.discountPrice;
    data['final_price'] = this.finalPrice;
    data['is_review'] = this.isReview;
    data['retuen_text'] = this.retuenText;
    data['cover_image_path_full_url'] = this.coverImagePathFullUrl;
    if (this.productOptionArray != null) {
      data['product_option_array'] = this.productOptionArray;
    }
    return data;
  }
}

class OtherDescriptionArray {
  String? title;
  String? description;

  OtherDescriptionArray({this.title, this.description});

  OtherDescriptionArray.fromJson(Map<String, dynamic> json) {
    title = json['title'] as String?;
    description = json['description'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = this.title;
    data['description'] = this.description;
    return data;
  }
}

class SubImage {
  int? id;
  int? productId;
  String? imagePath;
  String? themeId;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  String? demoField;
  String? imagePathFullUrl;

  SubImage({
    this.id, this.productId, this.imagePath, this.themeId,
    this.storeId, this.createdAt, this.updatedAt,
    this.demoField, this.imagePathFullUrl,
  });

  SubImage.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    productId = json['product_id'] as int?;
    imagePath = json['image_path'] as String?;
    themeId = json['theme_id'] as String?;
    storeId = json['store_id'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    demoField = json['demo_field'] as String?;
    imagePathFullUrl = json['image_path_full_url'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['image_path'] = this.imagePath;
    data['theme_id'] = this.themeId;
    data['store_id'] = this.storeId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['demo_field'] = this.demoField;
    data['image_path_full_url'] = this.imagePathFullUrl;
    return data;
  }
}
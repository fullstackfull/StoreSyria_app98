// updated
import '../../utils/helper.dart';

class ProductModel {
  int? status;
  String? message;
  ProductModelData? data;

  ProductModel({this.status, this.message, this.data});

  ProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] as int?;
    message = json['message'] as String?;
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? ProductModelData.fromJson(json['data'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) data['data'] = this.data!.toJson();
    return data;
  }
}

class ProductModelData {
  String? currencySymbol;
  int? currentPage, from, lastPage, perPage, to, total;
  List<ProductData>? data;
  List<Links>? links;
  String? firstPageUrl, lastPageUrl, nextPageUrl, path, prevPageUrl;

  ProductModelData({
    this.currentPage, this.data, this.firstPageUrl, this.from, this.lastPage,
    this.lastPageUrl, this.links, this.nextPageUrl, this.path, this.perPage,
    this.prevPageUrl, this.to, this.total,this.currencySymbol
  });

  ProductModelData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] as int?;
    currencySymbol = json['currency_symbol'] as String?;
    from = json['from'] as int?;
    lastPage = json['last_page'] as int?;
    perPage = json['per_page'] as int?;
    to = json['to'] as int?;
    total = json['total'] as int?;
    firstPageUrl = json['first_page_url'] as String?;
    lastPageUrl = json['last_page_url'] as String?;
    nextPageUrl = json['next_page_url'] as String?;
    path = json['path'] as String?;
    prevPageUrl = json['prev_page_url'] as String?;

    if (json['data'] != null && json['data'] is List) {
      data = <ProductData>[];
      for (var v in json['data']) {
        if (v is Map<String, dynamic>) data!.add(ProductData.fromJson(v));
      }
    }

    if (json['links'] != null && json['links'] is List) {
      links = <Links>[];
      for (var v in json['links']) {
        if (v is Map<String, dynamic>) links!.add(Links.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency_symbol'] = currencySymbol;
    data['current_page'] = currentPage; data['from'] = from; data['last_page'] = lastPage;
    data['per_page'] = perPage; data['to'] = to; data['total'] = total;
    data['first_page_url'] = firstPageUrl; data['last_page_url'] = lastPageUrl;
    data['next_page_url'] = nextPageUrl; data['path'] = path; data['prev_page_url'] = prevPageUrl;
    if (this.data != null) data['data'] = this.data!.map((v) => v.toJson()).toList();
    if (links != null) data['links'] = links!.map((v) => v.toJson()).toList();
    return data;
  }
}

class ProductData {
  int? id, categoryId, subcategoryId, brandId, labelId, taxId, shippingId;
  int? productStock, variantProduct, trending, averageRating, status;
  int? storeId, createdBy, isActive, maincategoryId, isReview;
  int? trackStock, minimumQuantity, maximumQuantity, lowStockThreshold;
  int? customFieldStatus;
  double? productWeight;

  String? price, salePrice,costPrice;
  String? finalPrice;
  String? discountAmount;
  String? discountType;

  String? name, slug, productCode, tag, tagApi;
  String? description, detail, specification;
  String? otherDescription, otherDescriptionApi;
  String? categoryName, defaultVariantName, defaultVariantPrice;
  String? retuenText, demoField, themeId;
  String? stockOrderStatus, productType, attributeId, productAttribute;
  String? taxStatus, previewType, previewVideo, previewContent, videoUrl;
  String? downloadableProduct, customField;

  String? coverImagePath, coverImageUrl;
  String? createdAt, updatedAt;

  String? variantId, variantAttribute, productOption, productOptionApi;
  List<dynamic>? productOptionArray;
  List<OtherDescriptionArray>? otherDescriptionArray;

  bool? inCart, inWhishlist;
  String? stockStatus;

  ProductData({
    this.productWeight,
    this.id, this.categoryId, this.subcategoryId, this.brandId, this.labelId,
    this.taxId, this.shippingId, this.productStock, this.variantProduct,
    this.trending, this.averageRating, this.status, this.storeId, this.createdBy,
    this.isActive, this.maincategoryId, this.isReview, this.trackStock,
    this.minimumQuantity, this.maximumQuantity, this.lowStockThreshold,
    this.customFieldStatus, this.price, this.salePrice,this.costPrice, this.finalPrice,
    this.discountAmount, this.discountType,
    this.name, this.slug, this.productCode, this.tag, this.tagApi,
    this.description, this.detail, this.specification, this.otherDescription,
    this.otherDescriptionApi, this.categoryName, this.defaultVariantName,
    this.defaultVariantPrice, this.retuenText, this.demoField, this.themeId,
    this.stockOrderStatus, this.productType, this.attributeId, this.productAttribute,
    this.taxStatus, this.previewType, this.previewVideo, this.previewContent,
    this.videoUrl, this.downloadableProduct, this.customField,
    this.coverImagePath, this.coverImageUrl,
    this.createdAt, this.updatedAt, this.variantId, this.variantAttribute,
    this.productOption, this.productOptionApi, this.productOptionArray,
    this.otherDescriptionArray, this.inCart, this.inWhishlist, this.stockStatus,
  });

  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    categoryId = json['category_id'] as int?;
    subcategoryId = json['subcategory_id'] as int?;
    brandId = json['brand_id'] as int?;
    labelId = json['label_id'] as int?;
    taxId = json['tax_id'] as int?;
    shippingId = json['shipping_id'] as int?;
    storeId = json['store_id'] as int?;
    createdBy = json['created_by'] as int?;
    maincategoryId = json['maincategory_id'] as int?;
    try {
      productWeight = json['product_weight'] != null
          ? double.tryParse(json['product_weight'].toString())
          : null;
    } catch (_) {
      productWeight = null;
    }
    productStock = json['product_stock'] as int?;
    variantProduct = json['variant_product'] as int?;
    trending = json['trending'] as int?;
    averageRating = json['average_rating'] as int?;
    status = json['status'] as int?;
    isActive = json['is_active'] as int?;
    isReview = json['is_review'] as int?;
    trackStock = json['track_stock'] as int?;
    minimumQuantity = json['minimum_quantity'] as int?;
    maximumQuantity = json['maximum_quantity'] as int?;
    lowStockThreshold = json['low_stock_threshold'] as int?;
    customFieldStatus = json['custom_field_status'] as int?;
    discountAmount = json['discount_amount'] ;

    name = json['name'] as String?;
    slug = json['slug'] as String?;
    productCode = json['product_code'] as String?;
    tag = json['tag'] as String?;
    tagApi = json['tag_api'] as String?;
    categoryName = json['category_name'] as String?;
    themeId = json['theme_id'] as String?;
    stockOrderStatus = json['stock_order_status'] as String?;
    productType = json['product_type'] as String?;
    attributeId = json['attribute_id'] as String?;
    productAttribute = json['product_attribute'] as String?;
    taxStatus = json['tax_status'] as String?;
    previewType = json['preview_type'] as String?;
    previewVideo = json['preview_video'] as String?;
    previewContent = json['preview_content'] as String?;
    videoUrl = json['video_url'] as String?;
    downloadableProduct = json['downloadable_product'] as String?;
    customField = json['custom_field'] as String?;
    demoField = json['demo_field'] as String?;
    retuenText = json['retuen_text'] as String?;
    stockStatus = json['stock_status'] as String?;

    description = json['description'] as String?;
    detail = json['detail'] as String?;
    specification = json['specification'] as String?;
    otherDescription = json['other_description'] as String?;
    otherDescriptionApi = json['other_description_api'] as String?;

    coverImagePath = json['cover_image_path'] as String?;
    coverImageUrl = json['cover_image_url'] as String?;

    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;

    variantId = json['variant_id'] as String?;
    variantAttribute = json['variant_attribute'] as String?;
    productOption = json['product_option'] as String?;
    productOptionApi = json['product_option_api'] as String?;
    defaultVariantName = json['default_variant_name'] as String?;
    defaultVariantPrice = json['default_variant_price'] as String?;

    inCart = json['in_cart'] as bool?;
    inWhishlist = json['in_whishlist'] as bool?;

    try {
      price = formatPriceRaw(json['price']);
    } catch (_) { price = null; }

    try {
      salePrice = formatPriceRaw(json['sale_price']);
    } catch (_) { salePrice = null; }

    try {
      costPrice = formatPriceRaw(json['cost_price']);
    } catch (_) { costPrice = null; }

    try {
      finalPrice = formatPriceRaw(json['final_price']);
    } catch (_) { finalPrice = null; }

    discountAmount = formatPriceRaw(json['discount_amount']);

    if (json['other_description_array'] != null && json['other_description_array'] is List) {
      otherDescriptionArray = <OtherDescriptionArray>[];
      for (var v in json['other_description_array']) {
        if (v is Map<String, dynamic>) {
          otherDescriptionArray!.add(OtherDescriptionArray.fromJson(v));
        }
      }
    }

    if (json['product_option_array'] != null && json['product_option_array'] is List) {
      productOptionArray = json['product_option_array'] as List<dynamic>;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // المعرفات والحالات
    data['id'] = id; data['category_id'] = categoryId; data['subcategory_id'] = subcategoryId;
    data['brand_id'] = brandId; data['label_id'] = labelId; data['tax_id'] = taxId;
    data['shipping_id'] = shippingId; data['store_id'] = storeId; data['created_by'] = createdBy;
    data['maincategory_id'] = maincategoryId; data['product_stock'] = productStock;
    data['variant_product'] = variantProduct; data['trending'] = trending;
    data['average_rating'] = averageRating; data['status'] = status;
    data['is_active'] = isActive; data['is_review'] = isReview;
    data['track_stock'] = trackStock; data['minimum_quantity'] = minimumQuantity;
    data['maximum_quantity'] = maximumQuantity; data['low_stock_threshold'] = lowStockThreshold;
    data['custom_field_status'] = customFieldStatus; data['discount_amount'] = discountAmount;

    // النصوص
    data['name'] = name; data['slug'] = slug; data['product_code'] = productCode;
    data['tag'] = tag; data['tag_api'] = tagApi; data['category_name'] = categoryName;
    data['theme_id'] = themeId; data['stock_order_status'] = stockOrderStatus;
    data['product_type'] = productType; data['attribute_id'] = attributeId;
    data['product_attribute'] = productAttribute; data['tax_status'] = taxStatus;
    data['preview_type'] = previewType; data['preview_video'] = previewVideo;
    data['preview_content'] = previewContent; data['video_url'] = videoUrl;
    data['downloadable_product'] = downloadableProduct; data['custom_field'] = customField;
    data['demo_field'] = demoField; data['retuen_text'] = retuenText;
    data['stock_status'] = stockStatus;

    // الوصف والصور والتواريخ
    data['description'] = description; data['detail'] = detail;
    data['specification'] = specification;
    data['other_description'] = otherDescription; data['other_description_api'] = otherDescriptionApi;
    data['cover_image_path'] = coverImagePath; data['cover_image_url'] = coverImageUrl;
    data['created_at'] = createdAt; data['updated_at'] = updatedAt;

    // الخيارات والأسعار
    data['variant_id'] = variantId; data['variant_attribute'] = variantAttribute;
    data['product_option'] = productOption; data['product_option_api'] = productOptionApi;
    data['default_variant_name'] = defaultVariantName; data['default_variant_price'] = defaultVariantPrice;
    data['in_cart'] = inCart;
    data['in_whishlist'] = inWhishlist;
    data['price'] = price;
    data['sale_price'] = salePrice;
    data['cost_price'] = costPrice;
    data['final_price'] = finalPrice;
    data['discount_type'] = discountType;

    // المصفوفات
    if (otherDescriptionArray != null) {
      data['other_description_array'] = otherDescriptionArray!.map((v) => v.toJson()).toList();
    }
    if (productOptionArray != null) {
      data['product_option_array'] = productOptionArray;
    }

    return data;
  }
}

class OtherDescriptionArray {
  String? title, description;

  OtherDescriptionArray({this.title, this.description});

  OtherDescriptionArray.fromJson(Map<String, dynamic> json) {
    title = json['title'] as String?;
    description = json['description'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}


class Links {
  String? url, label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'] as String?;
    label = json['label'] as String?;
    active = json['active'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}
// updated
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
  int? currentPage, from, lastPage, perPage, to, total;
  List<ProductData>? data;
  List<Links>? links;
  String? firstPageUrl, lastPageUrl, nextPageUrl, path, prevPageUrl;

  ProductModelData({
    this.currentPage, this.data, this.firstPageUrl, this.from, this.lastPage,
    this.lastPageUrl, this.links, this.nextPageUrl, this.path, this.perPage,
    this.prevPageUrl, this.to, this.total,
  });

  ProductModelData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] as int?;
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
  int? id, categoryId, subcategoryId, discountAmount, productStock, variantProduct;
  int? defaultVariantId, trending, averageRating, status, storeId, createdBy;
  int? isActive, maincategoryId, isReview;

  double? price;

  String? name, description, otherDescription, otherDescriptionApi, tag, tagApi;
  String? coverImagePath, coverImageUrl, discountType, variantId, variantAttribute;
  String? slug, themeId, productOption, productOptionApi, createdAt, updatedAt;
  String? demoField, categoryName, defaultVariantPrice, defaultVariantName;
  String? originalPrice, discountPrice, finalPrice, retuenText, coverImagePathFullUrl;
  double? salePrice;
  bool? inCart, inWhishlist;
  String? stockStatus;

  List<OtherDescriptionArray>? otherDescriptionArray;
  List<dynamic>? productOptionArray;

  ProductData({
    this.stockStatus,this.salePrice, this.id, this.name, this.description, this.otherDescription, this.otherDescriptionApi,
    this.tag, this.tagApi, this.categoryId, this.subcategoryId, this.coverImagePath,
    this.coverImageUrl, this.price, this.discountType, this.discountAmount,
    this.productStock, this.variantProduct, this.variantId, this.variantAttribute,
    this.defaultVariantId, this.trending, this.averageRating, this.slug, this.themeId,
    this.status, this.productOption, this.productOptionApi, this.storeId, this.createdBy,
    this.isActive, this.createdAt, this.updatedAt, this.demoField, this.categoryName,
    this.maincategoryId, this.otherDescriptionArray, this.inCart, this.inWhishlist,
    this.defaultVariantPrice, this.defaultVariantName, this.originalPrice,
    this.discountPrice, this.finalPrice, this.isReview, this.retuenText,
    this.coverImagePathFullUrl, this.productOptionArray,
  });

  ProductData.fromJson(Map<String, dynamic> json) {
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

    stockStatus = json['stock_status'] as String?;

    try {
      price = json['price'] != null ? double.parse(json['price'].toString()) : null;
    } catch (_) {
      price = null;
    }

    discountType = json['discount_type'] as String?;
    discountAmount = json['discount_amount'] as int?;
    productStock = json['product_stock'] as int?;
    variantProduct = json['variant_product'] as int?;
    variantId = json['variant_id'] as String?;
    variantAttribute = json['variant_attribute'] as String?;
    defaultVariantId = json['default_variant_id'] as int?;
    trending = json['trending'] as int?;
    averageRating = json['average_rating'] as int?;
    slug = json['slug'] as String?;
    themeId = json['theme_id'] as String?;
    status = json['status'] as int?;
    productOption = json['product_option'] as String?;
    productOptionApi = json['product_option_api'] as String?;
    storeId = json['store_id'] as int?;
    createdBy = json['created_by'] as int?;
    isActive = json['is_active'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    demoField = json['demo_field'] as String?;
    categoryName = json['category_name'] as String?;
    maincategoryId = json['maincategory_id'] as int?;

    if (json['other_description_array'] != null && json['other_description_array'] is List) {
      otherDescriptionArray = <OtherDescriptionArray>[];
      for (var v in json['other_description_array']) {
        if (v is Map<String, dynamic>) otherDescriptionArray!.add(OtherDescriptionArray.fromJson(v));
      }
    }

    try {
      salePrice = json['sale_price'] != null
          ? double.parse(json['sale_price'].toString())
          : null;
    } catch (_) {
      salePrice = null;
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

    if (json['product_option_array'] != null && json['product_option_array'] is List) {
      productOptionArray = json['product_option_array'] as List<dynamic>;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id; data['name'] = name; data['description'] = description;
    data['other_description'] = otherDescription; data['other_description_api'] = otherDescriptionApi;
    data['tag'] = tag; data['tag_api'] = tagApi; data['category_id'] = categoryId;
    data['subcategory_id'] = subcategoryId; data['cover_image_path'] = coverImagePath;
    data['cover_image_url'] = coverImageUrl; data['price'] = price;
    data['discount_type'] = discountType; data['discount_amount'] = discountAmount;
    data['product_stock'] = productStock; data['variant_product'] = variantProduct;
    data['variant_id'] = variantId; data['variant_attribute'] = variantAttribute;
    data['default_variant_id'] = defaultVariantId; data['trending'] = trending;
    data['average_rating'] = averageRating; data['slug'] = slug; data['theme_id'] = themeId;
    data['status'] = status; data['product_option'] = productOption;
    data['product_option_api'] = productOptionApi; data['store_id'] = storeId;
    data['created_by'] = createdBy; data['is_active'] = isActive;
    data['created_at'] = createdAt; data['updated_at'] = updatedAt;
    data['demo_field'] = demoField; data['category_name'] = categoryName;
    data['maincategory_id'] = maincategoryId;
    if (otherDescriptionArray != null)
      data['other_description_array'] = otherDescriptionArray!.map((v) => v.toJson()).toList();
    data['in_cart'] = inCart; data['in_whishlist'] = inWhishlist;
    data['default_variant_price'] = defaultVariantPrice; data['default_variant_name'] = defaultVariantName;
    data['original_price'] = originalPrice; data['discount_price'] = discountPrice;
    data['final_price'] = finalPrice; data['is_review'] = isReview;
    data['retuen_text'] = retuenText; data['cover_image_path_full_url'] = coverImagePathFullUrl;
    if (productOptionArray != null)
      data['product_option_array'] = productOptionArray;
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
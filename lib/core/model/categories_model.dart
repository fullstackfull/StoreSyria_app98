// ignore_for_file: unnecessary_this, prefer_collection_literals

class CategoriesModel {
  int? maxPrice;
  int? status;
  String? message;
  CategoriesModelData? data;

  CategoriesModel({
    this.maxPrice,
    this.status,
    this.message,
    this.data,
  });

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    maxPrice = _toInt(json['max_price']);
    status = _toInt(json['status']);
    message = json['message']?.toString();

    if (json['data'] is Map<String, dynamic>) {
      data = CategoriesModelData.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['max_price'] = maxPrice;
    data['status'] = status;
    data['message'] = message;

    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }

    return data;
  }
}

class CategoriesModelData {
  int? currentPage;
  int? from;
  int? lastPage;
  int? perPage;
  int? to;
  int? total;

  List<CategoryData>? data;
  List<Links>? links;

  String? firstPageUrl;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  String? prevPageUrl;

  CategoriesModelData({
    this.currentPage,
    this.from,
    this.lastPage,
    this.perPage,
    this.to,
    this.total,
    this.data,
    this.links,
    this.firstPageUrl,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.prevPageUrl,
  });

  CategoriesModelData.fromJson(Map<String, dynamic> json) {
    currentPage = _toInt(json['current_page']);
    from = _toInt(json['from']);
    lastPage = _toInt(json['last_page']);
    perPage = _toInt(json['per_page']);
    to = _toInt(json['to']);
    total = _toInt(json['total']);

    firstPageUrl = json['first_page_url']?.toString();
    lastPageUrl = json['last_page_url']?.toString();
    nextPageUrl = json['next_page_url']?.toString();
    path = json['path']?.toString();
    prevPageUrl = json['prev_page_url']?.toString();

    // Categories
    if (json['data'] is List) {
      data = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => CategoryData.fromJson(item))
          .toList();
    }

    // Pagination links
    if (json['links'] is List) {
      links = (json['links'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => Links.fromJson(item))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['current_page'] = currentPage;
    map['from'] = from;
    map['last_page'] = lastPage;
    map['per_page'] = perPage;
    map['to'] = to;
    map['total'] = total;

    map['first_page_url'] = firstPageUrl;
    map['last_page_url'] = lastPageUrl;
    map['next_page_url'] = nextPageUrl;
    map['path'] = path;
    map['prev_page_url'] = prevPageUrl;

    if (data != null) {
      map['data'] = data!
          .map((item) => item.toJson())
          .toList();
    }

    if (links != null) {
      map['links'] = links!
          .map((item) => item.toJson())
          .toList();
    }

    return map;
  }
}

class CategoryData {
  int? id;
  int? parentId;
  int? trending;
  int? status;
  int? storeId;
  int? totalProduct;

  String? name;
  String? slug;
  String? imagePath;
  String? iconPath;
  String? createdAt;
  String? updatedAt;
  String? demoField;

  String? imagePathFullUrl;
  String? iconPathFullUrl;

  CategoryData({
    this.id,
    this.name,
    this.slug,
    this.imagePath,
    this.iconPath,
    this.parentId,
    this.trending,
    this.status,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.demoField,
    this.totalProduct,
    this.imagePathFullUrl,
    this.iconPathFullUrl,
  });

  CategoryData.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    parentId = _toInt(json['parent_id']);
    trending = _toInt(json['trending']);
    status = _toInt(json['status']);
    storeId = _toInt(json['store_id']);
    totalProduct = _toInt(json['total_product']);

    name = json['name']?.toString();
    slug = json['slug']?.toString();

    imagePath = json['image_path']?.toString();
    iconPath = json['icon_path']?.toString();

    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    demoField = json['demo_field']?.toString();

    imagePathFullUrl = _cleanImageUrl(json['image_path_full_url']);
    iconPathFullUrl = _cleanImageUrl(json['icon_path_full_url']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['id'] = id;
    map['name'] = name;
    map['slug'] = slug;

    map['image_path'] = imagePath;
    map['icon_path'] = iconPath;

    map['parent_id'] = parentId;
    map['trending'] = trending;
    map['status'] = status;
    map['store_id'] = storeId;

    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['demo_field'] = demoField;

    map['total_product'] = totalProduct;

    map['image_path_full_url'] = imagePathFullUrl;
    map['icon_path_full_url'] = iconPathFullUrl;

    return map;
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
    active = json['active'] == true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['url'] = url;
    map['label'] = label;
    map['active'] = active;

    return map;
  }
}

String? _cleanImageUrl(dynamic value) {
  final url = value?.toString().trim();
  if (url == null || url.isEmpty || url.contains('default.jpg')) {
    return null;
  }
  return url;
}

int? _toInt(dynamic value) {
  if (value == null) return null;

  if (value is int) {
    return value;
  }

  if (value is double) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}
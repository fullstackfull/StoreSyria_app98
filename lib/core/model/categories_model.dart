// ignore_for_file: unnecessary_this, prefer_collection_literals
// updated
import 'coupon_model.dart'; // تأكد من صحة هذا الاستيراد إذا لم يكن مستخدماً

class CategoriesModel {
  int? status;
  String? message;
  CategoriesModelData? data;

  CategoriesModel({this.status, this.message, this.data});

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] as int?;
    message = json['message'] as String?;
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? CategoriesModelData.fromJson(json['data'] as Map<String, dynamic>)
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

class CategoriesModelData {
  int? currentPage, from, lastPage, perPage, to, total;
  List<CategoryData>? data;
  List<Links>? links;
  String? firstPageUrl, lastPageUrl, nextPageUrl, path, prevPageUrl;

  CategoriesModelData({
    this.currentPage, this.data, this.firstPageUrl, this.from, this.lastPage,
    this.lastPageUrl, this.links, this.nextPageUrl, this.path, this.perPage,
    this.prevPageUrl, this.to, this.total,
  });

  CategoriesModelData.fromJson(Map<String, dynamic> json) {
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

    // ✅ التحقق الآمن من أن القيمة قائمة قبل التكرار
    if (json['data'] != null && json['data'] is List) {
      data = <CategoryData>[];
      for (var v in json['data']) {
        if (v is Map<String, dynamic>) {
          data!.add(CategoryData.fromJson(v));
        }
      }
    }

    if (json['links'] != null && json['links'] is List) {
      links = <Links>[];
      for (var v in json['links']) {
        if (v is Map<String, dynamic>) {
          links!.add(Links.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;

    data['first_page_url'] = firstPageUrl;
    data['last_page_url'] = lastPageUrl;
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['prev_page_url'] = prevPageUrl;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryData {
  int? id, trending, status, storeId, categoryItem, maincategoryId, categoryId, totalProduct;
  String? name, imagePath, iconPath, themeId, createdAt, updatedAt, demoField;
  String? imagePathFullUrl, iconPathFullUrl;

  CategoryData({
    this.id, this.name, this.imagePath, this.iconPath, this.trending,
    this.status, this.themeId, this.storeId, this.createdAt, this.updatedAt,
    this.demoField, this.categoryItem, this.maincategoryId,
    this.imagePathFullUrl, this.iconPathFullUrl, this.totalProduct,
  });

  CategoryData.fromJson(dynamic json) {
    id = json['id'] as int?;
    categoryId = json['category_id'] as int?;
    name = json['name'] as String?;
    imagePath = json['image_path'] as String?;
    iconPath = json['icon_path'] as String?;
    trending = json['trending'] as int?;
    status = json['status'] as int?;
    themeId = json['theme_id'] as String?;
    storeId = json['store_id'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    demoField = json['demo_field'] as String?;
    categoryItem = json['category_item'] as int?;
    maincategoryId = json['maincategory_id'] as int?;
    imagePathFullUrl = json['image_path_full_url'] as String?;
    iconPathFullUrl = json['icon_path_full_url'] as String?;
    totalProduct = json['total_product'] as int?;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['category_id'] = categoryId;
    map['name'] = name;
    map['image_path'] = imagePath;
    map['icon_path'] = iconPath;
    map['trending'] = trending;
    map['status'] = status;
    map['theme_id'] = themeId;
    map['store_id'] = storeId;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['demo_field'] = demoField;
    map['category_item'] = categoryItem;
    map['maincategory_id'] = maincategoryId;
    map['image_path_full_url'] = imagePathFullUrl;
    map['icon_path_full_url'] = iconPathFullUrl;
    map['total_product'] = totalProduct;
    return map;
  }
}
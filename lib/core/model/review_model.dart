// ignore_for_file: unnecessary_this, prefer_collection_literals
// updated
class ReviewModel {
  int? status;
  String? message;
  List<ReviewData>? data;

  ReviewModel({this.status, this.message, this.data});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] as int?;
    message = json['message'] as String?;

    if (json['data'] != null && json['data'] is List) {
      data = <ReviewData>[];
      for (var v in json['data']) {
        if (v is Map<String, dynamic>) {
          data!.add(ReviewData.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReviewData {
  int? id, userId, categoryId, productId, ratingNo, status, storeId;
  String? title, description, themeId, createdAt, updatedAt, demoField, userName, productImagePath;

  ReviewData({
    this.id, this.userId, this.categoryId, this.productId, this.ratingNo,
    this.title, this.description, this.status, this.themeId, this.storeId,
    this.createdAt, this.updatedAt, this.demoField, this.userName, this.productImagePath,
  });

  ReviewData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    userId = json['user_id'] as int?;
    categoryId = json['category_id'] as int?;
    productId = json['product_id'] as int?;
    ratingNo = json['rating_no'] as int?;
    title = json['title'] as String?;
    description = json['description'] as String?;
    status = json['status'] as int?;
    themeId = json['theme_id'] as String?;
    storeId = json['store_id'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    demoField = json['demo_field'] as String?;
    userName = json['user_name'] as String?;
    productImagePath = json['product_image_path'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id; data['user_id'] = userId; data['category_id'] = categoryId;
    data['product_id'] = productId; data['rating_no'] = ratingNo; data['title'] = title;
    data['description'] = description; data['status'] = status; data['theme_id'] = themeId;
    data['store_id'] = storeId; data['created_at'] = createdAt; data['updated_at'] = updatedAt;
    data['demo_field'] = demoField; data['user_name'] = userName; data['product_image_path'] = productImagePath;
    return data;
  }
}

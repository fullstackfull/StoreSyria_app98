// ignore_for_file: unnecessary_this, prefer_collection_literals
// updated
class GetReviewUser {
  int? status;
  String? message;
  ReviewUserData? data;

  GetReviewUser({this.status, this.message, this.data});

  GetReviewUser.fromJson(Map<String, dynamic> json) {
    status = json['status'] as int?;
    message = json['message'] as String?;
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? ReviewUserData.fromJson(json['data'] as Map<String, dynamic>)
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

class ReviewUserData {
  List<Users>? users;

  ReviewUserData({this.users});

  ReviewUserData.fromJson(Map<String, dynamic> json) {
    // ✅ التحقق الآمن من أن القيمة قائمة قبل التكرار
    if (json['users'] != null && json['users'] is List) {
      users = <Users>[];
      for (var v in json['users']) {
        if (v is Map<String, dynamic>) {
          users!.add(Users.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  int? id;
  String? name;

  Users({this.id, this.name});

  Users.fromJson(Map<String, dynamic> json) {
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
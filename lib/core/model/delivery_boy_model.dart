class DeliveryBoyModel {
  String? status;
  String? message;
  List<DeliveryBoyData>? data;

  DeliveryBoyModel({
    this.status,
    this.message,
    this.data,
  });

  DeliveryBoyModel.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();

    if (json['data'] != null) {
      data = <DeliveryBoyData>[];
      json['data'].forEach((v) {
        data!.add(DeliveryBoyData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class DeliveryBoyData {
  int? id;
  String? name;
  String? email;
  String? password;
  String? contact;
  String? profileImage;
  String? type;
  String? commissionPercentage;
  int? isCommissionEnabled;
  int? createdBy;
  int? storeId;
  String? createdAt;
  String? updatedAt;

  DeliveryBoyData({
    this.id,
    this.name,
    this.email,
    this.password,
    this.contact,
    this.profileImage,
    this.type,
    this.commissionPercentage,
    this.isCommissionEnabled,
    this.createdBy,
    this.storeId,
    this.createdAt,
    this.updatedAt,
  });

  DeliveryBoyData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    email = json['email']?.toString();
    password = json['password']?.toString();
    contact = json['contact']?.toString();
    profileImage = json['profile_image']?.toString();
    type = json['type']?.toString();
    commissionPercentage = json['commission_percentage']?.toString();
    isCommissionEnabled = json['is_commission_enabled'] is int
        ? json['is_commission_enabled']
        : int.tryParse(json['is_commission_enabled']?.toString() ?? '0');
    createdBy = json['created_by'];
    storeId = json['store_id'];
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'contact': contact,
      'profile_image': profileImage,
      'type': type,
      'commission_percentage': commissionPercentage,
      'is_commission_enabled': isCommissionEnabled,
      'created_by': createdBy,
      'store_id': storeId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

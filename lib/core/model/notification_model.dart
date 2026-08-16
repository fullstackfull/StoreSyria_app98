// // ignore_for_file: prefer_collection_literals, unnecessary_this
//
// class NotificationModel {
//   bool? status;
//   NotificationModelData? data;
//   int? count;
//
//   NotificationModel({this.status, this.data, this.count});
//
//   NotificationModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     data = json['data'] != null ? NotificationModelData.fromJson(json['data']) : null;
//     count = json['count'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['status'] = this.status;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     data['count'] = this.count;
//     return data;
//   }
// }
//
// class NotificationModelData {
//   int? currentPage;
//   List<NotificationData>? data;
//   String? firstPageUrl;
//   int? from;
//   int? lastPage;
//   String? lastPageUrl;
//   List<Links>? links;
//   String? nextPageUrl;
//   String? path;
//   int? perPage;
//   String? prevPageUrl;
//   int? to;
//   int? total;
//
//   NotificationModelData({
//     this.currentPage,
//     this.data,
//     this.firstPageUrl,
//     this.from,
//     this.lastPage,
//     this.lastPageUrl,
//     this.links,
//     this.nextPageUrl,
//     this.path,
//     this.perPage,
//     this.prevPageUrl,
//     this.to,
//     this.total,
//   });
//
//   NotificationModelData.fromJson(Map<String, dynamic> json) {
//     currentPage = json['current_page'];
//     if (json['data'] != null && json['data'] is List) {
//       data = <NotificationData>[];
//       json['data'].forEach((v) {
//         data!.add(NotificationData.fromJson(v));
//       });
//     }
//     firstPageUrl = json['first_page_url'];
//     from = json['from'];
//     lastPage = json['last_page'];
//     lastPageUrl = json['last_page_url'];
//     if (json['links'] != null && json['links'] is List) {
//       links = <Links>[];
//       json['links'].forEach((v) {
//         links!.add(Links.fromJson(v));
//       });
//     }
//     nextPageUrl = json['next_page_url'];
//     path = json['path'];
//     perPage = json['per_page'];
//     prevPageUrl = json['prev_page_url'];
//     to = json['to'];
//     total = json['total'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['current_page'] = this.currentPage;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     data['first_page_url'] = this.firstPageUrl;
//     data['from'] = this.from;
//     data['last_page'] = this.lastPage;
//     data['last_page_url'] = this.lastPageUrl;
//     if (this.links != null) {
//       data['links'] = this.links!.map((v) => v.toJson()).toList();
//     }
//     data['next_page_url'] = this.nextPageUrl;
//     data['path'] = this.path;
//     data['per_page'] = this.perPage;
//     data['prev_page_url'] = this.prevPageUrl;
//     data['to'] = this.to;
//     data['total'] = this.total;
//     return data;
//   }
// }
//
// class NotificationData {
//   int? id;
//   int? storeId;
//   int? userId;
//   String? type;
//   String? title;
//   String? message;
//   String? referenceType;
//   int? referenceId;
//   NotificationDataDetails? data;
//   bool? isRead;
//   bool? pushSent;
//   String? createdAt;
//   String? updatedAt;
//
//   NotificationData({
//     this.id,
//     this.storeId,
//     this.userId,
//     this.type,
//     this.title,
//     this.message,
//     this.referenceType,
//     this.referenceId,
//     this.data,
//     this.isRead,
//     this.pushSent,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   NotificationData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     storeId = json['store_id'];
//     userId = json['user_id'];
//     type = json['type'];
//     title = json['title'];
//     message = json['message'];
//     referenceType = json['reference_type'];
//     referenceId = json['reference_id'];
//     data = json['data'] != null ? NotificationDataDetails.fromJson(json['data']) : null;
//     isRead = json['is_read'];
//     pushSent = json['push_sent'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['id'] = this.id;
//     data['store_id'] = this.storeId;
//     data['user_id'] = this.userId;
//     data['type'] = this.type;
//     data['title'] = this.title;
//     data['message'] = this.message;
//     data['reference_type'] = this.referenceType;
//     data['reference_id'] = this.referenceId;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     data['is_read'] = this.isRead;
//     data['push_sent'] = this.pushSent;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class NotificationDataDetails {
//   int? orderId;
//   String? productOrderId;
//   int? storeId;
//   String? finalPrice;
//   String? paymentType;
//   String? paymentStatus;
//   int? deliveredStatus;
//   String? orderDate;
//
//   NotificationDataDetails({
//     this.orderId,
//     this.productOrderId,
//     this.storeId,
//     this.finalPrice,
//     this.paymentType,
//     this.paymentStatus,
//     this.deliveredStatus,
//     this.orderDate,
//   });
//
//   NotificationDataDetails.fromJson(Map<String, dynamic> json) {
//     orderId = json['order_id'];
//     productOrderId = json['product_order_id'];
//     storeId = json['store_id'];
//     finalPrice = json['final_price']?.toString();
//     paymentType = json['payment_type'];
//     paymentStatus = json['payment_status'];
//     deliveredStatus = json['delivered_status'];
//     orderDate = json['order_date'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['order_id'] = this.orderId;
//     data['product_order_id'] = this.productOrderId;
//     data['store_id'] = this.storeId;
//     data['final_price'] = this.finalPrice;
//     data['payment_type'] = this.paymentType;
//     data['payment_status'] = this.paymentStatus;
//     data['delivered_status'] = this.deliveredStatus;
//     data['order_date'] = this.orderDate;
//     return data;
//   }
// }
//
// class Links {
//   String? url;
//   String? label;
//   bool? active;
//
//   Links({this.url, this.label, this.active});
//
//   Links.fromJson(Map<String, dynamic> json) {
//     url = json['url'];
//     label = json['label'];
//     active = json['active'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['url'] = this.url;
//     data['label'] = this.label;
//     data['active'] = this.active;
//     return data;
//   }
// }

// ignore_for_file: prefer_collection_literals, unnecessary_this

class NotificationModel {
  bool? status;
  NotificationModelData? data;
  int? count;

  NotificationModel({this.status, this.data, this.count});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? NotificationModelData.fromJson(json['data']) : null;
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['count'] = this.count;
    return data;
  }
}

class NotificationModelData {
  int? currentPage;
  List<NotificationData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  NotificationModelData({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  NotificationModelData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null && json['data'] is List) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url']?.toString();
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url']?.toString();
    if (json['links'] != null && json['links'] is List) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
    path = json['path']?.toString();
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url']?.toString();
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class NotificationData {
  int? id;
  int? storeId;
  int? userId;
  String? type;
  String? title;
  String? message;
  String? referenceType;
  int? referenceId;
  NotificationDataDetails? data;
  bool? isRead;
  bool? pushSent;
  String? createdAt;
  String? updatedAt;

  NotificationData({
    this.id,
    this.storeId,
    this.userId,
    this.type,
    this.title,
    this.message,
    this.referenceType,
    this.referenceId,
    this.data,
    this.isRead,
    this.pushSent,
    this.createdAt,
    this.updatedAt,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    userId = json['user_id'];
    type = json['type']?.toString();
    title = json['title']?.toString();
    message = json['message']?.toString();
    referenceType = json['reference_type']?.toString();
    referenceId = json['reference_id'];
    data = json['data'] != null ? NotificationDataDetails.fromJson(json['data']) : null;
    isRead = json['is_read'];
    pushSent = json['push_sent'];
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['store_id'] = this.storeId;
    data['user_id'] = this.userId;
    data['type'] = this.type;
    data['title'] = this.title;
    data['message'] = this.message;
    data['reference_type'] = this.referenceType;
    data['reference_id'] = this.referenceId;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['is_read'] = this.isRead;
    data['push_sent'] = this.pushSent;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class NotificationDataDetails {
  int? orderId;
  String? productOrderId;
  int? storeId;
  String? finalPrice;
  String? paymentType;
  String? paymentStatus;
  int? deliveredStatus;
  String? orderDate;

  NotificationDataDetails({
    this.orderId,
    this.productOrderId,
    this.storeId,
    this.finalPrice,
    this.paymentType,
    this.paymentStatus,
    this.deliveredStatus,
    this.orderDate,
  });

  NotificationDataDetails.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    productOrderId = json['product_order_id']?.toString();
    storeId = json['store_id'];
    finalPrice = json['final_price']?.toString();
    paymentType = json['payment_type']?.toString();
    paymentStatus = json['payment_status']?.toString();
    deliveredStatus = json['delivered_status'];
    orderDate = json['order_date']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['product_order_id'] = this.productOrderId;
    data['store_id'] = this.storeId;
    data['final_price'] = this.finalPrice;
    data['payment_type'] = this.paymentType;
    data['payment_status'] = this.paymentStatus;
    data['delivered_status'] = this.deliveredStatus;
    data['order_date'] = this.orderDate;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    label = json['label']?.toString();
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
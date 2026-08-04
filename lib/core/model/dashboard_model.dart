// ignore_for_file: unnecessary_this

import 'package:store_go_app/core/model/product_model.dart';

class DashboardModel {
  int? status;
  String? message;
  DashboardData? data;

  DashboardModel({
    this.status,
    this.message,
    this.data,
  });

  DashboardModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? DashboardData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class DashboardData {
  DashboardData({
    this.user,
    this.store,
    this.qrcode,
    this.products,
    this.sales,
    this.order,
    this.product,
    this.recentOrder,
    this.coupons,
  });

  DashboardData.fromJson(dynamic json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['store'] != null && json['store'] is List) {
      store = [];
      json['store'].forEach((v) {
        store?.add(Store.fromJson(v));
      });
    }
    qrcode = json['qr-code'] != null ? QrCode.fromJson(json['qr-code']) : null;
    products = json['products'];
    sales = json['sales'];
    order = json['order'];
    if (json['product'] != null && json['product'] is List) {
      product = [];
      json['product'].forEach((v) {
        product?.add(ProductData.fromJson(v));
      });
    }
    if (json['recent_order'] != null && json['recent_order'] is List) {
      recentOrder = [];
      json['recent_order'].forEach((v) {
        recentOrder?.add(RecentOrder.fromJson(v));
      });
    }
    if (json['coupons'] != null && json['coupons'] is List) {
      coupons = [];
      json['coupons'].forEach((v) {
        coupons?.add(Coupons.fromJson(v));
      });
    }
    if (json['orderchart'] != null && json['orderchart'] is List) {
      orderchart = <Orderchart>[];
      json['orderchart'].forEach((v) {
        orderchart!.add(Orderchart.fromJson(v));
      });
    }
    if (json['visitorchart'] != null && json['visitorchart'] is List) {
      visitorchart = <Visitorchart>[];
      json['visitorchart'].forEach((v) {
        visitorchart!.add(Visitorchart.fromJson(v));
      });
    }
  }

  User? user;
  List<Store>? store;
  QrCode? qrcode;
  int? products;
  int? sales;
  int? order;
  List<ProductData>? product;
  List<RecentOrder>? recentOrder;
  List<Coupons>? coupons;
  List<Orderchart>? orderchart;
  List<Visitorchart>? visitorchart;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (store != null) {
      map['store'] = store?.map((v) => v.toJson()).toList();
    }
    if (qrcode != null) {
      map['qr-code'] = qrcode?.toJson();
    }
    map['products'] = products;
    map['sales'] = sales;
    map['order'] = order;
    if (product != null) {
      map['product'] = product?.map((v) => v.toJson()).toList();
    }
    if (recentOrder != null) {
      map['recent_order'] = recentOrder?.map((v) => v.toJson()).toList();
    }
    if (coupons != null) {
      map['coupons'] = coupons?.map((v) => v.toJson()).toList();
    }
    if (this.orderchart != null) {
      map['orderchart'] = this.orderchart!.map((v) => v.toJson()).toList();
    }
    if (this.visitorchart != null) {
      map['visitorchart'] = this.visitorchart!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Coupons {
  Coupons({
    this.couponName,
    this.couponCode,
    this.couponType,
    this.discountAmount,
    this.id,
  });

  Coupons.fromJson(dynamic json) {
    couponName = json['coupon_name'];
    couponCode = json['coupon_code'];
    couponType = json['coupon_type'];
    discountAmount = json['discount_amount'];
    id = json['id'];
  }

  String? couponName;
  String? couponCode;
  String? couponType;
  int? discountAmount;
  int? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['coupon_name'] = couponName;
    map['coupon_code'] = couponCode;
    map['coupon_type'] = couponType;
    map['discount_amount'] = discountAmount;
    map['id'] = id;
    return map;
  }
}

class RecentOrder {
  int? id;
  String? productOrderId;
  String? userName;
  String? orderDate;
  double? finalPrice;
  String? deliveryStatus;
  String? currency;

  RecentOrder(
      {this.id,
      this.productOrderId,
      this.userName,
      this.orderDate,
      this.finalPrice,
      this.deliveryStatus,
      this.currency});

  RecentOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productOrderId = json['product_order_id'];
    userName = json['user_name'];
    orderDate = json['order_date'];
    finalPrice = json['final_price'] != null ? double.tryParse(json['final_price'].toString()) : null;
    deliveryStatus = json['delivery_status'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['product_order_id'] = this.productOrderId;
    data['user_name'] = this.userName;
    data['order_date'] = this.orderDate;
    data['final_price'] = this.finalPrice;
    data['delivery_status'] = this.deliveryStatus;
    data['currency'] = this.currency;
    return data;
  }
}


class QrCode {
  QrCode({
    this.url,
    this.name,
  });

  QrCode.fromJson(dynamic json) {
    url = json['url'];
    name = json['name'];
  }

  String? url;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['name'] = name;
    return map;
  }
}

class Store {
  Store({
    this.id,
    this.name,
  });

  Store.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  int? id;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}

class User {
  User({
    this.name,
    this.image,
  });

  User.fromJson(dynamic json) {
    name = json['name'];
    image = json['image']==''?"https://storesyria.com/uploads/profile/avatar.png":json['image'];
  }

  String? name;
  String? image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['image'] = image;
    return map;
  }
}

class Orderchart {
  String? date;
  int? order;

  Orderchart({this.date, this.order});

  Orderchart.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    order = json['order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['date'] = this.date;
    data['order'] = this.order;
    return data;
  }
}

class Visitorchart {
  String? date;
  int? pageview;
  int? uniquePageview;

  Visitorchart({this.date, this.pageview, this.uniquePageview});

  Visitorchart.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    pageview = json['pageview'];
    uniquePageview = json['unique_pageview'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['date'] = this.date;
    data['pageview'] = this.pageview;
    data['unique_pageview'] = this.uniquePageview;
    return data;
  }
}

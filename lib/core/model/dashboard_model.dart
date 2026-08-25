// ignore_for_file: unnecessary_this

import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/core/model/static_model.dart';

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
    data = json['data'] != null
        ? DashboardData.fromJson(json['data'])
        : null;
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
    this.orderchart,
    this.visitorchart,
  });

  DashboardData.fromJson(dynamic json) {
    user = json['user'] != null
        ? User.fromJson(json['user'])
        : null;

    // Stores
    if (json['store'] != null && json['store'] is List) {
      store = <Store>[];

      json['store'].forEach((v) {
        store!.add(Store.fromJson(v));
      });
    }

    // QR Code
    qrcode = json['qr-code'] != null
        ? QrCode.fromJson(json['qr-code'])
        : null;

    products = json['products'];
    sales = json['sales'];
    order = json['order'];

    // Products
    if (json['product'] != null && json['product'] is List) {
      product = <ProductData>[];

      json['product'].forEach((v) {
        product!.add(ProductData.fromJson(v));
      });
    }

    // Recent Orders
    if (json['recent_order'] != null &&
        json['recent_order'] is List) {
      recentOrder = <RecentOrder>[];

      json['recent_order'].forEach((v) {
        recentOrder!.add(
          RecentOrder.fromJson(v),
        );
      });
    }

    // Coupons
    if (json['coupons'] != null &&
        json['coupons'] is List) {
      coupons = <Coupons>[];

      json['coupons'].forEach((v) {
        coupons!.add(
          Coupons.fromJson(v),
        );
      });
    }

    // Order Chart
    if (json['orderchart'] != null &&
        json['orderchart'] is List) {
      orderchart = <Orderchart>[];

      json['orderchart'].forEach((v) {
        orderchart!.add(
          Orderchart.fromJson(v),
        );
      });
    }

    // Visitor Chart
    if (json['visitorchart'] != null &&
        json['visitorchart'] is List) {
      visitorchart = <VisitorChartData>[];

      json['visitorchart'].forEach((v) {
        visitorchart!.add(
          VisitorChartData.fromJson(v),
        );
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

  // نفس Model الموجود في static_model.dart
  List<VisitorChartData>? visitorchart;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (user != null) {
      map['user'] = user?.toJson();
    }

    if (store != null) {
      map['store'] =
          store!.map((v) => v.toJson()).toList();
    }

    if (qrcode != null) {
      map['qr-code'] = qrcode?.toJson();
    }

    map['products'] = products;
    map['sales'] = sales;
    map['order'] = order;

    if (product != null) {
      map['product'] =
          product!.map((v) => v.toJson()).toList();
    }

    if (recentOrder != null) {
      map['recent_order'] =
          recentOrder!.map((v) => v.toJson()).toList();
    }

    if (coupons != null) {
      map['coupons'] =
          coupons!.map((v) => v.toJson()).toList();
    }

    if (orderchart != null) {
      map['orderchart'] =
          orderchart!.map((v) => v.toJson()).toList();
    }

    if (visitorchart != null) {
      map['visitorchart'] =
          visitorchart!.map((v) => v.toJson()).toList();
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

    discountAmount = json['discount_amount'] != null
        ? double.tryParse(
      json['discount_amount'].toString(),
    )
        : null;

    id = json['id'];
  }

  String? couponName;
  String? couponCode;
  String? couponType;
  double? discountAmount;
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

  RecentOrder({
    this.id,
    this.productOrderId,
    this.userName,
    this.orderDate,
    this.finalPrice,
    this.deliveryStatus,
    this.currency,
  });

  RecentOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productOrderId = json['product_order_id'];
    userName = json['user_name'];
    orderDate = json['order_date'];

    finalPrice = json['final_price'] != null
        ? double.tryParse(
      json['final_price'].toString(),
    )
        : null;

    deliveryStatus = json['delivery_status'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =
    <String, dynamic>{};

    data['id'] = id;
    data['product_order_id'] = productOrderId;
    data['user_name'] = userName;
    data['order_date'] = orderDate;
    data['final_price'] = finalPrice;
    data['delivery_status'] = deliveryStatus;
    data['currency'] = currency;

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

    final imageValue =
    json['image']?.toString().trim();

    if (imageValue == null ||
        imageValue.isEmpty ||
        imageValue.contains('default.jpg')) {
      image = null;
    } else {
      image = imageValue;
    }
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

  Orderchart({
    this.date,
    this.order,
  });

  Orderchart.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    order = json['order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =
    <String, dynamic>{};

    data['date'] = date;
    data['order'] = order;

    return data;
  }
}
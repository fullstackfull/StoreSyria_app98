
String myPaymnetType = '';

class OrderDetailModel {
  int? status;
  String? message;
  OrderDetailData? data;

  OrderDetailModel({this.status, this.message, this.data});

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? OrderDetailData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class OrderDetailData {
  int? id;
  int? isGuest;
  String? orderId;
  String? deliveryDate;
  double? orderRewardPoint;
  int? returnPrice;
  dynamic returnStatusMessage;
  String? returnDate;
  String? orderStatusText;
  int? orderStatus;
  String? orderStatusMessage;
  List<Product>? product;
  int? isReview;
  BillingInformations? billingInformations;
  BillingInformations? deliveryInformations;
  String? paymnetType;
  String? paymnet;
  String? paymentStatus;
  String? delivery;
  String? deliveredCharge;
  CouponInfo? couponInfo;
  List<Tax>? tax;
  String? subTotal;
  String? taxPrice;
  String? finalPrice;
  List<Note>? notes;

  OrderDetailData(
      {this.id,
      this.isGuest,
      this.taxPrice,
      this.orderId,
      this.deliveryDate,
      this.orderRewardPoint,
      this.returnPrice,
      this.returnStatusMessage,
      this.returnDate,
      this.orderStatusText,
      this.orderStatus,
      this.orderStatusMessage,
      this.product,
      this.isReview,
      this.billingInformations,
      this.deliveryInformations,
      this.paymnetType,
      this.paymnet,
      this.paymentStatus,
      this.notes,
      this.delivery,
      this.deliveredCharge,
      this.couponInfo,
      this.tax,
      this.subTotal,
      this.finalPrice});

  OrderDetailData.fromJson(Map<String, dynamic> json) {
    myPaymnetType = json["paymnet_type"];
    print('=======myPaymnetType========$myPaymnetType');
    id = json['id'];
    isGuest = json['is_guest'];
    orderId = json['order_id'];
    deliveryDate = json['delivery_date'];
    orderRewardPoint = json['order_reward_point'] != null ? double.tryParse(json['order_reward_point'].toString()) : null;
    returnPrice = json['return_price'];
    returnStatusMessage = json['return_status_message'];
    returnDate = json['return_date'];
    orderStatusText = json['order_status_text'];
    orderStatus = json['order_status'];
    orderStatusMessage = json['order_status_message'];
    print('===============${json['product'].runtimeType}');
    if (json['product'].runtimeType != List<dynamic>) {
      print('--------> ${json['product']}');
      product = <Product>[];
      json['product'].values.map(
        (v) {
          product!.add(Product.fromJson(v));
        },
      );
      print('-product-===------> ${json['product'].values.map(
        (v) {
          print('==>$v');
          product!.add(Product.fromJson(v));
        },
      )}');
      print('-product-------> $product');
    } else {
      if (json['product'] != null) {
        print('===============${json['product']}');
        product = <Product>[];
        json['product'].forEach((v) {
          product!.add(Product.fromJson(v));
        });
      }
    }
    isReview = json['is_review'];
    billingInformations = json['billing_informations'] != null ? BillingInformations.fromJson(json['billing_informations']) : null;
    deliveryInformations = json['delivery_informations'] != null ? BillingInformations.fromJson(json['delivery_informations']) : null;
    paymnetType = json['paymnet_type'];
    paymnet = json['paymnet'];
    paymentStatus = json['payment_status'];
    delivery = json['delivery'];
    deliveredCharge = json['delivered_charge'];
    couponInfo = json['coupon_info'] != null ? CouponInfo.fromJson(json['coupon_info']) : null;
    if (json['tax'] != null && json['tax'] is List) {
      tax = <Tax>[];
      json['tax'].forEach((v) {
        tax!.add(Tax.fromJson(v));
      });
    }
    taxPrice = json ['tax_price'] ?? "";
    subTotal = json['sub_total'];
    finalPrice = json['final_price'];
    if (json['notes'] != null && json['notes'] is List) {
      notes = <Note>[];
      json['notes'].forEach((v) {
        notes!.add(Note.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['is_guest'] = this.isGuest;
    data['order_id'] = this.orderId;
    data['delivery_date'] = this.deliveryDate;
    data['order_reward_point'] = this.orderRewardPoint;
    data['return_price'] = this.returnPrice;
    data['return_status_message'] = this.returnStatusMessage;
    data['return_date'] = this.returnDate;
    data['order_status_text'] = this.orderStatusText;
    data['order_status'] = this.orderStatus;
    data['order_status_message'] = this.orderStatusMessage;
    if (this.product != null) {
      data['product'] = this.product!.map((v) => v.toJson()).toList();
    }
    data['is_review'] = this.isReview;
    if (this.billingInformations != null) {
      data['billing_informations'] = this.billingInformations!.toJson();
    }
    if (this.deliveryInformations != null) {
      data['delivery_informations'] = this.deliveryInformations!.toJson();
    }
    data['paymnet_type'] = this.paymnetType;
    data['paymnet'] = this.paymnet;
    data['payment_status'] = this.paymentStatus;
    data['delivery'] = this.delivery;
    data['delivered_charge'] = this.deliveredCharge;
    if (this.couponInfo != null) {
      data['coupon_info'] = this.couponInfo!.toJson();
    }
    if (this.tax != null) {
      data['tax'] = this.tax!.map((v) => v.toJson()).toList();
    }
    data['sub_total'] = this.subTotal;
    data['tax_price'] = this.taxPrice;
    data['final_price'] = this.finalPrice;
    if (this.notes != null) {
      data['notes'] = this.notes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  String? productId;
  String? image;
  String? name;
  String? orignalPrice;
  String? totalOrignalPrice;
  String? perProductDiscountPrice;
  String? discountPrice;
  String? finalPrice;
  String? qty;
  String? variantId;
  String? variantName;
  bool? productReturn;

  Product({this.productId, this.image, this.name, this.orignalPrice, this.totalOrignalPrice, this.perProductDiscountPrice, this.discountPrice, this.finalPrice, this.qty, this.variantId, this.variantName, this.productReturn});

  Product.fromJson(Map<String, dynamic> json) {
    print('=======myPaymnetType========$myPaymnetType');
    productId = json['product_id'].toString();
    image = json['image'];
    name = json['name'];
    orignalPrice = json['orignal_price'].toString();
    totalOrignalPrice = json['total_orignal_price'];
    perProductDiscountPrice = json['per_product_discount_price'];
    discountPrice = json['discount_price'];
    finalPrice = json['final_price'];
    qty = myPaymnetType == "POS" ? json["quantity"].toString() : json['qty'].toString();
    variantId = json['variant_id'].toString();
    variantName = json['variant_name'];
    final returnValue = json['return'];

    if (returnValue == true || returnValue == 1 || returnValue == '1') {
      productReturn = true;
    } else {
      productReturn = false;
    }  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['image'] = this.image;
    data['name'] = this.name;
    data['orignal_price'] = this.orignalPrice;
    data['total_orignal_price'] = this.totalOrignalPrice;
    data['per_product_discount_price'] = this.perProductDiscountPrice;
    data['discount_price'] = this.discountPrice;
    data['final_price'] = this.finalPrice;
    data['qty'] = this.qty;
    data['variant_id'] = this.variantId;
    data['variant_name'] = this.variantName;
    data['return'] = this.productReturn;
    return data;
  }
}

class BillingInformations {
  String? name;
  String? address;
  String? state;
  String? country;
  String? city;
  String? postCode;
  String? email;
  String? phone;

  BillingInformations({this.name, this.address, this.state, this.country, this.city, this.postCode, this.email, this.phone});

  BillingInformations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
    state = json['state'];
    country = json['country'];
    city = json['city'];
    postCode = json['post_code'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['address'] = this.address;
    data['state'] = this.state;
    data['country'] = this.country;
    data['city'] = this.city;
    data['post_code'] = this.postCode;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class CouponInfo {
  bool? status;
  String? message;
  String? code;
  String? discountString;
  String? price;
  String? discountString2;
  String? discountAmount;
  String? discount;

  CouponInfo({this.status, this.message, this.code, this.discountString, this.price, this.discountString2, this.discountAmount, this.discount});

  CouponInfo.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    code = json['code'];
    discountString = json['discount_string'];
    price = json['price'];
    discountString2 = json['discount_string2'];
    discountAmount = json['discount_amount'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['code'] = this.code;
    data['discount_string'] = this.discountString;
    data['price'] = this.price;
    data['discount_string2'] = this.discountString2;
    data['discount_amount'] = this.discountAmount;
    data['discount'] = this.discount;
    return data;
  }
}

class Tax {
  String? taxString;
  String? amountstring;

  Tax({this.taxString, this.amountstring});

  Tax.fromJson(Map<String, dynamic> json) {
    taxString = json['tax_string'];
    amountstring = json['amountstring'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['tax_string'] = this.taxString;
    data['amountstring'] = this.amountstring;
    return data;
  }
}

// ... (الكود السابق يبقى كما هو)

class Note {
  int? id;
  int? orderId;
  int? customerId;
  String? note;
  String? noteType;
  String? status;
  String? createdAt;
  String? updatedAt;

  Note({
    this.id,
    this.orderId,
    this.customerId,
    this.note,
    this.noteType,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Note.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    customerId = json['customer_id'];
    note = json['note'];
    noteType = json['note_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['customer_id'] = this.customerId;
    data['note'] = this.note;
    data['note_type'] = this.noteType;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

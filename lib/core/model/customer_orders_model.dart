class CustomerOrdersModel {
  int? status;
  String? message;
  CustomerOrdersData? data;

  CustomerOrdersModel({
    this.status,
    this.message,
    this.data,
  });

  CustomerOrdersModel.fromJson(Map<String, dynamic> json) {
    status = _toInt(json['status']);
    message = json['message']?.toString();

    data = json['data'] != null
        ? CustomerOrdersData.fromJson(
      Map<String, dynamic>.from(json['data']),
    )
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

// =====================================================
// HELPERS
// =====================================================

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

double? _toDouble(dynamic value) {
  if (value == null) return null;

  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}

bool? _toBool(dynamic value) {
  if (value == null) return null;

  if (value is bool) {
    return value;
  }

  if (value is int) {
    return value == 1;
  }

  final String stringValue = value.toString().toLowerCase();

  if (stringValue == 'true' || stringValue == '1') {
    return true;
  }

  if (stringValue == 'false' || stringValue == '0') {
    return false;
  }

  return null;
}

// =====================================================
// CUSTOMER ORDERS DATA
// =====================================================

class CustomerOrdersData {
  CustomerProfile? customer;
  List<CustomerOrder>? orders;
  CustomerOrdersPagination? pagination;

  CustomerOrdersData({
    this.customer,
    this.orders,
    this.pagination,
  });

  CustomerOrdersData.fromJson(Map<String, dynamic> json) {
    customer = json['customer'] != null
        ? CustomerProfile.fromJson(
      Map<String, dynamic>.from(json['customer']),
    )
        : null;

    if (json['orders'] != null && json['orders'] is List) {
      orders = <CustomerOrder>[];

      for (final v in json['orders']) {
        if (v is Map<String, dynamic>) {
          orders!.add(CustomerOrder.fromJson(v));
        } else if (v is Map) {
          orders!.add(
            CustomerOrder.fromJson(
              Map<String, dynamic>.from(v),
            ),
          );
        }
      }
    } else {
      orders = [];
    }

    pagination = json['pagination'] != null
        ? CustomerOrdersPagination.fromJson(
      Map<String, dynamic>.from(json['pagination']),
    )
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customer?.toJson(),
      'orders': orders?.map((v) => v.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

// =====================================================
// CUSTOMER
// =====================================================

class CustomerProfile {
  int? id;
  String? name;
  String? email;
  String? mobile;

  CustomerAddress? defaultAddress;

  int? orders;
  String? totalSpend;
  String? aov;

  CustomerProfile({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.defaultAddress,
    this.orders,
    this.totalSpend,
    this.aov,
  });

  CustomerProfile.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);

    name = json['name']?.toString();
    email = json['email']?.toString();
    mobile = json['mobile']?.toString();

    defaultAddress = json['default_address'] != null
        ? CustomerAddress.fromJson(
      Map<String, dynamic>.from(
        json['default_address'],
      ),
    )
        : null;

    orders = _toInt(json['orders']);

    totalSpend = json['total_spend']?.toString();

    aov = json['aov']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'default_address': defaultAddress?.toJson(),
      'orders': orders,
      'total_spend': totalSpend,
      'aov': aov,
    };
  }
}

// =====================================================
// ADDRESS
// =====================================================

class CustomerAddress {
  int? id;
  String? fullName;
  String? phone;
  String? title;
  String? address;
  String? stateName;

  int? countryId;
  int? stateId;
  int? cityId;
  int? postcode;

  String? deliveryInstructions;

  int? type;

  CustomerAddress({
    this.id,
    this.fullName,
    this.phone,
    this.title,
    this.address,
    this.countryId,
    this.stateId,
    this.stateName,
    this.cityId,
    this.postcode,
    this.deliveryInstructions,
    this.type,
  });

  CustomerAddress.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);

    fullName = json['full_name']?.toString();
    phone = json['phone']?.toString();
    title = json['title']?.toString();
    address = json['address']?.toString();

    countryId = _toInt(json['country_id']);
    stateId = _toInt(json['state_id']);
    stateName = json['state_name'];
    cityId = _toInt(json['city_id']);
    postcode = _toInt(json['postcode']);

    deliveryInstructions =
        json['delivery_instructions']?.toString();

    type = _toInt(json['type']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'title': title,
      'address': address,
      'country_id': countryId,
      'state_id': stateId,
      'state_name': stateName,
      'city_id': cityId,
      'postcode': postcode,
      'delivery_instructions': deliveryInstructions,
      'type': type,
    };
  }
}

// =====================================================
// ORDER
// =====================================================

class CustomerOrder {
  int? id;
  int? isGuest;

  String? orderId;
  String? deliveryDate;

  int? orderRewardPoint;

  dynamic returnPrice;

  String? returnStatusMessage;
  String? returnDate;

  String? paymentComment;
  String? additionalNote;

  String? orderStatusText;
  int? orderStatus;
  String? orderStatusMessage;

  String? paymentStatus;
  String? paymentReceipt;

  int? deliveryboyId;
  int? deliveryId;

  String? shippingMethod;

  dynamic couponPrice;

  List<CustomerOrderProduct>? product;

  int? isReview;

  CustomerBillingInformation? billingInformations;
  CustomerDeliveryInformation? deliveryInformations;

  String? paymnetType;
  String? paymnet;

  String? delivery;
  String? deliveredCharge;

  dynamic couponInfo;

  CustomerTax? tax;

  String? subTotal;
  String? finalPrice;
  String? taxPrice;
  String? taxName;

  dynamic taxRate;
  dynamic taxType;
  dynamic taxId;

  List<dynamic>? notes;

  CustomerOrder({
    this.id,
    this.isGuest,
    this.orderId,
    this.deliveryDate,
    this.orderRewardPoint,
    this.returnPrice,
    this.returnStatusMessage,
    this.returnDate,
    this.paymentComment,
    this.additionalNote,
    this.orderStatusText,
    this.orderStatus,
    this.orderStatusMessage,
    this.paymentStatus,
    this.paymentReceipt,
    this.deliveryboyId,
    this.deliveryId,
    this.shippingMethod,
    this.couponPrice,
    this.product,
    this.isReview,
    this.billingInformations,
    this.deliveryInformations,
    this.paymnetType,
    this.paymnet,
    this.delivery,
    this.deliveredCharge,
    this.couponInfo,
    this.tax,
    this.subTotal,
    this.finalPrice,
    this.taxPrice,
    this.taxName,
    this.taxRate,
    this.taxType,
    this.taxId,
    this.notes,
  });

  CustomerOrder.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);

    isGuest = _toInt(json['is_guest']);

    orderId = json['order_id']?.toString();

    deliveryDate = json['delivery_date']?.toString();

    orderRewardPoint =
        _toInt(json['order_reward_point']);

    returnPrice = json['return_price'];

    returnStatusMessage =
        json['return_status_message']?.toString();

    returnDate =
        json['return_date']?.toString();

    paymentComment =
        json['payment_comment']?.toString();

    additionalNote =
        json['additional_note']?.toString();

    orderStatusText =
        json['order_status_text']?.toString();

    orderStatus =
        _toInt(json['order_status']);

    orderStatusMessage =
        json['order_status_message']?.toString();

    paymentStatus =
        json['payment_status']?.toString();

    paymentReceipt =
        json['payment_receipt']?.toString();

    deliveryboyId =
        _toInt(json['deliveryboy_id']);

    deliveryId =
        _toInt(json['delivery_id']);

    shippingMethod =
        json['shipping_method']?.toString();

    couponPrice =
    json['coupon_price'];

    // -------------------------------------------------
    // PRODUCTS
    // -------------------------------------------------

    if (json['product'] != null &&
        json['product'] is List) {
      product = <CustomerOrderProduct>[];

      for (final v in json['product']) {
        if (v is Map<String, dynamic>) {
          product!.add(
            CustomerOrderProduct.fromJson(v),
          );
        } else if (v is Map) {
          product!.add(
            CustomerOrderProduct.fromJson(
              Map<String, dynamic>.from(v),
            ),
          );
        }
      }
    } else {
      product = [];
    }

    isReview =
        _toInt(json['is_review']);

    // -------------------------------------------------
    // BILLING
    // -------------------------------------------------

    billingInformations =
    json['billing_informations'] != null
        ? CustomerBillingInformation.fromJson(
      Map<String, dynamic>.from(
        json['billing_informations'],
      ),
    )
        : null;

    // -------------------------------------------------
    // DELIVERY
    // -------------------------------------------------

    deliveryInformations =
    json['delivery_informations'] != null
        ? CustomerDeliveryInformation.fromJson(
      Map<String, dynamic>.from(
        json['delivery_informations'],
      ),
    )
        : null;

    paymnetType =
        json['paymnet_type']?.toString();

    paymnet =
        json['paymnet']?.toString();

    delivery =
        json['delivery']?.toString();

    deliveredCharge =
        json['delivered_charge']?.toString();

    couponInfo =
    json['coupon_info'];

    // -------------------------------------------------
    // TAX
    // -------------------------------------------------

    tax = json['tax'] != null
        ? CustomerTax.fromJson(
      Map<String, dynamic>.from(
        json['tax'],
      ),
    )
        : null;

    subTotal =
        json['sub_total']?.toString();

    finalPrice =
        json['final_price']?.toString();

    taxPrice =
        json['tax_price']?.toString();

    taxName =
        json['tax_name']?.toString();

    taxRate =
    json['tax_rate'];

    taxType =
    json['tax_type'];

    taxId =
    json['tax_id'];

    // -------------------------------------------------
    // NOTES
    // -------------------------------------------------

    notes = json['notes'] != null &&
        json['notes'] is List
        ? List<dynamic>.from(json['notes'])
        : [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_guest': isGuest,
      'order_id': orderId,
      'delivery_date': deliveryDate,
      'order_reward_point': orderRewardPoint,
      'return_price': returnPrice,
      'return_status_message': returnStatusMessage,
      'return_date': returnDate,
      'payment_comment': paymentComment,
      'additional_note': additionalNote,
      'order_status_text': orderStatusText,
      'order_status': orderStatus,
      'order_status_message': orderStatusMessage,
      'payment_status': paymentStatus,
      'payment_receipt': paymentReceipt,
      'deliveryboy_id': deliveryboyId,
      'delivery_id': deliveryId,
      'shipping_method': shippingMethod,
      'coupon_price': couponPrice,
      'product': product
          ?.map((v) => v.toJson())
          .toList(),
      'is_review': isReview,
      'billing_informations':
      billingInformations?.toJson(),
      'delivery_informations':
      deliveryInformations?.toJson(),
      'paymnet_type': paymnetType,
      'paymnet': paymnet,
      'delivery': delivery,
      'delivered_charge': deliveredCharge,
      'coupon_info': couponInfo,
      'tax': tax?.toJson(),
      'sub_total': subTotal,
      'final_price': finalPrice,
      'tax_price': taxPrice,
      'tax_name': taxName,
      'tax_rate': taxRate,
      'tax_type': taxType,
      'tax_id': taxId,
      'notes': notes,
    };
  }
}

// =====================================================
// PRODUCT
// =====================================================

class CustomerOrderProduct {
  int? productId;

  String? image;
  String? name;

  dynamic orignalPrice;

  String? totalOrignalPrice;
  String? finalPrice;

  int? qty;
  int? variantId;

  String? variantName;

  bool? returnProduct;

  CustomerOrderProduct({
    this.productId,
    this.image,
    this.name,
    this.orignalPrice,
    this.totalOrignalPrice,
    this.finalPrice,
    this.qty,
    this.variantId,
    this.variantName,
    this.returnProduct,
  });

  CustomerOrderProduct.fromJson(
      Map<String, dynamic> json,
      ) {
    // API sometimes returns 64
    // and sometimes "64"
    productId =
        _toInt(json['product_id']);

    image =
        json['image']?.toString();

    name =
        json['name']?.toString();

    orignalPrice =
    json['orignal_price'];

    totalOrignalPrice =
        json['total_orignal_price']?.toString();

    finalPrice =
        json['final_price']?.toString();

    qty =
        _toInt(json['qty']);

    variantId =
        _toInt(json['variant_id']);

    variantName =
        json['variant_name']?.toString();

    returnProduct =
        _toBool(json['return']);
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'image': image,
      'name': name,
      'orignal_price': orignalPrice,
      'total_orignal_price': totalOrignalPrice,
      'final_price': finalPrice,
      'qty': qty,
      'variant_id': variantId,
      'variant_name': variantName,
      'return': returnProduct,
    };
  }
}

// =====================================================
// BILLING INFORMATION
// =====================================================

class CustomerBillingInformation {
  String? name;
  String? address;
  String? state;
  String? country;
  String? city;
  String? postCode;
  String? email;
  String? phone;

  CustomerBillingInformation({
    this.name,
    this.address,
    this.state,
    this.country,
    this.city,
    this.postCode,
    this.email,
    this.phone,
  });

  CustomerBillingInformation.fromJson(
      Map<String, dynamic> json,
      ) {
    name =
        json['name']?.toString();

    address =
        json['address']?.toString();

    state =
        json['state']?.toString();

    country =
        json['country']?.toString();

    city =
        json['city']?.toString();

    postCode =
        json['post_code']?.toString();

    email =
        json['email']?.toString();

    phone =
        json['phone']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'state': state,
      'country': country,
      'city': city,
      'post_code': postCode,
      'email': email,
      'phone': phone,
    };
  }
}

// =====================================================
// DELIVERY INFORMATION
// =====================================================

class CustomerDeliveryInformation {
  String? name;
  String? address;
  String? state;
  String? country;
  String? city;
  String? postCode;
  String? email;
  String? phone;

  CustomerDeliveryInformation({
    this.name,
    this.address,
    this.state,
    this.country,
    this.city,
    this.postCode,
    this.email,
    this.phone,
  });

  CustomerDeliveryInformation.fromJson(
      Map<String, dynamic> json,
      ) {
    name =
        json['name']?.toString();

    address =
        json['address']?.toString();

    state =
        json['state']?.toString();

    country =
        json['country']?.toString();

    city =
        json['city']?.toString();

    postCode =
        json['post_code']?.toString();

    email =
        json['email']?.toString();

    phone =
        json['phone']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'state': state,
      'country': country,
      'city': city,
      'post_code': postCode,
      'email': email,
      'phone': phone,
    };
  }
}

// =====================================================
// TAX
// =====================================================

class CustomerTax {
  dynamic amountString;

  CustomerTax({
    this.amountString,
  });

  CustomerTax.fromJson(
      Map<String, dynamic> json,
      ) {
    amountString =
    json['amountstring'];
  }

  Map<String, dynamic> toJson() {
    return {
      'amountstring': amountString,
    };
  }
}

// =====================================================
// PAGINATION
// =====================================================

class CustomerOrdersPagination {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;

  bool? hasMore;

  String? nextPageUrl;
  String? prevPageUrl;

  CustomerOrdersPagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.hasMore,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  CustomerOrdersPagination.fromJson(
      Map<String, dynamic> json,
      ) {
    total =
        _toInt(json['total']);

    perPage =
        _toInt(json['per_page']);

    currentPage =
        _toInt(json['current_page']);

    lastPage =
        _toInt(json['last_page']);

    hasMore =
        _toBool(json['has_more']);

    nextPageUrl =
        json['next_page_url']?.toString();

    prevPageUrl =
        json['prev_page_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'per_page': perPage,
      'current_page': currentPage,
      'last_page': lastPage,
      'has_more': hasMore,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
    };
  }
}
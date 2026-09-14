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
    status = json['status'];
    message = json['message']?.toString();
    data = json['data'] != null ? CustomerOrdersData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

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
        ? CustomerProfile.fromJson(json['customer'])
        : null;

    if (json['orders'] != null) {
      orders = <CustomerOrder>[];
      json['orders'].forEach((v) {
        orders!.add(CustomerOrder.fromJson(v));
      });
    }

    pagination = json['pagination'] != null
        ? CustomerOrdersPagination.fromJson(json['pagination'])
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

class CustomerProfile {
  int? id;
  String? name;
  String? email;
  String? mobile;

  CustomerProfile({
    this.id,
    this.name,
    this.email,
    this.mobile,
  });

  CustomerProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    email = json['email']?.toString();
    mobile = json['mobile']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
    };
  }
}

class CustomerOrder {
  int? id;
  int? orderId;
  int? customerId;
  String? customerName;
  String? customerEmail;
  String? total;
  String? discount;
  String? tax;
  String? shipping;
  String? grandTotal;
  String? paymentStatus;
  String? orderStatus;
  String? paymentMethod;
  String? shippingMethod;
  String? createdAt;
  String? updatedAt;

  CustomerOrder({
    this.id,
    this.orderId,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.total,
    this.discount,
    this.tax,
    this.shipping,
    this.grandTotal,
    this.paymentStatus,
    this.orderStatus,
    this.paymentMethod,
    this.shippingMethod,
    this.createdAt,
    this.updatedAt,
  });

  CustomerOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    customerId = json['customer_id'];
    customerName = json['customer_name']?.toString();
    customerEmail = json['customer_email']?.toString();
    total = json['total']?.toString();
    discount = json['discount']?.toString();
    tax = json['tax']?.toString();
    shipping = json['shipping']?.toString();
    grandTotal = json['grand_total']?.toString();
    paymentStatus = json['payment_status']?.toString();
    orderStatus = json['order_status']?.toString();
    paymentMethod = json['payment_method']?.toString();
    shippingMethod = json['shipping_method']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'total': total,
      'discount': discount,
      'tax': tax,
      'shipping': shipping,
      'grand_total': grandTotal,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'payment_method': paymentMethod,
      'shipping_method': shippingMethod,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

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

  CustomerOrdersPagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    hasMore = json['has_more'];
    nextPageUrl = json['next_page_url']?.toString();
    prevPageUrl = json['prev_page_url']?.toString();
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

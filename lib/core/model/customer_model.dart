import 'package:store_go_app/network/result.dart';

class CustomerModel {
  int? maxPrice;
  int? status;
  String? message;
  CustomerResponse? data;

  CustomerModel({
    this.maxPrice,
    this.status,
    this.message,
    this.data,
  });

  CustomerModel.fromJson(Map<String, dynamic> json) {
    maxPrice = json['max_price'];
    status = json['status'];
    message = json['message']?.toString();

    data = json['data'] is Map ? CustomerResponse.fromJson(jsonMap(json['data']))
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'max_price': maxPrice,
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CustomerResponse {
  List<CustomerData>? customers;
  CustomerPagination? pagination;

  CustomerResponse({
    this.customers,
    this.pagination,
  });

  CustomerResponse.fromJson(Map<String, dynamic> json) {
    if (json['customers'] is List) {
      customers = <CustomerData>[];

      json['customers'].forEach((v) {
        if (v is! Map<String, dynamic>) return;
        customers!.add(CustomerData.fromJson(v));
      });
    }

    pagination = json['pagination'] is Map ? CustomerPagination.fromJson(jsonMap(json['pagination']))
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'customers':
      customers?.map((v) => v.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class CustomerData {
  int? id;
  CustomerInfo? customerInfo;
  String? email;
  String? lastActive;
  String? dateRegistered;
  int? orders;
  String? totalSpend;
  String? aov;
  int? status;
  String? statusText;
  String? city;
  String? address;

  CustomerData({
    this.id,
    this.city,
    this.address,
    this.customerInfo,
    this.email,
    this.lastActive,
    this.dateRegistered,
    this.orders,
    this.totalSpend,
    this.aov,
    this.status,
    this.statusText,
  });

  CustomerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    customerInfo = json['customer_info'] is Map ? CustomerInfo.fromJson(jsonMap(json['customer_info']))
        : null;

    email = json['email'];
    address = json['address'];
    lastActive = json['last_active'];
    dateRegistered = json['date_registered'];
    orders = json['orders'];
    totalSpend = json['total_spend'];
    aov = json['aov'];
    status = json['status'];
    statusText = json['status_text'];
    city = json['state_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_info': customerInfo?.toJson(),
      'email': email,
      'last_active': lastActive,
      'date_registered': dateRegistered,
      'orders': orders,
      'total_spend': totalSpend,
      'aov': aov,
      'status': status,
      'status_text': statusText,
    };
  }
}

class CustomerInfo {
  String? name;
  String? mobile;

  CustomerInfo({
    this.name,
    this.mobile,
  });

  CustomerInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mobile = json['mobile'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
    };
  }
}

class CustomerPagination {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  bool? hasMore;

  CustomerPagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.hasMore,
  });

  CustomerPagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    hasMore = json['has_more'];
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'per_page': perPage,
      'current_page': currentPage,
      'last_page': lastPage,
      'has_more': hasMore,
    };
  }
}

  class CustomerCityModel {
  final List<CityModel> cities;

  CustomerCityModel({
  required this.cities,
  });

  factory CustomerCityModel.fromJson(Map<String, dynamic> json) {
  return CustomerCityModel(
  cities: jsonList(json['data'])
      .whereType<Map<String, dynamic>>()
      .map((e) => CityModel.fromJson(e))
      .toList(),
  );
  }
}

  class CityModel {
  final int id;
  final String name;

  CityModel({
  required this.id,
  required this.name,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
  return CityModel(
  id: json['id'] is int ? json['id'] as int : 0,
  name: json['name']?.toString() ?? '',
  );
  }
}

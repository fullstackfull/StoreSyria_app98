import 'order_model.dart';

class TopOrderModel {
  int? status;
  String? message;
  TopOrderData? data;

  TopOrderModel({this.status, this.message, this.data});

  TopOrderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? TopOrderData.fromJson(json['data'])
        : null;
  }
}

class TopOrderData {
  int? storeId;
  String? storeName;
  List<TopOrderItem>? topOrders;
  int? count;

  TopOrderData({
    this.storeId,
    this.storeName,
    this.topOrders,
    this.count,
  });

  TopOrderData.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    storeName = json['store_name'];
    count = json['count'];

    if (json['top_orders'] != null && json['top_orders'] is List) {
      topOrders = <TopOrderItem>[];
      json['top_orders'].forEach((v) {
        topOrders!.add(TopOrderItem.fromJson(v));
      });
    }
  }
}

class TopOrderItem {
  int? id;
  String? orderNumber;
  String? customerName;
  int? customerId;
  String? orderDate;
  double? finalPrice;
  String? paymentStatus;
  int? deliveredStatus;
  String? deliveredStatusText;

  TopOrderItem({
    this.id,
    this.orderNumber,
    this.customerName,
    this.customerId,
    this.orderDate,
    this.finalPrice,
    this.paymentStatus,
    this.deliveredStatus,
    this.deliveredStatusText,
  });

  TopOrderItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['order_number'];
    customerName = json['customer_name'];
    customerId = json['customer_id'];
    orderDate = json['order_date'];

    final rawPrice = json['final_price']?.toString() ?? '';
    finalPrice = double.tryParse(rawPrice.replaceAll(',', '')) ?? 0;

    paymentStatus = json['payment_status'];
    deliveredStatus = json['delivered_status'];
    deliveredStatusText = json['delivered_status_text'];
  }

  OrderData toOrderData() {
    return OrderData(
      id: id,
      productOrderId: orderNumber,
      orderDate: orderDate,
      userId: customerId,
      finalPrice: finalPrice,
      paymentStatus: paymentStatus,
      deliveredStatus: deliveredStatus,
      deliveredStatusString: deliveredStatusText,
      userName: customerName,
    );
  }
}
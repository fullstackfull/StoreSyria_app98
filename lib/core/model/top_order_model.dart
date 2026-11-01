import 'order_model.dart';
import 'package:store_go_app/network/result.dart';

class TopOrderModel {
  int? status;
  String? message;
  TopOrderData? data;

  TopOrderModel({this.status, this.message, this.data});

  TopOrderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] is Map
        ? TopOrderData.fromJson(jsonMap(json['data']))
        : null;
  }
}

class TopOrderData {
  int? storeId;
  String? storeName;
  List<TopOrderItem>? topOrders;
  int? count;

  /// WS K. The currency symbol lives on the ENVELOPE, never on an item.
  ///
  /// `Api\DashboardController::Top_orders` computes it (DashboardController.php
  /// :7287-7296) and places it at `data.currency_symbol` (:7341). The per-item
  /// `map()` at :7311-7330 builds nine keys and this is not among them, and the
  /// `->select()` at :7306 omits the column, so even `$order->currency_symbol`
  /// inside that map would be null. `TopOrderItem.fromJson` reads the key at the
  /// ITEM level, gets null, and the card rendered "1250.00 null" on the five
  /// largest orders by value.
  ///
  /// IT CAN LEGITIMATELY BE NULL. `currency_rates.symbol` is
  /// `varchar(20) DEFAULT NULL` and the backend tests whether the ROW exists,
  /// not whether its symbol is set — so this is graceful degradation, not a
  /// guarantee the symbol appears, and a non-null assertion here would be wrong.
  String? currencySymbol;

  TopOrderData({
    this.storeId,
    this.storeName,
    this.topOrders,
    this.count,
    this.currencySymbol,
  });

  TopOrderData.fromJson(Map<String, dynamic> json) {
    storeId = json['store_id'];
    storeName = json['store_name'];
    count = json['count'];

    /* `apiText` AND NOT `jsonMap`/`jsonList`, deliberately: those two spellings
       are HARVESTED BY NAME by `response_shape_resilience_test`, which would then
       add `currency_symbol` to this model's skew set and demand it tolerate a
       List. `apiText` is not a harvested spelling, and it type-checks every level
       so a skewed shape yields '' rather than throwing — which a raw
       `json['currency_symbol']` into a `String?` field would not. */
    currencySymbol = apiText(json, ['currency_symbol']);

    if (json['top_orders'] != null && json['top_orders'] is List) {
      topOrders = <TopOrderItem>[];
      json['top_orders'].forEach((v) {
        if (v is! Map<String, dynamic>) return;
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
  String? finalPrice;
  String? currencySymbol;
  String? paymentStatus;
  int? deliveredStatus;
  String? deliveredStatusText;

  TopOrderItem({
    this.id,
    this.orderNumber,
    this.currencySymbol,
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
    currencySymbol = json['currency_symbol'];
    customerName = json['customer_name'];
    customerId = json['customer_id'];
    orderDate = json['order_date'];

    finalPrice = json['final_price']?.toString() ?? '';

    paymentStatus = json['payment_status'];
    deliveredStatus = json['delivered_status'];
    deliveredStatusText = json['delivered_status_text'];
  }

  /// [fallbackCurrencySymbol] is the ENVELOPE's symbol, applied when this item
  /// carries none — which today is always, since the backend sends it only on
  /// the envelope. The item value still wins when present, so a future backend
  /// that starts sending one per row is not overridden.
  OrderData toOrderData({String? fallbackCurrencySymbol}) {
    return OrderData(
      id: id,
      productOrderId: orderNumber,
      orderDate: orderDate,
      userId: customerId,
      currencySymbol: (currencySymbol?.isNotEmpty ?? false)
          ? currencySymbol
          : (fallbackCurrencySymbol ?? ''),
      finalPrice: finalPrice,
      paymentStatus: paymentStatus,
      deliveredStatus: deliveredStatus,
      deliveredStatusString: deliveredStatusText,
      userName: customerName,
    );
  }
}

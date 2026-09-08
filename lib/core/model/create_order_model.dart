// core/model/create_order_request_model.dart

class CreateOrderRequest {
  final int customerId;
  final List<OrderProductRequest> products;
  final String paymentType; // "cod" ...
  final String paymentStatus; // "Unpaid" ...
  final double deliveryPrice;
  final double taxPrice;
  final String firstName;
  final String lastName;
  final String email;
  final String telephone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postcode;
  final String? additionalNote;

  CreateOrderRequest({
    required this.customerId,
    required this.products,
    required this.paymentType,
    required this.paymentStatus,
    required this.deliveryPrice,
    required this.taxPrice,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postcode,
    this.additionalNote,
  });

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'products': products.map((e) => e.toJson()).toList(),
    'payment_type': paymentType,
    'payment_status': paymentStatus,
    'delivery_price': deliveryPrice,
    'tax_price': taxPrice,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'telephone': telephone,
    'address': address,
    'city': city,
    'state': state,
    'country': country,
    'postcode': postcode,
    'additional_note': additionalNote,
  };
}

class OrderProductRequest {
  final int productId;
  final int quantity;
  final double price;

  OrderProductRequest({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'price': price,
  };
}
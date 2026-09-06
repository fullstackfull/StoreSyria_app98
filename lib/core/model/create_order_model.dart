class CreateOrderRequest {
  final int customerId;
  final List<OrderProduct> products;
  final String paymentType;
  final ShippingAddress shippingAddress;
  final double deliveryPrice;
  final double taxPrice;
  final String? additionalNote;

  CreateOrderRequest({
    required this.customerId,
    required this.products,
    required this.paymentType,
    required this.shippingAddress,
    required this.deliveryPrice,
    required this.taxPrice,
    this.additionalNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'products': products.map((e) => e.toJson()).toList(),
      'payment_type': paymentType,
      'shipping_address': shippingAddress.toJson(),
      'delivery_price': deliveryPrice,
      'tax_price': taxPrice,
      'additional_note': additionalNote,
    };
  }
}
class ShippingAddress {
  final String firstName;
  final String lastName;
  final String email;
  final String telephone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postcode;

  ShippingAddress({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postcode,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'telephone': telephone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postcode': postcode,
    };
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postcode: json['postcode'] ?? '',
    );
  }
}
class OrderProduct {
  final int productId;
  final int quantity;
  final double price;

  OrderProduct({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productId: json['product_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
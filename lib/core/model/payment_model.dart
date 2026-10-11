class PaymentMethod {
  final String key;
  final String name;

  PaymentMethod({
    required this.key,
    required this.name,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
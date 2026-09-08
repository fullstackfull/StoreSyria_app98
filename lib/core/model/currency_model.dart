class CurrencyResponse {
  final int status;
  final String message;
  final CurrencyData data;

  CurrencyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CurrencyResponse.fromJson(Map<String, dynamic> json) =>
      CurrencyResponse(
        status: json['status'] ?? 0,
        message: json['message'] ?? '',
        data: CurrencyData.fromJson(json['data']),
      );
}

class CurrencyData {
  final int storeId;
  final Currency currentCurrency;
  final List<Currency> currencies;

  CurrencyData({
    required this.storeId,
    required this.currentCurrency,
    required this.currencies,
  });

  factory CurrencyData.fromJson(Map<String, dynamic> json) => CurrencyData(
    storeId: json['store_id'] ?? 0,
    currentCurrency: Currency.fromJson(json['current_currency'] ?? {}),
    currencies: (json['currencies'] as List<dynamic>? ?? [])
        .map((e) => Currency.fromJson(e))
        .toList(),
  );
}

class Currency {
  final String code;
  final String name;
  final String symbol;

  Currency({required this.code, required this.name, required this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    code: json['code'],
    name: json['name'],
    symbol: json['symbol'],
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'symbol': symbol,
  };
}
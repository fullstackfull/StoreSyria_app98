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
  final double ratePerUsd;
  final bool isActive;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.ratePerUsd,
    required this.isActive,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      ratePerUsd: (json['rate_per_usd'] ?? 1).toDouble(),
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'rate_per_usd': ratePerUsd,
      'is_active': isActive,
    };
  }
}
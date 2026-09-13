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

class CurrencyRatesResponse {
  final int status;
  final String message;
  final CurrencyRatesData? data;

  CurrencyRatesResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CurrencyRatesResponse.fromJson(Map<String, dynamic> json) =>
      CurrencyRatesResponse(
        status: json['status'] ?? 0,
        message: json['message'] ?? '',
        data: json['data'] != null ? CurrencyRatesData.fromJson(json['data']) : null,
      );
}

class CurrencyRatesData {
  final int storeId;
  final String storeName;
  final String defaultCurrency;
  final List<CurrencyRateItem> currencyRates;
  final int count;

  CurrencyRatesData({
    required this.storeId,
    required this.storeName,
    required this.defaultCurrency,
    required this.currencyRates,
    required this.count,
  });

  factory CurrencyRatesData.fromJson(Map<String, dynamic> json) => CurrencyRatesData(
    storeId: json['store_id'] ?? 0,
    storeName: json['store_name'] ?? '',
    defaultCurrency: json['default_currency'] ?? '',
    currencyRates: (json['currency_rates'] as List<dynamic>? ?? [])
        .map((e) => CurrencyRateItem.fromJson(e))
        .toList(),
    count: json['count'] ?? 0,
  );
}

class CurrencyRateItem {
  final int? id;
  final String currencyCode;
  final String currencyName;
  final String symbol;
  double ratePerUsd;
  bool isActive;

  CurrencyRateItem({
    this.id,
    required this.currencyCode,
    required this.currencyName,
    required this.symbol,
    required this.ratePerUsd,
    required this.isActive,
  });

  factory CurrencyRateItem.fromJson(Map<String, dynamic> json) => CurrencyRateItem(
    id: json['id'],
    currencyCode: json['currency_code'] ?? json['code'] ?? '',
    currencyName: json['currency_name'] ?? json['name'] ?? '',
    symbol: json['symbol'] ?? '',
    ratePerUsd: (json['rate_per_usd'] is num)
        ? (json['rate_per_usd'] as num).toDouble()
        : double.tryParse(json['rate_per_usd']?.toString() ?? '1') ?? 1.0,
    isActive: json['is_active'] == true || json['is_active'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'currency_code': currencyCode,
    'currency_name': currencyName,
    'symbol': symbol,
    'rate_per_usd': ratePerUsd,
    'is_active': isActive,
  };
}
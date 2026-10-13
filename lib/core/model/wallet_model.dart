import 'package:store_go_app/network/result.dart';

class WalletPagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  WalletPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });

  factory WalletPagination.fromJson(Map<String, dynamic> json) {
    return WalletPagination(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      hasMore: json['has_more'] ?? false,
    );
  }
}

class WalletTransaction {
  final int id;
  final String type;
  final String direction;
  final String amount;
  final String currencyCode;
  final String balanceBefore;
  final String balanceAfter;
  final String description;
  final String status;
  final String createdAt;

  WalletTransaction( {
    required this.currencyCode,
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  bool get isCredit => direction == 'credit';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? 0,
      type: json['type']?.toString() ?? '',
      direction: json['direction']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      currencyCode: json['currency_code']?.toString() ?? '',
      balanceBefore: json['balance_before']?.toString() ?? '0',
      balanceAfter: json['balance_after']?.toString() ?? '0',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class WalletData {
  final int storeId;
  final String availableBalance;
  String? currencySymbol;
  final String currencyCode;
  final List<WalletTransaction> transactions;
  final WalletPagination pagination;

  WalletData({
    required this.storeId,
    required this.currencySymbol,
    required this.availableBalance,
    required this.currencyCode,
    required this.transactions,
    required this.pagination,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      storeId: json['store_id'] ?? 0,
        currencySymbol : json['currency_symbol'] ?? "",
        availableBalance: json['available_balance']?.toString() ?? '0',
      currencyCode: json['currency_code']?.toString() ?? '',
      transactions: jsonList(json['transactions'])
          .whereType<Map<String, dynamic>>()
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
      pagination: WalletPagination.fromJson(jsonMap(json['pagination'])),
    );
  }
}
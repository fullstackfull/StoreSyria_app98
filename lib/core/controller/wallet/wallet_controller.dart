import 'package:get/get.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import '../../../config/repository/wallet_repository.dart';
import '../../model/wallet_model.dart';

class WalletController extends GetxController {
  final WalletRepository walletRepository = WalletRepository();

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isAddingBalance = false.obs;
  RxBool isDeductingBalance = false.obs;

  RxString errorMessage = ''.obs;

  RxString availableBalance = '0'.obs;
  RxString currencyCode = ''.obs;

  RxList<WalletTransaction> transactions =
      <WalletTransaction>[].obs;

  Rxn<WalletPagination> pagination =
  Rxn<WalletPagination>();

  int _currentPage = 1;

  bool get hasMore => pagination.value?.hasMore ?? false;

  @override
  void onInit() {
    super.onInit();
    getWalletData();
  }

  Future<void> getWalletData({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await walletRepository.getWalletData(
        page: _currentPage,
      );

      response.fold(
        onSuccess: (data) {
          print("Wallet Response =====> $data");

          if (data['status'] == 1) {
            final walletData =
            WalletData.fromJson(data['data']);

            availableBalance.value =
                walletData.availableBalance;

            currencyCode.value =
                walletData.currencyCode;

            transactions.assignAll(
              walletData.transactions,
            );

            pagination.value =
                walletData.pagination;

            _currentPage =
                walletData.pagination.currentPage;
          } else {
            commonToast(
              data['message'] ??
                  'Failed to load wallet data',
            );
          }
        },
        onFailure: (reason, message, errors) {
          errorMessage.value =
              message ?? 'Error loading wallet data';

          commonToast(
            message ?? 'Error loading wallet data',
          );
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // Add Balance
  // =========================

  Future<void> addBalance({
    required double amount,
    required String description,
  }) async {
    if (amount <= 0) {
      commonToast('Amount must be greater than 0');
      return;
    }

    isAddingBalance.value = true;

    try {
      final response =
      await walletRepository.addBalanceData(
        description,
        amount,
      );

      response.fold(
        onSuccess: (data) async {
          print("Add Balance Response =====> $data");

          if (data['status'] == 1) {
            final balanceData = data['data'];

            availableBalance.value = balanceData['new_available_balance'].toString();

            currencyCode.value = balanceData['currency_code'].toString();

            commonToast(data['message'] ?? 'Balance added successfully.',
            );
            Get.back();

            await getWalletData(isRefresh: true);
          } else {
            commonToast(data['message'] ?? 'Failed to add balance',
            );
          }
        },
        onFailure: (reason, message, errors) {
          commonToast(
            message ?? 'Error adding balance',
          );
        },
      );
    } finally {
      isAddingBalance.value = false;
    }
  }


  Future<void> deductBalance({
    required double amount,
    required String description,
  }) async {
    if (amount <= 0) {
      commonToast('Amount must be greater than 0');
      return;
    }

    isDeductingBalance.value = true;

    try {
      final response =
      await walletRepository.deductBalanceData(
        description,
        amount,
      );

      response.fold(
        onSuccess: (data) async {
          print("Deduct Balance Response =====> $data");

          if (data['status'] == 1) {
            final balanceData = data['data'];

            availableBalance.value =
                balanceData['new_available_balance']
                    .toString();

            currencyCode.value =
                balanceData['currency_code']
                    .toString();

            commonToast(
              data['message'] ??
                  'Balance deducted successfully.',
            );

            await getWalletData(isRefresh: true);
          } else {
            commonToast(
              data['message'] ??
                  'Failed to deduct balance',
            );
          }
        },
        onFailure: (reason, message, errors) {
          commonToast(
            message ?? 'Error deducting balance',
          );
        },
      );
    } finally {
      isDeductingBalance.value = false;
    }
  }

  // =========================
  // Load More
  // =========================

  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || !hasMore) return;

    isLoadingMore.value = true;

    try {
      final nextPage = _currentPage + 1;

      final response =
      await walletRepository.getWalletData(
        page: nextPage,
      );

      response.fold(
        onSuccess: (data) {
          print(
            "Wallet Load More Response =====> $data",
          );

          if (data['status'] == 1) {
            final walletData =
            WalletData.fromJson(data['data']);

            transactions.addAll(
              walletData.transactions,
            );

            pagination.value =
                walletData.pagination;

            _currentPage =
                walletData.pagination.currentPage;
          } else {
            commonToast(
              data['message'] ??
                  'Failed to load more',
            );
          }
        },
        onFailure: (reason, message, errors) {
          commonToast(
            message ??
                'Error loading more transactions',
          );
        },
      );
    } finally {
      isLoadingMore.value = false;
    }
  }
}
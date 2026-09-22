import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import '../../../core/controller/wallet/wallet_controller.dart';
import '../../../translations/translation_service.dart';
import '../../new_widgets/balance_card.dart';
import '../../new_widgets/search_widget.dart';
import '../../new_widgets/transactions_widget.dart';
import '../../widget/common_appbar_widget.dart';
import '../../widget/error_empty_state.dart';
import '../../widget/loading_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

enum _DirectionFilter { all, credit, debit }

class _WalletScreenState extends State<WalletScreen> {
  final WalletController controller = Get.put(WalletController());
  final ScrollController _scrollController = ScrollController();

  static const Color _danger = Color(0xFFEF4444);

  _DirectionFilter _directionFilter = _DirectionFilter.all;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreTransactions();
    }
  }

  bool get _hasActiveFilters =>
      _directionFilter != _DirectionFilter.all || _statusFilter != null;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic =
        TranslationService.currentLocale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColor.cLight,
        appBar: simpleAppBar(
          title: 'wallet'.tr,
          label: null,
          onNewLabelTap: () {},
          isBack: true,
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.transactions.isEmpty) {
              return const LoadingWidget();
            }

            if (controller.errorMessage.value.isNotEmpty &&
                controller.transactions.isEmpty) {
              return ErrorState(
                message: controller.errorMessage.value,
                onRetry: () => controller.getWalletData(isRefresh: true),
              );
            }

            final isSearchMode = controller.isSearchActive.value;
            final transactions = isSearchMode
                ? controller.searchResults
                : controller.transactions;

            return RefreshIndicator(
              color: AppColor.themeNavyBlueColor,
              onRefresh: isSearchMode
                  ? () async {}
                  : () => controller.getWalletData(isRefresh: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    sliver: SliverToBoxAdapter(
                      child: balanceCard(
                          isDark: isDark,
                          controller: controller,
                          context: context
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                    sliver: SliverToBoxAdapter(
                      child: SearchRowWidget(
                        context: context,
                        controller: controller.searchController,
                        hint: 'search_by_transaction_id'.tr,
                        onChanged: controller.onSearchChanged,
                        onClear: controller.resetSearch,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                    sliver: SliverToBoxAdapter(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _filterButton(isDark: isDark),
                      ),
                    ),
                  ),
                  if (controller.isSearchingTransactions.value &&
                      transactions.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: LoadingWidget()),
                    )
                  else if (transactions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        message: isSearchMode
                            ? 'no_transactions_found'.tr
                            : 'no_transactions_found'.tr,
                        icon: Icons.receipt_long_outlined,
                        iconColor: isDark
                            ? Colors.white38
                            : Colors.grey.shade400,
                      ),
                    )
                  else
                    SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final tx = transactions[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: transactionCard(
                              currency: controller.currencySymbol.value,
                              tx: tx,
                              isDark: isDark,
                            ),
                          );
                        },
                        childCount: transactions.length,
                      ),
                    ),
                  ),
                  if (!isSearchMode)
                    SliverToBoxAdapter(
                      child: _loadMoreIndicator(isDark: isDark),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _filterButton({required bool isDark}) {
    final Color surfaceColor =
    isDark ? const Color(0xFF23252A) : const Color(0xFFF7F8FA);
    final Color borderColor = isDark
        ? Colors.white.withOpacity(.07)
        : const Color(0xFFE8EAEE);
    final Color textColor =
    isDark ? Colors.white : const Color(0xFF15171A);

    return Material(
      color: _hasActiveFilters ? AppColor.themeNavyBlueColor : surfaceColor,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _openFilterSheet(isDark: isDark),
        child: Container(
          width: 46.w,
          height: 46.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: _hasActiveFilters
                ? null
                : Border.all(color: borderColor),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 22.sp,
                color: _hasActiveFilters ? Colors.white : textColor,
              ),
              if (_hasActiveFilters)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: _danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilterSheet({required bool isDark}) {
    _DirectionFilter tempDirection = _directionFilter;
    String? tempStatus = _statusFilter;

    final Color cardColor =
    isDark ? const Color(0xFF1B1C20) : Colors.white;
    final Color surfaceColor =
    isDark ? const Color(0xFF23252A) : const Color(0xFFF7F8FA);
    final Color textColor =
    isDark ? Colors.white : const Color(0xFF15171A);
    final Color secondaryText =
    isDark ? const Color(0xFF9297A1) : const Color(0xFF777D87);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Widget chip({
              required String label,
              required bool selected,
              required VoidCallback onTap,
            }) {
              return GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColor.themeNavyBlueColor
                        : surfaceColor,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : textColor,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 18.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'filter_transactions'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            tempDirection = _DirectionFilter.all;
                            tempStatus = null;
                          });
                        },
                        child: Text(
                          'clear'.tr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'direction'.tr,
                    style: TextStyle(fontSize: 12.5.sp, color: secondaryText),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      chip(
                        label: 'all'.tr,
                        selected: tempDirection == _DirectionFilter.all,
                        onTap: () => setSheetState(
                                () => tempDirection = _DirectionFilter.all),
                      ),
                      chip(
                        label: 'credit'.tr,
                        selected: tempDirection == _DirectionFilter.credit,
                        onTap: () => setSheetState(
                                () => tempDirection = _DirectionFilter.credit),
                      ),
                      chip(
                        label: 'debit'.tr,
                        selected: tempDirection == _DirectionFilter.debit,
                        onTap: () => setSheetState(
                                () => tempDirection = _DirectionFilter.debit),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'status'.tr,
                    style: TextStyle(fontSize: 12.5.sp, color: secondaryText),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      chip(
                        label: 'all'.tr,
                        selected: tempStatus == null,
                        onTap: () => setSheetState(() => tempStatus = null),
                      ),
                      chip(
                        label: 'completed'.tr,
                        selected: tempStatus == 'completed',
                        onTap: () =>
                            setSheetState(() => tempStatus = 'completed'),
                      ),
                      chip(
                        label: 'pending'.tr,
                        selected: tempStatus == 'pending',
                        onTap: () =>
                            setSheetState(() => tempStatus = 'pending'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.themeNavyBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // TODO: لما تجهز فلترة الـ API، ابعت tempDirection/tempStatus
                        setState(() {
                          _directionFilter = tempDirection;
                          _statusFilter = tempStatus;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'apply_filters'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _loadMoreIndicator({required bool isDark}) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Center(
            child: SizedBox(
              width: 22.w,
              height: 22.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColor.themeNavyBlueColor,
                ),
              ),
            ),
          ),
        );
      }
      return SizedBox(height: 30.h);
    });
  }
}
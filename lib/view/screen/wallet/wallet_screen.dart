import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import '../../../core/controller/wallet/wallet_controller.dart';
import '../../../translations/translation_service.dart';
import '../../../utils/text_style.dart';
import '../../new_widgets/balance_card.dart';
import '../../new_widgets/date_filter.dart';
import '../../new_widgets/search_widget.dart';
import '../../new_widgets/shimmer.dart';
import '../../new_widgets/transactions_widget.dart';
import '../../widget/common_appbar_widget.dart';
import '../../widget/error_empty_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

const List<String> _kTransactionTypes = [
  "manual_deposit",
  "manual_withdrawal",
  "order_paid",
  "sale",
  "refund",
  "commission",
  "adjustment",
];

class _WalletScreenState extends State<WalletScreen> {
  final WalletController controller = Get.put(WalletController());
  final ScrollController _scrollController = ScrollController();

  static const Color _danger = Color(0xFFEF4444);

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
              return const ShimmerDetails(sections: 5, rowsPerSection: 4);
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
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchRowWidget(
                              context: context,
                              controller: controller.searchController,
                              hint: 'search_by_id'.tr,
                              onChanged: controller.onSearchChanged,
                              onClear: controller.resetSearch,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          _filterButton(isDark: isDark),
                        ],
                      ),
                    ),
                  ),
                  if (controller.isSearchingTransactions.value &&
                      transactions.isEmpty)
                    const SliverToBoxAdapter(
                      child: ShimmerDetails(
                          sections: 2,
                          rowsPerSection: 4
                      )
                    )
                  else if (transactions.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .6,
                        child: Center(
                          child: EmptyState(
                            message: isSearchMode
                                ? 'no_transactions_found'.tr
                                : 'no_transactions_found'.tr,
                            icon: Icons.receipt_long_outlined,
                            iconColor: isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                          ),
                        ),
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
    isDark ? const Color(0xFF23252A) : AppColor.cLight;
    final Color borderColor =
    isDark ? DarkThemeColor.cBorder : AppColor.cBorder;
    final Color textColor =
    isDark ? DarkThemeColor.cText : LightThemeColor.cText;

    final bool hasActiveFilters = controller.hasActiveFilters;

    return Material(
      color: hasActiveFilters ? AppColor.themeNavyBlueColor : surfaceColor,
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
            border: hasActiveFilters
                ? null
                : Border.all(color: borderColor),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 22.sp,
                color: hasActiveFilters ? Colors.white : textColor,
              ),
              if (hasActiveFilters)
                Positioned(
                  top: -4.h,
                  right: -4.w,
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
    if (controller.isSearchActive.value) {
      controller.resetSearch();
    }

    DateTime? tempFromDate = controller.filterFromDate.value;
    DateTime? tempToDate = controller.filterToDate.value;
    String? tempType = controller.filterTransactionType.value.isNotEmpty
        ? controller.filterTransactionType.value
        : null;

    final Color cardColor =
    isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final Color surfaceColor =
    isDark ? const Color(0xFF23252A) : AppColor.cLight;
    final Color textColor =
    isDark ? DarkThemeColor.cText : LightThemeColor.cText;
    final Color secondaryText =
    isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

    showModalBottomSheet(
      isScrollControlled: true,
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
                      horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColor.themeNavyBlueColor
                        : surfaceColor,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    label,
                    style: pSemiBold12.copyWith(
                      fontSize: 12.5.sp,
                      color: selected ? Colors.white : textColor,
                    ),
                  ),
                ),
              );
            }

            String dateRangeLabel() {
              if (tempFromDate == null && tempToDate == null) {
                return 'select_date_range'.tr;
              }
              final from = tempFromDate != null
                  ? dateFormatted(
                  date: tempFromDate.toString(),
                  formatType: formatForDateTime(FormatType.date))
                  : '...';
              final to = tempToDate != null
                  ? dateFormatted(
                  date: tempToDate.toString(),
                  formatType: formatForDateTime(FormatType.date))
                  : '...';
              return '$from - $to';
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 18.h,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'filter_transactions'.tr,
                            style: pBold16.copyWith(
                              fontSize: 16.sp,
                              color: textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(ctx);
                              await controller.resetTransactionFilters();
                            },
                            child: Text(
                              'reset'.tr,
                              style: pSemiBold14.copyWith(
                                fontSize: 14.sp,
                                color: _danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'date_range'.tr,
                        style: pRegular12.copyWith(
                          fontSize: 12.5.sp,
                          color: secondaryText,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () async {
                          final range = await showDateRangeBottomSheet(
                            context: ctx,
                            initialRange: (tempFromDate != null &&
                                tempToDate != null)
                                ? DateTimeRange(
                                start: tempFromDate!, end: tempToDate!)
                                : null,
                            onReset: () {
                              setSheetState(() {
                                tempFromDate = null;
                                tempToDate = null;
                              });
                            },
                          );
                          if (range != null) {
                            setSheetState(() {
                              tempFromDate = range.start;
                              tempToDate = range.end;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16.sp,
                                color: AppColor.themeNavyBlueColor,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  dateRangeLabel(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: pSemiBold12.copyWith(
                                    fontSize: 13.sp,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'transaction_type'.tr,
                        style: pRegular12.copyWith(
                          fontSize: 12.5.sp,
                          color: secondaryText,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          chip(
                            label: 'all'.tr,
                            selected: tempType == null,
                            onTap: () => setSheetState(() => tempType = null),
                          ),
                          for (final type in _kTransactionTypes)
                            chip(
                              label: type.tr,
                              selected: tempType == type,
                              onTap: () =>
                                  setSheetState(() => tempType = type),
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
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await controller.applyTransactionFilters(
                              fromDate: tempFromDate,
                              toDate: tempToDate,
                              type: tempType,
                            );
                          },
                          child: Text(
                            'apply_filters'.tr,
                            style: pBold14.copyWith(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

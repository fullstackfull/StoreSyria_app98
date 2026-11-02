import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/customers/customer_controller.dart';
import 'package:store_go_app/core/model/customer_model.dart';
import 'package:store_go_app/view/new_widgets/status_pill.dart';

class CustomerPickerBottomSheet extends StatefulWidget {
  const CustomerPickerBottomSheet({super.key});

  static Future<CustomerData?> show(BuildContext context) {
    return showModalBottomSheet<CustomerData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomerPickerBottomSheet(),
    );
  }

  @override
  State<CustomerPickerBottomSheet> createState() =>
      _CustomerPickerBottomSheetState();
}

class _CustomerPickerBottomSheetState
    extends State<CustomerPickerBottomSheet> {
  final CustomerController customerController = Get.find<CustomerController>();
  final ScrollController scrollController = ScrollController();

  static const Color navyBlue = Color(0xFF172C4E);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;


  @override
  void initState() {
    super.initState();

    if (customerController.customerList.isEmpty) {
      customerController.getCustomersData(1);
    }

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (customerController.isCustomerSearchActive.value) return;
    if (!customerController.isScroll.value) return;
    if (customerController.isLoading.value) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      customerController
          .getCustomersData(customerController.currantPage.value + 1);
    }
  }


  @override
  void dispose() {
    scrollController.dispose();
    customerController.clearCustomerSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? const Color(0xFF0F1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : navyBlue;
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF687386);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6EC);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, dragController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'select_customer'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        // Accessible name: this control has no visible text.
                        tooltip: 'close'.tr,
                        icon: Icon(Icons.close, color: secondaryTextColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: customerController.searchController,
                    onChanged: customerController.onCustomerSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'search_customer_hint'.tr,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Obx(() {
                        if (customerController.isSearchingCustomers.value) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (customerController.searchController.text.isNotEmpty) {
                          return IconButton(
                            // Accessible name: this control has no visible text.
                            tooltip: 'clear'.tr,
                            icon: const Icon(Icons.clear),
                            onPressed: customerController.resetCustomerSearch,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      filled: true,
                      fillColor:
                      isDark ? const Color(0xFF18263F) : const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: navyBlue, width: 1.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    final isSearchMode =
                        customerController.isCustomerSearchActive.value;
                    final list = isSearchMode
                        ? customerController.searchResults
                        : customerController.customerList;
            
                    final loadingFirstPage = isSearchMode
                        ? (customerController.isSearchingCustomers.value &&
                        list.isEmpty)
                        : (customerController.isLoading.value && list.isEmpty);
            
                    if (loadingFirstPage) {
                      return const Center(child: CircularProgressIndicator());
                    }
            
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'no_customers_found'.tr,
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      );
                    }
            
                    final showLoader =
                        !isSearchMode && customerController.isScroll.value;
            
                    return ListView.separated(
                      controller: scrollController,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: list.length + (showLoader ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: borderColor),
                      itemBuilder: (context, index) {
                        if (index >= list.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
            
                        final customer = list[index];
                        final name = customer.customerInfo?.name ?? '';
                        final email = customer.email ?? '';
                        final isActive = customer.status == 1;
                        final statusLabel = customer.statusText?.isNotEmpty == true
                            ? customer.statusText!
                            : isActive
                            ? 'active'.tr
                            : 'inactive'.tr;
            
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                            navyBlue.withValues(alpha: isDark ? 0.25 : 0.08),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: navyBlue, fontWeight: FontWeight.w700),
                            ),
                          ),
                          trailing: statusPill(
                              label: statusLabel,
                              isActive: isActive
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          subtitle: email.isNotEmpty
                              ? Text(email,
                              style: TextStyle(
                                  color: secondaryTextColor, fontSize: 12))
                              : null,
                          onTap: () => Navigator.of(context).pop(customer),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
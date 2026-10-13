import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/delivery_boy/delivery_boy_controller.dart';
import 'package:store_go_app/core/model/delivery_boy_model.dart';

class DeliveryBoyPickerBottomSheet extends StatefulWidget {
  final int? selectedId;

  const DeliveryBoyPickerBottomSheet({super.key, this.selectedId});

  static Future<DeliveryBoyData?> show(
      BuildContext context, {
        int? selectedId,
      }) {
    return showModalBottomSheet<DeliveryBoyData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryBoyPickerBottomSheet(selectedId: selectedId),
    );
  }

  @override
  State<DeliveryBoyPickerBottomSheet> createState() =>
      _DeliveryBoyPickerBottomSheetState();
}

class _DeliveryBoyPickerBottomSheetState
    extends State<DeliveryBoyPickerBottomSheet> {
  final DeliveryBoyController deliveryBoyController =
  Get.isRegistered<DeliveryBoyController>()
      ? Get.find<DeliveryBoyController>()
      : Get.put(DeliveryBoyController());

  final TextEditingController searchController = TextEditingController();
  final RxString query = ''.obs;

  static const Color navyBlue = Color(0xFF172C4E);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    if (deliveryBoyController.deliveryBoyList.isEmpty) {
      deliveryBoyController.getDeliveryBoysData();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<DeliveryBoyData> _filtered() {
    final q = query.value.trim().toLowerCase();
    final list = deliveryBoyController.deliveryBoyList;
    if (q.isEmpty) return list;
    return list.where((d) {
      return (d.name ?? '').toLowerCase().contains(q) ||
          (d.contact ?? '').toLowerCase().contains(q) ||
          (d.email ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? const Color(0xFF0F1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : navyBlue;
    final secondaryTextColor =
    isDark ? Colors.white70 : const Color(0xFF687386);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E6EC);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
                          'select_delivery_boy'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: secondaryTextColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (v) => query.value = v,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'search_delivery_boy_hint'.tr,
                      hintStyle: TextStyle(color: secondaryTextColor),
                      prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                      suffixIcon: Obx(() {
                        if (query.value.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: Icon(Icons.clear, color: secondaryTextColor),
                          onPressed: () {
                            searchController.clear();
                            query.value = '';
                          },
                        );
                      }),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF18263F)
                          : const Color(0xFFF7F8FA),
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
                        borderSide:
                        const BorderSide(color: navyBlue, width: 1.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    final list = _filtered();

                    if (deliveryBoyController.isLoading.value &&
                        deliveryBoyController.deliveryBoyList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'no_delivery_boys_found'.tr,
                              style: TextStyle(color: secondaryTextColor),
                            ),
                            if (deliveryBoyController.deliveryBoyList.isEmpty)
                              TextButton(
                                onPressed:
                                deliveryBoyController.getDeliveryBoysData,
                                child: Text('retry'.tr),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: dragController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: borderColor),
                      itemBuilder: (context, index) {
                        final boy = list[index];
                        final name = boy.name ?? '';
                        final contact = boy.contact ?? '';
                        final isSelected = boy.id != null &&
                            boy.id == widget.selectedId;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                            navyBlue.withValues(alpha: isDark ? 0.25 : 0.08),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: navyBlue,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF00B894))
                              : null,
                          title: Text(
                            name,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          subtitle: contact.isNotEmpty
                              ? Text(contact,
                              style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12))
                              : null,
                          onTap: () => Navigator.of(context).pop(boy),
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

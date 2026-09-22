// view/screen/order_screen/create_order_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/setting_controller/payment_setting_controller/payment_setting_controller.dart';
import 'package:store_go_app/core/model/payment_model.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/new_widgets/app_txt_field.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';
import '../../../core/controller/customers/customer_controller.dart';
import '../../../core/model/customer_model.dart';
import '../../new_widgets/customer_picker_bottom_sheet.dart';
import '../../new_widgets/product_picker_bottom_sheet.dart';
import '../../widget/common_snak_bar_widget.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final OrderController orderController = Get.find<OrderController>();
  final CustomerController customerController = Get.put(CustomerController());
  final PaymentSettingController paymentSettingsController =
  Get.put(PaymentSettingController());
  final ProductController productController = Get.find<ProductController>();

  int? initialCustomerId;
  bool isFromCustomerDetails = false;

  int currentStep = 0;

  final GlobalKey<FormState> _formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep3 = GlobalKey<FormState>();

  // ==================== نفس ألوان صفحة إضافة الزبون ====================
  static const Color navyBlue = Color(0xFF172C4E);
  static const Color darkBg = Color(0xFF101820);
  static const Color darkCard = Color(0xFF182331);
  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color secondaryText = Color(0xFF687386);
  static const Color lightBorder = Color(0xFFE2E6EC);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get backgroundColor => isDark ? darkBg : lightBg;
  Color get cardColor => isDark ? darkCard : Colors.white;
  Color get textColor => isDark ? Colors.white : navyBlue;
  Color get secondaryTextColor => isDark ? Colors.white70 : secondaryText;
  Color get borderColor => isDark ? Colors.white12 : lightBorder;

  @override
  void initState() {
    super.initState();

    orderController.resetCreateOrderForm();
    orderController.deliveryPriceController.text = '0';
    orderController.taxPriceController.text = '0';
    paymentSettingsController.getPaymentTypesData();
    customerController.getStatesData();

    final args = Get.arguments;
    if (args is Map) {
      initialCustomerId = args['customerId'] as int?;
      isFromCustomerDetails = args['isFromCustomerDetails'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: simpleAppBar(
        title: "new_order".tr,
        isBold: true,
        label: null,
        onNewLabelTap: () {},
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 16),
              Expanded(
                child: IndexedStack(
                  index: currentStep,
                  children: [
                    _buildStepOne(),
                    _buildStepTwo(),
                    _buildStepThree(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildFooterButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Step Indicator (نفس ستايل صفحة الزبون) ====================

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(child: _stepBar(active: currentStep >= 0)),
        const SizedBox(width: 6),
        Expanded(child: _stepBar(active: currentStep >= 1)),
        const SizedBox(width: 6),
        Expanded(child: _stepBar(active: currentStep >= 2)),
        const SizedBox(width: 10),
        Text(
          '${currentStep + 1}/3',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _stepBar({required bool active}) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: active ? navyBlue : borderColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ==================== STEP 1: Customer + Payment ====================

  Widget _buildStepOne() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final customer = orderController.selectedCustomer.value;

              // تعبية أولية لو جاي من صفحة تفاصيل الزبون
              if (initialCustomerId != null &&
                  customer == null &&
                  customerController.customerList.isNotEmpty) {
                final matched = customerController.customerList
                    .firstWhereOrNull((c) => c.id == initialCustomerId);
                if (matched != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && orderController.selectedCustomer.value == null) {
                      orderController.selectedCustomer.value = matched;
                      orderController.fillShippingFromCustomer(matched);
                    }
                  });
                }
              }

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  final picked = await CustomerPickerBottomSheet.show(context);
                  if (picked != null) {
                    orderController.selectedCustomer.value = picked;
                    orderController.fillShippingFromCustomer(picked);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'select_customer'.tr,
                    hintText: 'choose_customer'.tr,
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(9),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: navyBlue.withOpacity(isDark ? 0.20 : 0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_outline, color: navyBlue, size: 20),
                    ),
                    suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: secondaryTextColor),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    errorText: (currentStep == 0 && customer == null)
                        ? null // الفاليديشن الحقيقي عند الضغط "التالي"
                        : null,
                  ),
                  child: Text(
                    customer?.customerInfo?.name ?? 'choose_customer'.tr,
                    style: TextStyle(
                      color: customer == null ? secondaryTextColor : textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            Obx(() {
              final methods = paymentSettingsController.paymentMethods;

              return _buildDropdownField<PaymentMethod>(
                label: 'payment_method'.tr,
                hint: 'choose_payment_method'.tr,
                icon: Icons.payments_outlined,
                value: orderController.selectedPaymentMethod.value,
                items: methods.map((m) {
                  return DropdownMenuItem<PaymentMethod>(
                    value: m,
                    child: Text(m.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (method) {
                  orderController.selectedPaymentMethod.value = method;
                  orderController.paymentType.value = method?.key ?? '';
                },
                validator: (value) {
                  if (value == null) return 'please_select_payment_method'.tr;
                  return null;
                },
              );
            }),

            const SizedBox(height: 16),

            Obx(() {
              return _buildDropdownField<String>(
                label: 'payment_status'.tr,
                hint: 'payment_status'.tr,
                icon: Icons.receipt_long_outlined,
                value: orderController.paymentStatus.value,
                items: [
                  DropdownMenuItem(value: 'Paid', child: Text('paid'.tr)),
                  DropdownMenuItem(value: 'Unpaid', child: Text('unpaid'.tr)),
                ],
                onChanged: (val) {
                  if (val != null) orderController.paymentStatus.value = val;
                },
              );
            }),

            const SizedBox(height: 16),

            AppTextField(
              title: 'additional_note'.tr,
              hint: 'enter_additional_note'.tr,
              controller: orderController.noteController,
              icon: Icons.note_alt_outlined,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }


// ==================== STEP 2: Products ====================


  Widget _buildStepTwo() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_products'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),

            Obx(() {
              final availableProducts = productController.productList;

              return Column(
                children: List.generate(
                  orderController.orderLineItems.length,
                      (index) {
                    final line = orderController.orderLineItems[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: line.product.value != null
                              ? navyBlue
                              : borderColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () async {
                                    final picked = await ProductPickerBottomSheet.show(context);
                                    if (picked != null) {
                                      orderController.onProductSelected(index, picked);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'product'.tr,
                                      hintText: 'select_product'.tr,
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.all(6),
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: navyBlue.withOpacity(isDark ? 0.20 : 0.07),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.inventory_2_outlined,
                                            color: navyBlue, size: 18),
                                      ),
                                      suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                                          color: secondaryTextColor),
                                      filled: true,
                                      fillColor: cardColor,
                                      contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: borderColor),
                                      ),
                                    ),
                                    child: Text(
                                      line.product.value?.name ?? 'select_product'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: line.product.value == null
                                            ? secondaryTextColor
                                            : textColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (orderController.orderLineItems.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => orderController.removeLineItem(index),
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  title: 'quantity'.tr,
                                  hint: '1',
                                  controller: line.qtyController,
                                  icon: Icons.confirmation_number_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: AppTextField(
                                  title: 'price'.tr,
                                  hint: '0.00',
                                  controller: line.priceController,
                                  icon: Icons.attach_money_outlined,
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  suffixText: orderController.currencySymbol.value,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 4),

            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                orderController.addLineItem();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border.all(
                    color: navyBlue.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: navyBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "add_another_product".tr,
                      style: const TextStyle(
                        color: navyBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ==================== STEP 3: Shipping ====================

  Widget _buildStepThree() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKeyStep3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              title: 'first_name'.tr,
              hint: 'enter_first_name'.tr,
              controller: orderController.firstNameController,
              icon: Icons.person_outline,
              validator: (value) =>
                  Validator.validateRequired(value.toString()),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'last_name'.tr,
              hint: 'enter_last_name'.tr,
              controller: orderController.lastNameController,
              icon: Icons.person_outline,
              validator: (value) =>
                  Validator.validateRequired(value.toString()),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'email'.tr,
              hint: 'enter_email'.tr,
              controller: orderController.emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => Validator.validateEmail(value ?? ''),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'phone_number'.tr,
              hint: 'enter_phone_number'.tr,
              controller: orderController.phoneController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => Validator.validateMobile(value ?? ''),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            Obx(() {
              final cities = customerController.customerCityModel?.cities ?? [];

              return _buildDropdownField<String>(
                label: 'city'.tr,
                hint: 'select_city'.tr,
                icon: Icons.location_city_outlined,
                value: orderController.selectedCityId.value.isEmpty
                    ? null
                    : orderController.selectedCityId.value,
                items: cities.map<DropdownMenuItem<String>>((CityModel city) {
                  return DropdownMenuItem<String>(
                    value: city.id.toString(),
                    child: Text(city.name),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final city = cities.firstWhereOrNull(
                        (CityModel c) => c.id.toString() == id,
                  );
                  orderController.selectedCityId.value = id;
                  orderController.selectedCityName.value = city?.name ?? '';
                },
                validator: (value) {
                  if (value == null) return 'select_city'.tr;
                  return null;
                },
              );
            }),

            const SizedBox(height: 16),
            AppTextField(
              title: 'address'.tr,
              hint: 'enter_address'.tr,
              controller: orderController.addressController,
              icon: Icons.location_on_outlined,
              validator: (value) =>
                  Validator.validateRequired(value.toString()),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    title: 'delivery_price'.tr,
                    hint: '0.00',
                    controller: orderController.deliveryPriceController,
                    icon: Icons.local_shipping_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (value) => Validator.validateRequired(value.toString())
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    title: 'tax_price'.tr,
                    hint: '0.00',
                    controller: orderController.taxPriceController,
                    icon: Icons.price_change_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (value) => Validator.validateRequired(value.toString())
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildFinalTotalCard(),
          ],
        ),
      ),
    );
  }


  Widget _buildFooterButtons() {
    return Obx(() {
      final isLoading = orderController.isCreatingOrder.value;
      final isLast = currentStep == 2;

      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: isLoading ? null : _goBack,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: currentStep == 0
                    ? Text(
                  'cancel'.tr,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded,
                        size: 18, color: secondaryTextColor),
                    const SizedBox(width: 6),
                    Text(
                      'back'.tr,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : (isLast ? _submitOrder : _goNext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'create_order'.tr : 'next'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLast
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward_rounded,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // ==================== Navigation Logic ====================

  void _goNext() {
    FocusScope.of(context).unfocus();

    if (currentStep == 0) {
      if (orderController.selectedCustomer.value == null) {
        commonToast(type: AppSnackBarType.info,'please_select_customer'.tr);
        return;
      }
      if (!(_formKeyStep1.currentState?.validate() ?? false)) return;
    } else if (currentStep == 1) {
      final hasEmptyLine = orderController.orderLineItems
          .any((line) => line.product.value == null);
      if (hasEmptyLine) {
        commonToast(type: AppSnackBarType.info, 'please_select_product'.tr);
        return;
      }
      if (!(_formKeyStep2.currentState?.validate() ?? false)) return;
    }

    setState(() => currentStep++);
  }

  void _goBack() {
    FocusScope.of(context).unfocus();

    if (currentStep == 0) {
      Get.back();
    } else {
      setState(() => currentStep--);
    }
  }

  Future<void> _submitOrder() async {
    FocusScope.of(context).unfocus();

    if (!(_formKeyStep3.currentState?.validate() ?? false)) return;

    final success = await orderController.createOrderData(
      productList: productController.productList,
    );

    if (success) {
      if (isFromCustomerDetails) {
        customerController.getCustomerOrdersData(
          customerId: initialCustomerId.toString(),
          page: 1,
        );
      } else {
        orderController.getOrderData(1);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildFinalTotalCard() {
    return Obx(() {
      final listenables = <Listenable>[
        orderController.deliveryPriceController,
        orderController.taxPriceController,
        ...orderController.orderLineItems
            .expand((line) => [line.qtyController, line.priceController]),
      ];

      return AnimatedBuilder(
        animation: Listenable.merge(listenables),
        builder: (context, _) {
          final subtotal = orderController.productsTotal;
          final delivery =
              double.tryParse(orderController.deliveryPriceController.text.trim()) ?? 0;
          final tax =
              double.tryParse(orderController.taxPriceController.text.trim()) ?? 0;
          final finalTotal = subtotal + delivery + tax;

          return Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: navyBlue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryRow('subtotal'.tr, subtotal),
                _summaryRow('delivery_price'.tr, delivery),
                _summaryRow('tax_price'.tr, tax),
                const Divider(height: 20),
                _summaryRow('total'.tr, finalTotal, bold: true),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? textColor : secondaryTextColor,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: bold ? 15 : 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: bold ? navyBlue : textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                orderController.currencySymbol.value,
                style: TextStyle(
                  fontSize: bold ? 10 : 9,
                  fontWeight: FontWeight.w400,
                  color: bold ? navyBlue : secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    bool dense = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: secondaryTextColor,
        size: 24,
      ),
      dropdownColor: cardColor,
      borderRadius: BorderRadius.circular(16),
      menuMaxHeight: 280,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(9),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: navyBlue.withOpacity(isDark ? 0.20 : 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: navyBlue, size: 20),
        ),
        filled: true,
        fillColor: cardColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: dense ? 8 : 16,
        ),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor.withOpacity(0.6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red),
        labelStyle: TextStyle(color: secondaryTextColor, fontSize: 13),
        hintStyle: TextStyle(
          color: secondaryTextColor.withOpacity(0.75),
          fontSize: 13,
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
// view/screen/order_screen/create_order_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/order_controller/order_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_controller.dart';

import '../../../core/controller/customers/customer_controller.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final OrderController orderController = Get.find<OrderController>();
  final CustomerController customerController = Get.put(CustomerController());
  final ProductController productController = Get.find<ProductController>();

  int? initialCustomerId;
  bool isFromCustomerDetails = false;

  @override
  void initState() {
    super.initState();

    orderController.resetCreateOrderForm();

    final args = Get.arguments;

    if (args is Map) {
      initialCustomerId = args['customerId'] as int?;
      isFromCustomerDetails = args['isFromCustomerDetails'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cLight,
      appBar: simpleAppBar(
        title: "new_order".tr,
        isBold: true,
        label: null,
        onNewLabelTap: () {},
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: ListView(
          children: [
            // ================= CUSTOMER =================
            _sectionTitle("select_customer".tr),
            verticalSpace(8.h),
            Obx(() {
              final customers = customerController.customerList;

              if (initialCustomerId != null &&
                  orderController.selectedCustomer.value == null) {
                final customer = customers.firstWhereOrNull(
                      (c) => c.id == initialCustomerId,
                );

                if (customer != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted &&
                        orderController.selectedCustomer.value == null) {
                      orderController.selectedCustomer.value = customer;
                    }
                  });
                }
              }

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: _boxDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,

                    hint: Text("choose_customer".tr),

                    value: orderController.selectedCustomer.value?.id,

                    items: customers.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(
                          c.customerInfo?.name ?? '',
                        ),
                      );
                    }).toList(),

                    onChanged: (id) {
                      final customer = customers.firstWhereOrNull(
                            (c) => c.id == id,
                      );

                      orderController.selectedCustomer.value = customer;
                    },
                  ),
                ),
              );
            }),

            verticalSpace(20.h),

            // ================= PRODUCTS =================
            _sectionTitle("select_products".tr),
            verticalSpace(8.h),

            Obx(() {
              final products = productController.productList;

              if (products.isEmpty) {
                return Center(child: Text("no_products_found".tr));
              }

              return Column(
                children: products.map((product) {
                  final qty =
                      orderController.selectedProductsQty[product.id] ?? 0;
                  final isSelected = qty > 0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: _boxDecoration(
                      highlighted: isSelected,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            product.coverImageUrl ?? '',
                            width: 45.w,
                            height: 45.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(width: 45.w, height: 45.w, color: AppColor.cLight),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${product.price}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColor.cFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isSelected)
                          IconButton(
                            icon: Icon(Icons.add_circle,
                                color: AppColor.themeNavyBlueColor),
                            onPressed: () {
                              orderController.toggleProductSelection(
                                product.id ?? 0,
                              );
                            },
                          )
                        else
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  orderController.updateProductQty(
                                    product.id ?? 0,
                                    qty - 1,
                                  );
                                },
                              ),
                              Text('$qty',
                                  style: TextStyle(fontSize: 14.sp)),
                              IconButton(
                                icon: Icon(Icons.add_circle,
                                    color: AppColor.themeNavyBlueColor),
                                onPressed: () {
                                  orderController.updateProductQty(
                                    product.id ?? 0,
                                    qty + 1,
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),

            verticalSpace(20.h),

            // ================= SHIPPING INFO =================
            _sectionTitle("shipping_info".tr),
            verticalSpace(8.h),
            _buildTextField(orderController.addressController, "address".tr),
            verticalSpace(10.h),
            _buildTextField(orderController.cityController, "city".tr),
            verticalSpace(10.h),
            _buildTextField(orderController.stateController, "state".tr),
            verticalSpace(10.h),
            _buildTextField(orderController.countryController, "country".tr),
            verticalSpace(10.h),
            _buildTextField(orderController.postcodeController, "postcode".tr),
            verticalSpace(10.h),
            _buildTextField(orderController.noteController, "additional_note".tr,
                maxLines: 3),

            verticalSpace(24.h),

            // ================= SUBMIT =================
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.themeNavyBlueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: orderController.isCreatingOrder.value
                      ? null
                      : () async {
                    final success = await orderController.createOrderData(
                      productList: productController.productList,
                    );

                    if (success) {
                      Get.back();
                      if (isFromCustomerDetails) {
                        await customerController.getCustomerOrdersData(
                          customerId: initialCustomerId.toString(),
                          page: 1,
                        );
                      } else {
                        await orderController.getOrderData(1);
                      }
                    }
                  },
                  child: orderController.isCreatingOrder.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "create_order".tr,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),

            verticalSpace(30.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
    );
  }

  BoxDecoration _boxDecoration({bool highlighted = false}) {
    return BoxDecoration(
      color: AppColor.cWhite,
      border: Border.all(
        color: highlighted
            ? AppColor.themeNavyBlueColor
            : AppColor.themeNavyBlueColor.withOpacity(0.3),
      ),
      borderRadius: BorderRadius.circular(14.r),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColor.cWhite,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: AppColor.themeNavyBlueColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
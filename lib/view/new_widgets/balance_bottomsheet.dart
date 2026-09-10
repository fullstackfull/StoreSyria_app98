import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/wallet/wallet_controller.dart';
import '../../utils/colors.dart';
import 'app_txt_field.dart';

void showBalanceSheet({
  required bool isAdd,
  required BuildContext context,
  required WalletController controller,
  required bool isDark,
}) {


  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final Color cardColor =
  isDark ? const Color(0xFF1B1C20) : Colors.white;

  final Color surfaceColor =
  isDark ? const Color(0xFF23252A) : const Color(0xFFF7F8FA);

  final Color primaryText =
  isDark ? Colors.white : const Color(0xFF15171A);

  final Color secondaryText =
  isDark ? const Color(0xFF9297A1) : const Color(0xFF777D87);

  final Color accent = AppColor.themeNavyBlueColor;


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(22.r),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom:
          MediaQuery.of(ctx).viewInsets.bottom + 20.h,
        ),
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: AppColor.cBorder,
                        borderRadius:
                        BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                      Icons.attach_money_outlined,
                        color: accent,
                        size: 24.sp,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAdd
                                ? 'add_funds'.tr
                                : 'withdraw'.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: primaryText,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            isAdd
                                ? 'add_amount_to_wallet'.tr
                                : 'withdraw_amount_from_wallet'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.sp,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Amount
                AppTextField(
                  title: 'amount'.tr,
                  hint: 'enter_amount'.tr,
                  controller: amountController,
                  icon: Icons.payments_outlined,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'please_enter_amount'.tr;
                    }

                    final amount = double.tryParse(
                      value.trim(),
                    );

                    if (amount == null || amount <= 0) {
                      return 'please_enter_valid_amount'.tr;
                    }

                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                // Description
                AppTextField(
                  title: 'description'.tr,
                  hint: 'enter_description'.tr,
                  controller: descriptionController,
                  icon: Icons.description_outlined,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'please_enter_description'.tr;
                    }

                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                Obx(() {
                  final loading = isAdd
                      ? controller.isAddingBalance.value
                      : controller.isDeductingBalance.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                        // Validation
                        if (!formKey.currentState!
                            .validate()) {
                          return;
                        }

                        final amount =
                        double.parse(amountController.text.trim());

                        final description = descriptionController.text.trim();

                        if (isAdd) {
                          await controller.addBalance(
                            amount: amount,
                            description: description,
                          );
                        } else {
                          await controller.deductBalance(
                            amount: amount,
                            description:
                            description,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        disabledBackgroundColor:
                        Colors.grey.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14.r),
                        ),
                      ),
                      child: loading
                          ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child:
                        const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                            isAdd
                                ? 'add_funds'.tr
                                : 'withdraw'.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight:
                              FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
  );
}
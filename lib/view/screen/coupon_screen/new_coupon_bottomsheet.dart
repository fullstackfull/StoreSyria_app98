// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/widget/app_dialog.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class AddNewCouponWidget extends StatefulWidget {
  final bool isUpdate;

  final String? couponId;
  final String? name;
  final String? flat;
  final String? date;
  final String? discount;
  final String? code;
  final String? limit;
  final String? status;

  const AddNewCouponWidget({
    super.key,
    required this.isUpdate,
    this.couponId,
    this.name,
    this.flat,
    this.date,
    this.discount,
    this.code,
    this.limit,
    this.status,
  });

  @override
  State<AddNewCouponWidget> createState() => _AddNewCouponWidgetState();
}

class _AddNewCouponWidgetState extends State<AddNewCouponWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late NewCouponController couponController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color navyBlue = Color(0xFF172C4E);

  @override
  void initState() {
    super.initState();

    couponController = Get.find<NewCouponController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _setupData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _setupData() {
    if (widget.isUpdate) {
      couponController.couponNameController.text =
          widget.name ?? '';

      couponController.discountController.text =
          widget.discount ?? '';

      couponController.limitController.text =
          widget.limit ?? '';

      couponController.expDateController.text =
          widget.date ?? '';

      couponController.couponController.text =
          widget.code ?? '';

      final type = widget.flat ?? 'flat';

      couponController.couponType.value = type;

      couponController.isFlat.value =
          type.toLowerCase() == 'flat';

      final couponStatus = widget.status ?? '1';

      couponController.status.value = couponStatus;

      couponController.isStatus.value =
          couponStatus == '1';
    } else {
      couponController.clearCouponFields();

      couponController.couponType.value = 'flat';
      couponController.isFlat.value = true;

      couponController.status.value = '1';
      couponController.isStatus.value = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? const Color(0xFF0F1A2E) : const Color(0xFFF7F8FA);

  Color get cardColor =>
      isDark ? const Color(0xFF18263F) : Colors.white;

  Color get textColor =>
      isDark ? Colors.white : const Color(0xFF172C4E);

  Color get secondaryTextColor =>
      isDark ? Colors.white70 : const Color(0xFF687386);

  Color get borderColor =>
      isDark ? Colors.white12 : const Color(0xFFE2E6EC);

  void _close() {
    FocusScope.of(context).unfocus();
    Get.back();
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: navyBlue.withOpacity(
              isDark ? 0.25 : 0.08,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _close,
            icon: const Icon(
              Icons.close_rounded,
              color: navyBlue,
              size: 22,
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isUpdate
                    ? 'edit_coupon'.tr
                    : 'add_coupon'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.isUpdate
                    ? 'update_coupon_description'.tr
                    : 'create_coupon_description'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(
      String title, {
        bool required = true,
      }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),

            prefixIcon: Icon(
              icon,
              color: navyBlue,
              size: 21,
            ),

            filled: true,
            fillColor: cardColor,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: navyBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCouponType() {
    final isFlat = couponController.isFlat.value;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: navyBlue.withOpacity(
                isDark ? 0.22 : 0.07,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isFlat
                  ? Icons.payments_outlined
                  : Icons.percent_rounded,
              color: navyBlue,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'discount_type'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  isFlat
                      ? 'flat'.tr
                      : 'percentage'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: navyBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          CupertinoSwitch(
            value: isFlat,
            onChanged: (value) {
              couponController.isFlat.value = value;

              couponController.couponType.value =
              value ? 'flat' : 'percentage';
            },
            activeColor: navyBlue,
            thumbColor: Colors.white,
            trackColor: isDark
                ? Colors.white24
                : const Color(0xFFD6DAE0),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSwitch() {
    final isActive =
        couponController.isStatus.value;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: navyBlue.withOpacity(
                isDark ? 0.22 : 0.07,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isActive
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: navyBlue,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'status'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  isActive
                      ? 'active'.tr
                      : 'inactive'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? navyBlue
                        : secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          CupertinoSwitch(
            value: isActive,
            onChanged: (value) {
              couponController.isStatus.value =
                  value;

              couponController.status.value =
              value ? '1' : '0';
            },
            activeColor: navyBlue,
            thumbColor: Colors.white,
            trackColor: isDark
                ? Colors.white24
                : const Color(0xFFD6DAE0),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          'coupon_code'.tr,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller:
                couponController.couponController,
                validator: (value) {
                  return Validator.validateRequired(
                    value ?? '',
                  );
                },
                textCapitalization:
                TextCapitalization.characters,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  hintText: 'enter_coupon_code'.tr,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                    letterSpacing: 0,
                  ),
                  prefixIcon: const Icon(
                    Icons.confirmation_number_outlined,
                    color: navyBlue,
                    size: 21,
                  ),
                  filled: true,
                  fillColor: cardColor,
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide:
                    BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide:
                    BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: navyBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  couponController
                      .generateCodeData();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: navyBlue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                child: const Icon(
                  Icons.autorenew_rounded,
                  color: navyBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return _buildTextField(
      title: 'expiry_date'.tr,
      hint: 'select_expiry_date'.tr,
      controller:
      couponController.expDateController,
      icon: Icons.calendar_month_outlined,
      readOnly: true,
      textInputAction: TextInputAction.done,
      validator: (value) {
        return Validator.validateRequired(
          value ?? '',
        );
      },
      onTap: () {
        couponController.pickDate(context);
      },
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _close,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: borderColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'cancel'.tr,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: AppButton(
              onPressed: () {
                if (_formKey.currentState
                    ?.validate() ??
                    false) {
                  _submit();
                }
              },
              isLoading: couponController.isLoading.value,
              text:widget.isUpdate
                        ? 'update'.tr
                        : 'create'.tr,

                  ),
              ),
            ),
          ]);
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (Prefs.getBool(AppConstant.isDemoMode) ==
        true) {
      if (widget.isUpdate) {
        commonToast(type: AppSnackBarType.info, 
          AppConstant.demoString,
        );
        return;
      }
    }

    final name =
    couponController.couponNameController.text
        .trim();

    final discount =
    couponController.discountController.text
        .trim();

    final limit =
    couponController.limitController.text
        .trim();

    final date =
    couponController.expDateController.text
        .trim();

    final code =
    couponController.couponController.text
        .trim();

    if (name.isEmpty) {
      commonToast(type: AppSnackBarType.info, 
        'coupon_name_required'.tr,
      );
      return;
    }

    if (discount.isEmpty) {
      commonToast(type: AppSnackBarType.info, 
        'discount_required'.tr,
      );
      return;
    }

    if (limit.isEmpty) {
      commonToast(type: AppSnackBarType.info, 
        'coupon_limit_required'.tr,
      );
      return;
    }

    if (date.isEmpty) {
      commonToast(type: AppSnackBarType.info, 
        'expiry_date_required'.tr,
      );
      return;
    }

    if (code.isEmpty) {
      commonToast(type: AppSnackBarType.info, 
        'coupon_code_required'.tr,
      );
      return;
    }

    couponController.addCoupon(
      isUpdate: widget.isUpdate,
      couponId: widget.couponId ?? '0',
      couponName: name,
      couponType:
      couponController.couponType.value,
      disAmount: discount,
      couponLimit: limit,
      status: int.tryParse(
        couponController.status.value,
      ) ??
          1,
      date: date,
      code: code,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
            const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom:
              MediaQuery.of(context)
                  .viewInsets
                  .bottom +
                  16,
            ),
            child: SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),
              child: Obx(
                    () => Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration:
                          BoxDecoration(
                            color: isDark
                                ? Colors.white24
                                : const Color(
                              0xFFD6DAE0,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                      ),
      
                      const SizedBox(height: 22),
      
                      _buildHeader(),
      
                      const SizedBox(height: 24),
      
                      _buildTextField(
                        title: 'coupon_name'.tr,
                        hint: 'enter_coupon_name'.tr,
                        controller: couponController.couponNameController,
                        icon: Icons.local_offer_outlined,
                        validator: (value) {
                          return Validator.validateRequired(value ?? '');
                        },
                      ),
      
                      const SizedBox(height: 18),
      
                      _buildCodeField(),
      
                      const SizedBox(height: 18),
      
                      _buildTextField(
                        title: 'discount_amount'.tr,
                        hint: 'enter_discount_amount'.tr,
                        controller: couponController.discountController,
                        icon: Icons.discount_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final discount = value?.trim() ?? '';
      
                          if (discount.isEmpty) {
                            return 'discount_required'.tr;
                          }
      
                          final discountValue = double.tryParse(discount);
      
                          if (discountValue == null) {
                            return 'discount_must_be_number'.tr;
                          }
      
                          if (discountValue < 0) {
                            return 'discount_must_be_positive'.tr;
                          }
      
                          if (discountValue > 100) {
                            return 'discount_must_be_less_than_or_equal_100'.tr;
                          }
      
                          return null;
                        },
                      ),
      
                      const SizedBox(height: 18),
      
                      _buildTextField(
                        title: 'coupon_limit'.tr,
                        hint: 'enter_coupon_limit'.tr,
                        controller: couponController.limitController,
                        icon: Icons.people_outline_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return Validator.validateRequired(value ?? '');
                        },
                      ),
      
                      const SizedBox(height: 18),
      
                      _buildDateField(),
      
                      const SizedBox(height: 18),
      
                      _buildCouponType(),
      
                      const SizedBox(height: 12),
      
                      _buildStatusSwitch(),
      
                      const SizedBox(height: 28),
      
                      _buildButtons(),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
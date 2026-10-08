import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/new_widgets/app_txt_field.dart';
import '../../../core/controller/delivery_boy/delivery_boy_controller.dart';

class AddNewDeliveryBoyWidget extends StatefulWidget {
  final bool isUpdate;
  final String? deliveryBoyId;
  final String? name;
  final bool isChangePassword;
  final String? email;
  final String? contact;
  final String? commissionPercentage;
  final String? isCommissionEnabled;

  const AddNewDeliveryBoyWidget({
    super.key,
    this.isUpdate = false,
    this.deliveryBoyId,
    this.name,
    this.email,
    this.contact,
    this.commissionPercentage,
    this.isCommissionEnabled,
    this.isChangePassword = false,
  });

  @override
  State<AddNewDeliveryBoyWidget> createState() => _AddNewDeliveryBoyWidgetState();
}

class _AddNewDeliveryBoyWidgetState extends State<AddNewDeliveryBoyWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DeliveryBoyController deliveryBoyController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _commissionPercentageController;
  bool _isCommissionEnabled = true;
  bool _isLoading = false;
  static const Color navyBlue = Color(0xFF172C4E);
  static const Color darkBg = Color(0xFF0F1A2E);
  static const Color darkCard = Color(0xFF18263F);
  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color secondaryText = Color(0xFF687386);
  static const Color lightBorder = Color(0xFFE2E6EC);

  @override
  void initState() {
    super.initState();

    deliveryBoyController = Get.find<DeliveryBoyController>();
    _nameController = TextEditingController(text: widget.name ?? '');
    _emailController = TextEditingController(text: widget.email ?? '');
    _contactController = TextEditingController(text: widget.contact ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _commissionPercentageController = TextEditingController(text: widget.commissionPercentage ?? '0');
    _isCommissionEnabled = widget.isCommissionEnabled == null || widget.isCommissionEnabled == '1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _commissionPercentageController.dispose();
    super.dispose();
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get backgroundColor => isDark ? darkBg : lightBg;
  Color get cardColor => isDark ? darkCard : Colors.white;
  Color get textColor => isDark ? Colors.white : navyBlue;
  Color get secondaryTextColor => isDark ? Colors.white70 : secondaryText;
  Color get borderColor => isDark ? Colors.white12 : lightBorder;

  void _close() {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    Get.back();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;

      if (widget.isChangePassword) {
        success = await deliveryBoyController.updatePassDeliveryBoyData(
          passwordConfirm: _confirmPasswordController.text.trim(),
          deliveryBoyId: widget.deliveryBoyId!,
          password: _passwordController.text.trim(),
        );
      } else if (widget.isUpdate) {
        success = await deliveryBoyController.updateDeliveryBoyData(
          deliveryBoyId: widget.deliveryBoyId!,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          contact: _contactController.text.trim(),
          commissionPercentage:
          _commissionPercentageController.text.trim(),
          isCommissionEnabled:
          _isCommissionEnabled ? '1' : '0',
        );
      } else {
        success = await deliveryBoyController.addDeliveryBoyData(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          contact: _contactController.text.trim(),
          commissionPercentage:
          _commissionPercentageController.text.trim(),
          isCommissionEnabled:
          _isCommissionEnabled ? '1' : '0',
        );
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStatusSwitch() {
    final bool isActive = _isCommissionEnabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: navyBlue.withOpacity(isDark ? 0.22 : 0.07),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isActive
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: navyBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'commission_enabled'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isActive ? 'enabled'.tr : 'disabled'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? navyBlue : secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isActive,
            activeColor: navyBlue,
            onChanged: _isLoading
                ? null
                : (value) {
              setState(() {
                _isCommissionEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
          widget.isChangePassword
          ? 'change_password'.tr
              : widget.isUpdate
          ? 'edit_delivery_man'.tr
              : 'add_delivery_man'.tr,
          style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                  widget.isChangePassword
                      ? 'change_delivery_man_password'.tr
                      : widget.isUpdate
                      ? 'update_delivery_man_data'.tr
                      : 'enter_delivery_man_data'.tr,
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : _close,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Icon(Icons.close_rounded, color: textColor, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    if (widget.isChangePassword) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: 4,
          bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                title: 'password'.tr,
                hint: 'enter_password'.tr,
                controller: _passwordController,
                icon: Icons.lock_outline_rounded,
                validator: (value) {
                  final password = value ?? '';

                  if (password.trim().isEmpty) {
                    return 'password_required'.tr;
                  }

                  if (password.length < 8) {
                    return 'password_min_8_characters'.tr;
                  }

                  return Validator.validatePassword(password);
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              AppTextField(
                title: 'confirm_password'.tr,
                hint: 'confirm_password'.tr,
                controller: _confirmPasswordController,
                icon: Icons.lock_reset_outlined,
                validator: (value) {
                  final confirmPassword = value ?? '';

                  if (confirmPassword.trim().isEmpty) {
                    return 'confirm_password_required'.tr;
                  }

                  if (confirmPassword != _passwordController.text) {
                    return 'passwords_do_not_match'.tr;
                  }

                  return null;
                },
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 4,
        bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              title: 'name'.tr,
              hint: 'enter_name'.tr,
              controller: _nameController,
              icon: Icons.person_outline,
              validator: (value) {
                return Validator.validateRequired(value.toString());
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'email'.tr,
              hint: 'enter_email'.tr,
              controller: _emailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                return Validator.validateEmail(value ?? '');
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'phone_number'.tr,
              hint: 'enter_phone_number'.tr,
              controller: _contactController,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
              validator: (value) {
                return Validator.validateMobile(value ?? '');
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'commission_percentage'.tr,
              hint: 'enter_commission_percentage'.tr,
              controller: _commissionPercentageController,
              icon: Icons.percent_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'commission_percentage_required'.tr;
                }
                final commission = double.tryParse(value.trim());
                if (commission == null) {
                  return 'commission_percentage_invalid'.tr;
                }
                if (commission < 0 || commission > 100) {
                  return 'commission_percentage_range'.tr;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            if(!widget.isUpdate) ...[
              const SizedBox(height: 16),
              AppTextField(
                title: 'password'.tr,
                hint: 'enter_password'.tr,
                controller: _passwordController,
                icon: Icons.lock_outline_rounded,
                validator: (value) {
                  final password = value ?? '';
                  if (password.trim().isEmpty) {
                    return 'password_required'.tr;
                  }

                  if (password.length < 8) {
                    return 'password_min_8_characters'.tr;
                  }

                  return Validator.validatePassword(password);
                },
                textInputAction: TextInputAction.done,
              ),
            ],
            const SizedBox(height: 16),
            _buildStatusSwitch(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _close,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: navyBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
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
                    Icon(
                      widget.isChangePassword
                          ? Icons.lock_reset_outlined
                          : widget.isUpdate
                          ? Icons.save_outlined
                          : Icons.add_rounded,
                      size: 19,
                    ),
                  const SizedBox(width: 8),
                  Text(
                     widget.isChangePassword
                     ? 'confirm'.tr
                         : widget.isUpdate
                     ? 'update'.tr
                         : 'create'.tr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFD6DAE0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _buildHeader(),
              const SizedBox(height: 18),
              Flexible(
                child: _buildForm(),
              ),
              const SizedBox(height: 16),
              _buildFooterButtons(),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
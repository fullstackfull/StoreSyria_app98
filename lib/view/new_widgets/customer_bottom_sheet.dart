import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/new_widgets/app_txt_field.dart';
import '../../core/controller/customers/customer_controller.dart';
import 'app_snackbar.dart';

class AddNewCustomerWidget extends StatefulWidget {
  final bool isUpdate;

  final String? customerId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final String? password;
  final String? status;

  const AddNewCustomerWidget({
    super.key,
    this.isUpdate = false,
    this.customerId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.password,
    this.status,
  });

  @override
  State<AddNewCustomerWidget> createState() => _AddNewCustomerWidgetState();
}

class _AddNewCustomerWidgetState extends State<AddNewCustomerWidget>
    with SingleTickerProviderStateMixin {
  // Separate form keys so validation only fires for the visible step.
  final GlobalKey<FormState> _formKeyStep1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyStep2 = GlobalKey<FormState>();

  late CustomerController customerController;

  final PageController _pageController = PageController();
  int _currentStep = 0; // 0 = customer info, 1 = address info

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _passwordController;
  late TextEditingController _addressController;
  late TextEditingController _countryIdController;
  late TextEditingController _stateIdController;
  late TextEditingController _cityIdController;
  late TextEditingController _postcodeController;
  late TextEditingController _addressTitleController;
  late TextEditingController _deliveryInstructionsController;
  String _addressType = '1';

  bool _isActive = true;
  bool _isLoading = false;
  bool _isDefault = true;

  static const Color navyBlue = Color(0xFF172C4E);
  static const Color darkBg = Color(0xFF101820);
  static const Color darkCard = Color(0xFF182331);
  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color secondaryText = Color(0xFF687386);
  static const Color lightBorder = Color(0xFFE2E6EC);

  @override
  void initState() {
    super.initState();

    customerController = Get.find<CustomerController>();

    _firstNameController = TextEditingController(text: widget.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.lastName ?? '');
    _emailController = TextEditingController(text: widget.email ?? '');
    _mobileController = TextEditingController(text: widget.mobile ?? '');
    _passwordController = TextEditingController(text: widget.password ?? '');
    _addressController = TextEditingController();
    _countryIdController = TextEditingController();
    _stateIdController = TextEditingController();
    _cityIdController = TextEditingController();
    _postcodeController = TextEditingController();
    _addressTitleController = TextEditingController();
    _deliveryInstructionsController = TextEditingController();

    _isActive = widget.status == null || widget.status == '1';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _countryIdController.dispose();
    _stateIdController.dispose();
    _cityIdController.dispose();
    _postcodeController.dispose();
    _addressTitleController.dispose();
    _deliveryInstructionsController.dispose();

    _pageController.dispose();

    super.dispose();
  }

  // ============================================================
  // THEME
  // ============================================================

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor => isDark ? darkBg : lightBg;

  Color get cardColor => isDark ? darkCard : Colors.white;

  Color get textColor => isDark ? Colors.white : navyBlue;

  Color get secondaryTextColor => isDark ? Colors.white70 : secondaryText;

  Color get borderColor => isDark ? Colors.white12 : lightBorder;

  // ============================================================
  // CLOSE
  // ============================================================

  void _close() {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    Get.back();
  }

  // ============================================================
  // STEP NAVIGATION
  // ============================================================

  void _goToStep2() {
    FocusScope.of(context).unfocus();

    if (!(_formKeyStep1.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _currentStep = 1);

    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _backToStep1() {
    FocusScope.of(context).unfocus();

    setState(() => _currentStep = 0);

    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKeyStep2.currentState?.validate() ?? false)) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await customerController.addCustomerData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
        status: _isActive ? 1 : 0,
        // Address
        address: _addressController.text.trim(),
        countryId: _countryIdController.text.trim(),
        stateId: _stateIdController.text.trim(),
        cityId: _cityIdController.text.trim(),
        postcode: "0000",
        addressTitle: _addressTitleController.text.trim(),
        isDefault: _isDefault ? 1 : 0,
        deliveryInstructions: _deliveryInstructionsController.text.trim(),
        addressType: _addressType,
      );

      if (mounted) {
        Get.back();

        AppSnackBar.success(
          title: 'success',
          message: widget.isUpdate
              ? 'تم تحديث بيانات العميل بنجاح'
              : 'تمت إضافة العميل بنجاح',
        );
      }
    } catch (e) {
      debugPrint('Add customer error: $e');

      AppSnackBar.error(
        title: 'failed',
        message: 'حدث خطأ أثناء حفظ بيانات العميل',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // STEP INDICATOR
  // ============================================================

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(child: _stepBar(active: true)),
        const SizedBox(width: 6),
        Expanded(child: _stepBar(active: _currentStep >= 1)),
        const SizedBox(width: 10),
        Text(
          '${_currentStep + 1}/2',
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

  Widget _buildStepLabel() {
    final title = _currentStep == 0
        ? 'customer_info'.tr
        : 'address_info'.tr;

    final subtitle = _currentStep == 0
        ? 'customer_info_subtitle'.tr
        : 'address_info_subtitle'.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS SWITCH
  // ============================================================

  Widget _buildStatusSwitch() {
    final bool isActive = _isActive;

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
                  'status'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isActive ? 'active'.tr : 'inactive'.tr,
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
                _isActive = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEFAULT ADDRESS SWITCH
  // ============================================================

  Widget _buildDefaultAddressSwitch() {
    final bool isDefault = _isDefault;

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
              isDefault ? Icons.star_rounded : Icons.star_border_rounded,
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
                  'default_address'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDefault
                      ? 'default_address_active'.tr
                      : 'default_address_inactive'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDefault ? navyBlue : secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isDefault,
            activeColor: navyBlue,
            onChanged: _isLoading
                ? null
                : (value) {
              setState(() {
                _isDefault = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADDRESS TYPE DROPDOWN
  // ============================================================

  Widget _buildAddressTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.only(right: 10),
      child: DropdownButtonFormField<String>(
        value: _addressType,
        decoration: InputDecoration(
          labelText: 'address_type'.tr,
          border: InputBorder.none,
          prefixIcon: Icon(Icons.home_work_outlined, color: navyBlue),
        ),
        items: [
          DropdownMenuItem(value: '0', child: Text('home'.tr)),
          DropdownMenuItem(value: '1', child: Text('work'.tr)),
          DropdownMenuItem(value: '2', child: Text('other'.tr)),
        ],
        onChanged: _isLoading
            ? null
            : (value) {
          if (value == null) return;
          setState(() {
            _addressType = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'address_type_required'.tr;
          }
          return null;
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isUpdate ? 'edit_customer'.tr : 'add_customer'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isUpdate
                    ? 'update_customer_data'.tr
                    : 'enter_customer_data'.tr,
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

  // ============================================================
  // STEP 1: CUSTOMER INFO
  // ============================================================

  Widget _buildStep1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 4,
        bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              title: 'first_name'.tr,
              hint: 'enter_first_name'.tr,
              controller: _firstNameController,
              icon: Icons.person_outline,
              validator: (value) {
                return Validator.validateName(value ?? '', 'first_name'.tr);
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'last_name'.tr,
              hint: 'enter_last_name'.tr,
              controller: _lastNameController,
              icon: Icons.person_outline,
              validator: (value) {
                return Validator.validateName(value ?? '', 'last_name'.tr);
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'phone_number'.tr,
              hint: 'enter_phone_number'.tr,
              controller: _mobileController,
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
            const SizedBox(height: 16),
            _buildStatusSwitch(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP 2: ADDRESS INFO
  // ============================================================

  Widget _buildStep2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 4,
        bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              title: 'country_id'.tr,
              hint: 'enter_country_id'.tr,
              controller: _countryIdController,
              icon: Icons.public_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'country_required'.tr;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'city_id'.tr,
              hint: 'enter_city_id'.tr,
              controller: _cityIdController,
              icon: Icons.location_city_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'city_required'.tr;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'address'.tr,
              hint: 'enter_address'.tr,
              controller: _addressController,
              icon: Icons.location_on_outlined,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'address_required'.tr;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'address_title'.tr,
              hint: 'enter_address_title'.tr,
              controller: _addressTitleController,
              icon: Icons.label_outline_rounded,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'address_title_required'.tr;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              title: 'state_id'.tr,
              hint: 'enter_state_id'.tr,
              controller: _stateIdController,
              icon: Icons.map_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'state_required'.tr;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _buildAddressTypeDropdown(),
            const SizedBox(height: 16),
            _buildDefaultAddressSwitch(),
            const SizedBox(height: 16),
            AppTextField(
              title: 'delivery_instructions'.tr,
              hint: 'enter_delivery_instructions'.tr,
              controller: _deliveryInstructionsController,
              icon: Icons.delivery_dining_outlined,
              maxLines: 1,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER BUTTONS
  // ============================================================

  Widget _buildFooterButtons() {
    if (_currentStep == 0) {
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
                onPressed: _isLoading ? null : _goToStep2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'next'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 19),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _backToStep1,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
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
                    widget.isUpdate
                        ? Icons.save_outlined
                        : Icons.add_rounded,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isUpdate ? 'update'.tr : 'create'.tr,
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

  // ============================================================
  // BUILD
  // ============================================================

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
              // ==================================================
              // HANDLE
              // ==================================================
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

              // ==================================================
              // HEADER
              // ==================================================
              _buildHeader(),

              const SizedBox(height: 18),

              // ==================================================
              // STEP INDICATOR + LABEL
              // ==================================================
              _buildStepIndicator(),

              const SizedBox(height: 14),

              _buildStepLabel(),

              const SizedBox(height: 18),

              // ==================================================
              // STEP CONTENT (PageView)
              // ==================================================
              Flexible(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // FOOTER BUTTONS
              // ==================================================
              _buildFooterButtons(),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
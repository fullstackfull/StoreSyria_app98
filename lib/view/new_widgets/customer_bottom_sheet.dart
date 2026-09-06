import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/new_widgets/app_txt_field.dart';

import '../../core/controller/customers/customer_controller.dart';

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
  State<AddNewCustomerWidget> createState() =>
      _AddNewCustomerWidgetState();
}

class _AddNewCustomerWidgetState extends State<AddNewCustomerWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late CustomerController customerController;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _passwordController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isActive = true;
  bool _isLoading = false;

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

    _firstNameController = TextEditingController(
      text: widget.firstName ?? '',
    );

    _lastNameController = TextEditingController(
      text: widget.lastName ?? '',
    );

    _emailController = TextEditingController(
      text: widget.email ?? '',
    );

    _mobileController = TextEditingController(
      text: widget.mobile ?? '',
    );

    _passwordController = TextEditingController(
      text: widget.password ?? '',
    );

    _isActive = widget.status == null || widget.status == '1';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // THEME
  // ============================================================

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? darkBg : lightBg;

  Color get cardColor =>
      isDark ? darkCard : Colors.white;

  Color get textColor =>
      isDark ? Colors.white : navyBlue;

  Color get secondaryTextColor =>
      isDark ? Colors.white70 : secondaryText;

  Color get borderColor =>
      isDark ? Colors.white12 : lightBorder;

  // ============================================================
  // CLOSE
  // ============================================================

  void _close() {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    Get.back();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

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
      await customerController.addCustomerData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
        status: _isActive ? 1 : 0,
      );

      if (mounted) {
        Get.back();
      }
    } catch (e) {
      debugPrint(
        'Add customer error: $e',
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
  // STATUS SWITCH
  // ============================================================

  Widget _buildStatusSwitch() {
    final bool isActive = _isActive;

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
              size: 22,
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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                widget.isUpdate
                    ? 'edit_customer'.tr
                    : 'add_customer'.tr,
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
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
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
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: textColor,
              size: 22,
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
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom:
              MediaQuery.of(context).viewInsets.bottom +
                  16,
            ),
            child: SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // HANDLE
                    // ==================================================

                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white24
                              : const Color(0xFFD6DAE0),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // HEADER
                    // ==================================================

                    _buildHeader(),

                    const SizedBox(height: 24),

                    // ==================================================
                    // FIRST NAME
                    // ==================================================

                    AppTextField(
                      title: 'first_name'.tr,
                      hint: 'enter_first_name'.tr,
                      controller: _firstNameController,
                      icon: Icons.person_outline,
                      validator: (value) {
                        return Validator.validateName(
                          value ?? '',
                          'first_name'.tr,
                        );
                      },
                      textInputAction:
                      TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // LAST NAME
                    // ==================================================

                    AppTextField(
                      title: 'last_name'.tr,
                      hint: 'enter_last_name'.tr,
                      controller: _lastNameController,
                      icon: Icons.person_outline,
                      validator: (value) {
                        return Validator.validateName(
                          value ?? '',
                          'last_name'.tr,
                        );
                      },
                      textInputAction:
                      TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // MOBILE
                    // ==================================================

                    AppTextField(
                      title: 'phone_number'.tr,
                      hint: 'enter_phone_number'.tr,
                      controller: _mobileController,
                      icon: Icons.phone_outlined,
                      keyboardType:
                      TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+]'),
                        ),
                      ],
                      validator: (value) {
                        return Validator.validateMobile(
                          value ?? '',
                        );
                      },
                      textInputAction:
                      TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
// EMAIL
// ==================================================

                    AppTextField(
                      title: 'email'.tr,
                      hint: 'enter_email'.tr,
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        return Validator.validateEmail(
                          value ?? '',
                        );
                      },
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

       // ==================================================
      // PASSWORD
     // ==================================================

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

                    const SizedBox(height: 18),

                    // ==================================================
                    // STATUS
                    // ==================================================

                    _buildStatusSwitch(),

                    const SizedBox(height: 28),

                    // ==================================================
                    // BUTTONS
                    // ==================================================

                    Row(
                      children: [
                        // CANCEL
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed:
                              _isLoading
                                  ? null
                                  : _close,
                              style:
                              OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: borderColor,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),
                              child: Text(
                                'cancel'.tr,
                                style: TextStyle(
                                  color:
                                  secondaryTextColor,
                                  fontWeight:
                                  FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ADD
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                              _isLoading
                                  ? null
                                  : _submit,
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                navyBlue,
                                foregroundColor:
                                Colors.white,
                                elevation: 0,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 21,
                                height: 21,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                  Colors.white,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                                children: [
                                  Icon(
                                    widget.isUpdate
                                        ? Icons
                                        .save_outlined
                                        : Icons
                                        .add_rounded,
                                    size: 19,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    widget.isUpdate
                                        ? 'update'
                                        .tr
                                        : 'create'
                                        .tr,
                                    style:
                                    const TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight
                                          .w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
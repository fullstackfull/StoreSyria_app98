// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class AddNewCategoriesWidget extends StatefulWidget {
  final bool isUpdate;
  final int? categoryId;
  final String? name;
  final String? image;
  final String? icon;
  final String? trending;
  final String? status;

  const AddNewCategoriesWidget({
    super.key,
    required this.isUpdate,
    this.categoryId,
    this.name,
    this.image,
    this.icon,
    this.trending,
    this.status,
  });

  @override
  State<AddNewCategoriesWidget> createState() =>
      _AddNewCategoriesWidgetState();
}

class _AddNewCategoriesWidgetState extends State<AddNewCategoriesWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late CategoryController categoryController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color navyBlue = Color(0xFF172C4E);

  @override
  void initState() {
    super.initState();

    categoryController = Get.find<CategoryController>();

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
    categoryController.categoryName.clear();

    if (widget.isUpdate) {
      categoryController.categoryName.text = widget.name ?? '';

      categoryController.imagePath.value = widget.image ?? '';
      categoryController.iconPath.value = widget.icon ?? '';

      // Trending
      final isTrending = widget.trending == '1';
      categoryController.isTrending.value = isTrending;
      categoryController.trending.value = isTrending ? '1' : '0';

      // Status
      final isActive = widget.status == '1';
      categoryController.isActive.value = isActive;
    } else {
      categoryController.imagePath.value = '';
      categoryController.iconPath.value = '';

      categoryController.isTrending.value = false;
      categoryController.trending.value = '1';

      categoryController.isActive.value = false;
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
      isDark ? const Color(0xFF101820) : const Color(0xFFF7F8FA);

  Color get cardColor =>
      isDark ? const Color(0xFF182331) : Colors.white;

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

  Future<void> _pickImage({required bool isIcon}) async {
    final path = await categoryController.pickFile();

    if (path == null || path.toString().isEmpty) return;

    if (isIcon) {
      categoryController.iconPath.value = path.toString();
    } else {
      categoryController.imagePath.value = path.toString();
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: navyBlue.withOpacity(isDark ? 0.25 : 0.08),
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
                    ? 'edit_category'.tr
                    : 'add_category'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isUpdate
                    ? 'update_category_description'.tr
                    : 'create_category_description'.tr,
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

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Name
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'category_name'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
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
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: categoryController.categoryName,
          validator: (value) {
            return Validator.validateRequired(value ?? "");
          },
          textInputAction: TextInputAction.done,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: 'enter_category_name'.tr,
            hintStyle: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
            prefixIcon: Icon(
              Icons.category_outlined,
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
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
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

  Widget _buildAttachment({
    required String title,
    required String hint,
    required String path,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasFile = path.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        RichText(
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
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasFile ? navyBlue : borderColor,
                width: hasFile ? 1.2 : 1,
              ),
            ),
            child: Row(
              children: [
                // الصورة
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: hasFile
                      ? Image.network(
                    path,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: navyBlue.withOpacity(0.07),
                        child: Icon(
                          icon,
                          color: navyBlue,
                          size: 25,
                        ),
                      );
                    },
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    color: navyBlue.withOpacity(0.07),
                    child: Icon(
                      icon,
                      color: navyBlue,
                      size: 25,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile
                            ? path.split('/').last
                            : hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: hasFile
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: hasFile
                              ? textColor
                              : secondaryTextColor,
                        ),
                      ),

                      if (hasFile) ...[
                        const SizedBox(height: 3),
                        Text(
                          'tap_to_change'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSwitch() {
    final isTrending = categoryController.isTrending.value;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
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
              color: navyBlue.withOpacity(
                isDark ? 0.22 : 0.07,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isTrending
                  ? Icons.local_fire_department_rounded
                  : Icons.local_fire_department_outlined,
              color: navyBlue,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'trending'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isTrending
                      ? 'yes'.tr
                      : 'no'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isTrending
                        ? navyBlue
                        : secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          CupertinoSwitch(
            value: isTrending,
            onChanged: (value) {
              categoryController.isTrending.value = value;
              categoryController.trending.value = value ? '1' : '0';
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

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _close,
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
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _submit();
                }
              },
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
                  Icon(
                    widget.isUpdate
                        ? Icons.save_outlined
                        : Icons.add_rounded,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isUpdate
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

  void _submit() {
    FocusScope.of(context).unfocus();

    final name = categoryController.categoryName.text.trim();
    final image = categoryController.imagePath.value;
    final icon = categoryController.iconPath.value;

    if (name.isEmpty) {
      commonToast('category_name_required'.tr);
      return;
    }

    if (image.isEmpty) {
      commonToast('category_image_required'.tr);
      return;
    }

    if (icon.isEmpty) {
      commonToast('category_icon_required'.tr);
      return;
    }

    if (widget.isUpdate &&
        Prefs.getBool(AppConstant.isDemoMode) == true) {
      commonToast(AppConstant.demoString);
      return;
    }

    categoryController.addCategoriesData(
      isUpdate: widget.isUpdate,
      categoryId: widget.categoryId ?? 0,
      name: name,
      trending: categoryController.trending.value,
      status: widget.status ?? '1',

      // مهم: الصورة للصورة
      imagePath: image,

      // والأيقونة للأيقونة
      iconImagePath: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      maintainBottomViewPadding: true,
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
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Obx(
                    () => Form(
                      key: _formKey,
                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFD6DAE0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      _buildHeader(),

                      const SizedBox(height: 24),

                      _buildTextField(),

                      const SizedBox(height: 18),

                      _buildAttachment(
                        title: 'category_image'.tr,
                        hint: 'add_category_image'.tr,
                        path: categoryController.imagePath.value,
                        icon: Icons.image_outlined,
                        onTap: () => _pickImage(isIcon: false),
                      ),

                      const SizedBox(height: 14),

                      _buildAttachment(
                        title: 'category_icon'.tr,
                        hint: 'add_category_icon'.tr,
                        path: categoryController.iconPath.value,
                        icon: Icons.insert_emoticon_outlined,
                        onTap: () => _pickImage(isIcon: true),
                      ),

                      const SizedBox(height: 18),

                      _buildTrendingSwitch(),

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
  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
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
              color: navyBlue.withOpacity(
                isDark ? 0.22 : 0.07,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              categoryController.isActive.value
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: navyBlue,
              size: 21,
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
                  categoryController.isActive.value
                      ? 'active'.tr
                      : 'inactive'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: categoryController.isActive.value
                        ? navyBlue
                        : secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          CupertinoSwitch(
            value: categoryController.isActive.value,
            onChanged: (value) {
              categoryController.isActive.value = value;
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
}

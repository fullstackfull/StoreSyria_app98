import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import '../../../core/controller/setting_controller/store_setting_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/validator.dart';
import '../../new_widgets/app_txt_field.dart';
import '../../new_widgets/shimmer.dart';
import '../../new_widgets/social_widget.dart';
import '../../widget/app_dialog.dart';
import '../../widget/error_empty_state.dart';
import '../../widget/icon_and_image.dart';

class StoreInfoScreen extends StatefulWidget {
  const StoreInfoScreen({super.key});

  @override
  State<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends State<StoreInfoScreen> {
  final StoreSettingController controller =
  Get.find<StoreSettingController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getStoreInfoData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkThemeColor.cBackGround
          : const Color(0xFFF6F7F9),
      appBar: simpleAppBar(
        title: 'Store Information',
        label: null,
        isBack: true,
        isBold: true,
        onNewLabelTap: () {},
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.storeInfoData.value == null) {
            return const ShimmerDetails(sections: 3, rowsPerSection: 3);
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.storeInfoData.value == null) {
            return ErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.getStoreInfoData,
            );
          }

          if (controller.storeInfoData.value == null) {
            return EmptyState(
              message: 'No store information available',
              icon: Icons.store_outlined,
              actionWidget: ElevatedButton.icon(
                onPressed: controller.getStoreInfoData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColor.themeNavyBlueColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 22.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.r),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColor.themeNavyBlueColor,
            onRefresh: controller.getStoreInfoData,
            child: SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                30.h,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      context: context,
                      title: 'Store Information',
                      icon: Icons.store_outlined,
                      children: [
                        _field(
                          title: 'Store Name',
                          hint: 'Enter store name',
                          controller:
                          controller.storeNameController,
                          icon: Icons.store_outlined,
                          validator: (value) =>
                              Validator.validateRequired(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Email',
                          hint: 'Enter store email',
                          controller:
                          controller.storeEmailController,
                          icon: Icons.email_outlined,
                          keyboardType:
                          TextInputType.emailAddress,
                          validator: (value) =>
                              Validator.validateEmail(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Store URL',
                          hint: 'Enter store URL',
                          controller:
                          controller.storeUrlController,
                          icon: Icons.public_outlined,
                          keyboardType:
                          TextInputType.url,
                          validator: (value) =>
                              Validator.validateUrl(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Created At',
                          hint: 'Created at',
                          controller:
                          controller
                              .storeCreatedAtController,
                          icon:
                          Icons.calendar_today_outlined,
                          enabled: false,
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    _sectionCard(
                      context: context,
                      title: 'Owner Information',
                      icon: Icons.person_outline,
                      children: [
                        _field(
                          title: 'Owner Name',
                          hint: 'Enter owner name',
                          controller:
                          controller.ownerNameController,
                          icon: Icons.person_outline,
                          validator: (value) =>
                              Validator.validateRequired(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Owner Email',
                          hint: 'Enter owner email',
                          controller:
                          controller.ownerEmailController,
                          icon: Icons.email_outlined,
                          keyboardType:
                          TextInputType.emailAddress,
                          validator: (value) =>
                              Validator.validateEmail(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Mobile',
                          hint: 'Enter mobile number',
                          controller:
                          controller.mobileController,
                          icon: Icons.phone_outlined,
                          keyboardType:
                          TextInputType.phone,
                          validator: (value) =>
                              Validator.validateMobile(
                                value!,
                              ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    _sectionCard(
                      context: context,
                      title: 'Address',
                      icon:
                      Icons.location_on_outlined,
                      children: [

                        _field(
                          title: 'City',
                          hint: 'Enter city',
                          controller:
                          controller.cityController,
                          icon:
                          Icons.location_city_outlined,
                          validator: (value) =>
                              Validator.validateRequired(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Country',
                          hint: 'Enter country',
                          controller:
                          controller.countryController,
                          icon: Icons.public_outlined,
                          validator: (value) =>
                              Validator.validateRequired(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'State',
                          hint: 'Enter state',
                          controller:
                          controller.stateController,
                          icon: Icons.map_outlined,
                          validator: (value) =>
                              Validator.validateRequired(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Address',
                          hint: 'Enter store address',
                          controller:
                          controller.addressController,
                          icon: Icons.home_outlined,
                          validator: (value) =>
                              Validator.validateRequired(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Zipcode',
                          hint: 'Enter zipcode',
                          controller:
                          controller.zipcodeController,
                          icon: Icons.markunread_mailbox_outlined,
                          keyboardType:
                          TextInputType.number,
                          validator: (value) =>
                              Validator.validateRequired(
                                value!,
                              ),
                        ),

                        _field(
                          title: 'Full Address',
                          hint: 'Full address',
                          controller:
                          controller
                              .fullAddressController,
                          icon:
                          Icons.location_on_outlined,
                          maxLines: 2,
                          validator: (value) =>
                              Validator.validateRequired(
                                value!,
                              ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    SocialMediaSection(
                      controller: controller,
                    ),

                    SizedBox(height: 16.h),

                    _sectionCard(
                      context: context,
                      title: 'Media',
                      icon: Icons.image_outlined,
                      children: [
                        Obx(
                              () => _mediaPreview(
                            context: context,
                            title: 'Invoice Logo',
                            serverUrl: controller.invoiceLogoController.text,
                            selectedPath: controller.selectedInvoiceLogo.value,
                            onPick:
                            controller.pickInvoiceLogo,
                          ),
                        ),

                        SizedBox(height: 18.h),

                        Obx(
                              () => _mediaPreview(
                            context: context,
                            title: 'Store Image',
                            serverUrl: controller.storeImageController.text,
                            selectedPath: controller.selectedStoreImage.value,
                            onPick:
                            controller.pickStoreImage,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    Obx(
                          () => SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: AppButton(
                          onPressed:
                          controller.isUpLoading.value
                              ? null
                              : _submit,
                          text:
                          controller.isUpLoading.value
                              ? 'Saving...'
                              : 'Save Changes',
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    controller.updateStoreInfo();
  }


  Widget _field({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: AppTextField(
        title: title,
        hint: hint,
        controller: controller,
        icon: icon,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final Color cardColor = isDark
        ? const Color(0xFF18263F)
        : Colors.white;

    final Color titleColor = isDark
        ? Colors.white
        : const Color(0xFF172C4E);

    final Color iconBackground = isDark
        ? Colors.white.withOpacity(0.07)
        : const Color(0xFF172C4E)
        .withOpacity(0.06);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE5E8ED),
        ),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.035),
            blurRadius: 12,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                  BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color:
                  AppColor.themeNavyBlueColor,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight:
                    FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          ...children,
        ],
      ),
    );
  }

// ============================================================
// MEDIA PREVIEW
// ============================================================

  Widget _mediaPreview({
    required BuildContext context,
    required String title,
    required String serverUrl,
    required String selectedPath,
    required VoidCallback onPick,
  }) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final bool hasLocalImage =
        selectedPath.isNotEmpty;

    final bool hasServerImage =
        serverUrl.isNotEmpty;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight:
                  FontWeight.w600,
                  color: isDark
                      ? Colors.white70
                      : const Color(
                    0xFF687386,
                  ),
                ),
              ),
            ),

            OutlinedButton.icon(
              onPressed: onPick,
              icon: Icon(
                Icons.image_outlined,
                size: 17.sp,
              ),
              label: Text(
                hasLocalImage
                    ? 'Change File'
                    : 'Pick File',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                AppColor
                    .themeNavyBlueColor,
                side: BorderSide(
                  color: AppColor
                      .themeNavyBlueColor
                      .withOpacity(0.35),
                ),
                padding:
                EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 7.h,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    10.r,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        Container(
          width: double.infinity,
          height: 170.h,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white
                .withOpacity(0.03)
                : const Color(0xFFF7F8FA),
            borderRadius:
            BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark
                  ? Colors.white
                  .withOpacity(0.07)
                  : const Color(0xFFE2E6EC),
            ),
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(14.r),
            child: hasLocalImage
                ? Image.file(
              File(selectedPath),
              fit: BoxFit.contain,
              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return _emptyImageState(
                  context,
                  'Unable to preview image',
                );
              },
            )
                : hasServerImage
                ? buildCachedNetworkImage(
              imageUrl: serverUrl,
              fit: BoxFit.contain,
            )
                : _emptyImageState(
              context,
              'No image selected',
            ),
          ),
        ),

        if (hasLocalImage) ...[
          SizedBox(height: 6.h),

          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 15.sp,
                color:
                AppColor
                    .themeNavyBlueColor,
              ),

              SizedBox(width: 4.w),

              Expanded(
                child: Text(
                  'New image selected',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:
                    AppColor
                        .themeNavyBlueColor,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

// ============================================================
// EMPTY IMAGE
// ============================================================

  Widget _emptyImageState(
      BuildContext context,
      String message,
      ) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 38.sp,
            color: isDark
                ? Colors.white38
                : Colors.grey,
          ),

          SizedBox(height: 6.h),

          Text(
            message,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? Colors.white38
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

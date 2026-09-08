import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import '../../../core/controller/setting_controller/store_setting_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/helper.dart'; // Importing the helper file
import '../../new_widgets/app_txt_field.dart';
import '../../widget/error_empty_state.dart';
import '../../widget/icon_and_image.dart';
import '../../widget/loading_widget.dart';

class StoreInfoScreen extends StatefulWidget {
  const StoreInfoScreen({super.key});

  @override
  State<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends State<StoreInfoScreen> {
  final StoreSettingController controller = Get.find<StoreSettingController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getStoreInfoData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkThemeColor.cBackGround : const Color(0xFFF6F7F9),
      appBar: simpleAppBar(
        title: 'Store Information',
        label: null,
        isBack: true,
        isBold: true,
        onNewLabelTap: () {},
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.storeInfoData.value == null) {
            return const LoadingWidget();
          }

          if (controller.errorMessage.value.isNotEmpty && controller.storeInfoData.value == null) {
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
                  backgroundColor: AppColor.themeNavyBlueColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColor.themeNavyBlueColor,
            onRefresh: controller.getStoreInfoData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STORE INFORMATION
                  _sectionCard(
                    context: context,
                    title: 'Store Information',
                    icon: Icons.store_outlined,
                    children: [
                      _field(title: 'Store Name', hint: 'Enter store name', controller: controller.storeNameController, icon: Icons.store_outlined),
                      _field(title: 'Email', hint: 'Enter store email', controller: controller.storeEmailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      _field(title: 'Store URL', hint: 'Enter store URL', controller: controller.storeUrlController, icon: Icons.public_outlined, keyboardType: TextInputType.url),
                      _field(title: 'Created At', hint: 'Created at', controller: controller.storeCreatedAtController, icon: Icons.calendar_today_outlined, enabled: false),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // OWNER INFORMATION
                  _sectionCard(
                    context: context,
                    title: 'Owner Information',
                    icon: Icons.person_outline,
                    children: [
                      _field(title: 'Owner Name', hint: 'Enter owner name', controller: controller.ownerNameController, icon: Icons.person_outline),
                      _field(title: 'Owner Email', hint: 'Enter owner email', controller: controller.ownerEmailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      _field(title: 'Mobile', hint: 'Enter mobile number', controller: controller.mobileController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ADDRESS
                  _sectionCard(
                    context: context,
                    title: 'Address',
                    icon: Icons.location_on_outlined,
                    children: [
                      _field(title: 'Address', hint: 'Enter store address', controller: controller.addressController, icon: Icons.home_outlined),
                      _field(title: 'City', hint: 'Enter city', controller: controller.cityController, icon: Icons.location_city_outlined),
                      _field(title: 'State', hint: 'Enter state', controller: controller.stateController, icon: Icons.map_outlined),
                      _field(title: 'Country', hint: 'Enter country', controller: controller.countryController, icon: Icons.public_outlined),
                      _field(title: 'Zipcode', hint: 'Enter zipcode', controller: controller.zipcodeController, icon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number),
                      _field(title: 'Full Address', hint: 'Full address', controller: controller.fullAddressController, icon: Icons.location_on_outlined, maxLines: 2),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // SOCIAL MEDIA SECTION
                  SocialMediaSection(
                    controller: controller,
                  ),
                  SizedBox(height: 16.h),

                  // MEDIA SECTION (Using buildCachedNetworkImage from helper)
                  _sectionCard(
                    context: context,
                    title: 'Media',
                    icon: Icons.image_outlined,
                    children: [
                      _mediaPreview(context: context, title: 'Invoice Logo', url: controller.invoiceLogoController.text),
                      SizedBox(height: 18.h),
                      _mediaPreview(context: context, title: 'Store Image', url: controller.storeImageController.text),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: controller.updateStoreInfoData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.themeNavyBlueColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('Save Changes', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _field({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF182331) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF172C4E);
    final Color iconBackground = isDark ? Colors.white.withOpacity(0.07) : const Color(0xFF172C4E).withOpacity(0.06);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E8ED)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(12.r)),
                child: Icon(icon, color: AppColor.themeNavyBlueColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(child: Text(title, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: titleColor))),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  // Updated to use buildCachedNetworkImage from helper
  Widget _mediaPreview({required BuildContext context, required String title, required String url}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF687386))),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 170.h,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : const Color(0xFFE2E6EC)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: buildCachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

// =========================
// Social Media Section Widget
// =========================
class SocialMediaSection extends StatelessWidget {
  final StoreSettingController controller;

  const SocialMediaSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF182331) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF172C4E);
    final Color iconBackground = isDark ? Colors.white.withOpacity(0.07) : const Color(0xFF172C4E).withOpacity(0.06);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E8ED)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(12.r)),
                child: Icon(Icons.share_outlined, color: AppColor.themeNavyBlueColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(child: Text('Social Media', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: titleColor))),
            ],
          ),
          SizedBox(height: 20.h),

          SocialMediaField(
            title: 'Facebook',
            hint: 'Facebook link',
            controller: controller.facebookController,
            iconWidget: assetImageWidget(image: 'assets/icon/facebook.png', width: 24.w, height: 24.w),
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 14.h),

          SocialMediaField(
            title: 'Twitter / X',
            hint: 'Twitter / X link',
            controller: controller.twitterController,
            iconWidget: assetImageWidget(image: "assets/icon/twitter.png", width: 24.w, height: 24.w),
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 14.h),

          SocialMediaField(
            title: 'Instagram',
            hint: 'Instagram link',
            controller: controller.instagramController,
            iconWidget: assetImageWidget(image: 'assets/icon/instagram.png', width: 24.w, height: 24.w),
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 14.h),

          SocialMediaField(
            title: 'WhatsApp',
            hint: 'WhatsApp number or link',
            controller: controller.whatsappController,
            iconWidget: assetImageWidget(image: 'assets/icon/whatsapp.png', width: 24.w, height: 24.w),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

// =========================
// Custom Social Media Field Widget
// =========================
class SocialMediaField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final Widget iconWidget;
  final TextInputType keyboardType;

  const SocialMediaField({
    Key? key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.iconWidget,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF687386),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E6EC),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: iconWidget,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
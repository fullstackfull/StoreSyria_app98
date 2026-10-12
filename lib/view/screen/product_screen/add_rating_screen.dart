// ignore_for_file: must_be_immutable, prefer_const_constructors

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/core/controller/product_controller/add_review_controller.dart';
import '../../widget/app_dialog.dart';
import 'package:store_go_app/utils/app_log.dart';

class AddRatingScreen extends StatefulWidget {
  final String categoryId;
  final String productId;
  final String id;
  final bool isUpdate;
  final double? rate;
  final String? user;
  final String? title;
  final String? description;
  final String? status;
  final String? reviewId;

  const AddRatingScreen({super.key, required this.categoryId, required this.productId, required this.isUpdate, this.rate, this.user, this.title, this.description, this.status, this.reviewId, required this.id});

  @override
  State<AddRatingScreen> createState() => _AddRatingScreenState();
}

class _AddRatingScreenState extends State<AddRatingScreen> {
  AddReviewController addReviewController = Get.put(AddReviewController());
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    });

    if (widget.isUpdate == true) {
      addReviewController.rate.value = widget.rate ?? 0.0;

      addReviewController.titleController.text = widget.title ?? '';
      addReviewController.descriptionController.text =
          widget.description ?? '';

      addReviewController.isStatus.value = widget.status == "1";
      addReviewController.status.value =
      widget.status == "1" ? '1' : '0';
    } else {
      // Default values for new review
      addReviewController.rate.value = 0.0;

      addReviewController.isStatus.value = false;
      addReviewController.status.value = '0';

      addReviewController.titleController.clear();
      addReviewController.descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
    isDark ? DarkThemeColor.cBackGround : const Color(0xFFF5F6F8);

    final cardColor = isDark ? DarkThemeColor.cCardBackground : Colors.white;

    final borderColor =
    isDark ? DarkThemeColor.cBorder : const Color(0xFFE9EAEE);

    final primaryTextColor = isDark ? Colors.white : AppColor.cText;

    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : AppColor.cFont;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: simpleAppBar(
        isBack: true,
        title: widget.isUpdate == true
            ? 'update_review'.tr
            : 'add_review'.tr,
        label: null,
        onNewLabelTap: () {  },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Obx(
                () {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // RATE CARD
                      // ==================================================
                      _sectionCard(
                        cardColor: cardColor,
                        borderColor: borderColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              icon: Icons.star_rounded,
                              label: 'select_your_rate'.tr,
                              primaryTextColor: primaryTextColor,
                            ),

                            verticalSpace(14.h),

                            Center(
                              child: RatingBar.builder(
                                initialRating:
                                addReviewController.rate.value,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemSize: 38.sp,
                                unratedColor:
                                secondaryTextColor.withOpacity(0.3),
                                glow: false,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star_rate_rounded,
                                  color: AppColor.cGreenFont,
                                ),
                                onRatingUpdate: (rating) {
                                  AppLog.d(rating);
                                  addReviewController.rate.value = rating;
                                  AppLog.d(addReviewController.rate.value);
                                },
                              ),
                            ),

                            verticalSpace(8.h),

                            Center(
                              child: Text(
                                addReviewController.rate.value > 0
                                    ? "${addReviewController.rate.value.toStringAsFixed(0)} / 5"
                                    : 'tap_star_to_rate'.tr,
                                style: pMedium12.copyWith(
                                  color: secondaryTextColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      verticalSpace(16.h),

                      // ==================================================
                      // DETAILS CARD
                      // ==================================================
                      _sectionCard(
                        cardColor: cardColor,
                        borderColor: borderColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              icon: Icons.edit_note_rounded,
                              label: 'review_details'.tr,
                              primaryTextColor: primaryTextColor,
                            ),

                            verticalSpace(12.h),

                            AddProductTextField(
                              controller:
                              addReviewController.titleController,
                              labelText: 'review_title'.tr,
                              hintText: 'enter_review_title'.tr,
                              validator: (value) {
                                return Validator.validateRequired(value!);
                              },
                            ),

                            verticalSpace(6.h),

                            AddProductTextField(
                                controller: addReviewController
                                    .descriptionController,
                                labelText: 'description'.tr,
                                hintText: 'description'.tr,
                                validator: (value) {
                                  return Validator.validateRequired(
                                      value!);
                                },
                                maxLines: 5),
                          ],
                        ),
                      ),

                      verticalSpace(16.h),

                      // ==================================================
                      // STATUS CARD
                      // ==================================================
                      _sectionCard(
                        cardColor: cardColor,
                        borderColor: borderColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              icon: Icons.visibility_outlined,
                              label: 'visibility'.tr,
                              primaryTextColor: primaryTextColor,
                            ),

                            verticalSpace(10.h),

                            Obx(
                                  () {
                                final isVisible =
                                    addReviewController.isStatus.value;


                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isVisible
                                        ? AppColor.themeGreenColor
                                        : Colors.grey)
                                        .withOpacity(0.08),
                                    borderRadius:
                                    BorderRadius.circular(12.r),
                                    // border: Border.all(
                                    //   color: (isVisible
                                    //       ? AppColor.themeGreenColor
                                    //       : Colors.grey)
                                    //       .withOpacity(0.3),
                                    // ),
                                  ),
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      isVisible
                                          ? 'visible_to_public'.tr
                                          : 'hidden_from_public'.tr,
                                      style: pMedium12.copyWith(
                                        fontSize: 14.sp,
                                        color: isVisible
                                            ? AppColor.themeGreenColor
                                            : primaryTextColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      isVisible
                                          ? 'review_visible_hint'.tr
                                          : 'review_hidden_hint'.tr,
                                      style: pRegular10.copyWith(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    value: isVisible,
                                    onChanged: (value) {
                                      addReviewController.isStatus.value =
                                          value;
                                      addReviewController.status.value =
                                      value ? '1' : '0';
                                    },
                                    activeColor: AppColor.themeGreenColor,
                                    activeTrackColor: AppColor.themeGreenColor.withOpacity(0.3),
                                    inactiveThumbColor:
                                    Colors.grey.shade500,
                                    inactiveTrackColor:
                                    isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      verticalSpace(24.h),

                      AppButton(
                        isLoading: addReviewController.isAddReviewLoading.value,
                        text: widget.isUpdate == true
                            ? 'update_review'.tr
                            : 'send_review'.tr,
                        width: double.infinity,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (widget.isUpdate == true) {
                              if (Prefs.getBool(
                                  AppConstant.isDemoMode) ==
                                  true) {
                                commonToast(type: AppSnackBarType.info, AppConstant.demoString);
                              } else {
                                addReviewController.addReview(
                                  id: widget.id,
                                  isUpdate: widget.isUpdate,
                                  reviewId: widget.reviewId ?? '',
                                  userId:
                                  addReviewController.userId.value,
                                  title: addReviewController
                                      .titleController.text
                                      .trim(),
                                  description: addReviewController
                                      .descriptionController.text
                                      .trim(),
                                  categoryId: widget.categoryId,
                                  productId: widget.productId,
                                  rating: addReviewController.rate.value
                                      .toString(),
                                  status:
                                  addReviewController.status.value,
                                );
                              }
                            } else {
                              addReviewController.addReview(
                                id: widget.id,
                                isUpdate: widget.isUpdate,
                                reviewId: widget.reviewId ?? '',
                                userId: addReviewController.userId.value,
                                title: addReviewController
                                    .titleController.text
                                    .trim(),
                                description: addReviewController
                                    .descriptionController.text
                                    .trim(),
                                categoryId: widget.categoryId,
                                productId: widget.productId,
                                rating: addReviewController.rate.value
                                    .toString(),
                                status: addReviewController.status.value,
                              );
                            }
                          }
                        },
                      ),

                      verticalSpace(10.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================
  Widget _sectionCard({
    required Widget child,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        // border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================
  Widget _sectionTitle({
    required IconData icon,
    required String label,
    required Color primaryTextColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppColor.themeGreenColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: AppColor.themeGreenColor,
          ),
        ),
        horizontalSpace(8.w),
        Text(
          label,
          style: pBold14.copyWith(
            color: primaryTextColor,
            fontSize: 15.sp,
          ),
        ),
      ],
    );
  }
}
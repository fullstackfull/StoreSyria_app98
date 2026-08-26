// ignore_for_file: must_be_immutable, avoid_print, prefer_const_constructors

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
import 'package:store_go_app/core/controller/product_controller/add_review_controller.dart';

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
      getData();
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

  getData() {
    addReviewController.getReviewUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cBackGround,
      appBar: simpleAppBar(title: widget.isUpdate == true ? "Update Review" : "Add Review"),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(
          () {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select your Rate:", style: pBold14),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: RatingBar.builder(
                        initialRating: addReviewController.rate.value,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 36,
                        unratedColor: AppColor.cFont,
                        glow: false,
                        itemBuilder: (context, _) => Icon(
                          Icons.star_rate_rounded,
                          color: AppColor.cGreenFont,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                          addReviewController.rate.value = rating;
                          print(addReviewController.rate.value);
                        },
                      ),
                    ),
                    verticalSpace(10),
                    AddProductTextField(
                      controller: addReviewController.titleController,
                      labelText: 'Review Title',
                      hintText: 'Enter Review Title',
                      validator: (value) {
                        return Validator.validateRequired(value!);
                      },
                    ),
                    AddProductTextField(
                        controller: addReviewController.descriptionController,
                        labelText: 'Description',
                        hintText: 'Description',
                        validator: (value) {
                          return Validator.validateRequired(value!);
                        },
                        maxLines: 5),
                    verticalSpace(10),
                    Obx(
                          () => SwitchListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 2.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: AppColor.cBorder,
                          ),
                        ),
                        tileColor: Colors.white,
                        title: Text(
                          'Status',
                          style: pMedium12.copyWith(
                            fontSize: 14.sp,
                            color: AppColor.cDarkGreyFont,
                          ),
                        ),
                        value: addReviewController.isStatus.value,
                        onChanged: (value) {
                          addReviewController.isStatus.value = value;
                          addReviewController.status.value = value ? '1' : '0';
                        },
                        activeColor: AppColor.themeGreenColor,
                        activeTrackColor: AppColor.themeGreenColor.withOpacity(0.3),
                        inactiveThumbColor: Colors.grey.shade500,
                        inactiveTrackColor: Colors.grey.shade300,
                      ),
                    ),
                    verticalSpace(20),
                    CommonButton(
                      title: widget.isUpdate == true ? "Update Review" : 'Send Review',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (widget.isUpdate == true) {
                            if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                              commonToast(AppConstant.demoString);
                            } else {
                              addReviewController.addReview(
                                id : widget.id,
                                isUpdate: widget.isUpdate,
                                reviewId: widget.reviewId ?? '',
                                userId: addReviewController.userId.value,
                                title: addReviewController.titleController.text.trim(),
                                description: addReviewController.descriptionController.text.trim(),
                                categoryId: widget.categoryId,
                                productId: widget.productId,
                                rating: addReviewController.rate.value.toString(),
                                status: addReviewController.status.value,
                              );
                            }
                          } else {
                            addReviewController.addReview(
                              id: widget.id,
                              isUpdate: widget.isUpdate,
                              reviewId: widget.reviewId ?? '',
                              userId: addReviewController.userId.value,
                              title: addReviewController.titleController.text.trim(),
                              description: addReviewController.descriptionController.text.trim(),
                              categoryId: widget.categoryId,
                              productId: widget.productId,
                              rating: addReviewController.rate.value.toString(),
                              status: addReviewController.status.value,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, must_be_immutable, avoid_print, prefer_const_constructors_in_immutables

import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/prefer.dart';
import '../product_screen/product_widget.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/validator.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';

class AddNewCategoriesWidget extends StatefulWidget {
  final bool isUpdate;
  final int? categoryId;
  final String? name;
  final String? image;
  final String? icon;
  final String? trending;
  final String? status;

  AddNewCategoriesWidget({Key? key, required this.isUpdate, this.categoryId, this.name, this.image, this.icon, this.trending, this.status}) : super(key: key);

  @override
  State<AddNewCategoriesWidget> createState() => _AddNewCategoriesWidgetState();
}

class _AddNewCategoriesWidgetState extends State<AddNewCategoriesWidget> {
  CategoryController categoryController = Get.put(CategoryController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isUpdate == true) {
      categoryController.categoryName.text = widget.name!;
      categoryController.imagePath.value = widget.image!;
      categoryController.iconPath.value = widget.icon!;
      categoryController.imagePath.value = '';
      categoryController.iconPath.value = '';
      if (widget.trending == '1') {
        categoryController.isTrending.value = true;
      } else {
        categoryController.isTrending.value = false;
      }
    } else {
      categoryController.iconPath.value = '';
      categoryController.imagePath.value = '';
      categoryController.categoryName.clear();
      categoryController.isTrending.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: AppColor.cBackGround,
          ),
          padding: EdgeInsets.all(24),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Row(
                    children: [
                      assetSvdImageWidget(
                        image: DefaultImages.closeIcn,
                        colorFilter: ColorFilter.mode(AppColor.cGreenFont, BlendMode.srcIn),
                      ),
                      horizontalSpace(8),
                      Text(
                        "Close",
                        style: pSemiBold14.copyWith(
                          color: AppColor.cGreenFont,
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(8),
                Text(
                  "Create",
                  style: pRegular12,
                ),
                verticalSpace(10),
                Text(
                  "New Category",
                  style: pRegular18.copyWith(
                    color: AppColor.cGreenFont,
                  ),
                ),
                verticalSpace(10),
                horizontalDivider(),
                verticalSpace(10),
                AddProductTextField(
                  controller: categoryController.categoryName,
                  labelText: 'Name:',
                  hintText: 'Enter Name',
                  validator: (value) {
                    return Validator.validateRequired(value!);
                  },
                ),
                verticalSpace(10),
                Text(
                  "Image:",
                  style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
                ),
                verticalSpace(15),
                GestureDetector(
                  onTap: () async {
                    categoryController.imagePath.value = await categoryController.pickFile();
                  },
                  child: addAttachmentWidget(
                    categoryController.imagePath.value == '' ? "+ Add attachment..." : categoryController.imagePath.value.split('/').last,
                  ),
                ),
                verticalSpace(10),
                Text(
                  "Icon:",
                  style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
                ),
                verticalSpace(15),
                GestureDetector(
                  onTap: () async {
                    categoryController.iconPath.value = await categoryController.pickFile();
                  },
                  child: addAttachmentWidget(
                    categoryController.iconPath.value == '' ? "+ Add attachment..." : categoryController.iconPath.value.split('/').last,
                  ),
                ),
                verticalSpace(10),
                Row(
                  children: [
                    CupertinoSwitch(
                      value: categoryController.isTrending.value,
                      onChanged: (value) {
                        categoryController.isTrending.value = value;
                        if (value == true) {
                          categoryController.trending.value = "1";
                        } else {
                          categoryController.trending.value = "0";
                        }
                        print("==========${categoryController.trending.value}");
                      },
                      activeColor: AppColor.themeGreenColor,
                      thumbColor: AppColor.cWhite,
                      trackColor: AppColor.cFont,
                    ),
                    horizontalSpace(8),
                    Text(
                      "Trending",
                      style: pRegular12,
                    ),
                  ],
                ),
                verticalSpace(25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: CommonIconButton(
                          title: 'Close',
                          iconData: DefaultImages.closeIcn,
                          onPressed: () {
                            Get.back();
                          },
                          width: 75,
                          height: 35,
                          btnColor: AppColor.cButton,
                          textColor: AppColor.cDarkGreyFont),
                    ),
                    horizontalSpace(15),
                    Expanded(
                      flex: 2,
                      child: CommonIconButton(
                        title: widget.isUpdate == true ? "Update" : 'Create',
                        iconData: DefaultImages.whiteDoneIcn,
                        onPressed: () {
                          if (categoryController.categoryName.text.isNotEmpty && categoryController.iconPath.value != '' && categoryController.imagePath.value != '') {
                            print("----->(${categoryController.iconPath.value})");
                            print("----->(${categoryController.imagePath.value})");
                            if (widget.isUpdate == true) {
                              if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                                commonToast(AppConstant.demoString);
                              } else {
                                categoryController.addCategoriesData(
                                  isUpdate: widget.isUpdate,
                                  categoryId: widget.categoryId!,
                                  name: categoryController.categoryName.text.trim(),
                                  trending: categoryController.trending.value,
                                  status: "1",
                                  imagePath: categoryController.iconPath.value,
                                  iconImagePath: categoryController.imagePath.value,
                                );
                              }
                            } else {
                              categoryController.addCategoriesData(
                                isUpdate: widget.isUpdate,
                                categoryId: 0,
                                name: categoryController.categoryName.text.trim(),
                                trending: categoryController.trending.value,
                                status: "1",
                                imagePath: categoryController.iconPath.value,
                                iconImagePath: categoryController.imagePath.value,
                              );
                            }
                          }
                        },
                        width: 240,
                        height: 35,
                      ),
                    ),
                  ],
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}

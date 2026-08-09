// ignore_for_file: prefer_const_constructors

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/core/model/categories_model.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/view/screen/home_screen/add_category_bottomsheet.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/order_screen/order_screen.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_text_field.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_button.dart';

import '../../widget/app_dialog.dart';
import '../../widget/error_empty_state.dart';
import '../../widget/loading_widget.dart';

class CategoriesScreen extends StatefulWidget {
  final bool isBack;

  const CategoriesScreen({Key? key, required this.isBack}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with AutomaticKeepAliveClientMixin {
  CategoryController categoryController = Get.put(CategoryController());
  ScrollController? scrollController;
  bool _isFirstLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        categoryController.currantPage.value = 1;
        categoryController.isScroll.value = true;
        categoryController.categoriesList.clear();
        getData();
      }
    });
    scrollController = ScrollController();
    scrollController!.addListener(() {
      if (categoryController.isScroll.value == true && scrollController!.offset >= scrollController!.position.maxScrollExtent && !scrollController!.position.outOfRange) {
        categoryController.currantPage.value += 1;
        categoryController.getCategoryData(categoryController.currantPage.value);
        print("currantPage................-> ${categoryController.currantPage.value}");
      }
    });
  }

  getData() {
    categoryController.getCategoryData(categoryController.currantPage.value);
  }

  @override
  void dispose() {
    scrollController!.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: AppColor.cBackGround,
        appBar: simpleAppBar(isBack: widget.isBack, title: "All Categories", date: "Monday, 30 Jan"),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonIconButton(
                  title: 'Add Category',
                  iconData: DefaultImages.addCircleIcn,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColor.cBackGround,
                      barrierColor: AppColor.cGreyOpacity,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      builder: (context) {
                        return AddNewCategoriesWidget(
                          isUpdate: false,
                        );
                      },
                    );
                  },
                  height: 51,
                ),
                verticalSpace(20),
                // searchFieldWidget(
                //   context: context,
                //   controller: categoryController.searchController,
                //   hint: 'Search for order',
                //   onChanged: (value) {
                //     if (value.length >= 3) {
                //       categoryController.searchCategoryData(name: value);
                //     }
                //   },
                //   onTap: () {
                //     getData();
                //     categoryController.searchController.clear();
                //   },
                // ),
                verticalSpace(25),
                Text(
                  "Category List",
                  style: pRegular20,
                ),
                verticalSpace(25),
                Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Product",
                              style: pBold12.copyWith(color: AppColor.cDarkGreyFont, fontSize: 10),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Category",
                              style: pBold12.copyWith(color: AppColor.cDarkGreyFont, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Action",
                              style: pBold12.copyWith(color: AppColor.cDarkGreyFont, fontSize: 10),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                verticalSpace(10),
                categoryController.categoriesList.isEmpty ? SizedBox() : horizontalDivider(),
                Expanded(
             child: Obx(() {
            /// First Loading
            if (categoryController.isLoading.value &&
            categoryController.currantPage.value == 1) {
            return const Center(child: LoadingWidget());
            }

            /// Error
            if (categoryController.errorMessage.isNotEmpty &&
            categoryController.categoriesList.isEmpty) {
            return RefreshIndicator(
            onRefresh: () async => getData(),
            child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
            SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * .6,
            child: Center(
            child: ErrorState(
            message: categoryController.errorMessage.value,
            onRetry: getData,
            )),
            ),
            ]));
            }

            /// Empty
            if (categoryController.categoriesList.isEmpty) {
            return RefreshIndicator(
            onRefresh: () async => getData(),
            child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
            SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * .6,
            child: Center(
            child: EmptyState(
            message: "no_orders_found".tr,
            icon: Icons.receipt_long_outlined,
            ),
            ),
            ),
            ],
            ),
            );
            }

            /// Data
            return RefreshIndicator(
            backgroundColor: Colors.white,
            onRefresh: () async => getData(),
            child: ListView.separated(
            controller: scrollController,
            itemCount: categoryController.categoriesList.length,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
            CategoryData category = categoryController.categoriesList[index];
            return buildCategoryWidget(
            image: category.imagePathFullUrl!,
            title: 'Shop',
            subTitle: category.name!,
            category: category.themeId?.capitalizeFirst ?? "No Theme",
            deleteFun: () {
            AppDialog.showCustomDialog(
              iconColor: AppColor.cRedText,
              confirmColor: AppColor.cRedText,
              context: context,
              onConfirm: () =>  categoryController.deleteCategoriesData(
                  categoryId: category.id ?? 0)
            );
          },
            filterFun: () {
            showModalBottomSheet(
            context: context,
            backgroundColor: AppColor.cBackGround,
            barrierColor: AppColor.cGreyOpacity,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            ),
            ),
            builder: (context) {
            return AddNewCategoriesWidget(
            isUpdate: true,
            categoryId: category.id,
            name: category.name,
            image: category.imagePathFullUrl,
            icon: category.iconPath,
            trending: category.trending.toString(),
            status: category.status.toString(),
            );
            },
            );
            },
            );
            },
            separatorBuilder: (context, index) => horizontalDivider(),
            ),
            );
            })),
            ]);
          }),
        ),
      ),
    );
  }

  Widget buildCategoryWidget({required String image, required String title, required String subTitle, required String category, required Function() filterFun, required Function() deleteFun}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Container(
                height: 55,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColor.cBackGround,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: getImageUrl(image),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.network(
                      DefaultImages.productImg,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              horizontalSpace(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: pRegular12.copyWith(color: AppColor.cDarkGreyFont),
                    ),
                    verticalSpace(3),
                    Text(
                      subTitle,
                      style: pSemiBold16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            category,
            style: pRegular12.copyWith(
              color: AppColor.cDarkGreyFont,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                  onTap: filterFun,
                  child: Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(color: AppColor.themeNavyBlueColor, borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                      Icons.edit,
                      color: AppColor.cWhite,
                      size: 15,
                    ),
                  )),
              horizontalSpace(8),
              GestureDetector(
                onTap: deleteFun,
                child: Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(color: AppColor.cRedText, borderRadius: BorderRadius.circular(8)),
                  child: Align(
                    child: assetSvdImageWidget(image: DefaultImages.deleteIcn, height: 12, width: 12),
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

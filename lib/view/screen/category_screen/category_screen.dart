// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/category_widget.dart';
import 'package:store_go_app/view/screen/home_screen/add_category_bottomsheet.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import '../../new_widgets/shimmer.dart';

class CategoriesScreen extends StatefulWidget {
  final bool isBack;
  const CategoriesScreen({super.key, required this.isBack});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with AutomaticKeepAliveClientMixin {
  final CategoryController categoryController = Get.find<CategoryController>();
  final ScrollController scrollController = ScrollController();
  bool _isFirstLoad = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        categoryController.currantPage.value = 1;
        categoryController.isScroll.value = true;
        categoryController.categoriesList.clear();
        getData();
      }
    });
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!categoryController.isScroll.value) return;
    if (categoryController.isLoading.value) return;

    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      categoryController.currantPage.value += 1;
      categoryController.getCategoryData(categoryController.currantPage.value);
    }
  }

  Future<void> getData() async {
    await categoryController.getCategoryData(categoryController.currantPage.value);
  }

  Future<void> _fetchInitialData() async {
    categoryController.currantPage.value = 1;
    categoryController.isScroll.value = true;
    categoryController.categoriesList.clear();
    await getData();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: simpleAppBar(
          isBold: true,
          title: "all_categories".tr,
          label: "add_category".tr,
          onNewLabelTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.black54,
              isScrollControlled: true,
              useSafeArea: false,
              transitionAnimationController: AnimationController(
                vsync: Navigator.of(context),
                duration: const Duration(milliseconds: 400),
              ),
              builder: (context) {
                return AddNewCategoriesWidget(
                  isUpdate: false,
                );
              },
            );
          },
        ),
        backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cLight,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Obx(() {
                  // Loading State
                  if (categoryController.isLoading.value && categoryController.currantPage.value == 1) {
                    return const ShimmerGrid();
                  }

                  // Error State
                  if (categoryController.errorMessage.isNotEmpty && categoryController.categoriesList.isEmpty) {
                    return RefreshIndicator(
                      backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
                      onRefresh: _fetchInitialData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .6,
                            child: Center(
                              child: ErrorState(
                                message: categoryController.errorMessage.value,
                                onRetry: _fetchInitialData,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Empty State
                  if (categoryController.categoriesList.isEmpty) {
                    return RefreshIndicator(
                      backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
                      onRefresh: _fetchInitialData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .6,
                            child: Center(
                              child: EmptyState(
                                message: "no_categories_found".tr,
                                icon: Icons.category_outlined,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Data List
                  return RefreshIndicator(
                    backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
                    onRefresh: _fetchInitialData,
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 15.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${categoryController.categoriesModel?.data?.total ?? 0} ${'items'.tr}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    height: 1.2,
                                    color: isDark ? Colors.grey.shade400 : AppColor.cDarkGreyFont,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                final category = categoryController.categoriesList[index];
                                return buildCategoryWidget(context: context,category: category,categoryController: categoryController);
                              },
                              childCount: categoryController.categoriesList.length,
                            ),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220.w,
                              crossAxisSpacing: 14.w,
                              mainAxisSpacing: 14.h,
                              mainAxisExtent: 235.h,
                            ),
                          ),
                        ),

                        if (categoryController.isScroll.value)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.themeNavyBlueColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

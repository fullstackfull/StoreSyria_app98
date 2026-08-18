// ignore_for_file: prefer_const_constructors, must_be_immutable, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';

import 'package:store_go_app/view/widget/loading_widget.dart';
import 'package:store_go_app/view/screen/product_screen/add_rating_screen.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/product_controller/product_detail_controller.dart';
import 'package:store_go_app/core/controller/product_controller/add_review_controller.dart';

import '../../widget/app_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final String categoryId;
  final String productId;
  final String id;

  const ProductDetailScreen({
    super.key,
    required this.categoryId,
    required this.productId,
    required this.id,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailController productDetailController =
  Get.put(ProductDetailController());

  final AddReviewController reviewController =
  Get.put(AddReviewController());

  final PageController _pageController = PageController();

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await productDetailController.getProductDetail(widget.productId);
    await reviewController.getReviewData(widget.productId);

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // IMAGE URL
  // ============================================================

  String _getFullImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return '';
    }

    final value = url.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final baseUrl = Prefs.getString(AppConstant.imageUrl);

    if (baseUrl != null && baseUrl.isNotEmpty) {
      final cleanBase =
      baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

      final cleanPath =
      value.startsWith('/') ? value.substring(1) : value;

      return '$cleanBase/$cleanPath';
    }

    return getImageUrl(value);
  }

  // ============================================================
  // GET ALL PRODUCT IMAGES
  // ============================================================

  List<String> _getProductImages() {
    final images = <String>[];

    final product = productDetailController.product;

    if (product == null) {
      return images;
    }

    // ----------------------------------------------------------
    // 1. COVER IMAGE
    // ----------------------------------------------------------

    try {
      final coverUrl = product.coverImageUrl;

      if (coverUrl != null && coverUrl.toString().trim().isNotEmpty) {
        final fullUrl = _getFullImageUrl(coverUrl.toString());

        if (fullUrl.isNotEmpty) {
          images.add(fullUrl);
        }
      }
    } catch (_) {}

    // ----------------------------------------------------------
    // 2. SUB IMAGES
    // ----------------------------------------------------------

    final subImages =
        productDetailController.productDetailModel?.data?.subImages;

    if (subImages != null && subImages.isNotEmpty) {
      for (final image in subImages) {
        try {
          String? imageUrl;

          if (image.imagePathFullUrl != null &&
              image.imagePathFullUrl!.trim().isNotEmpty) {
            imageUrl = image.imagePathFullUrl;
          } else if (image.imagePath != null &&
              image.imagePath!.trim().isNotEmpty) {
            imageUrl = image.imagePath;
          }

          if (imageUrl != null && imageUrl.trim().isNotEmpty) {
            final fullUrl = _getFullImageUrl(imageUrl);

            if (fullUrl.isNotEmpty && !images.contains(fullUrl)) {
              images.add(fullUrl);
            }
          }
        } catch (_) {}
      }
    }

    return images;
  }

  // ============================================================
  // REVIEW
  // ============================================================

  bool _hasCurrentUserReview() {
    final currentUserId = reviewController.userId.value.toString();

    return reviewController.reviewList.any(
          (review) => review.userId?.toString() == currentUserId,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
    isDark ? DarkThemeColor.cBackGround : const Color(0xFFF5F6F8);

    final cardColor =
    isDark ? DarkThemeColor.cCardBackground : Colors.white;

    final borderColor =
    isDark ? DarkThemeColor.cBorder : const Color(0xFFE9EAEE);

    final primaryTextColor =
    isDark ? Colors.white : AppColor.cText;

    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : AppColor.cFont;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: GetBuilder<ProductDetailController>(
            builder: (controller) {
              final product = controller.product;

              if (product == null ||
                  controller.productDetailModel?.data == null) {
                return const Center(
                  child: LoadingWidget(),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    10.h,
                    16.w,
                    30.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(primaryTextColor),

                      verticalSpace(18.h),

                      // ==================================================
                      // PRODUCT NAME
                      // ==================================================

                      Text(
                        product.name ?? 'no_name'.tr,
                        style: pSemiBold23.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),

                      verticalSpace(16.h),

                      // ==================================================
                      // IMAGE SLIDER
                      // ==================================================

                      _buildImageSlider(
                        cardColor: cardColor,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),

                      verticalSpace(18.h),

                      // ==================================================
                      // BASIC INFO
                      // ==================================================

                      _buildBasicInfoCard(
                        product: product,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),

                      verticalSpace(16.h),

                      // ==================================================
                      // PROPERTIES
                      // ==================================================

                      _buildPropertiesCard(
                        product: product,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),

                      verticalSpace(16.h),

                      // ==================================================
                      // STATUS
                      // ==================================================

                      _buildStatusCard(
                        product: product,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),

                      verticalSpace(16.h),

                      // ==================================================
                      // REVIEWS
                      // ==================================================

                      _buildReviewsCard(
                        cardColor: cardColor,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),
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
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(Color textColor) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: textColor,
              size: 27.sp,
            ),
          ),
        ),

        const Spacer(),

        Text(
          'product_details'.tr,
          style: pMedium14.copyWith(
            color: textColor,
            fontSize: 15.sp,
          ),
        ),

        const Spacer(),

        SizedBox(width: 40.w),
      ],
    );
  }

  // ============================================================
  // IMAGE SLIDER
  // ============================================================

  Widget _buildImageSlider({
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final images = _getProductImages();

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250.h,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 55.sp,
          color: Colors.grey.shade400,
        ),
      );
    }

    return Column(
      children: [
        // ========================================================
        // MAIN IMAGE
        // ========================================================

        Container(
          width: double.infinity,
          height: 260.h,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey.shade900
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                if (!mounted) return;

                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.contain,

                  placeholder: (context, url) {
                    return const Center(
                      child: LoadingWidget(),
                    );
                  },

                  errorWidget: (context, url, error) {
                    return Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 50.sp,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        // ========================================================
        // THUMBNAILS
        // ========================================================

        if (images.length > 1) ...[
          verticalSpace(12.h),

          SizedBox(
            height: 62.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => horizontalSpace(8.w),
              itemBuilder: (context, index) {
                final isSelected =
                    _currentImageIndex == index;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration:
                      const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 200),
                    width: 62.w,
                    height: 62.w,
                    padding: EdgeInsets.all(
                      isSelected ? 2.w : 1.w,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius:
                      BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.themeGreenColor
                            : borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(9.r),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,

                        placeholder: (_, __) {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                            ),
                          );
                        },

                        errorWidget: (_, __, ___) {
                          return Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 22.sp,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ======================================================
          // DOT INDICATOR
          // ======================================================

          verticalSpace(10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
                  (index) {
                final selected =
                    _currentImageIndex == index;

                return AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 200),
                  margin:
                  EdgeInsets.symmetric(horizontal: 3.w),
                  width: selected ? 20.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColor.themeGreenColor
                        : (isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300),
                    borderRadius:
                    BorderRadius.circular(20.r),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // BASIC INFO CARD
  // ============================================================

  Widget _buildBasicInfoCard({
    required dynamic product,
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    final price = _value(
      product,
      'finalPrice',
      fallback: _value(
        product,
        'price',
        fallback: '0',
      ),
    );

    final salePrice = _value(
      product,
      'salePrice',
    );

    final sku = _value(
      product,
      'productCode',
      fallback: _value(
        product,
        'sku',
      ),
    );

    final stockStatus = _value(
      product,
      'stockStatus',
      fallback: 'in_stock',
    );

    return _sectionCard(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'basic_data'.tr,
            style: pSemiBold14.copyWith(
              fontSize: 16.sp,
              color: primaryTextColor,
            ),
          ),

          verticalSpace(15.h),

          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade900
                  : const Color(0xFFF7F8FA),
              borderRadius:
              BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                _infoRow(
                  label: 'name_en'.tr,
                  value: product.name ?? '-',
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),

                _thinDivider(borderColor),

                _infoRow(
                  label: 'price'.tr,
                  value:
                  '$price ${'currency'.tr}',
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),

                if (salePrice.isNotEmpty) ...[
                  _thinDivider(borderColor),

                  _infoRow(
                    label: 'sale_price'.tr,
                    value:
                    '$salePrice ${'currency'.tr}',
                    primaryTextColor:
                    primaryTextColor,
                    secondaryTextColor:
                    secondaryTextColor,
                  ),
                ],

                _thinDivider(borderColor),

                _infoRow(
                  label: 'stock_status'.tr,
                  value: stockStatus,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                ),

                _thinDivider(borderColor),

                _infoRow(
                  label: 'sku'.tr,
                  value: sku.isEmpty ? '-' : sku,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                  leadingIcon:
                  Icons.qr_code_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROPERTIES CARD
  // ============================================================

  Widget _buildPropertiesCard({
    required dynamic product,
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    final categoryId = _value(
      product,
      'categoryId',
    );

    final weight = _value(
      product,
      'productWeight',
    );

    final description = _value(
      product,
      'description',
    );

    return _sectionCard(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'additional_properties'.tr,
            style: pSemiBold14.copyWith(
              fontSize: 16.sp,
              color: primaryTextColor,
            ),
          ),

          verticalSpace(5.h),

          _propertyRow(
            icon: Icons.grid_view_rounded,
            title: 'category'.tr,
            subtitle: categoryId.isEmpty
                ? '-'
                : '#$categoryId',
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          _propertyRow(
            icon: Icons.scale_outlined,
            title: 'product_weight'.tr,
            subtitle: weight.isEmpty
                ? '-'
                : '$weight kg',
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          _propertyRow(
            icon: Icons.description_outlined,
            title: 'description'.tr,
            subtitle: description.isEmpty
                ? '-'
                : description,
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard({
    required dynamic product,
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    final status = _value(
      product,
      'status',
      fallback: '0',
    );

    final stockStatus = _value(
      product,
      'stockStatus',
      fallback: 'in_stock',
    );

    final isVisible = status == '1';
    final isInStock = stockStatus == 'in_stock';

    return _sectionCard(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'product_status'.tr,
            style: pSemiBold14.copyWith(
              fontSize: 16.sp,
              color: primaryTextColor,
            ),
          ),

          verticalSpace(14.h),

          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _statusChip(
                icon: isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                label: isVisible
                    ? 'visible'.tr
                    : 'hidden'.tr,
                color: isVisible
                    ? const Color(0xFF2E7D32)
                    : Colors.grey,
              ),

              _statusChip(
                icon: isInStock
                    ? Icons.inventory_2_outlined
                    : Icons.remove_shopping_cart_outlined,
                label: stockStatus,
                color: isInStock
                    ? const Color(0xFF2E7D32)
                    : Colors.grey,
              ),
            ],
          ),

          verticalSpace(18.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 12.h,
                    ),
                    side:
                    BorderSide(color: borderColor),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(24.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.share_outlined,
                    size: 17.sp,
                    color: primaryTextColor,
                  ),
                  label: Text(
                    'share'.tr,
                    style: pMedium12.copyWith(
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),

              horizontalSpace(10.w),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 12.h,
                    ),
                    side:
                    BorderSide(color: borderColor),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(24.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.open_in_new_rounded,
                    size: 17.sp,
                    color: primaryTextColor,
                  ),
                  label: Text(
                    'view_on_store'.tr,
                    style: pMedium12.copyWith(
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEWS CARD
  // ============================================================

  Widget _buildReviewsCard({
    required Color cardColor,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    return _sectionCard(
      cardColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ratings'.tr,
                style: pSemiBold14.copyWith(
                  fontSize: 16.sp,
                  color: primaryTextColor,
                ),
              ),

              Obx(() {
                final hasReview =
                _hasCurrentUserReview();

                return GestureDetector(
                  onTap: hasReview
                      ? null
                      : () {
                    Get.to(
                          () => AddRatingScreen(
                        id: widget.id,
                        categoryId:
                        widget.categoryId,
                        productId:
                        widget.productId,
                        isUpdate: false,
                      ),
                    );
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: hasReview
                          ? Colors.grey
                          .withOpacity(0.12)
                          : AppColor
                          .themeGreenColor
                          .withOpacity(0.1),
                      borderRadius:
                      BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          hasReview
                              ? Icons
                              .check_circle_outline
                              : Icons
                              .rate_review_outlined,
                          size: 16.sp,
                          color: hasReview
                              ? Colors.grey
                              : AppColor
                              .themeGreenColor,
                        ),
                        horizontalSpace(5.w),
                        Text(
                          hasReview
                              ? 'Already Reviewed'.tr
                              : 'write_review'.tr,
                          style:
                          pMedium12.copyWith(
                            color: hasReview
                                ? Colors.grey
                                : AppColor
                                .themeGreenColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),

          verticalSpace(14.h),

          _buildReviewsList(
            primaryTextColor:
            primaryTextColor,
            secondaryTextColor:
            secondaryTextColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEWS LIST
  // ============================================================

  Widget _buildReviewsList({
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Obx(() {
      if (reviewController.reviewList.isEmpty) {
        return Padding(
          padding:
          EdgeInsets.symmetric(
            vertical: 30.h,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 42.sp,
                  color: Colors.grey.shade400,
                ),

                verticalSpace(12.h),

                Text(
                  'no_reviews_yet'.tr,
                  style: pSemiBold14.copyWith(
                    color:
                    secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics:
        const NeverScrollableScrollPhysics(),
        itemCount:
        reviewController.reviewList.length,
        separatorBuilder: (_, __) =>
            verticalSpace(12.h),
        itemBuilder: (context, index) {
          final review =
          reviewController.reviewList[index];

          final time =
              DateTime.tryParse(
                review.createdAt ?? '',
              ) ??
                  DateTime.now();

          final rating =
              double.tryParse(
                review.ratingNo
                    ?.toString() ??
                    '0',
              ) ??
                  0;

          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade900
                  : const Color(0xFFF7F8FA),
              borderRadius:
              BorderRadius.circular(14.r),
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
                      decoration:
                      BoxDecoration(
                        color: AppColor
                            .themeGreenColor
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColor
                            .themeGreenColor,
                        size: 22.sp,
                      ),
                    ),

                    horizontalSpace(10.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.userName ??
                                'User',
                            style:
                            pSemiBold12
                                .copyWith(
                              color:
                              primaryTextColor,
                              fontSize: 13.sp,
                            ),
                          ),

                          verticalSpace(3.h),

                          Text(
                            reviewController
                                .convertToAgo(
                              time,
                            ),
                            style:
                            pRegular10
                                .copyWith(
                              color:
                              secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    RatingBar.builder(
                      initialRating: rating,
                      itemCount: 5,
                      itemSize: 14.sp,
                      ignoreGestures: true,
                      itemBuilder:
                          (_, __) => const Icon(
                        Icons.star_rounded,
                        color:
                        Color(0xFFFFC107),
                      ),
                      onRatingUpdate:
                          (_) {},
                    ),
                  ],
                ),

                if (review.title != null &&
                    review.title!.isNotEmpty) ...[
                  verticalSpace(10.h),

                  Text(
                    review.title!,
                    style:
                    pSemiBold12.copyWith(
                      color:
                      primaryTextColor,
                    ),
                  ),
                ],

                if (review.description !=
                    null &&
                    review.description!
                        .isNotEmpty) ...[
                  verticalSpace(6.h),

                  Text(
                    review.description!,
                    style:
                    pRegular12.copyWith(
                      color:
                      secondaryTextColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    });
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required String label,
    required String value,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    IconData? leadingIcon,
  }) {
    return Padding(
      padding:
      EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: pSemiBold12.copyWith(
                color: primaryTextColor,
                fontSize: 13.sp,
              ),
            ),
          ),

          horizontalSpace(10.w),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: 14.sp,
                  color: secondaryTextColor,
                ),
                horizontalSpace(4.w),
              ],

              Text(
                label,
                style: pRegular12.copyWith(
                  color: secondaryTextColor,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROPERTY ROW
  // ============================================================

  Widget _propertyRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding:
          EdgeInsets.symmetric(
            vertical: 12.h,
          ),
          child: Row(
            children: [
              Container(
                padding:
                EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: secondaryTextColor
                      .withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 17.sp,
                  color:
                  secondaryTextColor,
                ),
              ),

              horizontalSpace(10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style:
                      pSemiBold12.copyWith(
                        color:
                        primaryTextColor,
                        fontSize: 13.5.sp,
                      ),
                    ),

                    verticalSpace(3.h),

                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow:
                      TextOverflow.ellipsis,
                      textAlign:
                      TextAlign.right,
                      style:
                      pRegular10.copyWith(
                        color:
                        secondaryTextColor,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
              ),

              horizontalSpace(5.w),

              Icon(
                Icons.chevron_left_rounded,
                size: 18.sp,
                color:
                secondaryTextColor,
              ),
            ],
          ),
        ),

        if (!isLast)
          _thinDivider(
            secondaryTextColor.withOpacity(0.12),
          ),
      ],
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius:
        BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15.sp,
            color: color,
          ),

          horizontalSpace(6.w),

          Text(
            label,
            style: pMedium12.copyWith(
              color: color,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required Color cardColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
        BorderRadius.circular(16.r),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset:
            const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SAFE GETTER
  // ============================================================

  String _value(
      dynamic object,
      String field, {
        String fallback = '',
      }) {
    try {
      dynamic value;

      switch (field) {
        case 'finalPrice':
          value = object.finalPrice;
          break;

        case 'price':
          value = object.price;
          break;

        case 'salePrice':
          value = object.salePrice;
          break;

        case 'productCode':
          value = object.productCode;
          break;

        case 'sku':
          value = object.sku;
          break;

        case 'stockStatus':
          value = object.stockStatus;
          break;

        case 'status':
          value = object.status;
          break;

        case 'categoryId':
          value = object.categoryId;
          break;

        case 'productWeight':
          value = object.productWeight;
          break;

        case 'description':
          value = object.description;
          break;

        default:
          value = null;
      }

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    } catch (_) {}

    return fallback;
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _thinDivider(Color color) {
    return Divider(
      height: 1,
      thickness: 1,
      color: color,
    );
  }
}
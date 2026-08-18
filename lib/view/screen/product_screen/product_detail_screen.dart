// ignore_for_file: prefer_const_constructors, must_be_immutable, avoid_print, sized_box_for_whitespace

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/product_screen/add_rating_screen.dart';
import 'package:store_go_app/core/controller/product_controller/add_review_controller.dart';
import 'package:store_go_app/core/controller/product_controller/product_detail_controller.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import '../../widget/app_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final String categoryId;
  final String productId;
  final String id;

  const ProductDetailScreen({super.key, required this.categoryId, required this.productId, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailController productDetailController = Get.put(ProductDetailController());
  final AddReviewController reviewController = Get.put(AddReviewController());

  String? _originalCoverImage;

  bool _hasCurrentUserReview() {
    final currentUserId = reviewController.userId.value.toString();

    return reviewController.reviewList.any(
          (review) => review.userId?.toString() == currentUserId,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
      if (productDetailController.product != null) {
        _originalCoverImage = _getFullImageUrl(productDetailController.product!.coverImagePath);
        if (_originalCoverImage == null || _originalCoverImage!.isEmpty) {
          final model = productDetailController.productDetailModel;
          if (model?.data?.subImage != null && model!.data!.subImage!.isNotEmpty) {
            _originalCoverImage = model.data!.subImage![0].imagePathFullUrl;
          }
        }
      }
    });
  }

  void getData() {
    reviewController.getReviewData(widget.productId);
    productDetailController.getProductDetail(widget.productId);
  }

  String _getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;

    final baseUrl = Prefs.getString(AppConstant.imageUrl);
    if (baseUrl != null && baseUrl.isNotEmpty && baseUrl.startsWith('http')) {
      final cleanBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      final cleanPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
      return '$cleanBase$cleanPath';
    }
    return getImageUrl(relativePath);
  }

  void _resetToOriginalImage() {
    if (_originalCoverImage != null && _originalCoverImage!.isNotEmpty) {
      productDetailController.productImage.value = _originalCoverImage!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround;
    final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;
    final borderColor = isDark ? DarkThemeColor.cBorder : AppColor.cBorder.withOpacity(0.5);
    final primaryTextColor = isDark ? Colors.white : AppColor.cText;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : AppColor.cFont;
    final accentColor = AppColor.cGreenFont;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: simpleAppBar(title: "product_details".tr),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 90.h),
        child: GetBuilder<ProductDetailController>(
          builder: (controller) {
            final model = controller.productDetailModel;
            final product = controller.product;

            if (model == null || product == null) {
              return SizedBox(height: 600.h, child: const Center(child: LoadingWidget()));
            }

            if (_originalCoverImage == null || _originalCoverImage!.isEmpty) {
              _originalCoverImage = _getFullImageUrl(product.coverImagePath);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(product, model, cardColor, borderColor, isDark),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(24.h),

                      if (product.categoryName != null && product.categoryName!.isNotEmpty)
                        Text(
                          product.categoryName!,
                          style: pRegular12.copyWith(color: accentColor, fontWeight: FontWeight.w600),
                        ),
                      verticalSpace(6.h),
                      Text(
                        product.name ?? "no_name".tr,
                        style: pSemiBold23.copyWith(fontSize: 22.sp, color: primaryTextColor),
                        maxLines: 2,
                      ),

                      verticalSpace(12.h),

                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: double.tryParse(product.averageRating?.toString() ?? "0") ?? 0.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 16.sp,
                            unratedColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            itemBuilder: (_, __) => Icon(Icons.star_rate_rounded, color: const Color(0xFFFFC107)),
                            onRatingUpdate: (rating) {},
                          ),
                          horizontalSpace(8.w),
                          Text(
                            "${product.averageRating ?? "0.0"} | ${reviewController.reviewList.length} Reviews",
                            style: pRegular12.copyWith(color: secondaryTextColor),
                          ),
                        ],
                      ),

                      verticalSpace(20.h),

                      _buildPriceCard(product, cardColor, borderColor, isDark, accentColor),

                      verticalSpace(16.h),

                      _buildStockChip(product, isDark),

                      verticalSpace(24.h),

                      _buildDescriptionSections(product, cardColor, borderColor, isDark),

                      verticalSpace(24.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ratings".tr, style: pSemiBold18.copyWith(fontSize: 18.sp, color: primaryTextColor)),
                          Obx(() {
                            final hasMyReview = _hasCurrentUserReview();

                            return GestureDetector(
                              onTap: hasMyReview
                                  ? null
                                  : () {
                                Get.to(() => AddRatingScreen(
                                  id: widget.id,
                                  categoryId: widget.categoryId,
                                  productId: widget.productId,
                                  isUpdate: false,
                                ));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 7.h,
                                ),
                                decoration: BoxDecoration(
                                  color: hasMyReview
                                      ? Colors.grey.withOpacity(0.12)
                                      : AppColor.themeGreenColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      hasMyReview
                                          ? Icons.check_circle_outline
                                          : Icons.rate_review_outlined,
                                      size: 16.sp,
                                      color: hasMyReview
                                          ? Colors.grey
                                          : AppColor.themeGreenColor,
                                    ),
                                    horizontalSpace(5.w),
                                    Text(
                                      hasMyReview
                                          ? "Already Reviewed".tr
                                          : "write_review".tr,
                                      style: pMedium12.copyWith(
                                        color: hasMyReview
                                            ? Colors.grey
                                            : AppColor.themeGreenColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      verticalSpace(12.h),

                      _buildReviewsList(cardColor, borderColor, primaryTextColor, secondaryTextColor, isDark),

                      verticalSpace(20.h),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildImageGallery(dynamic product, dynamic model, Color cardColor, Color subtleBorder, bool isDark) {
    return Container(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Obx(() {
        final currentImage = productDetailController.productImage.value;

        final bool isOriginal = _originalCoverImage != null &&
            (currentImage == _originalCoverImage ||
                (_originalCoverImage!.isNotEmpty && currentImage.contains(_originalCoverImage!.split('/').last)));

        return Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 320.h,
                  width: double.infinity,
                  color: cardColor,
                  child: buildCachedNetworkImage(
                    imageUrl: _getFullImageUrl(currentImage),
                    fit: BoxFit.contain,
                  ),
                ),

                if (model.data?.subImage != null && model.data!.subImage!.isNotEmpty)
                  SizedBox(
                    height: 70.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: model.data!.subImage!.length,
                      itemBuilder: (context, index) {
                        final subImg = model.data!.subImage![index];
                        final isSelected = currentImage == subImg.imagePathFullUrl;

                        return GestureDetector(
                          onTap: () {
                            productDetailController.productImage.value = subImg.imagePathFullUrl ?? '';
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60.w,
                            height: 60.h,
                            margin: EdgeInsets.only(right: 10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected ? AppColor.themeGreenColor : subtleBorder,
                                width: isSelected ? 2 : 1,
                              ),
                              color: cardColor,
                            ),
                            padding: EdgeInsets.all(4.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: CachedNetworkImage(
                                imageUrl: _getFullImageUrl(subImg.imagePathFullUrl),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: isDark ? Colors.grey[800] : Colors.grey[100]),
                                errorWidget: (context, url, error) => Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            // زر الرجوع للصورة الأصلية
            if (!isOriginal && _originalCoverImage != null && _originalCoverImage!.isNotEmpty)
              Positioned(
                top: 20.h,
                left: 20.w,
                child: GestureDetector(
                  onTap: _resetToOriginalImage,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                        color: isDark ? Colors.black54 : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ]
                    ),
                    child: Icon(
                        Icons.image,
                        color: AppColor.themeGreenColor,
                        size: 20.sp
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
  Widget _buildPriceCard(dynamic product, Color cardColor, Color borderColor, bool isDark, Color accentColor) {
    final double? finalPrice = double.tryParse(product.finalPrice?.toString() ?? "0");
    final double? originalPrice = double.tryParse(product.originalPrice?.toString() ?? "0");

    bool hasDiscount = originalPrice != null && originalPrice > 0 && finalPrice != null && finalPrice < originalPrice;
    double discountPercentage = 0;
    if (hasDiscount) {
      discountPercentage = ((originalPrice - finalPrice) / originalPrice) * 100;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\$${product.finalPrice ?? "0"}",
                style: pSemiBold23.copyWith(fontSize: 26.sp, color: accentColor),
              ),
              if (hasDiscount)
                Text(
                  "\$${product.originalPrice}",
                  style: pRegular14.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[500],
                    fontSize: 14.sp,
                  ),
                ),
            ],
          ),
          if (hasDiscount)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "-${discountPercentage.toStringAsFixed(0)}%",
                style: pBold12.copyWith(color: Colors.white, fontSize: 13.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockChip(dynamic product, bool isDark) {
    final int stock = int.tryParse(product.productStock?.toString() ?? "0") ?? 0;
    final bool isInStock = stock > 0;

    final bgColor = isInStock
        ? (isDark ? const Color(0xFF1B3A1E) : const Color(0xFFE8F5E9))
        : (isDark ? const Color(0xFF3A1414) : const Color(0xFFFFEBEE));
    final fgColor = isInStock
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
        : (isDark ? const Color(0xFFE57373) : const Color(0xFFC62828));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInStock ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: fgColor,
            size: 18.sp,
          ),
          horizontalSpace(6.w),
          Text(
            isInStock ? "In Stock ($stock)" : "Out of Stock",
            style: pMedium12.copyWith(color: fgColor, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSections(dynamic product, Color cardColor, Color borderColor, bool isDark) {
    List<Widget> widgets = [];

    if (product.description != null && product.description!.isNotEmpty) {
      widgets.add(_buildInfoCard("description".tr, product.description!, cardColor, borderColor, isDark));
    }

    if (product.otherDescriptionArray != null) {
      for (var item in product.otherDescriptionArray!) {
        if (item.title != null && item.title!.isNotEmpty) {
          widgets.add(_buildInfoCard(item.title!, item.description ?? "", cardColor, borderColor, isDark));
        }
      }
    }

    if (widgets.isEmpty) return const SizedBox.shrink();

    return Column(children: widgets);
  }

  Widget _buildInfoCard(String title, String content, Color cardColor, Color borderColor, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            title: Text(
              title,
              style: pSemiBold14.copyWith(fontSize: 15.sp, color: isDark ? Colors.white : AppColor.cText),
            ),
            iconColor: AppColor.themeGreenColor,
            collapsedIconColor: isDark ? Colors.grey[500] : Colors.grey[400],
            children: [
              Text(
                content,
                style: pRegular12.copyWith(
                  color: isDark ? Colors.grey[400] : AppColor.cFont,
                  height: 1.6,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList(Color cardColor, Color borderColor, Color primaryTextColor, Color secondaryTextColor, bool isDark) {
    return Obx(() {
      if (reviewController.reviewList.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 40.h),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.rate_review_outlined, size: 40.sp, color: isDark ? Colors.grey[400] : Colors.grey[400]),
              ),
              verticalSpace(16.h),
              Text("no_reviews_yet".tr, style: pSemiBold14.copyWith(color: secondaryTextColor)),
              verticalSpace(4.h),
              Text("Be the first to review this product", style: pRegular12.copyWith(color: secondaryTextColor.withOpacity(0.7))),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reviewController.reviewList.length,
        separatorBuilder: (_, __) => verticalSpace(16.h),
        itemBuilder: (context, index) {
          final review = reviewController.reviewList[index];
          final time1 = DateTime.tryParse(review.createdAt ?? "") ?? DateTime.now();

          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with better fallback
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColor.themeGreenColor.withOpacity(0.3), AppColor.themeGreenColor.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: _getFullImageUrl(review.productImagePath),
                          width: 44.w,
                          height: 44.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: Icon(Icons.person, size: 20.sp, color: AppColor.themeGreenColor)),
                          errorWidget: (context, url, error) => Center(child: Icon(Icons.person, size: 20.sp, color: AppColor.themeGreenColor)),
                        ),
                      ),
                    ),
                    horizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(review.userName ?? "User", style: pSemiBold12.copyWith(fontSize: 14.sp, color: primaryTextColor)),
                              RatingBar.builder(
                                initialRating: double.tryParse(review.ratingNo?.toString() ?? "0") ?? 0.0,
                                itemSize: 14.sp,
                                itemCount: 5,
                                ignoreGestures: true,
                                itemBuilder: (_, __) => Icon(Icons.star_rate_rounded, color: const Color(0xFFFFC107)),
                                onRatingUpdate: (rating) {},
                              ),
                            ],
                          ),
                          verticalSpace(2.h),
                          Text(reviewController.convertToAgo(time1), style: pRegular10.copyWith(color: secondaryTextColor, fontSize: 11.sp)),
                        ],
                      ),
                    ),
                  ],
                ),

                if (review.title != null && review.title!.isNotEmpty) ...[
                  verticalSpace(12.h),
                  Text(review.title!, style: pSemiBold12.copyWith(fontSize: 14.sp, color: primaryTextColor)),
                ],

                if (review.description != null && review.description!.isNotEmpty) ...[
                  verticalSpace(6.h),
                  Text(
                    review.description!,
                    style: pRegular12.copyWith(color: secondaryTextColor, height: 1.6, fontSize: 13.sp),
                  ),
                ],

                // Admin Actions Section
                if (Prefs.getBool(AppConstant.isDemoMode) != true)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Status Switch with Label
                          Row(
                            children: [
                              Text("Active", style: pRegular10.copyWith(color: secondaryTextColor)),
                              horizontalSpace(4.w),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  value: review.status == 1,
                                  onChanged: (value) {
                                    reviewController.changeReviewData(review.id!, productId: widget.productId);
                                  },
                                  activeColor: AppColor.themeGreenColor,
                                ),
                              ),
                            ],
                          ),

                          Spacer(),

                          // Edit Button
                          GestureDetector(
                            onTap: () async {
                              Get.to(() => AddRatingScreen(
                                id: widget.id,
                                categoryId: widget.categoryId,
                                productId: widget.productId,
                                isUpdate: true,
                                reviewId: review.id.toString(),
                                rate: double.tryParse(review.ratingNo?.toString() ?? "0") ?? 0.0,
                                title: review.title,
                                description: review.description,
                                user: review.userName,
                                status: review.status.toString(),
                              ));
                              await reviewController.getReviewData(widget.productId);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColor.themeNavyBlueColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit_outlined, size: 16.sp, color: AppColor.themeNavyBlueColor),
                            ),
                          ),

                          horizontalSpace(8.w),

                          // Delete Button
                          GestureDetector(
                            onTap: () {
                              AppDialog.showCustomDialog(
                                message: "deleteReview",
                                  iconColor: AppColor.cRedText,
                                  confirmColor: AppColor.cRedText,
                                  context: context,
                                  onConfirm: () async {
                                    await reviewController.deleteReviewData(
                                      reviewId: review.id.toString(),
                                      productId: widget.productId,
                                    );
                                  });
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColor.cRedText.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.delete_outline, size: 16.sp, color: AppColor.cRedText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }}
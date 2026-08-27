import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import 'package:store_go_app/view/screen/product_screen/add_rating_screen.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/product_controller/product_detail_controller.dart';
import 'package:store_go_app/core/controller/product_controller/add_review_controller.dart';
import '../../../core/model/product_model.dart';
import '../../widget/app_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final String categoryId;
  final ProductData product;
  final String productId;
  final String id;

  const ProductDetailScreen({
    super.key,
    required this.categoryId,
    required this.productId,
    required this.id,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {

  final ProductDetailController productDetailController =
  Get.put(ProductDetailController());

  final AddReviewController reviewController =
  Get.put(AddReviewController());

  final PageController _pageController =
  PageController();

  int _currentImageIndex = 0;
  @override
  void initState() {
    super.initState();

    productDetailController.setProduct(widget.product);

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
    await productDetailController
        .getProductDetail(widget.productId);

    await reviewController
        .getReviewData(widget.productId);

    if (mounted) {
      setState(() {});
    }
  }

  bool _hasCurrentUserReview() {
    final currentUserId =
    reviewController.userId.value.toString();

    return reviewController.reviewList.any(
          (review) =>
      review.userId?.toString() == currentUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? DarkThemeColor.cBackGround
        : const Color(0xFFF5F6F8);

    final cardColor = isDark
        ? DarkThemeColor.cCardBackground
        : Colors.white;

    final borderColor = isDark
        ? DarkThemeColor.cBorder
        : const Color(0xFFE9EAEE);

    final primaryTextColor =
    isDark ? Colors.white : AppColor.cText;

    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : AppColor.cFont;

    return Scaffold(
      appBar: simpleAppBar(
        title: 'product_details'.tr,
      ),
      backgroundColor: backgroundColor,
      body: GetBuilder<ProductDetailController>(
        builder: (controller) {
          final product = controller.product;

          if (product == null) {
            return const Center(
              child: LoadingWidget(),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                10.h,
                16.w,
                30.h,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildImageSlider(
                    cardColor: cardColor,
                    borderColor: borderColor,
                    isDark: isDark,
                  ),

                  verticalSpace(18.h),

                  _buildBasicInfoCard(
                    product: product,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primaryTextColor:
                    primaryTextColor,
                    secondaryTextColor:
                    secondaryTextColor,
                    isDark: isDark,
                  ),

                  verticalSpace(16.h),

                  _buildPropertiesCard(
                    product: product,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primaryTextColor:
                    primaryTextColor,
                    secondaryTextColor:
                    secondaryTextColor,
                    isDark: isDark,
                  ),

                  verticalSpace(16.h),

                  _buildStatusCard(
                    product: product,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primaryTextColor:
                    primaryTextColor,
                    secondaryTextColor:
                    secondaryTextColor,
                    isDark: isDark,
                  ),

                  verticalSpace(16.h),

                  _buildReviewsCard(
                    cardColor: cardColor,
                    borderColor: borderColor,
                    primaryTextColor:
                    primaryTextColor,
                    secondaryTextColor:
                    secondaryTextColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // IMAGE SLIDER + ZOOM
  // ============================================================

  Widget _buildImageSlider({
    required Color cardColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final images =
    productDetailController.getProductImages();

    if (images.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 250.h,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 55.sp,
          color: Colors.grey.shade400,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 260.h,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius:
            BorderRadius.circular(14.r),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(14.r),
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
                return Hero(
                  tag: 'product_image_${widget.productId}',
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.contain,
                    placeholder:
                        (context, url) {
                      return const Center(
                        child: LoadingWidget(),
                      );
                    },
                    errorWidget:
                        (context, url, error) {
                      return Center(
                        child: Icon(
                          Icons
                              .broken_image_outlined,
                          size: 50.sp,
                          color:
                          Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),

        if (images.length > 1)
          Padding(
            padding:
            EdgeInsets.only(top: 10.h),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: List.generate(
                images.length,
                    (index) {
                  final isActive =
                      _currentImageIndex == index;

                  return AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration:
                    const Duration(
                      milliseconds: 250,
                    ),
                    margin:
                    EdgeInsets.symmetric(
                      horizontal: 3.w,
                    ),
                    width:
                    isActive ? 11.w : 7.w,
                    height:
                    isActive ? 11.w : 7.w,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColor
                          .themeNavyBlueColor
                          : Colors
                          .grey.shade400,
                      borderRadius:
                      BorderRadius.circular(
                        10.r,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
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

    final productStock = _value(
      product,
      'productStock',
      fallback: '0',
    );

    final sku = _value(
      product,
      'productCode',
      fallback: _value(
        product,
        'sku',
      ),
    );

    return productInfoContainer(
      backgroundColor: cardColor,
      borderColor: borderColor,
      child: Column(
        children: [
          _infoRow(
            label: 'name'.tr,
            value: product.name ?? '-',
            primaryTextColor:
            primaryTextColor,
            secondaryTextColor:
            secondaryTextColor,
            leadingIcon:
            Icons.person_outline,
          ),

          _thinDivider(borderColor),

          _infoRow(
            label: 'price'.tr,
            value: price,
            primaryTextColor:
            primaryTextColor,
            secondaryTextColor:
            secondaryTextColor,
            leadingIcon:
            Icons.price_change,
          ),

          if (salePrice.isNotEmpty) ...[
            _thinDivider(borderColor),

            _infoRow(
              label: 'sale_price'.tr,
              value: salePrice,
              primaryTextColor:
              primaryTextColor,
              secondaryTextColor:
              secondaryTextColor,
              leadingIcon:
              Icons.price_change_outlined,
            ),
          ],

          _thinDivider(borderColor),

          // PRODUCT STOCK
          _infoRow(
            label: 'product_stock'.tr,
            value: productStock,
            primaryTextColor:
            primaryTextColor,
            secondaryTextColor:
            secondaryTextColor,
            leadingIcon:
            Icons.inventory_2_outlined,
          ),

          _thinDivider(borderColor),

          _infoRow(
            label: 'sku'.tr,
            value:
            sku.isEmpty ? '-' : sku,
            primaryTextColor:
            primaryTextColor,
            secondaryTextColor:
            secondaryTextColor,
            leadingIcon:
            Icons.qr_code_rounded,
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

    return productInfoContainer(
      backgroundColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
            primaryTextColor:
            primaryTextColor,
            secondaryTextColor:
            secondaryTextColor,
          ),

          _propertyRow(
            icon: Icons.scale,
            title: 'product_weight'.tr,
            subtitle: weight.isEmpty
                ? '-'
                : '$weight kg',
            primaryTextColor:
            primaryTextColor,
            secondaryTextColor:
            secondaryTextColor,
          ),

          _propertyRow(
            icon:
            Icons.description,
            title: 'description'.tr,
            subtitle: description.isEmpty
                ? '-'
                : description,
            primaryTextColor:
            primaryTextColor,
            secondaryTextColor:
            secondaryTextColor,
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
    ).toLowerCase().trim();

    final trackStock = _value(
      product,
      'trackStock',
      fallback: '0',
    );

    final isVisible = status == '1';

    final isInStock = stockStatus == 'in_stock';
    final isOutOfStock = stockStatus == 'out_of_stock';
    final isOnBackorder = stockStatus == 'on_backorder';

    final isTrackStock =
        trackStock == '1' ||
            trackStock.toLowerCase() == 'true';

    // Stock status properties
    IconData stockIcon;
    String stockLabel;
    Color stockColor;

    if (isInStock) {
      stockIcon = Icons.inventory_2_outlined;
      stockLabel = 'in_stock'.tr;
      stockColor = const Color(0xFF2E7D32);
    } else if (isOutOfStock) {
      stockIcon = Icons.remove_shopping_cart_outlined;
      stockLabel = 'out_of_stock'.tr;
      stockColor = const Color(0xFFD32F2F);
    } else if (isOnBackorder) {
      stockIcon = Icons.schedule_outlined;
      stockLabel = 'on_backorder'.tr;
      stockColor = const Color(0xFFEF6C00);
    } else {
      // Fallback لأي قيمة غير معروفة
      stockIcon = Icons.help_outline_rounded;
      stockLabel = stockStatus.isEmpty
          ? 'unknown'.tr
          : stockStatus;
      stockColor = Colors.grey;
    }

    return productInfoContainer(
      backgroundColor: cardColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            spacing: 4.w,
            runSpacing: 8.h,
            children: [
              // VISIBILITY
              _statusChip(
                icon: isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                label: isVisible
                    ? 'visible'.tr
                    : 'hidden'.tr,
                color: isVisible
                    ? const Color(0xFF2E7D32)
                    : isDark ? Colors.grey : Colors.grey.shade800,
              ),

              // STOCK STATUS
              _statusChip(
                icon: stockIcon,
                label: stockLabel,
                color: stockColor,
              ),

              // TRACK STOCK
              _statusChip(
                icon: isTrackStock
                    ? Icons.track_changes_rounded
                    : Icons.do_not_disturb_on_outlined,
                label: isTrackStock
                    ? 'tracked'.tr
                    : 'not_tracked'.tr,
                color: isTrackStock
                    ? AppColor.themeGreenColor
                    : isDark ? Colors.grey : Colors.grey.shade800,
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
    return productInfoContainer(
      backgroundColor: cardColor,
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
                          () =>
                          AddRatingScreen(
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
                    decoration:
                    BoxDecoration(
                      color: hasReview
                          ? Colors.grey
                          .withOpacity(0.12)
                          : AppColor
                          .themeGreenColor
                          .withOpacity(0.1),
                      borderRadius:
                      BorderRadius.circular(
                        20.r,
                      ),
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
                              ? 'Already Reviewed'
                              .tr
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

  Widget _buildReviewsList({
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Obx(() {
      if (reviewController.reviewList.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h),
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
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reviewController.reviewList.length,
        separatorBuilder: (_, __) => verticalSpace(12.h),
        itemBuilder: (context, index) {
          final review = reviewController.reviewList[index];

          // ✅ التحقق مما إذا كان التقييم للمستخدم الحالي
          final currentUserId = reviewController.userId.value.toString();
          final isMyReview = review.userId?.toString() == currentUserId;

          final time = DateTime.tryParse(review.createdAt ?? '') ??
              DateTime.now();

          final rating = double.tryParse(
            review.ratingNo?.toString() ?? '0',
          ) ??
              0;

          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isDark
                  ? DarkThemeColor.cCardBackground
                  : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: secondaryTextColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: secondaryTextColor,
                        size: 20.sp,
                      ),
                    ),

                    horizontalSpace(10.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.userName ?? 'User',
                            style: pSemiBold12.copyWith(
                              color: primaryTextColor,
                              fontSize: 13.sp,
                            ),
                          ),
                          verticalSpace(3.h),
                          Text(
                            reviewController.convertToAgo(time),
                            style: pRegular10.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isMyReview) ...[
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 18.sp, color: AppColor.themeGreenColor),
                        onPressed: () {
                          Get.to(() => AddRatingScreen(
                            id: widget.id,
                            categoryId: widget.categoryId,
                            productId: widget.productId,
                            reviewId: review.id.toString(), // مهم للتحديث
                            isUpdate: true,
                            rate: rating,
                            title: review.title,
                            description: review.description,
                          ));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red),
                        onPressed: () {
                          AppDialog.showCustomDialog(
                            context: context,
                            title: 'delete'.tr,
                            message: 'are_you_sure_delete_review'.tr,
                            lottieAsset: 'assets/lottie/delete_icon.json',
                            confirmColor: Colors.red,
                            onConfirm: () async {
                              await reviewController.deleteReviewData(
                                reviewId: review.id.toString(),
                                productId: widget.productId,
                              );
                            },
                          );
                        },
                      ),
                    ],

                    horizontalSpace(5.w),

                    RatingBar.builder(
                      initialRating: rating,
                      itemCount: 5,
                      itemSize: 14.sp,
                      ignoreGestures: true,
                      itemBuilder: (_, __) => const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                      ),
                      onRatingUpdate: (_) {},
                    ),
                  ],
                ),

                if (review.title != null && review.title!.isNotEmpty) ...[
                  verticalSpace(10.h),
                  Text(
                    review.title!,
                    style: pSemiBold12.copyWith(color: primaryTextColor),
                  ),
                ],

                if (review.description != null &&
                    review.description!.isNotEmpty) ...[
                  verticalSpace(10.h),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: borderColor,
                  ),
                  verticalSpace(10.h),
                  Text(
                    review.description!,
                    style: pRegular12.copyWith(
                      color: secondaryTextColor,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    size: 14.sp,
                    color:
                    secondaryTextColor,
                  ),
                  horizontalSpace(4.w),
                ],

                Flexible(
                  child: Text(
                    label,
                    style:
                    pRegular12.copyWith(
                      color:
                      secondaryTextColor,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          horizontalSpace(10.w),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
              pSemiBold12.copyWith(
                color:
                primaryTextColor,
                fontSize: 13.sp,
              ),
            ),
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
        ListTile(
          contentPadding:
          EdgeInsets.symmetric(
            vertical: 2.h,
            horizontal: 0,
          ),

          leading: Container(
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
              color: secondaryTextColor,
            ),
          ),

          title: Text(
            title,
            style: pSemiBold12.copyWith(
              color:
              primaryTextColor,
              fontSize: 13.5.sp,
            ),
          ),

          subtitle: Html(
            data: subtitle,
            style: {
              "body": Style(
                maxLines: 5,
                textOverflow:
                TextOverflow.ellipsis,
                margin: Margins.zero,
                padding:
                HtmlPaddings.zero,
              ),
            },
          ),
        ),

        if (!isLast)
          _thinDivider(
            secondaryTextColor
                .withOpacity(0.12),
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
        color:
        color.withOpacity(0.1),
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
            style:
            pMedium12.copyWith(
              color: color,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
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

        case 'productStock':
          value = object.productStock;
          break;

        case 'trackStock':
          value = object.trackStock;
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

  // ============================================================
  // PRODUCT INFO CONTAINER
  // ============================================================

  Widget productInfoContainer({
    required Widget child,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(14.r),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: child,
    );
  }
}

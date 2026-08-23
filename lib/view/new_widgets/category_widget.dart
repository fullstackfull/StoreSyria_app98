// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/core/model/categories_model.dart';
import 'package:store_go_app/utils/colors.dart';
import '../screen/home_screen/add_category_bottomsheet.dart';
import '../widget/app_dialog.dart';

Widget buildCategoryWidget({
  required BuildContext context,
  required CategoryData category,
  required CategoryController categoryController,
}) {
  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  // =========================================================
  // COLORS
  // =========================================================

  final Color cardColor =
  isDark ? const Color(0xFF1B1C20) : Colors.white;

  final Color surfaceColor =
  isDark ? const Color(0xFF23252A) : const Color(0xFFF7F8FA);

  final Color primaryText =
  isDark ? Colors.white : const Color(0xFF15171A);

  final Color secondaryText =
  isDark ? const Color(0xFF9297A1) : const Color(0xFF777D87);

  final Color borderColor =
  isDark
      ? Colors.white.withOpacity(.07)
      : const Color(0xFFE8EAEE);

  final Color accent =
      AppColor.themeNavyBlueColor;

  const Color success = Color(0xFF16A34A);
  const Color danger = Color(0xFFEF4444);
  const Color warning = Color(0xFFF59E0B);

  // =========================================================
  // DATA
  // =========================================================

  final String name =
  category.name?.trim().isNotEmpty == true
      ? category.name!.trim()
      : 'no_name'.tr;

  final String imageUrl =
      category.imagePathFullUrl?.trim() ?? '';

  final String iconUrl =
      category.iconPathFullUrl?.trim() ?? '';

  final bool hasImage =
      imageUrl.isNotEmpty && imageUrl.startsWith('http');

  final bool hasIcon =
      iconUrl.isNotEmpty && iconUrl.startsWith('http');

  final bool isTrending =
      category.trending == 1;

  final bool isActive =
      category.status == 1;

  final int totalProducts =
      category.totalProduct ?? 0;

  return Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(22.r),
      border: Border.all(
        color: borderColor,
        width: 1,
      ),
      boxShadow: isDark
          ? null
          : [
        BoxShadow(
          color: Colors.black.withOpacity(.055),
          blurRadius: 20,
          spreadRadius: -5,
          offset: Offset(0, 8),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.22,
          child: Stack(
            fit: StackFit.expand,
            children: [

              // IMAGE
              hasImage
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                fadeInDuration:
                Duration(milliseconds: 250),
                placeholder: (_, __) =>
                    _imageLoading(
                      isDark: isDark,
                      accent: accent,
                    ),
                errorWidget: (_, __, ___) =>
                    _imagePlaceholder(
                      isDark: isDark,
                    ),
              )
                  : _imagePlaceholder(
                isDark: isDark,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(.30),
                          Colors.transparent,
                          Colors.black.withOpacity(.72),
                        ],
                        stops: [
                          0,
                          .48,
                          1,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 9.h,
                right: 9.w,
                child: _categoryMenu(
                  context: context,
                  category: category,
                  categoryController:
                  categoryController,
                  isDark: isDark,
                  accent: accent,
                  danger: danger,
                ),
              ),
              Positioned(
                left: 13.w,
                right: 13.w,
                bottom: 12.h,
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [

                    // ICON
                    Container(
                      width: 42.w,
                      height: 42.w,
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(13.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(.18),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: hasIcon
                          ? CachedNetworkImage(
                        imageUrl: iconUrl,
                        fit: BoxFit.contain,
                        errorWidget:
                            (_, __, ___) =>
                            Icon(
                              Icons.category_outlined,
                              color: secondaryText,
                              size: 22.sp,
                            ),
                      )
                          : Icon(
                        Icons.category_outlined,
                        color: secondaryText,
                        size: 22.sp,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing: -.3,
                        shadows: [
                          Shadow(
                            color: Colors.black
                                .withOpacity(.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // =====================================================
        // CONTENT
        // =====================================================

        Padding(
          padding: EdgeInsets.fromLTRB(
            13.w,
            13.h,
            13.w,
            13.h,
          ),
          child: Column(
            children: [
              Row(
                children: [

                  Expanded(
                    child: _dashboardStat(
                      icon:
                      Icons.inventory_2_outlined,
                      label:
                      'Products'.tr,
                      value:
                      totalProducts.toString(),
                      color: accent,
                      primaryText:
                      primaryText,
                      secondaryText:
                      secondaryText,
                      surfaceColor:
                      surfaceColor,
                    ),
                  ),

                  _verticalDivider(
                    color: borderColor,
                  ),

                  Expanded(
                    child: _dashboardStat(
                      icon: isTrending
                          ? Icons
                          .trending_up_outlined
                          : Icons
                          .trending_flat_rounded,
                      label:
                      'Trending'.tr,
                      value: isTrending
                          ? 'Yes'.tr
                          : 'No'.tr,
                      color: isTrending
                          ? warning
                          : secondaryText,
                      primaryText:
                      primaryText,
                      secondaryText:
                      secondaryText,
                      surfaceColor:
                      surfaceColor,
                    ),
                  ),

                  _verticalDivider(
                    color: borderColor,
                  ),

                  Expanded(
                    child: _dashboardStat(
                      icon: isActive
                          ? Icons
                          .verified_outlined
                          : Icons
                          .block_outlined,
                      label:
                      'Status'.tr,
                      value: isActive
                          ? 'Active'.tr
                          : 'Inactive'.tr,
                      color: isActive
                          ? success
                          : danger,
                      primaryText:
                      primaryText,
                      secondaryText:
                      secondaryText,
                      surfaceColor:
                      surfaceColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// =============================================================
// CATEGORY MENU
// =============================================================

Widget _categoryMenu({
  required BuildContext context,
  required CategoryData category,
  required CategoryController categoryController,
  required bool isDark,
  required Color accent,
  required Color danger,
}) {
  final Color menuColor =
  isDark
      ? const Color(0xFF242529)
      : Colors.white;

  return PopupMenuButton<String>(
    padding: EdgeInsets.zero,
    tooltip: '',
    offset: Offset(0, 40.h),
    elevation: 10,
    color: menuColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.r),
    ),

    icon: Container(
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withOpacity(.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.more_vert,
        size: 20.sp,
        color: Colors.black87,
      ),
    ),

    onSelected: (value) {

      // EDIT
      if (value == 'edit') {
        showModalBottomSheet(
          context: context,
          backgroundColor: isDark
              ? DarkThemeColor.cCardBackground
              : AppColor.cWhite,
          barrierColor: Colors.black54,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.vertical(
              top: Radius.circular(25.r),
            ),
          ),
          builder: (_) {
            return AddNewCategoriesWidget(
              isUpdate: true,
              categoryId: category.id,
              name: category.name,
              image:
              category.imagePathFullUrl,
              icon:
              category.iconPathFullUrl,
              trending:
              category.trending?.toString(),
              status:
              category.status?.toString(),
            );
          },
        );
      }

      // DELETE
      if (value == 'delete') {
        AppDialog.showCustomDialog(
          context: context,
          title: 'delete'.tr,
          message: 'deleteCategory'.tr,
          lottieAsset:
          'assets/lottie/delete_icon.json',
          confirmColor: danger,
          onConfirm: () =>
            categoryController
                .deleteCategoriesData(
              categoryId:
              category.id ?? 0,
            ),
        );
      }
    },

    itemBuilder: (_) => [

      PopupMenuItem<String>(
        value: 'edit',
        height: 50.h,
        child: _menuItem(
          icon: Icons.edit_outlined,
          title: 'edit'.tr,
          color: accent,
          isDark: isDark,
        ),
      ),

      PopupMenuItem<String>(
        value: 'delete',
        height: 50.h,
        child: _menuItem(
          icon:
          Icons.delete_outline_rounded,
          title: 'delete'.tr,
          color: danger,
          isDark: isDark,
        ),
      ),
    ],
  );
}

// =============================================================
// MENU ITEM
// =============================================================

Widget _menuItem({
  required IconData icon,
  required String title,
  required Color color,
  required bool isDark,
}) {
  return Row(
    children: [

      Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: color.withOpacity(.09),
          borderRadius:
          BorderRadius.circular(9.r),
        ),
        child: Icon(
          icon,
          size: 17.sp,
          color: color,
        ),
      ),

      SizedBox(width: 10.w),

      Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isDark
              ? Colors.white
              : const Color(0xFF202124),
        ),
      ),
    ],
  );
}

// =============================================================
// IMAGE BADGE
// =============================================================

Widget _imageBadge({
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: 8.w,
      vertical: 5.h,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.95),
      borderRadius:
      BorderRadius.circular(30.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.12),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        SizedBox(width: 5.w),

        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 8.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
// =============================================================
// DASHBOARD STAT
// =============================================================

Widget _dashboardStat({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
  required Color primaryText,
  required Color secondaryText,
  required Color surfaceColor,
}) {
  return Column(
    children: [

      Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: color.withOpacity(.09),
          borderRadius:
          BorderRadius.circular(11.r),
        ),
        child: Icon(
          icon,
          size: 17.sp,
          color: color,
        ),
      ),

      SizedBox(height: 6.h),

      Text(
        value,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style: TextStyle(
          color: primaryText,
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
        ),
      ),

      SizedBox(height: 2.h),

      Text(
        label,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: secondaryText,
          fontSize: 7.5.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// =============================================================
// VERTICAL DIVIDER
// =============================================================

Widget _verticalDivider({
  required Color color,
}) {
  return Container(
    width: 1,
    height: 48.h,
    color: color,
    margin: EdgeInsets.symmetric(
      horizontal: 5.w,
    ),
  );
}

// =============================================================
// IMAGE PLACEHOLDER
// =============================================================

Widget _imagePlaceholder({
  required bool isDark,
}) {
  return Container(
    color: isDark
        ? const Color(0xFF202125)
        : const Color(0xFFF0F2F5),
    child: Center(
      child: Container(
        width: 54.w,
        height: 54.w,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(.05)
              : Colors.white.withOpacity(.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.category_outlined,
          size: 29.sp,
          color: isDark
              ? const Color(0xFF686C75)
              : const Color(0xFFB2B7BF),
        ),
      ),
    ),
  );
}

// =============================================================
// IMAGE LOADING
// =============================================================

Widget _imageLoading({
  required bool isDark,
  required Color accent,
}) {
  return Container(
    color: isDark
        ? const Color(0xFF202125)
        : const Color(0xFFF0F2F5),
    child: Center(
      child: SizedBox(
        width: 24.w,
        height: 24.w,
        ),
    ),
  );
}
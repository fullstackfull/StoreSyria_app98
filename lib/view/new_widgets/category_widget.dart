// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/category_controller.dart';
import 'package:store_go_app/core/model/categories_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/new_widgets/pop_up_menu.dart';
import '../screen/home_screen/add_category_bottomsheet.dart';
import '../widget/app_dialog.dart';

Widget buildCategoryWidget({
  required BuildContext context,
  required CategoryData category,
  required CategoryController categoryController,
}) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  // ------------------------------ COLORS ------------------------------
  final Color cardColor = isDark ? const Color(0xFF18263F) : Colors.white;
  final Color surfaceColor =
  isDark ? const Color(0xFF213252) : const Color(0xFFF5F6F8);
  final Color primaryText = isDark ? Colors.white : const Color(0xFF0F1A2E);
  final Color secondaryText =
  isDark ? const Color(0xFFA9B8D0) : const Color(0xFF777D87);
  final Color borderColor =
  isDark ? Colors.white.withValues(alpha: .07) : const Color(0xFFE8EAEE);
  final Color accent = AppColor.themeNavyBlueColor;

  const Color success = Color(0xFF16A34A);
  const Color danger = Color(0xFFEF4444);
  const Color warning = Color(0xFFF59E0B);

  // ------------------------------- DATA -------------------------------
  final String name = category.name?.trim().isNotEmpty == true
      ? category.name!.trim()
      : 'no_name'.tr;

  final String imageUrl = category.imagePathFullUrl?.trim() ?? '';
  final String iconUrl = category.iconPathFullUrl?.trim() ?? '';

  final bool hasImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');
  final bool hasIcon = iconUrl.isNotEmpty && iconUrl.startsWith('http');

  final bool isTrending = category.trending == 1;
  final bool isActive = category.status == 1;
  final int totalProducts = category.totalProduct ?? 0;

  return Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: borderColor),
      boxShadow: isDark
          ? null
          : [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 18,
          spreadRadius: -4,
          offset: Offset(0, 8),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================== IMAGE ==========================
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasImage
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 250),
                placeholder: (_, __) =>
                    _imageLoading(isDark: isDark, accent: accent),
                errorWidget: (_, __, ___) =>
                    _imagePlaceholder(isDark: isDark),
              )
                  : _imagePlaceholder(isDark: isDark),

              // soft gradient (top + bottom) for readable chips
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .28),
                          Colors.transparent,
                          Colors.black.withValues(alpha: .22),
                        ],
                        stops: [0, .45, 1],
                      ),
                    ),
                  ),
                ),
              ),

              // STATUS chip (top-start)
              PositionedDirectional(
                top: 9.h,
                start: 9.w,
                child: _chip(
                  label: isActive ? 'Active'.tr : 'Inactive'.tr,
                  color: isActive ? success : danger,
                  dot: true,
                ),
              ),

              // MENU (top-end)
              PositionedDirectional(
                top: 6.h,
                end: 6.w,
                child: _categoryMenu(
                  context: context,
                  category: category,
                  categoryController: categoryController,
                  isDark: isDark,
                  accent: accent,
                  danger: danger,
                ),
              ),

              // TRENDING chip (bottom-start) - only when trending
              if (isTrending)
                PositionedDirectional(
                  start: 9.w,
                  bottom: 9.h,
                  child: _chip(
                    label: 'Trending'.tr,
                    color: warning,
                    icon: Icons.trending_up_rounded,
                  ),
                ),
            ],
          ),
        ),

        // ========================== CONTENT ==========================
        Padding(
          padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON + NAME
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: hasIcon
                        ? CachedNetworkImage(
                      imageUrl: iconUrl,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.category_outlined,
                        color: secondaryText,
                        size: 18.sp,
                      ),
                    )
                        : Icon(
                      Icons.category_outlined,
                      color: secondaryText,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 13.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.2,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 9.h),

              // PRODUCTS BAR
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? .18 : .07),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 15.sp,
                      color: isDark ? Colors.white70 : accent,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Products'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      totalProducts.toString(),
                      style: TextStyle(
                        color: isDark ? Colors.white : accent,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// =============================================================
// CHIP (status / trending)
// =============================================================

Widget _chip({
  required String label,
  required Color color,
  bool dot = false,
  IconData? icon,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot)
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        if (icon != null) Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF15171A),
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
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
  return AppPopupMenu(
    color: Colors.white,
    changeFun: () {
      showModalBottomSheet(
        context: context,
        backgroundColor:
        isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
        barrierColor: Colors.black54,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        builder: (_) {
          return AddNewCategoriesWidget(
            isUpdate: true,
            categoryId: category.id,
            name: category.name,
            image: category.imagePathFullUrl,
            icon: category.iconPathFullUrl,
            trending: category.trending?.toString(),
            status: category.status?.toString(),
          );
        },
      );
    },
    deleteFun: () {
      AppDialog.showCustomDialog(
        context: context,
        title: 'delete'.tr,
        message: 'deleteCategory'.tr,
        lottieAsset: 'assets/lottie/delete_icon.json',
        confirmColor: danger,
        onConfirm: () async {
          categoryController.deleteCategoriesData(
            categoryId: category.id ?? 0,
          );
        },
      );
    },
  );
}

// =============================================================
// IMAGE PLACEHOLDER / LOADING
// =============================================================

Widget _imagePlaceholder({required bool isDark}) {
  return Container(
    color: isDark ? const Color(0xFF18263F) : const Color(0xFFF0F2F5),
    child: Center(
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: .05)
              : Colors.white.withValues(alpha: .8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.category_outlined,
          size: 28.sp,
          color: isDark ? const Color(0xFFA9B8D0) : const Color(0xFFB2B7BF),
        ),
      ),
    ),
  );
}

Widget _imageLoading({required bool isDark, required Color accent}) {
  return Container(
    color: isDark ? const Color(0xFF18263F) : const Color(0xFFF0F2F5),
    child: Center(
      child: SizedBox(
        width: 22.w,
        height: 22.w,
        child: CircularProgressIndicator(strokeWidth: 2, color: accent),
      ),
    ),
  );
}
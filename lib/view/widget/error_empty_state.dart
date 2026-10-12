import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';


class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final double? iconSize;
  final Color? iconColor;
  final Widget? actionWidget;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.iconSize,
    this.iconColor,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: iconSize ?? 72.r,
                    color: iconColor ?? (isDark ? Colors.white38 : Colors.grey.shade400),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isDark ? Colors.white70 : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (actionWidget != null) ...[
                    SizedBox(height: 24.h),
                    actionWidget!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: .08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 46.sp,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    "something_went_wrong".tr,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    message.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark
                          ? Colors.white60
                          : Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  if (onRetry != null)
                    IconButton(
                      onPressed: onRetry,
                      icon: Icon(Icons.refresh,size: 30.w,),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.themeNavyBlueColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
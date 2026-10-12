import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AppPopupMenu extends StatelessWidget {
  final VoidCallback? viewFun;
  final VoidCallback? changeFun;
  final VoidCallback? changeFun2;
  final VoidCallback? deleteFun;
  final VoidCallback? changeFun3;

  final String? changeText3;
  final String? changeText;
  final Color? color;
  final String? changeText2;
  final String? viewText;
  final String? deleteText;

  const AppPopupMenu({
    super.key,
    this.viewFun,
    this.changeFun,
    this.changeFun3,
    this.changeText3,
    this.changeFun2,
    this.deleteFun,
    this.changeText,
    this.changeText2,
    this.viewText,
    this.deleteText,
    this.color,
  });

  // ============================================================
  // CONDITIONS
  // ============================================================

  bool get canView => viewFun != null;
  bool get canChange => changeFun != null;
  bool get canChange2 => changeFun2 != null;
  bool get canDelete => deleteFun != null;
  bool get canChange3 => changeFun3 != null;

  bool get hasAnyAction =>
      canView || canChange || canChange2 || canChange3 || canDelete;

  // ============================================================
  // HELPERS
  // ============================================================

  PopupMenuEntry<String> _divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuItem<String>(
      enabled: false,
      height: 1.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Divider(
        height: 1.h,
        thickness: 1,
        color: isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.08),
      ),
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 32.h,
      child: Row(
        children: [
          Icon(
            icon,
            size: 15.sp,
            color: color,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildItems(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : const Color(0xFF172C4E);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF687386);

    final items = <PopupMenuEntry<String>>[];

    // VIEW
    if (canView) {
      items.add(
        _menuItem(
          value: 'view',
          icon: Icons.visibility_outlined,
          label: viewText ?? 'view'.tr,
          color: secondaryTextColor,
          textColor: primaryTextColor,
        ),
      );
    }

    // CHANGE 1
    if (canChange) {
      if (items.isNotEmpty) items.add(_divider(context));
      items.add(
        _menuItem(
          value: 'change',
          icon: Icons.edit_outlined,
          label: changeText ?? 'change'.tr,
          color: secondaryTextColor,
          textColor: primaryTextColor,
        ),
      );
    }

    // CHANGE 2
    if (canChange2) {
      if (items.isNotEmpty) items.add(_divider(context));
      items.add(
        _menuItem(
          value: 'change2',
          icon: Icons.edit_outlined,
          label: changeText2 ?? 'change2'.tr,
          color: secondaryTextColor,
          textColor: primaryTextColor,
        ),
      );
    }

    if (canChange3) {
      if (items.isNotEmpty) items.add(_divider(context));
      items.add(
        _menuItem(
          value: 'change3',
          icon: Icons.delivery_dining_outlined,
          label: changeText3 ?? 'assign_delivery_boy'.tr,
          color: secondaryTextColor,
          textColor: primaryTextColor,
        ),
      );
    }

    // DELETE
    if (canDelete) {
      if (items.isNotEmpty) items.add(_divider(context));
      items.add(
        _menuItem(
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: deleteText ?? 'delete'.tr,
          color: Colors.redAccent,
          textColor: primaryTextColor,
        ),
      );
    }

    return items;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (!hasAnyAction) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF18263F) : Colors.white;
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF687386);

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      splashRadius: 22.r,
      offset: Offset(0, 35.h),
      tooltip: 'more'.tr,

      icon: Container(
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : color ?? Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey)
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 17.sp,
          color: subTextColor,
        ),
      ),

      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.4),
      color: cardColor,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),

      onSelected: (value) {
        switch (value) {
          case 'view':
            viewFun?.call();
            break;
          case 'change':
            changeFun?.call();
            break;
          case 'change2':
            changeFun2?.call();
            break;
          case 'change3':
            changeFun3?.call();
            break;
          case 'delete':
            deleteFun?.call();
            break;
        }
      },
      itemBuilder: (context) => _buildItems(context),
    );
  }
}
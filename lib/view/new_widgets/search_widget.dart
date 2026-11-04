import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/colors.dart';
import 'app_txt_field.dart';

Widget SearchRowWidget({
  required BuildContext context,
  required TextEditingController controller,
  String? hint,
  Function(String)? onChanged,
  VoidCallback? onClear,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return AppTextField(
    controller: controller,
    hint: hint,
    // This widget has no `title`, so without a name of its own the field would
    // be announced by its placeholder when empty and by nothing at all once
    // something is typed. 'search' is the key already used by the clear button
    // below, so no new translation key is introduced -- and it is deliberately
    // not `hint`, which would make the field announce the same sentence twice.
    semanticLabel: 'search'.tr,
    icon: Icons.search_rounded,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    suffix: IconButton(
      // Accessible name: this control has no visible text.
      tooltip: 'search'.tr,
      onPressed: onClear,
      splashRadius: 20,
      icon: Icon(
        Icons.arrow_right_alt_outlined,
        size: 22.sp,
        color: isDark ? Colors.white : AppColor.themeNavyBlueColor,
      ),
    ),
  );
}
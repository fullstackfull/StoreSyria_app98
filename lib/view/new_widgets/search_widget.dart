import 'package:flutter/material.dart';
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
    icon: Icons.search_rounded,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    suffix: IconButton(
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
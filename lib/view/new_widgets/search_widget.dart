import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/view/widget/common_text_field.dart';
import '../../utils/colors.dart';

Widget SearchRowWidget({
  required BuildContext context,
  required TextEditingController controller,
  String? hint,
  Function(String)? onChanged,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite;

  return Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(30.r),
    ),
    child: CommonTextField(
      prefix: DefaultImages.searchIcn,
      suffix: IconButton(
          onPressed: () {
            controller.clear();
            onChanged?.call("");
            },
          icon: Icon(Icons.arrow_right_alt_outlined)
      ),
      hintText: hint,
      color: isDark ? Colors.grey : Colors.white,
      controller: controller,
      onChanged: onChanged,
    ),
  );
}
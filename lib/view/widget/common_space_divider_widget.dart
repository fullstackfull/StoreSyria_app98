import 'package:flutter/material.dart';

import '../../utils/colors.dart';

Widget verticalSpace(double height) {
  return SizedBox(
    height: height,
  );
}

Widget horizontalSpace(double width) {
  return SizedBox(
    width: width,
  );
}

Widget horizontalDivider({Color? color}) {
  return Divider(
    color: color ?? AppColor.cDivider,
    thickness: 1,
  );
}

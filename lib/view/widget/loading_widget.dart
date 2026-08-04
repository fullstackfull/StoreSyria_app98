// ignore_for_file: prefer_const_constructors

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';

class Loader {
  static showLoader() {
    LoadingWidget();
  }

  static hideLoader() {
    Get.back(closeOverlays: true);
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColor.themeNavyBlueColor),
    );
  }
}

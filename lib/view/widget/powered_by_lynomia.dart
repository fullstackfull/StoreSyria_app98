import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class PoweredByLynomia extends StatelessWidget {
  const PoweredByLynomia({super.key});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap:() async{
        final uri = Uri.parse("https://lynomia.com");
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
      child: Text(
        "Powered by Lynomia".tr,
        textAlign: TextAlign.center,
        style: pRegular14.copyWith(color: Colors.grey),
      ),
    );
  }
}

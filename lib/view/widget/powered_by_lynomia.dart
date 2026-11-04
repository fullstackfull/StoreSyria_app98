import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class PoweredByLynomia extends StatelessWidget {
  const PoweredByLynomia({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap:() async{
        final uri = Uri.parse("https://lynomia.com");
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
      child: Text(
        "Powered by Lynomia".tr,
        textAlign: TextAlign.center,
        /* P2.5-A-11. The third identical Colors.grey (#9E9E9E) on the login card, 2.68:1
           on white -- folded into the same repair rather than deferred, because this widget
           has exactly ONE call site (login_widget.dart:230) so the blast radius is that one
           card. Shipping two of three would have closed a row named for this defect while
           the screen still painted it. */
        style: pRegular14.copyWith(
          color: isDark ? DarkThemeColor.cSecondaryText : LightThemeColor.cFont,
        ),
      ),
    );
  }
}

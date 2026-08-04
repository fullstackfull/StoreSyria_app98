// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/controller/home_controller/drawer_controller.dart';
import 'package:store_go_app/core/controller/dashboard_manager_controller/dashboard_manager_controller.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/widget/icon_and_image.dart';

import 'home_screen_widget.dart';

class DrawerScreen extends StatelessWidget {
  DrawerScreen({Key? key}) : super(key: key);
  MyDrawerController drawerController = Get.put(MyDrawerController());

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: Get.width,
        color: AppColor.cBackGround,
        padding: EdgeInsets.all(24),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  children: [
                    assetSvdImageWidget(image: DefaultImages.closeIcn, width: 18, height: 18),
                    horizontalSpace(20),
                    Text(
                      "Dashboard",
                      style: pRegular14,
                    )
                  ],
                ),
              ),
              verticalSpace(35),
              Wrap(
                children: List.generate(
                  drawerController.drawerItem.length,
                  (index) {
                    var data = drawerController.drawerItem[index];
                    return GestureDetector(
                      onTap: () {
                        drawerController.currantIndex.value = index;
                        Get.back();

                        // Map drawer index to dashboard tab index
                        // Drawer: 0=Dashboard, 1=Orders, 2=Products, 3=Categories, 4=Statistics, 5=Settings, 6=Shipping, 7=Tax, 8=Coupon
                        // Dashboard: 0=Orders, 1=Products, 2=Dashboard, 3=Categories, 4=Settings
                        final Map<int, int> drawerToDashboardMap = {
                          0: 2, // Dashboard -> Dashboard (index 2)
                          1: 0, // Orders -> Orders (index 0)
                          2: 1, // Products -> Products (index 1)
                          3: 3, // Categories -> Categories (index 3)
                          4: -1, // Statistics -> not in dashboard tabs
                          5: 4, // Settings -> Settings (index 4)
                          6: -1, // Shipping -> not in dashboard tabs
                          7: -1, // Tax -> not in dashboard tabs
                          8: -1, // Coupon -> not in dashboard tabs
                        };

                        final dashboardTabIndex = drawerToDashboardMap[index];

                        if (dashboardTabIndex != null && dashboardTabIndex >= 0) {
                          // Use DashboardManagerController for dashboard tabs
                          final dashboardController = Get.find<DashboardManagerController>();
                          dashboardController.updateIndex(dashboardTabIndex);
                        } else {
                          // For other screens, use normal navigation
                          Get.toNamed(data['route']);
                        }
                      },
                      child: drawerWidget(
                        isSelected: drawerController.currantIndex.value == index,
                        title: data['title'],
                        icon: data['icon'],
                      ),
                    );
                  },
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}



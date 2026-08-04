// ignore_for_file: avoid_print, must_be_immutable, prefer_const_constructors_in_immutables

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/view/widget/custom_bottom_nav_bar/bar_item.dart';
import 'package:store_go_app/view/widget/custom_bottom_nav_bar/custom_bottom_nav_bar.dart';
import 'package:store_go_app/core/controller/dashboard_manager_controller/dashboard_manager_controller.dart';
import 'package:store_go_app/core/controller/setting_controller/theme_controller.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class DashBoardManagerScreen extends StatefulWidget {
  const DashBoardManagerScreen({super.key});

  @override
  State<DashBoardManagerScreen> createState() => _DashBoardManagerScreenState();
}

class _DashBoardManagerScreenState extends State<DashBoardManagerScreen> with TickerProviderStateMixin {
  final DashboardManagerController dashboardManagerController = Get.find<DashboardManagerController>();
  final ThemeController themeController = Get.find<ThemeController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: dashboardManagerController.currantIndex.value,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        dashboardManagerController.updateIndex(_tabController.index);
      }
    });

    // Sync TabController when currantIndex changes from other sources (buttons, drawer)
    ever(dashboardManagerController.currantIndex, (index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDark = themeController.isDark.value;
      final Color bgColor = isDark ? DarkThemeColor.cBackGround : LightThemeColor.cBackGround;
      final Color navBgColor = isDark ? DarkThemeColor.cBottomNavyBlueColor : LightThemeColor.cBottomNavyBlueColor;
      final Color navInactiveColor = isDark ? Colors.white54 : AppColor.cDarkGreyFont;
      final Color navActiveColor = isDark ? AppColor.themeGreenColor : AppColor.cWhite;


      return Scaffold(
        backgroundColor: bgColor,
        body: IndexedStack(
          index: dashboardManagerController.currantIndex.value,
          children: dashboardManagerController.screens,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
            child: SizedBox(
              height: 73.h,
              child: StylishBottomBar(
                currentIndex: dashboardManagerController.currantIndex.value,
                backgroundColor: navBgColor,
                borderRadius: BorderRadius.circular(20.r),
                elevation: 4,
                option: BubbleBarOptions(
                  barStyle: BubbleBarStyle.vertical,
                  bubbleFillStyle: BubbleFillStyle.fill,
                  opacity: 0.15,
                ),
                items: dashboardManagerController.naviBarItemList.map((element) {
                  return BottomBarItem(
                    icon: SvgPicture.asset(
                      element['icon'],
                      width: 20.w,
                      height: 20.w,
                      colorFilter: ColorFilter.mode(
                        navInactiveColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    selectedIcon: SvgPicture.asset(
                      element['icon'],
                      width: 20.w,
                      height: 20.w,
                      colorFilter: ColorFilter.mode(
                        navActiveColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: Text(
                      element['title'],
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    backgroundColor: navActiveColor,
                    selectedColor: navActiveColor,
                    unSelectedColor: navInactiveColor,
                  );
                }).toList(),
                onTap: (index) {
                  dashboardManagerController.updateIndex(index);
                  _tabController.animateTo(index);
                },
              ),
            ),
          ),
        ),
       );
    });
  }
}


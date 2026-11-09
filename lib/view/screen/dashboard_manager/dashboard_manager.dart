import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/utils/colors.dart';
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
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: dashboardManagerController.currantIndex.value,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        dashboardManagerController.updateIndex(_tabController.index);
      }
    });

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
      final Color bgColor = isDark ? DarkThemeColor.cBackGround : AppColor.cLight;
      final Color navBgColor = isDark ? DarkThemeColor.cBottomNavyBlueColor : LightThemeColor.cBottomNavyBlueColor;
      // P2.5-FLUTTER-SHELL. THE BAR IS DARK NAVY IN BOTH THEMES -- `cBottomNavyBlueColor` is
      // #14213A in dark and #172C4E in light -- so its inactive label has to be a LIGHT tint in
      // both. In light mode it was `AppColor.cDarkGreyFont`, a grey meant for light backgrounds,
      // which measured **3.14:1** on that navy. Four of the five labels are unselected at any
      // moment, on the one surface that stays on screen for the whole session.
      //
      // `Colors.white54` is what the dark theme already used (5.60:1 there) and gives 5.15:1
      // here, so the two themes now agree instead of one of them being wrong. Measured off the
      // rendered bar: `test/screens/dashboard_shell_capture_test.dart`.
      final Color navInactiveColor = Colors.white54;
      final Color navActiveColor = isDark ? DarkThemeColor.cPrimary : AppColor.cWhite;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          final now = DateTime.now();

          if (_lastBackPressTime == null ||
              now.difference(_lastBackPressTime!) >
                  const Duration(seconds: 2)) {

            _lastBackPressTime = now;

            Get.rawSnackbar(
              messageText: Text( "tap_again_to_close".tr,
                textAlign: TextAlign.center,
                style: TextStyle( color: Colors.white,
                  fontSize: 14.sp,
                )),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColor.themeNavyBlueColor.withValues(alpha: 0.9),
              margin: EdgeInsets.symmetric(vertical: 90.h,horizontal: 90.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              borderRadius: 22.r,
              duration: const Duration(seconds: 2),
            );
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: bgColor,

          body: IndexedStack(
            index: dashboardManagerController.currantIndex.value,
            children: dashboardManagerController.screens,
          ),

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
              child: SizedBox(
                height: 70.h,
                child: StylishBottomBar(
                  currentIndex:
                  dashboardManagerController.currantIndex.value,
                  backgroundColor: navBgColor,
                  borderRadius: BorderRadius.circular(40.r),
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
                        width: 25.w,
                        height: 25.w,
                        colorFilter: ColorFilter.mode(
                          navInactiveColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      selectedIcon: SvgPicture.asset(
                        element['icon'],
                        width: 25.w,
                        height: 25.w,
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
        ),
      );
    });
  }
}
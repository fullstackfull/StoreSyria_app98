import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_go_app/utils/colors.dart';
import '../../../core/controller/plan/my_plan_controller.dart';
import '../../new_widgets/my_plan_widget.dart';
import '../../new_widgets/shimmer.dart';
import '../../widget/common_appbar_widget.dart';
import '../../widget/error_empty_state.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  final PlanController controller = Get.put(PlanController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMyPlanData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme
            .of(context)
            .brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF101114) : AppColor.cLight,
      appBar: simpleAppBar(
        title: 'MyPlan'.tr,
        label: null,
        onNewLabelTap: () {},
        isBack: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.currentPlanResponse == null) {
            return const ShimmerDetails(sections: 4, rowsPerSection: 4);
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.currentPlanResponse == null) {
            return ErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.getMyPlanData,
            );
          }

          final response = controller.currentPlanResponse;

          if (response == null) {
            return EmptyState(
              message: 'no_MyPlan_found'.tr,
              icon: Icons.diamond_outlined,
            );
          }

          final plan = response.data.currentPlan;

          return RefreshIndicator(
            color: AppColor.themeNavyBlueColor,
            onRefresh: controller.getMyPlanData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20.w,
                20.h,
                20.w,
                30.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyPlanCard(
                    context: context,
                    isDark: isDark,
                    plan: plan,
                    storeId: response.data.storeId,
                  ),

                  SizedBox(height: 24.h),

                  sectionTitle(
                    title: 'plan_usage'.tr,
                    isDark: isDark,
                  ),

                  SizedBox(height: 12.h),

                  usageCard(
                    title: 'products'.tr,
                    used: plan.limits.products.used,
                    max: plan.limits.products.max,
                    remaining: plan.limits.products.remaining,
                    percentage: plan.limits.products.percentage,
                    icon: Icons.shopping_bag_outlined,
                    isDark: isDark,
                  ),

                  SizedBox(height: 10.h),

                  usageCard(
                    title: 'stores'.tr,
                    used: plan.limits.stores.used,
                    max: plan.limits.stores.max,
                    remaining: plan.limits.stores.remaining,
                    percentage: plan.limits.stores.percentage,
                    icon: Icons.storefront_outlined,
                    isDark: isDark,
                  ),

                  SizedBox(height: 10.h),

                  usageCard(
                    title: 'users'.tr,
                    used: plan.limits.users.used,
                    max: plan.limits.users.max,
                    remaining: plan.limits.users.remaining,
                    percentage: plan.limits.users.percentage,
                    icon: Icons.people_outline,
                    isDark: isDark,
                  ),

                  SizedBox(height: 24.h),

                  sectionTitle(
                    title: 'MyPlan_details'.tr,
                    isDark: isDark,
                  ),

                  SizedBox(height: 12.h),

                  detailsCard(
                    isDark: isDark,
                    children: [
                      detailRow(
                        title: 'price'.tr,
                        value: "${plan.price} ${plan.currency}",
                        icon: Icons.payments_outlined,
                        isDark: isDark,
                      ),
                      divider(isDark),
                      detailRow(
                        title: 'duration'.tr,
                        value: plan.durationText,
                        icon: Icons.schedule_outlined,
                        isDark: isDark,
                      ),
                      divider(isDark),
                      detailRow(
                        title: 'expire_date'.tr,
                        value: plan.planStatus.planExpireDate,
                        icon: Icons.event_outlined,
                        isDark: isDark,
                      ),
                      divider(isDark),
                      detailRow(
                        title: 'status'.tr,
                        value: plan.planStatus.status,
                        icon: Icons.verified_outlined,
                        valueColor: plan.planStatus.isExpired
                            ? const Color(0xFFEF4444)
                            : AppColor.themeGreenColor,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  sectionTitle(
                    title: 'features'.tr,
                    isDark: isDark,
                  ),

                  SizedBox(height: 12.h),

                  featuresCard(
                    isDark: isDark,
                    plan: plan,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
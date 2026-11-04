// ignore_for_file: prefer_const_constructors

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/core/model/shipping_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/constant.dart';
import 'package:store_go_app/utils/images.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/screen/home_screen/add_shipping_bottomsheet.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_button.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/home_controller/shipping_controller.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import '../../new_widgets/shimmer.dart';

import 'home_screen_widget.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({Key? key}) : super(key: key);

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  ShippingController shippingController = Get.put(ShippingController());
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    shippingController.currantPage.value = 1;
    shippingController.isScroll.value = true;
    //shippingController.imageBaseUrl.value =
        Prefs.getString(AppConstant.imageUrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (shippingController.isScroll.value &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      shippingController.currantPage.value++;
      shippingController.getShippingData(
          shippingController.currantPage.value);
    }
  }

  @override
  void dispose() {
    // The listener was anonymous and the controller was never disposed, so every visit to this
    // screen leaked one. `tax_screen.dart:60-64` already does both; extracting `_onScroll` above
    // is what makes `removeListener` possible.
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  /// One `Future<void>` serves `initState` and every `RefreshIndicator.onRefresh` below, which
  /// needs a future to await before it retracts the spinner.
  Future<void> _getData() async {
    await shippingController.getShippingData(shippingController.currantPage.value);
  }

  getData() {
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColor.cLabel;

    return Scaffold(
      backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
      appBar: simpleAppBar(
          title: "Shipping".tr,
          isBack: true,
          label: null,
          onNewLabelTap: () {  }),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonIconButton(
              title: 'Add Shipping'.tr,
              iconData: DefaultImages.addCircleIcn,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
                  barrierColor: AppColor.cGreyOpacity,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  builder: (context) {
                    return AddShippingWidget(
                      isUpdate: false,
                    );
                  },
                );
              },
              height: 51,
            ),
            verticalSpace(20),
            Text(
              "Shipping".tr,
              style: pRegular20.copyWith(color: textColor),
            ),
            verticalSpace(15),
            // List content (reactive). `Expanded` OUTSIDE `Obx` -- the RefreshIndicator
            // branches below need bounded constraints (tax_screen.dart:102).
            Expanded(child: Obx(() => _buildBody(isDark))),
          ],
        ),
      ),
    );
  }

  /// The four states this screen owes a merchant, in the order the view must test them.
  ///
  /// Mirrors `tax_screen.dart:143-230`, which is the sibling precedent, with one
  /// correction: the empty branch is PAGE-SCOPED. A request for a page past the last one
  /// answers `status: 1` with `data: []`, and `getShippingData` clears the list before it
  /// assigns, so page 2 of a 1-page result empties a list the merchant has rows in. An
  /// unscoped `isEmpty` would then announce "no shipping methods found" to someone looking
  /// at a catalogue. Reading `currantPage.value` here also keeps it tracked by the `Obx`.
  Widget _buildBody(bool isDark) {
    final textColor = isDark ? Colors.white : AppColor.cLabel;
    final descriptionColor =
        isDark ? DarkThemeColor.cSecondaryText : AppColor.cFont;

    /// First load: a shimmer rather than a blank rectangle. `ShimmerList`, not
    /// `ShimmerTable` -- these rows are image-plus-two-lines cards, the shape
    /// products/customers/orders already shimmer with, while the table matches tax.
    if (shippingController.isLoading.value &&
        shippingController.shippingList.isEmpty) {
      return const ShimmerList();
    }

    /// ERROR BEFORE EMPTY, and the order is the point rather than a detail: a failed
    /// request also leaves the list empty, so testing `isEmpty` first tells a merchant
    /// whose network dropped that they have NO SHIPPING METHODS. Same correction
    /// `customer_screen.dart:158-162` records.
    if (shippingController.errorMessage.value.isNotEmpty &&
        shippingController.shippingList.isEmpty) {
      return RefreshIndicator(
        backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
        onRefresh: _getData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .6,
              child: Center(
                child: ErrorState(
                  message: shippingController.errorMessage.value,
                  onRetry: _getData,
                ),
              ),
            ),
          ],
        ),
      );
    }

    /// Empty -- genuinely empty, which is why it is scoped to the first page. No
    /// `iconColor`: the widget's own per-theme colours are contrast-pinned and an
    /// explicit one overrides them (test/a11y/empty_state_contrast_test.dart:116-125).
    if (shippingController.shippingList.isEmpty &&
        shippingController.currantPage.value <= 1) {
      return RefreshIndicator(
        backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
        onRefresh: _getData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .6,
              child: Center(
                child: EmptyState(
                  message: 'no_shipping_methods_found'.tr,
                  icon: Icons.local_shipping_outlined,
                ),
              ),
            ),
          ],
        ),
      );
    }

    /// The list. An empty page 2 lands here and renders `itemCount: 0` -- the blank area
    /// this screen has always shown, which is honest, rather than an empty state, which
    /// would not be.
    return RefreshIndicator(
      backgroundColor: isDark ? DarkThemeColor.cCardBackground : Colors.white,
      onRefresh: _getData,
      child: ListView.builder(
        controller: scrollController,
        itemCount: shippingController.shippingList.length,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          ShippingData shipping = shippingController.shippingList[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Slidable(
              key: ValueKey(index),
              endActionPane: ActionPane(
                motion: ScrollMotion(),
                children: [
                  slidableActionWidget(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: isDark ? DarkThemeColor.cBackGround : AppColor.cBackGround,
                          barrierColor: AppColor.cGreyOpacity,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          builder: (context) {
                            return AddShippingWidget(
                              isUpdate: true,
                              shippingId: shipping.id.toString(),
                              name: shipping.name,
                              description: shipping.description,
                            );
                          },
                        );
                      },
                      image: DefaultImages.changeIcn,
                      title: "edit".tr),
                  slidableActionWidget(
                      onTap: () {
                        if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                          commonToast(type: AppSnackBarType.info, AppConstant.demoString.tr);
                        } else {
                          shippingController.deleteShippingData(shippingId: shipping.id.toString());
                        }
                      },
                      image: DefaultImages.deleteIcn,
                      title: "delete".tr,
                      color: AppColor.cRedText),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? DarkThemeColor.cCardBackground : AppColor.cWhite,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColor.themeGreenColor),
                  boxShadow: [
                    BoxShadow(color: AppColor.cShadow),
                  ],
                ),
                padding: EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                       imageUrl: getImageUrl(shippingController.imageBaseUrl.value + (shipping.imagePath ?? '')),
                       width: 45,
                       height: 45,
                       errorWidget: (context, url, error) => Icon(Icons.local_shipping, size: 45, color: isDark ? Colors.white70 : Colors.grey),
                       fit: BoxFit.cover,
                     ),
                    horizontalSpace(15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                shipping.name ?? '',
                                style: pMedium14.copyWith(color: textColor),
                              ),
                            ],
                          ),
                          verticalSpace(8),
                          Text(
                            shipping.description ?? '',
                            style: pRegular12.copyWith(color: descriptionColor),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

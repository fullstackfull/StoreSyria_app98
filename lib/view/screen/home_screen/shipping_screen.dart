// ignore_for_file: prefer_const_constructors, avoid_print

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

    scrollController.addListener(() {
      if (shippingController.isScroll.value &&
          scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
        shippingController.currantPage.value++;
        shippingController.getShippingData(
            shippingController.currantPage.value);
      }
    });
  }

  getData() {
    shippingController.getShippingData(shippingController.currantPage.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cBackGround,
      appBar: simpleAppBar(title: "Shipping"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonIconButton(
                title: 'Add Shipping',
                iconData: DefaultImages.addCircleIcn,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColor.cBackGround,
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
                "Shipping",
                style: pRegular20,
              ),
              verticalSpace(15),
              Obx(() {
                return Expanded(
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
                                      backgroundColor: AppColor.cBackGround,
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
                                  title: "Edit"),
                              slidableActionWidget(
                                  onTap: () {
                                    if (Prefs.getBool(AppConstant.isDemoMode) == true) {
                                      commonToast(AppConstant.demoString);
                                    } else {
                                      shippingController.deleteShippingData(shippingId: shipping.id.toString());
                                    }
                                  },
                                  image: DefaultImages.deleteIcn,
                                  title: "Delete",
                                  color: AppColor.cRedText),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.cWhite,
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
                                   errorWidget: (context, url, error) => Icon(Icons.local_shipping, size: 45),
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
                                            shipping.name!,
                                            style: pMedium14,
                                          ),
                                        ],
                                      ),
                                      verticalSpace(8),
                                      Text(
                                        shipping.description!,
                                        style: pRegular12,
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
              })
            ],
          ),
        ),
      ),
    );
  }
}

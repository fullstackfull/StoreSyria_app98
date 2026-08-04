// ignore_for_file: must_be_immutable, prefer_const_constructors_in_immutables

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/core/model/view_used_coupon_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/helper.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/screen/order_screen/order_screen.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/core/controller/home_controller/new_coupon_controller.dart';

class CouponDetailScreen extends StatefulWidget {
  final int couponId;

  CouponDetailScreen({super.key, required this.couponId});

  @override
  State<CouponDetailScreen> createState() => _CouponDetailScreenState();
}

class _CouponDetailScreenState extends State<CouponDetailScreen> {
  NewCouponController couponController = Get.put(NewCouponController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  getData() {
    couponController.getUsedCouponData(widget.couponId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: AppColor.cBackGround,
        appBar: simpleAppBar(
          title: "Coupon Detail",
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "NAME",
                          style: pSemiBold12,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "ORDER ID",
                          style: pSemiBold12,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "AMOUNT",
                          style: pSemiBold12,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "DATE",
                          style: pSemiBold12,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: horizontalDivider(),
                  ),
                  Expanded(
                    child: couponController.viewCouponsList.isEmpty
                        ? Center(child: dataNotFoundTextWidget())
                        : ListView.separated(
                            itemCount: couponController.viewCouponsList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              ViewUsedCouponData data = couponController.viewCouponsList[index];
                              return couponDetailWidget(
                                name: data.couponName!,
                                orderId: "#${data.productOrderId}",
                                amount: data.amount.toString(),
                                date: dateFormatted(date: data.dateUsed!, formatType: formatForDateTime(FormatType.date)),
                              );
                            },
                            separatorBuilder: (context, index) => horizontalDivider(),
                          ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget couponDetailWidget({
    required String name,
    required String orderId,
    required String amount,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              name,
              style: pRegular12,
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              orderId,
              style: pRegular12,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              style: pRegular12,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              date,
              style: pRegular12,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

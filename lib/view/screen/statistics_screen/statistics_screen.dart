// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/utils/colors.dart';
import 'package:store_go_app/utils/text_style.dart';
import 'package:store_go_app/view/widget/common_appbar_widget.dart';
import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
import 'package:store_go_app/view/screen/home_screen/home_screen_widget.dart';
import 'package:store_go_app/core/controller/home_controller/statistic_controller.dart';
import 'package:store_go_app/view/screen/statistics_screen/statistics_screen_widget.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

class StatisticsScreen extends StatefulWidget {
  StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsController statisticsController = Get.put(StatisticsController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
    });
  }

  getData() {
    statisticsController.getStaticData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cBackGround,
      appBar: simpleAppBar(title: "Analytics"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            return statisticsController.isDataAvailable.value == true ||
                    statisticsController.staticsDataModel == null
                ? LoadingWidget()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Visitors",
                          style: pRegular20,
                        ),
                        verticalSpace(20),
                        StatisticsVisitorGraph(
                          visitorChart: statisticsController
                              .staticsDataModel!.data!.visitorchart!,
                        ),
                        verticalSpace(20),
                        // titleShowMoreWidget(
                        //   title: "Top 5 URL",
                        //   btnName: "Show more statistics",
                        //   onPresses: () {},
                        // ),
                        statisticsController.topUrlList.isEmpty
                            ? SizedBox()
                            : Text(
                                "Top URL",
                                style: pRegular20,
                              ),
                        verticalSpace(
                            statisticsController.topUrlList.isEmpty ? 0 : 10),
                        statisticsController.topUrlList.isEmpty
                            ? SizedBox()
                            : ListView.builder(
                                itemCount:
                                    statisticsController.topUrlList.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  TopUrl topUrl =
                                      statisticsController.topUrlList[index];
                                  return topUrlWidget(
                                    title: "My Store",
                                    subTitle: topUrl.url!,
                                    total: topUrl.totalClick.toString(),
                                    digit: (index + 1).toString(),
                                    shareFun: () {
                                      onShare(link: '${topUrl.url}');
                                    },
                                  );
                                },
                              ),
                        verticalSpace(20),
                        statisticsController
                                .staticsDataModel!.data!.platform!.isEmpty
                            ? SizedBox()
                            : Text(
                                "Platforms",
                                style: pRegular20,
                              ),
                        statisticsController
                                .staticsDataModel!.data!.platform!.isEmpty
                            ? SizedBox()
                            : verticalSpace(20),
                        statisticsController
                                .staticsDataModel!.data!.platform!.isEmpty
                            ? SizedBox()
                            : PlatformBarChart(
                                list: statisticsController
                                    .staticsDataModel!.data!.platform!),
                        verticalSpace(20),
                        // titleShowMoreWidget(
                        //   title: "Browsers",
                        //   btnName: "Show more statistics",
                        //   onPresses: () {},
                        // ),
                        statisticsController
                                .staticsDataModel!.data!.browser!.isEmpty
                            ? SizedBox()
                            : Text(
                                "Browsers",
                                style: pRegular20,
                              ),
                        verticalSpace(10),
                        statisticsController
                                .staticsDataModel!.data!.browser!.isEmpty
                            ? SizedBox()
                            : BrowsersGraph(
                                isDevice: false,
                                browser: statisticsController
                                    .staticsDataModel!.data!.browser!,
                              ),
                        verticalSpace(20),
                        statisticsController
                                .staticsDataModel!.data!.device!.isEmpty
                            ? SizedBox()
                            : Text(
                                "Device",
                                style: pRegular20,
                              ),
                        verticalSpace(20),
                        statisticsController
                                .staticsDataModel!.data!.device!.isEmpty
                            ? SizedBox()
                            : BrowsersGraph(
                                isDevice: true,
                                device: statisticsController
                                    .staticsDataModel!.data!.device!,
                              ),
                      ],
                    ),
                  );
          }),
        ),
      ),
    );
  }
}

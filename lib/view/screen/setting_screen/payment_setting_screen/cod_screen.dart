// // ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables
//
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:store_go_app/utils/colors.dart';
// import 'package:store_go_app/utils/constant.dart';
// import 'package:store_go_app/utils/images.dart';
// import 'package:store_go_app/utils/prefer.dart';
// import 'package:store_go_app/utils/text_style.dart';
// import 'package:store_go_app/utils/helper.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:store_go_app/view/widget/common_button.dart';
// import 'package:store_go_app/view/widget/common_appbar_widget.dart';
// import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
// import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
// import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
// import 'package:store_go_app/core/controller/setting_controller/payment_setting_controller/cod_controller.dart';
// import 'package:store_go_app/core/controller/setting_controller/payment_setting_controller/payment_setting_controller.dart';
//
// class CODScreen extends StatefulWidget {
//   final String description;
//   final String isCodEnable;
//   final String image;
//   final String currency;
//   final String currencySymbol;
//
//   CODScreen({super.key, required this.description, required this.isCodEnable, required this.image, required this.currency, required this.currencySymbol});
//
//   @override
//   State<CODScreen> createState() => _CODScreenState();
// }
//
// class _CODScreenState extends State<CODScreen> {
//   PaymentSettingController paymentSettingController = Get.find();
//
//   CodController codController = Get.put(CodController());
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.isCodEnable == "on") {
//       codController.isStatus.value = true;
//     } else {
//       codController.isStatus.value = false;
//     }
//     codController.descriptionController.text = widget.description;
//     if (widget.image != '') {
//       codController.networkImage.value = Prefs.getString(AppConstant.imageUrl) + widget.image;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).requestFocus(FocusNode());
//       },
//       child: Scaffold(
//         backgroundColor: AppColor.cBackGround,
//         appBar: simpleAppBar(
//             title: 'Cash on Delivery',
//             isBack: true,
//             label: null, onNewLabelTap: () {  }),
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Obx(() {
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Text(
//                           "Status:",
//                           style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
//                         ),
//                         horizontalSpace(10),
//                         CupertinoSwitch(
//                           value: codController.isStatus.value,
//                           onChanged: (value) {
//                             codController.isStatus.value = value;
//                             if (value == true) {
//                               codController.status.value = 'on';
//                             } else {
//                               codController.status.value = 'off';
//                             }
//                             print("-----------${codController.status.value}");
//                           },
//                           activeColor: AppColor.themeGreenColor,
//                         ),
//                       ],
//                     ),
//                     verticalSpace(10),
//                     AddProductTextField(
//                       controller: codController.descriptionController,
//                       labelText: 'Description',
//                       hintText: 'Cash on Delivery',
//                       maxLines: 6,
//                     ),
//                     verticalSpace(10),
//                     Text(
//                       "Image",
//                       style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
//                     ),
//                     verticalSpace(10),
//                     CommonIconButton(
//                       title: "Choose file here",
//                       iconData: DefaultImages.whiteUploadIcn,
//                       onPressed: () {
//                         codController.pickImages();
//                       },
//                     ),
//                     verticalSpace(15),
//                     SizedBox(
//                       width: 150,
//                       height: 80,
//                       child: codController.imagePath.value == ''
//                           ? CachedNetworkImage(
//                               imageUrl: getImageUrl(codController.networkImage.value),
//                               placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
//                               errorWidget: (context, url, error) => SizedBox(),
//                               fit: BoxFit.cover,
//                             )
//                           : Image.file(File(codController.imagePath.value)),
//                     ),
//                     verticalSpace(25),
//                     CommonButton(
//                       title: "Save",
//                       onPressed: () {
//                         print(codController.descriptionController.text);
//                         if (Prefs.getBool(AppConstant.isDemoMode) == true) {
//                           commonToast(AppConstant.demoString);
//                         } else {
//                           codController.setCODData(
//                             currencyName: widget.currency,
//                             currency: widget.currencySymbol,
//                             status: codController.status.value,
//                             codInfo: codController.descriptionController.text.trim(),
//                             image: codController.imagePath.value,
//                           );
//                         }
//                       },
//                     )
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

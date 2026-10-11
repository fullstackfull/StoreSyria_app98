// // ignore_for_file: must_be_immutable, prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print
//
// import 'dart:io';
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
// import 'package:store_go_app/core/controller/setting_controller/payment_setting_controller/stripe_controller.dart';
//
// class StripeScreen extends StatefulWidget {
//   final String currency;
//   final String currencySymbol;
//
//   StripeScreen({super.key, required this.currency, required this.currencySymbol});
//
//   @override
//   State<StripeScreen> createState() => _StripeScreenState();
// }
//
// class _StripeScreenState extends State<StripeScreen> {
//   StripeController stripeController = Get.put(StripeController());
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       getData();
//     });
//   }
//
//   getData() {
//     stripeController.getStripePaymentData();
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
//             title: "Stripe",
//             label: null,
//             isBack : true,
//             onNewLabelTap: () {  }),
//         body: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Obx(() {
//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         "Status:",
//                         style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
//                       ),
//                       horizontalSpace(10),
//                       CupertinoSwitch(
//                         value: stripeController.isStatus.value,
//                         onChanged: (value) {
//                           stripeController.isStatus.value = value;
//                           if (value == true) {
//                             stripeController.status.value = 'on';
//                           } else {
//                             stripeController.status.value = 'off';
//                           }
//                           print("-----------${stripeController.status.value}");
//                         },
//                         activeColor: AppColor.themeGreenColor,
//                       ),
//                     ],
//                   ),
//                   verticalSpace(10),
//                   AddProductTextField(
//                     controller: stripeController.keyController,
//                     labelText: 'Publishable Key',
//                     hintText: 'pk_test_aLoicAw16w12wxLlmI9uluaf008XMnn2VJ',
//                     obscureText: Prefs.getBool(AppConstant.isDemoMode),
//                     obscuringCharacter: '*',
//                   ),
//                   verticalSpace(10),
//                   AddProductTextField(
//                     controller: stripeController.secretController,
//                     labelText: 'Stripe Secret',
//                     hintText: 'sk_test_Nxr9kmP8BvNr8rPp7TiTvDZr005whVFgmH',
//                     obscureText: Prefs.getBool(AppConstant.isDemoMode),
//                     obscuringCharacter: '*',
//                   ),
//                   verticalSpace(10),
//                   AddProductTextField(
//                     controller: stripeController.descriptionController,
//                     labelText: 'Description',
//                     hintText: 'stripe',
//                     maxLines: 6,
//                   ),
//                   verticalSpace(10),
//                   Text(
//                     "Image",
//                     style: pMedium12.copyWith(color: AppColor.cDarkGreyFont),
//                   ),
//                   verticalSpace(10),
//                   CommonIconButton(
//                     title: "Choose file here",
//                     iconData: DefaultImages.whiteUploadIcn,
//                     onPressed: () {
//                       stripeController.pickImages();
//                     },
//                   ),
//                   verticalSpace(15),
//                   SizedBox(
//                     width: 150,
//                     height: 80,
//                      child: stripeController.imagePath.value == ''
//                          ? CachedNetworkImage(
//                              imageUrl: getImageUrl(stripeController.networkImage.value),
//                        errorWidget: (context, url, error) => SizedBox(),
//                        fit: BoxFit.cover,
//                            )
//                          : Image.file(File(stripeController.imagePath.value)),
//                   ),
//                   verticalSpace(25),
//                   CommonButton(
//                     title: "Save",
//                     onPressed: () {
//                       FocusScope.of(context).requestFocus(FocusNode());
//                       Future.delayed(
//                         Duration(milliseconds: 500),
//                         () {
//                           if (Prefs.getBool(AppConstant.isDemoMode) == true) {
//                             commonToast(AppConstant.demoString);
//                           } else {
//                             stripeController.setStripeTransferData(
//                                 currencyName: widget.currency,
//                                 currency: widget.currencySymbol,
//                                 status: stripeController.status.value,
//                                 bankInfo: stripeController.descriptionController.text.trim(),
//                                 secret: stripeController.secretController.text.trim(),
//                                 key: stripeController.keyController.text.trim(),
//                                 image: stripeController.imagePath.value);
//                           }
//                         },
//                       );
//                     },
//                   )
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

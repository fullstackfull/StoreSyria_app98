// // ignore_for_file: avoid_print
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:store_go_app/config/repository/payment_setting_repository.dart';
// import 'package:store_go_app/utils/base_api.dart';
// import 'package:store_go_app/utils/constant.dart';
// import 'package:store_go_app/utils/images.dart';
// import 'package:store_go_app/utils/prefer.dart';
// import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
// import 'package:store_go_app/view/widget/loading_widget.dart';
// import 'package:http/http.dart' as http;
//
// class StripeController extends GetxController {
//   PaymentSettingRepository paymentSettingRepository =
//       PaymentSettingRepository();
//   TextEditingController keyController = TextEditingController();
//   TextEditingController secretController = TextEditingController();
//   TextEditingController descriptionController = TextEditingController();
//   RxString imagePath = ''.obs;
//   RxString networkImage = DefaultImages.stripeImg.obs;
//
//   RxBool isStatus = true.obs;
//   RxString status = 'on'.obs;
//
//   Future pickImages() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 100,
//         maxHeight: 1000,
//         maxWidth: 1000);
//
//     if (pickedFile != null) {
//       imagePath.value = File(pickedFile.path).path;
//     } else {
//       commonToast("'Nothing is selected'");
//     }
//   }
//
//   getStripePaymentData() async {
//     Loader.showLoader();
//     var response = await paymentSettingRepository.getStripePaymentData();
//     if (response != null) {
//       if (response['status'] == 1) {
//         keyController.text = response['data']['publishable_key'];
//         secretController.text = response['data']['stripe_secret'];
//         descriptionController.text = response['data']['stripe_unfo'];
//         if (response['data']['stripe_image'] != '') {
//               response['data']['stripe_image'];
//         }
//         if (response['data']['is_stripe_enabled'] == 'on') {
//           isStatus.value = true;
//           status.value = response['data']['is_stripe_enabled'];
//         } else {
//           isStatus.value = false;
//           status.value = response['data']['is_stripe_enabled'];
//         }
//       } else {
//         commonToast(response['data']['message']);
//       }
//     }
//     Get.back();
//   }
//
//   setStripeTransferData({
//     required String currencyName,
//     required String currency,
//     required String status,
//     required String bankInfo,
//     required String secret,
//     required String key,
//     required String image,
//   }) async {
//     Loader.showLoader();
//     String url = API.baseUrl + API.stripePaymentUrl;
//     AppLog.d(" URL===> $url");
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//     // R7-N1: do NOT hand-roll the Authorization header here.
//     request.headers.addAll(NetworkHttps.authHeaders());
//     request.fields.addAll({
//       'store_id': Prefs.getStoreID(),
//       'CURRENCY_NAME': currencyName,
//       'CURRENCY': currency,
//       'is_stripe_enabled': status,
//       'stripe_secret': secret,
//       'publishable_key': key,
//       'stripe_unfo': bankInfo,
//     });
//     if (imagePath.value != '') {
//       request.files
//           .add(await http.MultipartFile.fromPath('stripe_image', image));
//     }
//     http.StreamedResponse response = await request.send();
//     print("v statusCode===========>${response.statusCode}");
//     var decodedData = jsonDecode(await response.stream.bytesToString());
//     print("1111===========>$decodedData");
//     if (response.statusCode == 200) {
//       commonToast(decodedData['data']['message']);
//       Get.back();
//     } else {
//       commonToast(decodedData['data']['message']);
//
//       print("${response.reasonPhrase!}.11111111111111111");
//     }
//     Get.back();
//   }
// }

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
// import 'package:store_go_app/view/screen/auth/login_widget.dart';
// import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
// import 'package:store_go_app/view/widget/loading_widget.dart';
// import 'package:http/http.dart' as http;
//
// class BankTransferController extends GetxController {
//   PaymentSettingRepository paymentSettingRepository = PaymentSettingRepository();
//   TextEditingController descriptionController = TextEditingController();
//   RxString imagePath = ''.obs;
//   RxString networkImage = DefaultImages.bankTransferImg.obs;
//   RxBool isStatus = true.obs;
//   RxString status = 'on'.obs;
//
//   Future pickImages() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
//
//     if (pickedFile != null) {
//       imagePath.value = File(pickedFile.path).path;
//     } else {
//       commonToast("'Nothing is selected'");
//     }
//   }
//
//   getBankPaymentData() async {
//     Loader.showLoader();
//     var response = await paymentSettingRepository.getBankPaymentData();
//     if (response != null) {
//       if (response['status'] == 1) {
//         descriptionController.text = response['data']['bank_transfer'];
//         if (response['data']['bank_transfer_image'] != '') {
//         }
//         if (response['data']['is_bank_transfer_enabled'] == 'on') {
//           isStatus.value = true;
//           status.value = response['data']['is_bank_transfer_enabled'];
//         } else {
//           isStatus.value = false;
//           status.value = response['data']['is_bank_transfer_enabled'];
//         }
//       } else {
//         commonToast(response['data']['message']);
//       }
//     }
//     Get.back();
//   }
//
//   setBankTransferData({
//     required String currencyName,
//     required String currency,
//     required String status,
//     required String bankInfo,
//     required String image,
//   }) async {
//     Loader.showLoader();
//     String url = API.baseUrl + API.bankPaymentUrl;
//     print(" URL===> $url");
//     print("authHeaders===>${Prefs.getToken()}");
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//     request.headers.addAll({
//       "Authorization": 'Bearer ${Prefs.getToken()}',
//       HttpHeaders.contentTypeHeader: 'application/json',
//       HttpHeaders.cacheControlHeader: "no-cache",
//     });
//     request.fields.addAll({'store_id': Prefs.getStoreID(), 'CURRENCY_NAME': currencyName, 'CURRENCY': currency, 'is_bank_transfer_enabled': status, 'bank_transfer': bankInfo});
//     if (imagePath.value != '') {
//       request.files.add(await http.MultipartFile.fromPath('bank_transfer_image', image));
//     }
//     http.StreamedResponse response = await request.send();
//     print("v statusCode===========>${response.statusCode}");
//     var decodedData = jsonDecode(await response.stream.bytesToString());
//     print("1111===========>$decodedData");
//     if (response.statusCode == 200) {
//       commonToast(decodedData['data']['message']);
//       Get.back();
//     } else if (response.statusCode == 401) {
//       await Prefs.clear();
//       Get.offAll(() => NormalLoginWidget());
//     } else {
//       commonToast(decodedData['data']['message']);
//
//       print("${response.reasonPhrase!}.11111111111111111");
//     }
//     Get.back();
//   }
// }

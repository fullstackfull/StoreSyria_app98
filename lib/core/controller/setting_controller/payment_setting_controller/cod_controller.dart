// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:store_go_app/config/repository/payment_setting_repository.dart';
// import 'package:store_go_app/utils/base_api.dart';
// import 'package:store_go_app/utils/images.dart';
// import 'package:store_go_app/utils/prefer.dart';
// import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';
// import 'package:store_go_app/view/widget/loading_widget.dart';
//
// class CodController extends GetxController {
//   PaymentSettingRepository paymentSettingRepository = PaymentSettingRepository();
//   TextEditingController descriptionController = TextEditingController();
//   RxString imagePath = ''.obs;
//   RxString networkImage = DefaultImages.codImg.obs;
//   RxBool isStatus = true.obs;
//   RxString status = 'on'.obs;
//   RxString codDescription = ''.obs;
//   RxString codImage = ''.obs;
//   RxString isCodEnabled = 'on'.obs;
//
//   final TextEditingController currencyController = TextEditingController();
//   final TextEditingController currencySymbolController = TextEditingController();
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
//   setCODData({
//     required String currencyName,
//     required String currency,
//     required String status,
//     required String codInfo,
//     required String image,
//   }) async {
//     Loader.showLoader();
//     String url = API.baseUrl + API.codPaymentUrl;
//     AppLog.d(" URL===> $url");
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//     // R7-N1: do NOT hand-roll the Authorization header here.
//     request.headers.addAll(NetworkHttps.authHeaders());
//     request.fields.addAll({
//       'store_id': Prefs.getStoreID(),
//       'CURRENCY_NAME': currencyName,
//       'CURRENCY': currency,
//       'is_cod_enabled': status,
//       'cod_info': codInfo
//     });
// if(imagePath.value!=''){
//   request.files.add(await http.MultipartFile.fromPath('cod_image', image));
// }
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
//
//   Future<void> getCodPaymentData() async {
//     Loader.showLoader();
//
//     try {
//       final response =
//       await paymentSettingRepository.getCodPaymentData();
//
//       if (response != null) {
//         final data = response.data;
//
//         if (data != null && data['status'] == 1) {
//           final responseData =
//           data['data'] as Map<String, dynamic>?;
//
//           if (responseData != null) {
//             currencyController.text =
//                 responseData['CURRENCY_NAME']?.toString() ?? '';
//
//             currencySymbolController.text =
//                 responseData['CURRENCY']?.toString() ?? '';
//
//             codDescription.value = responseData['cod_info']?.toString() ?? '';
//
//             isCodEnabled.value = responseData['is_cod_enabled']?.toString() ?? 'on';
//
//             codImage.value = responseData['cod_image']?.toString() ?? '';
//           }
//         } else {
//           commonToast(
//             data?['message']?.toString() ??
//                 'Something went wrong',
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint(
//         'getCodPaymentData ERROR: $e',
//       );
//
//       commonToast(
//         'Something went wrong',
//       );
//     } finally {
//       if (Get.isDialogOpen == true) {
//         Get.back();
//       }
//     }
//   }
// }

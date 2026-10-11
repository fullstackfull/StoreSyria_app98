// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_go_app/config/repository/setting_repository.dart';
import 'package:store_go_app/core/model/email_setting_model.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class EmailSettingController extends GetxController {
  SettingRepository settingRepository = SettingRepository();
  TextEditingController mailDriver = TextEditingController();
  TextEditingController mailHost = TextEditingController();
  TextEditingController mailPort = TextEditingController();
  TextEditingController mailUserName = TextEditingController();
  TextEditingController mailPassword = TextEditingController();
  TextEditingController mailEncryption = TextEditingController();
  TextEditingController mailFromAddress = TextEditingController();
  TextEditingController mailFromName = TextEditingController();
  TextEditingController emailController = TextEditingController();
  EmailSettingModel? emailSettingModel;
  EmailSetting? emailSetting;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  saveEmailSettingData({
    required String mailDriver,
    required String mailHost,
    required String mailPort,
    required String mailUserName,
    required String mailPassword,
    required String mailEncryption,
    required String mailFromAddress,
    required String mailFromName,
  }) async {
    isLoading.value = true;
    var data = {
      'store_id': Prefs.getStoreID(),
      'mail_driver': mailDriver,
      'mail_host': mailHost,
      'mail_port': mailPort,
      'mail_username': mailUserName,
      'mail_password': mailPassword,
      'mail_encryption': mailEncryption,
      'mail_from_address': mailFromAddress,
      'mail_from_name': mailFromName,
    };
    final response = await settingRepository.saveEmailSettingData(data: data);
    isLoading.value = false;
    response.fold(
      onSuccess: (data) {
        commonToast(type: AppSnackBarType.success, data['data']['message'] ?? 'Success');
      },
      onFailure: (reason,message,errors) {
        errorMessage.value = message ?? 'Error saving email setting';
        commonToast(type: AppSnackBarType.error, message ?? 'Error saving email setting');
      },
    );
  }

  getEmailSettingData() async {
    isLoading.value = true;
    final response = await settingRepository.getEmailSettingData();
    isLoading.value = false;
    response.fold(
      onSuccess: (data) {
        if(data['status'] == 1) {
          emailSettingModel = EmailSettingModel.fromJson(data);
          emailSetting = emailSettingModel!.data;
          mailDriver.text = emailSetting?.mailDriver ?? '';
          mailHost.text = emailSetting?.mailHost ?? '';
          mailPort.text = emailSetting?.mailPort ?? '';
          mailUserName.text = emailSetting?.mailUserName ?? '';
          mailPassword.text = emailSetting?.mailPassword ?? '';
          mailEncryption.text = emailSetting?.mailEncryption ?? '';
          mailFromAddress.text = emailSetting?.mailFromAddress ?? '';
          mailFromName.text = emailSetting?.mailFromName ?? '';
        } else {
          commonToast(type: AppSnackBarType.error, data['data']['message'] ?? 'Failed');
        }
      },
      onFailure: (reason,message,errors) {
        errorMessage.value = message ?? 'Error loading email setting';
        commonToast(type: AppSnackBarType.error, message ?? 'Error loading email setting');
      },
    );
  }

  sendTextEmailData({required String email}) async {
    isLoading.value = true;
    final response = await settingRepository.setTestMailData(email: email);
    isLoading.value = false;
    response.fold(
      onSuccess: (data) {
        commonToast(type: AppSnackBarType.success, data['data']['message'] ?? 'Success');
      },
      onFailure: (reason,message,errors) {
        errorMessage.value = message ?? 'Error sending email';
        commonToast(type: AppSnackBarType.error, message ?? 'Error sending email');
      },
    );
  }

  @override
  void onClose() {
    mailDriver.dispose();
    mailHost.dispose();
    mailPort.dispose();
    mailUserName.dispose();
    mailPassword.dispose();
    mailEncryption.dispose();
    mailFromAddress.dispose();
    mailFromName.dispose();
    emailController.dispose();
    super.onClose();
  }
}
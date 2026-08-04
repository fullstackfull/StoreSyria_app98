// ignore_for_file: prefer_collection_literals, unnecessary_this

class EmailSettingModel {
  int? status;
  String? message;
  EmailSetting? data;

  EmailSettingModel({this.status, this.message, this.data});

  EmailSettingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? EmailSetting.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class EmailSetting {
  String? mailDriver;
  String? mailHost;
  String? mailPort;
  String? mailUserName;
  String? mailPassword;
  String? mailEncryption;
  String? mailFromAddress;
  String? mailFromName;

  EmailSetting(
      { this.mailDriver,
        this.mailHost,
        this.mailPort,
        this.mailUserName,
        this.mailPassword,
        this.mailEncryption,
        this.mailFromAddress,
        this.mailFromName});

  EmailSetting.fromJson(Map<String, dynamic> json) {
    mailDriver = json['MAIL_DRIVER'];
    mailHost = json['MAIL_HOST'];
    mailPort = json['MAIL_PORT'];
    mailUserName = json['MAIL_USERNAME'];
    mailPassword = json['MAIL_PASSWORD'];
    mailEncryption = json['MAIL_ENCRYPTION'];
    mailFromName = json['MAIL_FROM_NAME'];
    mailFromAddress = json['MAIL_FROM_ADDRESS'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['MAIL_DRIVER'] = this.mailDriver;
    data['MAIL_HOST'] = this.mailHost;
    data['MAIL_PORT'] = this.mailPort;
    data['MAIL_USERNAME'] = this.mailUserName;
    data['MAIL_PASSWORD'] = this.mailPassword;
    data['MAIL_ENCRYPTION'] = this.mailEncryption;
    data['MAIL_FROM_NAME'] = this.mailFromName;
    data['MAIL_FROM_ADDRESS'] = this.mailFromAddress;
    return data;
  }
}

import 'package:store_go_app/network/result.dart';

class ImageBaseUrlModel {
  ImageBaseUrlModel({
      this.status, 
      this.message, 
      this.data,});

  ImageBaseUrlModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] is Map ? ImageUrlData.fromJson(jsonMap(json['data'])) : null;
  }
  int? status;
  String? message;
  ImageUrlData? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }

}
class ImageUrlData {
  ImageUrlData({
    this.imageUrl,
    this.paymentUrl,});

  ImageUrlData.fromJson(dynamic json) {
    imageUrl = json['image_url'];
    paymentUrl = json['payment_url'];
  }
  String ? imageUrl;
  String ? paymentUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['image_url'] = imageUrl;
    map['payment_url'] = paymentUrl;
    return map;
  }

}
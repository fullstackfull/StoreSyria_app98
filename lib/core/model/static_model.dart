// ignore_for_file: prefer_collection_literals, unnecessary_this

class StaticsDataModel {
  int? status;
  String? message;
  StaticData? data;

  StaticsDataModel({this.status, this.message, this.data});

  StaticsDataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? StaticData.fromJson(json['data']) : null;
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

class StaticData {
  List<VisitorChartData>? visitorchart;
  List<TopUrl>? topurl;
  List<PlatformData>? platform;
  List<BrowserData>? browser;
  List<DeviceData>? device;

  StaticData(
      {this.visitorchart,
      this.topurl,
      this.platform,
      this.browser,
      this.device});

  StaticData.fromJson(Map<String, dynamic> json) {
    if (json['visitorchart'] != null && json['visitorchart'] is List) {
      visitorchart = <VisitorChartData>[];
      json['visitorchart'].forEach((v) {
        visitorchart!.add(VisitorChartData.fromJson(v));
      });
    }
    if (json['topurl'] != null && json['topurl'] is List) {
      topurl = <TopUrl>[];
      json['topurl'].forEach((v) {
        topurl!.add(TopUrl.fromJson(v));
      });
    }
    if (json['platform'] != null && json['platform'] is List) {
      platform = <PlatformData>[];
      json['platform'].forEach((v) {
        platform!.add(PlatformData.fromJson(v));
      });
    }
    if (json['browser'] != null && json['browser'] is List) {
      browser = <BrowserData>[];
      json['browser'].forEach((v) {
        browser!.add(BrowserData.fromJson(v));
      });
    }
    if (json['device'] != null && json['device'] is List) {
      device = <DeviceData>[];
      json['device'].forEach((v) {
        device!.add(DeviceData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.visitorchart != null) {
      data['visitorchart'] = this.visitorchart!.map((v) => v.toJson()).toList();
    }
    if (this.topurl != null) {
      data['topurl'] = this.topurl!.map((v) => v.toJson()).toList();
    }
    if (this.platform != null) {
      data['platform'] = this.platform!.map((v) => v.toJson()).toList();
    }
    if (this.browser != null) {
      data['browser'] = this.browser!.map((v) => v.toJson()).toList();
    }
    if (this.device != null) {
      data['device'] = this.device!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VisitorChartData {
  String? date;
  int? pageview;
  int? uniquePageview;

  VisitorChartData({this.date, this.pageview, this.uniquePageview});

  VisitorChartData.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    pageview = json['pageview'];
    uniquePageview = json['unique_pageview'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['date'] = this.date;
    data['pageview'] = this.pageview;
    data['unique_pageview'] = this.uniquePageview;
    return data;
  }
}

class TopUrl {
  double? totalClick;
  String? url;

  TopUrl({
    this.totalClick,
    this.url,
  });

  TopUrl.fromJson(Map<String, dynamic> json) {
    final value = json['total_click'];

    totalClick = value is num
        ? value.toDouble()
        : null;

    url = json['url']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'total_click': totalClick,
      'url': url,
    };
  }
}

class PlatformData {
  String? platform;
  int? data;
  String? colour;

  PlatformData({this.platform, this.data, this.colour});

  PlatformData.fromJson(Map<String, dynamic> json) {
    platform = json['platform'];
    data = json['data'];
    colour = json['colour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['platform'] = this.platform;
    data['data'] = this.data;
    data['colour'] = this.colour;
    return data;
  }
}

class BrowserData {
  String? browser;
  int? data;
  String? colour;

  BrowserData({this.browser, this.data, this.colour});

  BrowserData.fromJson(Map<String, dynamic> json) {
    browser = json['browser'];
    data = json['data'];
    colour = json['colour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['browser'] = this.browser;
    data['data'] = this.data;
    data['colour'] = this.colour;
    return data;
  }
}

class DeviceData {
  String? device;
  int? data;
  String? colour;

  DeviceData({this.device, this.data, this.colour});

  DeviceData.fromJson(Map<String, dynamic> json) {
    device = json['device'];
    data = json['data'];
    colour = json['colour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['device'] = this.device;
    data['data'] = this.data;
    data['colour'] = this.colour;
    return data;
  }
}

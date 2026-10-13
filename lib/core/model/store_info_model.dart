import 'package:store_go_app/network/result.dart';

class StoreInfoResponse {
  final String? status;
  final String? message;
  final StoreInfoData? data;

  StoreInfoResponse({
    this.status,
    this.message,
    this.data,
  });

  factory StoreInfoResponse.fromJson(Map<String, dynamic> json) {
    return StoreInfoResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map ? StoreInfoData.fromJson(jsonMap(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class StoreInfoData {
  final Store? store;
  final Owner? owner;
  final Address? address;
  final Media? media;
  final SocialMedia? socialMedia;
  final StoreSettings? settings;

  StoreInfoData({
    this.store,
    this.owner,
    this.address,
    this.media,
    this.socialMedia,
    this.settings,
  });

  factory StoreInfoData.fromJson(Map<String, dynamic> json) {
    return StoreInfoData(
      store: json['store'] is Map ? Store.fromJson(jsonMap(json['store']))
          : null,
      owner: json['owner'] is Map ? Owner.fromJson(jsonMap(json['owner']))
          : null,
      address: json['address'] is Map ? Address.fromJson(jsonMap(json['address']))
          : null,
      media: json['media'] is Map ? Media.fromJson(jsonMap(json['media']))
          : null,
      socialMedia: json['social_media'] is Map ? SocialMedia.fromJson(jsonMap(json['social_media']))
          : null,
      settings: json['settings'] is Map ? StoreSettings.fromJson(jsonMap(json['settings']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store': store?.toJson(),
      'owner': owner?.toJson(),
      'address': address?.toJson(),
      'media': media?.toJson(),
      'social_media': socialMedia?.toJson(),
      'settings': settings?.toJson(),
    };
  }
}

class Store {
  final int? id;
  final String? name;
  final String? slug;
  final String? email;
  final String? defaultLanguage;
  final String? storeUrl;
  final String? createdAt;

  Store({
    this.id,
    this.name,
    this.slug,
    this.email,
    this.defaultLanguage,
    this.storeUrl,
    this.createdAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      email: json['email']?.toString(),
      defaultLanguage: json['default_language']?.toString(),
      storeUrl: json['store_url']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'email': email,
      'default_language': defaultLanguage,
      'store_url': storeUrl,
      'created_at': createdAt,
    };
  }
}

class Owner {
  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? createdAt;

  Owner({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.createdAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'created_at': createdAt,
    };
  }
}

class Address {
  final String? storeAddress;
  final String? storeCity;
  final String? storeState;
  final String? storeZipcode;
  final String? storeCountry;
  final String? fullAddress;

  Address({
    this.storeAddress,
    this.storeCity,
    this.storeState,
    this.storeZipcode,
    this.storeCountry,
    this.fullAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      storeAddress: json['store_address']?.toString(),
      storeCity: json['store_city']?.toString(),
      storeState: json['store_state']?.toString(),
      storeZipcode: json['store_zipcode']?.toString(),
      storeCountry: json['store_country']?.toString(),
      fullAddress: json['full_address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_address': storeAddress,
      'store_city': storeCity,
      'store_state': storeState,
      'store_zipcode': storeZipcode,
      'store_country': storeCountry,
      'full_address': fullAddress,
    };
  }
}

class Media {
  final String? invoiceLogo;
  final String? storeImage;

  Media({
    this.invoiceLogo,
    this.storeImage,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      invoiceLogo: json['invoice_logo']?.toString(),
      storeImage: json['store_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_logo': invoiceLogo,
      'store_image': storeImage,
    };
  }
}

class SocialMedia {
  final SocialLink? facebook;
  final SocialLink? twitter;
  final SocialLink? instagram;
  final SocialLink? telegram;
  final SocialLink? whatsapp;

  SocialMedia({
    this.facebook,
    this.telegram,
    this.whatsapp,
    this.twitter,
    this.instagram,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      facebook: json['facebook'] is Map ? SocialLink.fromJson(jsonMap(json['facebook']))
          : null,
      twitter: json['twitter'] is Map ? SocialLink.fromJson(jsonMap(json['twitter']))
          : null,
      instagram: json['instagram'] is Map ? SocialLink.fromJson(jsonMap(json['instagram']))
          : null,
      whatsapp: json['whatsapp'] is Map ? SocialLink.fromJson(jsonMap(json['whatsapp']))
          : null,
      telegram: json['telegram'] is Map ? SocialLink.fromJson(jsonMap(json['telegram']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook?.toJson(),
      'twitter': twitter?.toJson(),
      'instagram': instagram?.toJson(),
      'whatsapp': whatsapp?.toJson(),
    };
  }
}

class SocialLink {
  final String? link;
  final String? icon;

  SocialLink({
    this.link,
    this.icon,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      link: json['link']?.toString(),
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link': link,
      'icon': icon,
    };
  }
}

class StoreSettings {
  final String? currencyName;
  final String? currencyFormat;
  final String? siteRtl;
  final String? dateFormat;
  final String? timezone;

  StoreSettings({
    this.currencyName,
    this.currencyFormat,
    this.siteRtl,
    this.dateFormat,
    this.timezone,
  });

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    return StoreSettings(
      currencyName: json['currency_name']?.toString(),
      currencyFormat: json['currency_format']?.toString(),
      siteRtl: json['site_rtl']?.toString(),
      dateFormat: json['date_format']?.toString(),
      timezone: json['timezone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency_name': currencyName,
      'currency_format': currencyFormat,
      'site_rtl': siteRtl,
      'date_format': dateFormat,
      'timezone': timezone,
    };
  }
}

class UpdateStoreRequest {
  final String storeName;
  final String storeEmail;
  final String ownerName;
  final String storeSlug;
  final String ownerMobile;
  final String storeAddress;
  final String storeCity;
  final String storeState;
  final String storeZipcode;
  final String storeCountry;
  final String customStoreUrl;

  /// Local file paths
  final String invoiceLogo;
  final String storeImage;

  final List<SocialMediaRequest> socialMedia;

  UpdateStoreRequest({
    required this.storeName,
    required this.storeEmail,
    required this.ownerName,
    required this.storeSlug,
    required this.ownerMobile,
    required this.storeAddress,
    required this.storeCity,
    required this.storeState,
    required this.storeZipcode,
    required this.storeCountry,
    required this.customStoreUrl,
    this.invoiceLogo = '',
    this.storeImage = '',
    this.socialMedia = const [],
  });

  /// Normal form-data fields
  Map<String, String> get fields {
    final data = <String, String>{
      'store_name': storeName,
      'store_email': storeEmail,
      'owner_name': ownerName,
      'store_slug': storeSlug,
      'owner_mobile': ownerMobile,
      'store_address': storeAddress,
      'store_city': storeCity,
      'store_state': storeState,
      'store_zipcode': storeZipcode,
      'store_country': storeCountry,
      'custom_store_url': customStoreUrl,
    };

    for (int i = 0; i < socialMedia.length; i++) {
      final social = socialMedia[i];

      data['social_media[$i][platform]'] = social.platform;
      data['social_media[$i][link]'] = social.link;
      data['social_media[$i][icon]'] = social.icon;
    }

    return data;
  }

  /// Multipart files
  Map<String, String> get files {
    final data = <String, String>{};

    if (invoiceLogo.isNotEmpty) {
      data['invoice_logo'] = invoiceLogo;
    }

    if (storeImage.isNotEmpty) {
      data['store_image'] = storeImage;
    }

    return data;
  }
}

class SocialMediaRequest {
  final String platform;
  final String link;
  final String icon;

  SocialMediaRequest({
    required this.platform,
    required this.link,
    required this.icon,
  });
}

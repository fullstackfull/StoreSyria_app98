class LanguageResponse {
  final int status;
  final String message;
  final LanguageData data;

  LanguageResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LanguageResponse.fromJson(Map<String, dynamic> json) {
    return LanguageResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: LanguageData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class LanguageData {
  final int storeId;
  final String storeName;
  final List<Language> languages;
  final String currentLanguage;

  LanguageData({
    required this.storeId,
    required this.storeName,
    required this.languages,
    required this.currentLanguage,
  });

  factory LanguageData.fromJson(Map<String, dynamic> json) {
    return LanguageData(
      storeId: json['store_id'] ?? 0,
      storeName: json['store_name'] ?? '',
      languages: (json['languages'] as List?)
          ?.map((e) => Language.fromJson(e))
          .toList() ??
          [],
      currentLanguage: json['current_language'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'store_name': storeName,
      'languages': languages.map((e) => e.toJson()).toList(),
      'current_language': currentLanguage,
    };
  }
}

class Language {
  final String code;
  final String name;
  final String flag;

  Language({
    required this.code,
    required this.name,
    required this.flag,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      flag: json['flag'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'flag': flag,
    };
  }
}
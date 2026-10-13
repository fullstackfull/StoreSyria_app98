import 'package:store_go_app/network/result.dart';

class CurrentPlanResponse {
  final int maxPrice;
  final int status;
  final String message;
  final CurrentPlanData data;

  CurrentPlanResponse({
    required this.maxPrice,
    required this.status,
    required this.message,
    required this.data,
  });

  factory CurrentPlanResponse.fromJson(Map<String, dynamic> json) {
    return CurrentPlanResponse(
      maxPrice: json['max_price'] ?? 0,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: CurrentPlanData.fromJson(jsonMap(json['data'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_price': maxPrice,
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class CurrentPlanData {
  final int storeId;
  final Plan currentPlan;
  final CurrentUserPlan currentUserPlan;

  CurrentPlanData({
    required this.storeId,
    required this.currentPlan,
    required this.currentUserPlan,
  });

  factory CurrentPlanData.fromJson(Map<String, dynamic> json) {
    return CurrentPlanData(
      storeId: json['store_id'] ?? 0,
      currentPlan: Plan.fromJson(jsonMap(json['current_plan'])),
      currentUserPlan:
      CurrentUserPlan.fromJson(jsonMap(json['current_user_plan'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'current_plan': currentPlan.toJson(),
      'current_user_plan': currentUserPlan.toJson(),
    };
  }
}

class Plan {
  final int id;
  final String name;
  final num price;
  final String currency;
  final String currencyName;
  final String duration;
  final String durationText;
  final String priceDisplay;
  final PlanLimits limits;
  final PlanFeatures features;
  final bool hasTrial;
  final int trialDays;
  final String description;
  final PlanStatus planStatus;
  final UserSubscription userSubscription;

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.currencyName,
    required this.duration,
    required this.durationText,
    required this.priceDisplay,
    required this.limits,
    required this.features,
    required this.hasTrial,
    required this.trialDays,
    required this.description,
    required this.planStatus,
    required this.userSubscription,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? '',
      currencyName: json['currency_name'] ?? '',
      duration: json['duration'] ?? '',
      durationText: json['duration_text'] ?? '',
      priceDisplay: json['price_display'] ?? '',
      limits: PlanLimits.fromJson(jsonMap(json['limits'])),
      features: PlanFeatures.fromJson(jsonMap(json['features'])),
      hasTrial: json['has_trial'] ?? false,
      trialDays: json['trial_days'] ?? 0,
      description: json['description'] ?? '',
      planStatus: PlanStatus.fromJson(jsonMap(json['plan_status'])),
      userSubscription:
      UserSubscription.fromJson(jsonMap(json['user_subscription'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'currency_name': currencyName,
      'duration': duration,
      'duration_text': durationText,
      'price_display': priceDisplay,
      'limits': limits.toJson(),
      'features': features.toJson(),
      'has_trial': hasTrial,
      'trial_days': trialDays,
      'description': description,
      'plan_status': planStatus.toJson(),
      'user_subscription': userSubscription.toJson(),
    };
  }
}

class PlanLimits {
  final PlanLimit products;
  final PlanLimit stores;
  final PlanLimit users;

  PlanLimits({
    required this.products,
    required this.stores,
    required this.users,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      products: PlanLimit.fromJson(jsonMap(json['products'])),
      stores: PlanLimit.fromJson(jsonMap(json['stores'])),
      users: PlanLimit.fromJson(jsonMap(json['users'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.toJson(),
      'stores': stores.toJson(),
      'users': users.toJson(),
    };
  }
}

class PlanLimit {
  final int max;
  final int used;
  final int remaining;
  final double percentage;

  PlanLimit({
    required this.max,
    required this.used,
    required this.remaining,
    required this.percentage,
  });

  factory PlanLimit.fromJson(Map<String, dynamic> json) {
    return PlanLimit(
      max: json['max'] ?? 0,
      used: json['used'] ?? 0,
      remaining: json['remaining'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max': max,
      'used': used,
      'remaining': remaining,
      'percentage': percentage,
    };
  }
}

class PlanFeatures {
  final bool customDomain;
  final bool subDomain;
  final bool chatgpt;
  final bool pwa;
  final bool shippingMethod;
  final bool enableTax;
  final String storageLimit;

  PlanFeatures({
    required this.customDomain,
    required this.subDomain,
    required this.chatgpt,
    required this.pwa,
    required this.shippingMethod,
    required this.enableTax,
    required this.storageLimit,
  });

  factory PlanFeatures.fromJson(Map<String, dynamic> json) {
    return PlanFeatures(
      customDomain: json['custom_domain'] ?? false,
      subDomain: json['sub_domain'] ?? false,
      chatgpt: json['chatgpt'] ?? false,
      pwa: json['pwa'] ?? false,
      shippingMethod: json['shipping_method'] ?? false,
      enableTax: json['enable_tax'] ?? false,
      storageLimit: json['storage_limit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custom_domain': customDomain,
      'sub_domain': subDomain,
      'chatgpt': chatgpt,
      'pwa': pwa,
      'shipping_method': shippingMethod,
      'enable_tax': enableTax,
      'storage_limit': storageLimit,
    };
  }
}

class PlanStatus {
  final String status;
  final bool isExpired;
  final String planExpireDate;
  final int daysRemaining;
  final String expireMessage;

  PlanStatus({
    required this.status,
    required this.isExpired,
    required this.planExpireDate,
    required this.daysRemaining,
    required this.expireMessage,
  });

  factory PlanStatus.fromJson(Map<String, dynamic> json) {
    return PlanStatus(
      status: json['status'] ?? '',
      isExpired: json['is_expired'] ?? false,
      planExpireDate: json['plan_expire_date'] ?? '',
      daysRemaining: json['days_remaining'] ?? 0,
      expireMessage: json['expire_message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'is_expired': isExpired,
      'plan_expire_date': planExpireDate,
      'days_remaining': daysRemaining,
      'expire_message': expireMessage,
    };
  }
}

class UserSubscription {
  final bool isCurrentPlan;
  final String planExpireDate;
  final String? trialExpireDate;
  final bool isTrialPlan;
  final bool hasRequestedPlan;

  UserSubscription({
    required this.isCurrentPlan,
    required this.planExpireDate,
    this.trialExpireDate,
    required this.isTrialPlan,
    required this.hasRequestedPlan,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      isCurrentPlan: json['is_current_plan'] ?? false,
      planExpireDate: json['plan_expire_date'] ?? '',
      trialExpireDate: json['trial_expire_date'],
      isTrialPlan: json['is_trial_plan'] ?? false,
      hasRequestedPlan: json['has_requested_plan'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_current_plan': isCurrentPlan,
      'plan_expire_date': planExpireDate,
      'trial_expire_date': trialExpireDate,
      'is_trial_plan': isTrialPlan,
      'has_requested_plan': hasRequestedPlan,
    };
  }
}

class CurrentUserPlan {
  final String planId;
  final int trialPlan;
  final String requestedPlan;

  CurrentUserPlan({
    required this.planId,
    required this.trialPlan,
    required this.requestedPlan,
  });

  factory CurrentUserPlan.fromJson(Map<String, dynamic> json) {
    return CurrentUserPlan(
      planId: json['plan_id']?.toString() ?? '',
      trialPlan: json['trial_plan'] ?? 0,
      requestedPlan: json['requested_plan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'trial_plan': trialPlan,
      'requested_plan': requestedPlan,
    };
  }
}
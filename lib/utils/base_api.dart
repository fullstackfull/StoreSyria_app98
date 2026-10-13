
class API {
  static String baseUrl = "https://storesyria.com/api/admin";
  //static String baseUrl = "https://designer-railway-lyrically.ngrok-free.dev/api/admin";
  static String loginUrl = '/adminlogin';
  static String logoutUrl = '/adminlogout';
  static String dashboardUrl = '/dashboard';

  static String imageBaseUrl = '/base_url';
  static String storeIdUrl = '?store_id=';
  static String andStoreIdUrl = '&store_id=';
  static const String andStatusUrl = "&delivered_status=";
  static const String andFromDateUrl = "&from_date=";
  static const String andToDateUrl = "&to_date=";
  static String categoryListUrl = '/categorylist';
  static String createProductUrl = '/createproduct';
  static String productListUrl = '/productlist';
  static String deleteProductListUrl = '/deleteproduct';
  static String searchProductListUrl = '/searchproduct';
  static String viewProductUrl = '/viewproduct';

  static String productIdUrl = '&product_id=';

  static String orderListUrl = '/orderlist';
  static String couponListUrl = '/couponlist';
  static String shippingListUrl = '/shippinglist';
  static String taxListUrl = '/taxlist';
  static String viewOrderUrl = '/vieworder';
  static String deleteOrderUrl = '/deleteorder';

  static String orderIdUrl = '&order_id=';

  static String addCategoryUrl = '/addcategory';
  static String updateCategoryUrl = '/updatecategory';
  static String deleteCategoryUrl = '/deletecategory';
  static String mainCategoryUrl = '&maincategory_id=';
  static String categoryIdUrl = '&category_id=';
  static String generateCodeUrl = '/generatecode';
  static String addCouponUrl = '/addcoupon';
  static String updateCouponUrl = '/updatecoupon';
  static String deleteCouponUrl = '/deletecoupon';

  static String couponIdUrl = '&coupon_id=';

  static String addShippingUrl = '/addshipping';
  static String updateShippingUrl = '/updateshipping';
  static String deleteShippingUrl = '/deleteshipping';

  static String shippingIdUrl = '&shipping_id=';

  static String addTaxUrl = '/addtax';
  static String updateTaxUrl = '/updatetax';
  static String deleteTaxUrl = '/deletetax';
  static String taxIdUrl = '&tax_id=';
  static String searchDataUrl = '/searchdata';
  static String deleteProductUrl = '/deleteproduct';
  static String addProductUrl = '/addproduct';

  static String pageUrl = '?page=';
  static String andPageUrl = '&page=';

  // static String createReviewUrl = '/createreview';
  static String addReviewUrl = '/addreview';
  static String updateReviewUrl = '/updatereview';
  static String reviewListUrl = '/reviewlist';
  // static String reviewStatusUrl = '/reviewstatus';
  static String deleteReviewUrl = '/deletereview/';

  static String staticsDataUrl = '/staticsdata';
  static String editProfileUrl = '/editprofile';
  static String updatePasswordUrl = '/updatepassword';
  static String emailSettingUrl = '/emailsetting';
  static String getEmailSettingUrl = '/getemailsetting';
  static String getLoyaltySettingUrl = '/getloyalitysetting';
  static String loyaltySettingUrl = '/loyalitysetting';
  // static String getCodPaymentUrl = '/get-cod-payment';
  // static String codPaymentUrl = '/cod-payment';
  // static String getBankPaymentUrl = '/get-bank-payment';
  // static String bankPaymentUrl = '/bank-payment';
  // static String getStripePaymentUrl = '/get-stripe-payment';
  // static String stripePaymentUrl = '/stripe-payment';
  static String testMailUrl = '/testmail';
  static String changeStoreUrl = '/changestore';
  static String viewUsedCouponUrl = '/view-used-coupon';
  static String updateProductUrl = '/updateproduct';
  static String deleteStoreUrl = '/deletestore';
  static String fcmTokenUrl = '/store/fcm-token';
  static String notificationUrl = '/notification';

  // new
  static String customersUrl = '/customerlist';
  static String addCustomerUrl = '/AddCustomer';
  static String deleteCustomerUrl = '/destroyCustomer';
  static String customerIdUrl = '?customer_id=';
  static String customerOrdersUrl = '/customer/orders';

  static String topOrdersUrl = '/Top_orders';
  static String languagesUrl = '/getAvailableLanguages';
  static String currenciesUrl = '/getCurrenciesApi';
  static String createOrderUrl = '/createOrderViaApi';
  static String changeLanguageUrl = '/updateStoreLanguage';
  static String changeCurrencyUrl = '/updateCurrencyApi';
  static String getStoreInfoUrl = '/getStoreInfo';
  static String getStoreCurrencyLangUrl = '/getCurrentLanguageAndCurrency';
  static String getCurrencyRatesUrl = '/get-currency-rates';
  static String toggleCurrencyStatusUrl = '/toggle-currency-status';
  static String updateCurrencyRateUrl = '/update-currency-rate';

  //wallet
  static String walletUrl = '/wallet/transactions';
  static String addBalanceUrl = '/wallet/add-balance';
  static String deductBalanceUrl = '/wallet/deduct-balance';

  //plans
  static String myPlanUrl = '/indexAllPlan';

  //payments
  static String paymentTypesUrl = '/getActivePaymentMethods';
  static String searchProductUrl = '/searchProductsByName';
  static String updateStoreInfoUrl = '/updateStoreOwnerInfo';
  static String getStatesUrl = '/getStatesByCountry';
  static String updateCustomerUrl = '/update-customer';
  static String searchCustomerUrl = '/searchCustomerByName';

  // Delivery Boys
  static String deliveryBoysUrl = '/deliveryboysIndex';
  static String addDeliveryBoyUrl = '/deliveryboyStore';
  static String updateDeliveryBoyUrl = '/deliveryboysUpdate';
  static String updatePassDeliveryBoyUrl = '/deliveryboysReset-password';
  static String deleteDeliveryBoyUrl = '/deliveryboysDestroy';
  static String assignOrderUrl = '/assignOrders';
  static String deliveryBoyIdUrl = '/';

  // Order status and order notes.
  //
  // These three were written as literals inside order_repository.dart
  // (lines 87, 108 and 128) instead of here, which took them OUT of the
  // cross-repo API contract: they are absent from repo A's generated manifest
  // (tests/Support/ApiContract/manifests/flutter-endpoints.json, 81
  // uncommented endpoints, none of them these), so the server side had no
  // record that the shipped app calls them and nothing would fail if a route
  // rename dropped them. Same bytes on the wire as the literals they replace.
  static String updateOrderStatusUrl = '/orders/update-status';
  static String createOrderNoteUrl = '/orders/notes/create';
  static String deleteOrderNoteUrl = '/orders/notes/delete';

}
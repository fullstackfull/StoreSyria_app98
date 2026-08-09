
class API {
  static String baseUrl = "https://storesyria.com/api/admin";
  static String loginUrl = '/adminlogin';
  static String dashboardUrl = '/dashboard';

  static String imageBaseUrl = '/base_url';
  static String storeIdUrl = '?store_id=';
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

  static String createReviewUrl = '/createreview';
  static String addReviewUrl = '/addreview';
  static String updateReviewUrl = '/updatereview';
  static String reviewListUrl = '/reviewlist';
  static String reviewStatusUrl = '/reviewstatus';
  static String deleteReviewUrl = '/deletereview';

  static String reviewIdUrl = '&review_id=';

  static String staticsDataUrl = '/staticsdata';
  static String editProfileUrl = '/editprofile';
  static String updatePasswordUrl = '/updatepassword';
  static String emailSettingUrl = '/emailsetting';
  static String getEmailSettingUrl = '/getemailsetting';
  static String getLoyaltySettingUrl = '/getloyalitysetting';
  static String loyaltySettingUrl = '/loyalitysetting';
  static String getCodPaymentUrl = '/get-cod-payment';
  static String codPaymentUrl = '/cod-payment';
  static String getBankPaymentUrl = '/get-bank-payment';
  static String bankPaymentUrl = '/bank-payment';
  static String getStripePaymentUrl = '/get-stripe-payment';
  static String stripePaymentUrl = '/stripe-payment';
  static String testMailUrl = '/testmail';
  static String changeStoreUrl = '/changestore';
  static String viewUsedCouponUrl = '/view-used-coupon';
  static String updateProductUrl = '/updateproduct';
  static String deleteStoreUrl = '/deletestore';
  static String fcmTokenUrl = '/store/fcm-token';
  static String notificationUrl = '/notification';
}

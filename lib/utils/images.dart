class DefaultImages {
  ///SVG icons
  static String storeGoLogo = "assets/svg/loginLogo.png";
  static String storeGoLogoDark = "assets/svg/loginLogoDark.png";
  static String envelopeIcn = 'assets/svg/envelope.svg';
  static String googleIcn = 'assets/svg/google.svg';
  static String facebookIcn = 'assets/svg/fb.svg';
  static String language2Icn = 'assets/svg/language.svg';
  static String currencyIcn = 'assets/svg/currency.svg';
  static String currencyExIcn = 'assets/svg/currency_exchange.svg';
  static String appleIcn = 'assets/svg/apple.svg';
  static String lockIcn = 'assets/svg/lock.svg';
  static String userIcn = "assets/svg/user.svg";
  static String callIcn = "assets/svg/call.svg";
  static String myPlanImg = "assets/svg/my_plan.svg";
  static String nextIcn = "assets/svg/next.svg";
  static String successIcn = "assets/svg/success.svg";
  static String ordersIcn = "assets/svg/orders.svg";
  static String moreIcn = "assets/svg/more.svg";
  static String productIcn = "assets/svg/product.svg";
  static String dashboardIcn = "assets/svg/dashboard.svg";
  static String categoriesIcn = "assets/svg/categories.svg";
  static String settingIcn = "assets/svg/setting.svg";
  static String menuIcn = "assets/svg/menu.svg";
  static String addCircleIcn = "assets/svg/add_circle.svg";
  static String sLogoIcn = "assets/svg/logoStore.svg";
  static String dropDownIcn = "assets/svg/drop_down.svg";
  static String graphIcn = "assets/svg/graph_icn.svg";
  static String qrCodeIcn = "assets/svg/qr_code.svg";
  static String listIcn = "assets/svg/list_icn.svg";
  static String gridIcn = "assets/svg/grid_icn.svg";
  static String cartIcn = "assets/svg/cart_icn.svg";
  static String paymentIcn = "assets/svg/payment_methods.svg";
  static String deliveryManIcn = "assets/svg/delivery-man.svg";
  static String arrowDownIcn = "assets/svg/arrow_down.svg";
  static String arrowUpIcn = "assets/svg/arrow_up.svg";
  static String copyIcn = "assets/svg/copy.svg";
  static String shareIcn = "assets/svg/share_icn.svg";
  static String doneIcn = "assets/svg/done.svg";
  static String downloadIcn = "assets/svg/download.svg";
  static String eyeIcn = "assets/svg/eye.svg";
  static String changeIcn = "assets/svg/change.svg";
  static String languageIcn = "assets/svg/lang.svg";
  static String deleteIcn = "assets/svg/delete.svg";
  static String backIcn = "assets/svg/back.svg";
  static String newProductIcn = "assets/svg/new_product.svg";
  static String newCategoryIcn = "assets/svg/new_category.svg";
  static String uploadIcn = "assets/svg/upload.svg";
  static String whiteUploadIcn = "assets/svg/white_upload.svg";
  static String closeIcn = "assets/svg/close.svg";
  static String whiteDoneIcn = "assets/svg/white_done.svg";
  static String generateIcn = "assets/svg/generate.svg";
  static String greenNextIcn = "assets/svg/green_next.svg";
  static String searchIcn = "assets/svg/search.svg";
  static String filterIcn = "assets/svg/filter_icn.svg";
  static String redCloseIcn = "assets/svg/red_close.svg";
  static String printerIcn = "assets/svg/printer.svg";
  static String circleSquareIcn = "assets/svg/circle_square.svg";
  static String planIcn = "assets/svg/plan.svg";
  static String statisticIcn = "assets/svg/statistic.svg";
  static String cameraIcn = "assets/svg/camera.svg";
  static String whiteCloseIcn = "assets/svg/white_close.svg";
  static String galleryIcn = "assets/svg/gallary.svg";
  static String siteIcn = "assets/svg/site_setting.svg";
  static String storeIcn = "assets/svg/store_setting.svg";
  static String themeIcn = "assets/svg/theme_settings.svg";
  static String loyaltyIcn = "assets/svg/loyality_setting.svg";
  static String upgradeIcn = "assets/svg/upgrade.svg";
  static String shippingIcn = "assets/svg/shipping.svg";
  static String taxIcn = "assets/svg/tax.svg";
  static String couponIcn = "assets/svg/coupon.svg";
  static String cardIcn = "assets/svg/card.svg";
  static String brightnessIcn = "assets/svg/brightness.svg";
  static String logoutIcn = "assets/svg/logout.svg";
  static String invoiceIcn = "assets/svg/invoice.svg";
  static String splashLogoImg = "assets/svg/splash_logo.svg";
  static String emptyNotification = "assets/svg/empty_notification.svg";

  static String welcomeImg = "assets/svg/welcome.svg";
  static String groupImg = "assets/svg/group.svg";
  static String walletImg = "assets/svg/wallet.svg";
  // Five absolute URLs on apps.rajodiya.com -- the upstream eCommerceGo
  // vendor's own demo installation -- used to live here: profileImg,
  // productImg, codImg, bankTransferImg and stripeImg.
  //
  // Only profileImg was live, as the errorWidget of the merchant avatar on
  // two production screens, so every avatar miss sent a request to a third
  // party nobody here has a contract with: an availability dependency, a
  // traffic and IP signal about this product's user base, and another
  // company's demo face shipped to Syrian merchants. Both call sites now fall
  // straight through to the local Icon(Icons.person) that was already their
  // terminal fallback.
  //
  // The other four were referenced only from commented-out lines in the
  // payment-setting controllers and are simply gone.
  //
  // Guarded by test/security/no_vendor_asset_hosts_test.dart, which fails on
  // ANY vendor or placeholder image host rather than on these five strings --
  // the defect was a habit, and a sixth would be just as wrong.
}

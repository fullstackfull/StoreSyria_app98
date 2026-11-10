/// NESTED API FIXTURES, in one place, for the screens whose payloads are too deep to inline.
///
/// WHY THIS FILE EXISTS. Most screens in this app take a flat list and a page number, and a test
/// can write that payload inline without obscuring what it is testing. A handful cannot: the order
/// detail payload alone carries billing and delivery addresses, a product line array, coupon info,
/// a tax block and eleven money fields, and `OrderDetailModel.fromJson` reads SIXTY-FOUR distinct
/// keys. Inlining that in each test buries the one field the test is about, and the thirteen
/// heavier screens would each grow their own slightly-different copy -- which is how two fixtures
/// drift until a test passes against a shape the server never sends.
///
/// THE RULE FOR EVERYTHING HERE: every builder returns the FULL shape the parser reads, with
/// realistic values, and takes named overrides for the fields a given test actually varies. A test
/// that wants a discounted order says so in one argument; everything else stays the default and
/// stays the same across tests.
///
/// VALUES ARE PLAUSIBLE SYRIAN RETAIL DATA, not `foo`/`bar`. A capture is read by a person, and a
/// screen full of placeholder strings hides exactly the layout problems these captures exist to
/// find -- an Arabic name is a different width from `test`, and a four-digit price wraps where a
/// one-digit price does not.
library;

/// A money string as the API sends it: already formatted, already carrying its symbol.
/// The app does not format these -- it prints them -- so a fixture that sends a bare number tests
/// a code path the server never produces.
String _money(String amount) => amount;

/// ---------------------------------------------------------------------------------------------
/// ORDER DETAIL -- `GET /vieworder?store_id=&order_id=`
/// ---------------------------------------------------------------------------------------------

Map<String, dynamic> billingAddress({
  String name = 'Amina Haddad',
  String city = 'Damascus',
  String state = 'Rif Dimashq',
}) =>
    {
      'name': name,
      'email': 'amina.haddad@example.com',
      'phone': '+963 11 555 0142',
      'address': 'Al-Mazzeh, Building 14, Flat 3',
      'city': city,
      'state': state,
      'country': 'Syria',
      'post_code': '0100',
    };

/// One product line inside an order.
///
/// `price`, `orignal_price` and `per_product_discount_price` are three different numbers on
/// purpose: a fixture where they are all equal cannot show whether the screen prints the right
/// one, and printing the wrong one is the defect class this app already shipped once
/// (P2.5-FLUTTER-PRICE).
Map<String, dynamic> orderProductLine({
  String name = 'Aleppo Laurel Soap, 6 bars',
  int qty = 2,
  String price = '24,000',
  String originalPrice = '30,000',
  String discount = '6,000',
  String? variantName,
}) =>
    {
      'product_id': 41,
      'name': name,
      'image': 'https://example.test/uploads/products/laurel-soap.png',
      'qty': qty,
      'price': _money(price),
      'orignal_price': _money(originalPrice),
      'per_product_discount_price': _money(discount),
      'variant_id': variantName == null ? null : 7,
      'variant_name': variantName,
      'final_price': _money(price),
    };

/// The whole order-detail envelope.
///
/// `orderStatus` drives the status pill and, on this screen, which actions render -- so it is the
/// first override any caller reaches for.
Map<String, dynamic> orderDetailResponse({
  String orderId = 'SY-10427',
  /// 4 is Confirmed in `orders.delivered_status`, and it is the default here on purpose: it is
  /// the status whose server-side English spelling is MISSPELLED. `Order.php:440` sends
  /// `__('Comfirmed')`, a typo that `tests/Feature/ApiContract/OrderStatusTextTest` pins for the
  /// API -- so it cannot be corrected on one surface without desynchronising the other three.
  /// Defaulting to it means these captures show whether the app survives that: it does, because
  /// the screen now translates the INTEGER through `StatusBadgeHelper.getOrderLabel` instead of
  /// printing the server's string.
  int orderStatus = 4,
  String orderStatusText = 'Comfirmed',
  String currencySymbol = 'ل.س',
  List<Map<String, dynamic>>? products,
  String subTotal = '48,000',
  String tax = '4,800',
  String discount = '6,000',
  String deliveryCharge = '5,000',
  String total = '51,800',
  String? deliveryName,
  int isGuest = 0,
  int isReview = 0,
  Map<String, dynamic>? couponInfo,
}) =>
    {
      'status': 1,
      'message': 'Order detail',
      'data': {
        'id': 1042,
        'order_id': orderId,
        'is_guest': isGuest,
        'customer_id': 8,
        'created_at': '2026-11-02 14:20:00',
        'updated_at': '2026-11-03 09:05:00',
        'delivery_date': '2026-11-05',
        'order_status': orderStatus,
        'order_status_text': orderStatusText,
        /*
         * F154. THE TWO ADDITIVE FIELDS THE API NOW SENDS, present here so the fixture is the
         * shape the server really produces.
         *
         * The admin API never runs `SetLocate`, so `order_status_text` arrives in the
         * APPLICATION DEFAULT language rather than the merchant's. Rather than localise an
         * existing field -- which would have broken the five places this client compares
         * `payment_status` to the literal `'paid'` -- the server adds a stable key and a
         * localised label beside it.
         *
         * This app does not READ them: it translates the integer `order_status` client-side
         * through `StatusBadgeHelper.getOrderLabel`, which is locale-independent and works
         * offline. They are in the fixture to prove the client tolerates them, which is what
         * "additive" has to mean in practice.
         */
        'order_status_key': 'confirmed',
        'order_status_label': 'مؤكد',
        'order_status_message': 'Your order is being prepared.',
        'order_reward_point': 24.0,
        'is_review': isReview,
        'currency_symbol': currencySymbol,
        'product': products ??
            [
              orderProductLine(),
              orderProductLine(
                name: 'Damask Rose Water, 250ml',
                qty: 1,
                price: '12,000',
                originalPrice: '12,000',
                discount: '0',
                variantName: '250ml',
              ),
            ],
        'billing_informations': billingAddress(),
        'delivery_informations': billingAddress(),
        'paymnet_type': 'cod',
        'paymnet': 'Cash On Delivery',
        'payment_status': 'Pending',
        'delivery': deliveryName,
        'delivery_id': deliveryName == null ? null : '3',
        'deliveryboy_id': deliveryName == null ? null : 3,
        'sub_total': _money(subTotal),
        'tax': _money(tax),
        'tax_string': '10%',
        'discount': _money(discount),
        'discount_string': 'WELCOME10',
        'discount_price': _money(discount),
        'discount_amount': _money(discount),
        'delivered_charge': _money(deliveryCharge),
        'total_orignal_price': _money('60,000'),
        'final_price': _money(total),
        'amountstring': '$currencySymbol $total',
        'coupon_info': couponInfo,
        'notes': const <Map<String, dynamic>>[],
        'note': null,
        'note_type': null,
        'return': null,
        'return_price': null,
        'return_date': null,
        'return_status_message': null,
      },
    };

/// An order with nothing bought -- the shape a screen must survive rather than crash on.
///
/// `order_detail_screen.dart:808` force-unwraps a field that a null product list leaves absent,
/// which is recorded in `order_detail_model.dart:130`. A capture test that only ever drives the
/// happy path never reaches that line.
Map<String, dynamic> orderDetailEmptyResponse() {
  final body = orderDetailResponse(products: const []);
  (body['data'] as Map<String, dynamic>)['sub_total'] = '0';
  (body['data'] as Map<String, dynamic>)['final_price'] = '0';
  return body;
}

/// ---------------------------------------------------------------------------------------------
/// PRODUCT DETAIL
///
/// TWO PIECES, and the first version of this file got the split wrong.
///
/// `ProductDetailScreen` takes the PRODUCT as a constructor argument -- a `ProductData` the
/// caller already has from the list -- and fetches only its IMAGES from `/viewproduct`.
/// `ProductDetailModel` reads `image_path`, `image_path_full_url` and `product_id`, and nothing
/// about name or price. A fixture built as "the product detail response" parses to an empty
/// image list and a screen that renders the product fine, which is why the mistake is invisible.
/// ---------------------------------------------------------------------------------------------

/// The map `ProductData.fromJson` reads. Every field is optional on that model, so a missing key
/// renders as null rather than throwing -- which is exactly why the ones that matter are all set
/// here: a blank price is indistinguishable from a free product.
Map<String, dynamic> productDataJson({
  int id = 41,
  String name = 'Aleppo Laurel Soap, 6 bars',
  String price = '30000',
  String? finalPrice = '24000',
  String currencySymbol = 'ل.س',
  int quantity = 42,
  String categoryName = 'Bath & Body',
  double rating = 4.5,
}) =>
    {
      'id': id,
      'name': name,
      'slug': 'aleppo-laurel-soap',
      'sku': 'SOAP-LAUREL-6',
      'description': 'Traditional Aleppo soap, cured for nine months.',
      'detail': 'Olive oil and laurel berry oil. Handmade in Aleppo.',
      'price': price,
      // `final_price` is the field the card prints (P2.5-FLUTTER-PRICE): the server resolves it
      // from the product's own price, and it is NOT the same thing as a discount price.
      'final_price': finalPrice ?? price,
      'discount_amount': finalPrice == null ? '0' : '6000',
      'currency_symbol': currencySymbol,
      // `product_stock`, not `quantity`: the model reads the former and ignores the latter, so a
      // fixture using `quantity` renders a product with no stock and says nothing about it.
      'product_stock': quantity,
      'category_id': 3,
      'category_name': categoryName,
      'brand_id': 2,
      'label_id': null,
      'tax_id': null,
      'cover_image_url': 'https://example.test/uploads/products/laurel-soap.png',
      'cover_image_path': 'uploads/products/laurel-soap.png',
      'average_rating': rating,
      'is_review': 1,
      'is_active': 1,
      // BOOLEANS, not 0/1: `active`, `in_cart` and `in_whishlist` are cast `as bool?` while
      // `is_active` beside them is `as int?`. The model mixes both conventions for what the host
      // stores as tinyint, so a fixture has to match each field rather than the column family.
      'active': true,
      'in_cart': false,
      'in_whishlist': false,
      'variant_product': 0,
      // STRING, not int: `downloadable_product` is cast `as String?` (the host column is a
      // varchar). Sent as `0` it threw `type 'int' is not a subtype of type 'String?'` and took
      // the whole screen down -- the third fixture type mismatch in this file, and the reason
      // each one is recorded where it happened.
      'downloadable_product': '0',
      'product_weight': '0.9',
      'custom_field_status': 0,
      'created_at': '2026-09-14 10:00:00',
      'updated_at': '2026-11-01 12:30:00',
    };

/// `GET /viewproduct?store_id=&product_id=` -- the image list, and only that.
Map<String, dynamic> productImagesResponse({int images = 3}) => {
      'status': 1,
      'message': 'Product images',
      'data': List<Map<String, dynamic>>.generate(
        images,
        (i) => {
          'id': 200 + i,
          'product_id': 41,
          'image_path': 'uploads/products/laurel-soap-$i.png',
          'image_path_full_url': 'https://example.test/uploads/products/laurel-soap-$i.png',
          'store_id': 1,
          'created_at': '2026-09-14 10:00:00',
          'updated_at': '2026-09-14 10:00:00',
        },
      ),
    };

/// A product whose gallery is empty -- the state a screen must render rather than crash on.
Map<String, dynamic> productNoImagesResponse() => productImagesResponse(images: 0);

/// ---------------------------------------------------------------------------------------------
/// COUPON DETAIL -- `GET /view-used-coupon`
///
/// NOT the coupon's definition. `CouponDetailScreen` renders its REDEMPTION HISTORY: each row is
/// one order that used the code, which is why `ViewUsedCouponModel` reads `order_id`,
/// `product_order_id`, `amount` and `date_used` and nothing about the discount rule. A fixture
/// built from the coupon's own fields -- which is what this builder held first -- parses to an
/// empty list and renders a screen that looks exactly like a coupon nobody has used.
/// ---------------------------------------------------------------------------------------------

Map<String, dynamic> usedCouponResponse({
  String couponName = 'WELCOME10',
  int redemptions = 3,
}) =>
    {
      'status': 1,
      'message': 'Used coupon list',
      'data': List<Map<String, dynamic>>.generate(
        redemptions,
        (i) => {
          'id': 90 + i,
          'coupon_id': 5,
          'coupon_name': couponName,
          'user_id': 8 + i,
          'order_id': 1040 + i,
          'product_order_id': 'SY-104${27 + i}',
          // TYPES MATTER HERE, and getting them wrong is silent. `ViewUsedCouponData.fromJson`
          // does `(json['amount'] as num?)` and assigns `theme_id` to a `String?` field, so a
          // string amount or a numeric theme id THROWS inside the parse -- and the controller
          // catches it, sets `usedCouponErrorMessage` to 'Something went wrong' and leaves the
          // list empty. That renders as a coupon nobody has used. Both were wrong here first.
          'amount': (i + 1) * 2400,
          'date_used': '2026-11-0${i + 1}',
          'theme_id': '1',
          'created_at': '2026-11-0${i + 1} 10:00:00',
          'updated_at': '2026-11-0${i + 1} 10:00:00',
        },
      ),
    };

/// A coupon nobody has redeemed -- the empty state, which must be distinguishable from a failure.
Map<String, dynamic> usedCouponEmptyResponse() => usedCouponResponse(redemptions: 0);

/// ---------------------------------------------------------------------------------------------
/// MY PLAN -- `GET /indexAllPlan?store_id=`
///
/// Deep but FORGIVING: every field in `my_plan_model.dart` is read as `json['x'] ?? default` and
/// every nested object through `jsonMap(...)`, so a partial payload parses rather than throwing.
/// That tolerance is exactly why the fixture is written out in full here: a missing key does not
/// fail, it renders a zero -- a plan page showing `0 / 0 products` looks like a real answer.
/// ---------------------------------------------------------------------------------------------

Map<String, dynamic> _planLimit(int max, int used) => {
      'max': max,
      'used': used,
      'remaining': max < 0 ? -1 : max - used,
      'percentage': max <= 0 ? 0.0 : (used / max * 100),
    };

Map<String, dynamic> currentPlanResponse({
  String planName = 'Growth',
  num price = 120000,
  String currency = 'ل.س',
  String currencyName = 'Syrian Pound',
  String expiry = '2027-03-01',
  int daysRemaining = 112,
  int maxProducts = 500,
  int usedProducts = 128,
  bool expired = false,
  bool trial = false,
}) =>
    {
      'status': 1,
      'message': 'Current plan',
      'data': {
        'current_plan': {
          'id': 2,
          'name': planName,
          'price': price,
          'currency': currency,
          'currency_name': currencyName,
          'duration': 'year',
          'duration_text': 'Yearly',
          'price_display': '$currency $price',
          'description': 'For stores that are growing quickly.',
          'has_trial': trial,
          'trial_days': trial ? 14 : 0,
          'limits': {
            'products': _planLimit(maxProducts, usedProducts),
            'stores': _planLimit(3, 1),
            'users': _planLimit(10, 4),
          },
          'features': {
            'custom_domain': true,
            'sub_domain': true,
            'chatgpt': false,
            'pwa': true,
            'shipping_method': true,
            'enable_tax': true,
            'storage_limit': '5 GB',
          },
          'plan_status': {
            'is_current_plan': true,
            'is_expired': expired,
            'is_trial_plan': trial,
            'plan_expire_date': expiry,
            'days_remaining': daysRemaining,
            'expire_message': expired ? 'Your plan has expired.' : '',
          },
          'user_subscription': {
            'plan_id': 2,
            'plan_status': expired ? 'expired' : 'active',
            'plan_expire_date': expiry,
          },
        },
        'current_user_plan': {
          'plan_id': 2,
          'plan_expire_date': expiry,
          'is_expired': expired,
          'days_remaining': daysRemaining,
        },
        'has_requested_plan': false,
        'requested_plan': null,
      },
    };

/// An expired plan -- the state whose whole purpose is to say so loudly.
Map<String, dynamic> expiredPlanResponse() =>
    currentPlanResponse(expired: true, daysRemaining: 0, expiry: '2026-10-01');

/// ---------------------------------------------------------------------------------------------
/// STORE PAYMENT METHODS -- `GET /getActivePaymentMethods?store_id=`
///
/// The list lives under `data.active_methods`, NOT under `data` itself, and each entry is just
/// `{key, name}`. The controller reads it with `jsonList(responseData['active_methods'])` --
/// a tolerant helper that returns an empty list for a Map or a null -- so a payload that puts the
/// array one level too high parses to zero methods and renders "no payment methods configured".
/// That is a sentence a merchant would believe.
/// ---------------------------------------------------------------------------------------------

Map<String, dynamic> activePaymentMethodsResponse({
  List<List<String>>? methods,
}) =>
    {
      'status': 1,
      'message': 'Active payment methods',
      'data': {
        'active_methods': (methods ??
                const [
                  ['cod', 'Cash On Delivery'],
                  ['bank_transfer', 'Bank Transfer'],
                  ['stripe', 'Stripe'],
                  ['paypal', 'Paypal'],
                ])
            .map((m) => {'key': m[0], 'name': m[1]})
            .toList(),
      },
    };

/// A store that has switched every gateway off. Distinct from a failed load only if the screen
/// says so, which is what the premise test asserts.
Map<String, dynamic> noActivePaymentMethodsResponse() =>
    activePaymentMethodsResponse(methods: const []);

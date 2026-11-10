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
/// ---------------------------------------------------------------------------------------------

Map<String, dynamic> productDetailResponse({
  String name = 'Aleppo Laurel Soap, 6 bars',
  String price = '30,000',
  String? salePrice = '24,000',
  String currencySymbol = 'ل.س',
  int stock = 42,
  bool enableStock = true,
}) =>
    {
      'status': 1,
      'message': 'Product detail',
      'data': {
        'id': 41,
        'name': name,
        'sku': 'SOAP-LAUREL-6',
        'description':
            'Traditional Aleppo soap, cured for nine months. Olive oil and laurel berry oil.',
        'price': _money(price),
        'sale_price': salePrice == null ? null : _money(salePrice),
        'final_price': _money(salePrice ?? price),
        'currency_symbol': currencySymbol,
        'quantity': stock,
        'enable_stock_management': enableStock ? 1 : 0,
        'stock_status': stock > 0 ? 'in_stock' : 'out_of_stock',
        'cover_image': 'https://example.test/uploads/products/laurel-soap.png',
        'product_image': const [
          {'image': 'https://example.test/uploads/products/laurel-soap.png'},
        ],
        'category': {'id': 3, 'name': 'Bath & Body'},
        'brand': {'id': 2, 'name': 'Homs Cotton'},
        'tax': const [
          {'id': 1, 'name': 'VAT', 'tax_value': '10', 'type': 'percentage'},
        ],
        'variants': const <Map<String, dynamic>>[],
        'rating': 4.5,
        'review_count': 12,
      },
    };

/// ---------------------------------------------------------------------------------------------
/// CURRENT PLAN -- the My Plan screen
/// ---------------------------------------------------------------------------------------------

Map<String, dynamic> currentPlanResponse({
  String planName = 'Growth',
  String price = '120,000',
  String currencySymbol = 'ل.س',
  String expiry = '2027-03-01',
  bool unlimitedProducts = false,
}) =>
    {
      'status': 1,
      'message': 'Current plan',
      'data': {
        'id': 2,
        'name': planName,
        'price': _money(price),
        'currency_symbol': currencySymbol,
        'duration': 'Yearly',
        'expiry_date': expiry,
        'max_products': unlimitedProducts ? -1 : 500,
        'max_orders': unlimitedProducts ? -1 : 5000,
        'used_products': 128,
        'used_orders': 1042,
        'description': 'For stores that are growing quickly.',
        'enable_custom_domain': 1,
        'enable_chatgpt': 0,
      },
    };

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

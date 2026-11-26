/// LIST-PAGE API FIXTURES — the shallow list payloads more than one file now renders.
/// =================================================================================================
///
/// WHY A SHARED FILE, AND IT IS THE SAME REASON `sample_cards.dart` EXISTS. `screen_harness.dart`
/// can drive a whole screen in front of a stubbed network, and two different kinds of test now do
/// it with the SAME payload: `test/screens/populated_screen_capture_test.dart` (evidence captures,
/// written only when `SS_CAPTURE_DIR` is set) and `test/golden/screen_golden_test.dart` (a pixel
/// baseline, compared on every push once a human approves it). A copied fixture is how those two
/// come to photograph different screens while reporting the same name.
///
/// This project has already paid for that twice, and both times the test went GREEN against the
/// wrong picture:
///
///   * `email` nested inside `customer_info`, where `CustomerInfo` does not read it — the API puts
///     it beside that object — so four baselines froze a literal `--` where the address belongs;
///   * `mobile` instead of `contact` on the delivery man, with the same result.
///
/// `sample_cards.dart` was created for exactly this reason when a second file began measuring the
/// two list cards. This is that move for the list PAYLOADS.
///
/// `nested_fixtures.dart` is deliberately not where these went: its own header scopes it to the
/// payloads "too deep to inline" — the order detail's sixty-four keys and its siblings. These are
/// shallow list pages, and mixing them in would make that header false.
///
/// THE RULE HERE IS THE ONE NESTED_FIXTURES STATES: every builder returns the full shape the
/// parser reads, with plausible Syrian retail data rather than `foo`/`bar`, because a capture is
/// read by a person and an Arabic name is a different width from `test`.
library;

/// Three customers, in the envelope `CustomerModel.fromJson` reads.
///
/// `email` and `state_name` sit at the ROOT, not inside `customer_info` — `CustomerInfo` carries
/// only name and mobile, and the API puts both of these beside that object. The first version of
/// this project's golden fixture nested `email`, so it was never read and four baselines froze a
/// literal `--` where the address belongs.
///
/// The third row's `status: 0` is not padding: it is the only one that renders the INACTIVE pill,
/// and a fixture of three active customers would photograph one branch of a two-branch widget.
Map<String, Object?> customerListPage() => <String, Object?>{
      'status': 1,
      'data': <String, Object?>{
        'customers': <Object?>[
          <String, Object?>{
            'id': 1,
            'customer_info': <String, Object?>{'name': 'أمينة حداد', 'mobile': '0911222333'},
            'email': 'amina@example.test',
            'state_name': 'دمشق',
            'status': 1,
          },
          <String, Object?>{
            'id': 2,
            'customer_info': <String, Object?>{'name': 'عمر خليل', 'mobile': '0922333444'},
            'email': 'omar@example.test',
            'state_name': 'حلب',
            'status': 1,
          },
          <String, Object?>{
            'id': 3,
            'customer_info': <String, Object?>{'name': 'نور صالح', 'mobile': '0933444555'},
            'email': 'nour@example.test',
            'state_name': 'اللاذقية',
            'status': 0,
          },
        ],
        'pagination': <String, Object?>{'last_page': 1},
      },
    };

/// Two products. `ProductModelData` is the Laravel paginator shape — `data.data` is the LIST —
/// and `ProductData` uses typed casts (`json['id'] as int?`, `json['status'] as int?`), so a
/// string where an int belongs throws rather than parsing to null. The controller gates on
/// `data['status'] == 1` (`product_controller.dart:117`), an INT, which is a different check
/// from the delivery-man endpoint's.
///
/// The second row carries `product_stock: 0` and `is_active: 0` on purpose: out-of-stock and
/// inactive are separate branches of the product card, and a fixture of two healthy products
/// photographs neither.
Map<String, Object?> productListPage() => <String, Object?>{
      'status': 1,
      'data': <String, Object?>{
        'currency_symbol': r'$',
        'out_of_stock_threshold': 0,
        'current_page': 1,
        'last_page': 1,
        'per_page': 10,
        'total': 2,
        'data': <Object?>[
          <String, Object?>{
            'id': 1,
            'name': 'قميص قطن دمشقي',
            'product_code': 'SS-1001',
            'price': 150,
            'final_price': 150,
            'product_stock': 12,
            'track_stock': 1,
            'status': 1,
            'is_active': 1,
            'variant_product': 0,
          },
          <String, Object?>{
            'id': 2,
            'name': 'وشاح حريري',
            'product_code': 'SS-1002',
            'price': 85,
            'final_price': 85,
            'product_stock': 0,
            'track_stock': 1,
            'status': 1,
            'is_active': 0,
            'variant_product': 0,
          },
        ],
      },
    };

Map<String, Object?> orderRow({
  required int id,
  required String ref,
  required String customer,
  required String total,
  required int status,
  required String statusText,
}) =>
    <String, Object?>{
      'id': id,
      'product_order_id': ref,
      'order_id_string': ref,
      'user_name': customer,
      'order_date': '2026-11-08',
      'created_at': '2026-11-08 09:12:00',
      'final_price': total,
      'product_price': total,
      'delivery_price': '0',
      'tax_price': '0',
      'coupon_price': '0',
      'return_price': '0',
      'currency_symbol': 'ل.س',
      'payment_type': 'COD',
      'payment_status': 'pending',
      'delivered_status': status,
      'delivered_status_string': statusText,
      'is_guest': 0,
      'store_id': 1,
      'user_id': 4,
    };

Map<String, Object?> orderListPage() => <String, Object?>{
      'status': 1,
      'data': <String, Object?>{
        'current_page': 1,
        'last_page': 1,
        'per_page': 10,
        'total': 2,
        'data': <Object?>[
          orderRow(
            id: 1041,
            ref: 'SS-1041',
            customer: 'ليلى حداد',
            total: '85000',
            // 6 IS "Shipped" -- the numbering is NOT free, and it agrees with the server's
            // `Order::getDeliveredStatusStringAttribute()`: 0 Pending, 1 Delivered, 2 Cancel,
            // 3 Return, 4 Confirmed, 5 Picked Up, 6 Shipped. The card reads this INT, not
            // `delivered_status_string`, so the first version of this fixture -- 2 with the
            // string 'Shipped' -- captured an order badged "Cancelled". The card was right and
            // the fixture was wrong; `test/widgets/order_status_label_test.dart` pins the map.
            status: 6,
            statusText: 'Shipped',
          ),
          orderRow(
            id: 1042,
            ref: 'SS-1042',
            customer: 'Marwan Haddad',
            total: '126500',
            status: 0,
            statusText: 'Pending',
          ),
        ],
      },
    };

/// Two coupons, in the same paginator envelope. `CouponData` reads `coupon_name`, `coupon_code`,
/// `coupon_type` and `discount_amount` — not `name`/`code`, which is the kind of near-miss that
/// parses to an empty list and renders a convincing empty state.
Map<String, Object?> couponListPage() => <String, Object?>{
      'status': 1,
      'data': <String, Object?>{
        'current_page': 1,
        'last_page': 1,
        'per_page': 10,
        'total': 2,
        'data': <Object?>[
          <String, Object?>{
            'id': 1,
            'coupon_name': 'خصم العيد',
            'coupon_code': 'EID25',
            'coupon_type': 'percentage',
            'discount_amount': 25,
            'coupon_limit': 100,
            'coupon_expiry_date': '2026-12-31',
            'status': 1,
          },
          <String, Object?>{
            'id': 2,
            'coupon_name': 'شحن مجاني',
            'coupon_code': 'FREESHIP',
            'coupon_type': 'flat',
            'discount_amount': 10,
            'coupon_limit': 50,
            'coupon_expiry_date': '2026-11-30',
            'status': 1,
          },
        ],
      },
    };

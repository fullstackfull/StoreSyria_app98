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

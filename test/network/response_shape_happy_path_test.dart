// The POSITIVE half of the nested-response fix.
//
// `test/network/response_shape_resilience_test.dart` proves no shape CRASHES.
// On its own that is a weak property: a parser that discarded every field
// would pass it. These tests assert that a WELL-FORMED body still parses to
// the same values it did before `jsonMap` / `jsonList` and the element guards
// were introduced -- i.e. that the fix degrades skewed shapes without
// swallowing real data.
//
// Payload field names and nesting come from the response shapes the parsers
// read, and the two `product` shapes come from the branch
// `order_detail_model.dart` has always had: a JSON array, and -- for a POS
// order -- an object keyed by product id.

import 'package:flutter_test/flutter_test.dart';

import 'package:store_go_app/core/model/dashboard_model.dart';
import 'package:store_go_app/core/model/order_detail_model.dart';
import 'package:store_go_app/core/model/payment_model.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/core/model/tax_model.dart';
import 'package:store_go_app/core/model/wallet_model.dart';
import 'package:store_go_app/network/result.dart';

void main() {
  group('jsonMap / jsonList pass real data through unchanged', () {
    test('jsonMap keeps every entry of a real object', () {
      final out = jsonMap(<String, dynamic>{'a': 1, 'b': 'two'});

      expect(out, hasLength(2));
      expect(out['a'], 1);
      expect(out['b'], 'two');
    });

    test('jsonMap accepts a Map<dynamic, dynamic>, which a cast would reject',
        () {
      // The reason the helper uses `Map<String, dynamic>.from` rather than a
      // cast: a platform channel and a re-decoded FCM payload both produce
      // `Map<dynamic, dynamic>`, and `as Map<String, dynamic>` throws on it.
      final out = jsonMap(<dynamic, dynamic>{'a': 1});

      expect(out['a'], 1);
    });

    test('jsonList keeps every element of a real array', () {
      expect(jsonList(<dynamic>[1, 2, 3]), <dynamic>[1, 2, 3]);
    });

    test('and both degrade instead of throwing', () {
      expect(jsonMap(null), isEmpty);
      expect(jsonMap(<dynamic>[]), isEmpty);
      expect(jsonMap('ok'), isEmpty);
      expect(jsonList(null), isEmpty);
      expect(jsonList(<String, dynamic>{}), isEmpty);
      expect(jsonList(7), isEmpty);
    });
  });

  test('a real wallet body still yields its balance and every transaction',
      () {
    final wallet = WalletData.fromJson(<String, dynamic>{
      'store_id': 4,
      'currency_symbol': r'$',
      'available_balance': '1250.75',
      'currency_code': 'USD',
      'transactions': <dynamic>[
        <String, dynamic>{'id': 1, 'amount': '100.00'},
        <String, dynamic>{'id': 2, 'amount': '50.50'},
      ],
      'pagination': <String, dynamic>{'current_page': 1, 'last_page': 3},
    });

    expect(wallet.storeId, 4);
    expect(wallet.currencySymbol, r'$');
    expect(wallet.availableBalance, '1250.75');
    expect(wallet.currencyCode, 'USD');
    expect(wallet.transactions, hasLength(2));
    expect(wallet.pagination.currentPage, 1);
  });

  test('a real tax body still yields every row', () {
    final tax = TaxModel.fromJson(<String, dynamic>{
      'status': 1,
      'data': <String, dynamic>{
        'total': 2,
        'data': <dynamic>[
          <String, dynamic>{'id': 7, 'tax_name': 'VAT', 'tax_amount': '15'},
          <String, dynamic>{'id': 8, 'name': 'City', 'tax_amount': '2'},
        ],
        'links': <dynamic>[
          <String, dynamic>{'label': '1', 'active': true},
        ],
      },
    });

    expect(tax.data.data, hasLength(2));
    expect(tax.data.data.first.taxName, 'VAT');
    // `tax_name` absent, `name` present -- the fallback the parser declares.
    expect(tax.data.data[1].taxName, 'City');
    expect(tax.data.links, hasLength(1));
  });

  test('a real dashboard body still yields every list it carries', () {
    final dash = DashboardData.fromJson(<String, dynamic>{
      'store': <dynamic>[
        <String, dynamic>{'id': 1, 'name': 'Main'},
        <String, dynamic>{'id': 2, 'name': 'Branch'},
      ],
      'product': <dynamic>[
        <String, dynamic>{'id': 11, 'name': 'Shirt'},
      ],
      'recent_order': <dynamic>[
        <String, dynamic>{'id': 21},
        <String, dynamic>{'id': 22},
        <String, dynamic>{'id': 23},
      ],
      'coupons': <dynamic>[
        <String, dynamic>{'id': 31},
      ],
      'user': <String, dynamic>{'id': 99, 'name': 'Owner'},
    });

    expect(dash.store, hasLength(2));
    expect(dash.product, hasLength(1));
    expect(dash.recentOrder, hasLength(3));
    expect(dash.coupons, hasLength(1));
    expect(dash.user?.name, 'Owner');
  });

  test('a real statistics body still yields every chart series', () {
    final stats = StaticsDataModel.fromJson(<String, dynamic>{
      'status': 1,
      'data': <String, dynamic>{
        'visitorchart': <dynamic>[
          <String, dynamic>{'date': '2026-01-01'},
          <String, dynamic>{'date': '2026-01-02'},
        ],
        'topurl': <dynamic>[
          <String, dynamic>{'url': '/a'},
        ],
        'platform': <dynamic>[
          <String, dynamic>{'name': 'android'},
        ],
        'browser': <dynamic>[
          <String, dynamic>{'name': 'chrome'},
        ],
        'device': <dynamic>[
          <String, dynamic>{'name': 'mobile'},
        ],
      },
    });

    expect(stats.data?.visitorchart, hasLength(2));
    expect(stats.data?.topurl, hasLength(1));
    expect(stats.data?.platform, hasLength(1));
    expect(stats.data?.browser, hasLength(1));
    expect(stats.data?.device, hasLength(1));
  });

  test('a real payment body still yields every active method', () {
    final method = PaymentMethod.fromJson(<String, dynamic>{
      'name': 'Cash on delivery',
      'key': 'cod',
    });

    expect(method.name, 'Cash on delivery');
  });

  group('order detail keeps BOTH product shapes', () {
    Map<String, dynamic> body(dynamic product) => <String, dynamic>{
          'status': 1,
          'data': <String, dynamic>{
            'id': 500,
            'order_id': 'ORD-500',
            'paymnet_type': 'COD',
            'product': product,
          },
        };

    test('the array shape yields every product', () {
      final order = OrderDetailModel.fromJson(body(<dynamic>[
        <String, dynamic>{'id': 1, 'name': 'Shirt'},
        <String, dynamic>{'id': 2, 'name': 'Shoes'},
      ]));

      expect(order.data?.product, hasLength(2));
      expect(order.data?.product?.first.name, 'Shirt');
    });

    test('the POS keyed-object shape yields every product too', () {
      // This is the branch whose products were only ever added as a SIDE
      // EFFECT of `Iterable.toString()` inside an `AppLog.d(...)`
      // interpolation, because the `.map` above it was lazy and discarded.
      // Deleting that debug log from the pre-fix code makes this expectation
      // read 0 instead of 2 -- measured, see the commit message.
      final order = OrderDetailModel.fromJson(body(<String, dynamic>{
        '11': <String, dynamic>{'id': 11, 'name': 'Shirt'},
        '12': <String, dynamic>{'id': 12, 'name': 'Shoes'},
      }));

      expect(order.data?.product, hasLength(2));
      expect(
        order.data?.product?.map((p) => p.name).toList(),
        containsAll(<String?>['Shirt', 'Shoes']),
      );
    });

    test('an absent product key yields an empty list, never null', () {
      // `order_detail_screen.dart:808` force-unwraps `detail.product!`, so a
      // null here is a crash on the order-detail screen.
      final order = OrderDetailModel.fromJson(body(null));

      expect(order.data?.product, isNotNull);
      expect(order.data?.product, isEmpty);
    });

    test('paymnet_type is still read, and an absent one is empty not null',
        () {
      expect(OrderDetailModel.fromJson(body(<dynamic>[])).data?.paymnetType,
          'COD');

      final noType = OrderDetailModel.fromJson(<String, dynamic>{
        'status': 1,
        'data': <String, dynamic>{'id': 1},
      });

      expect(noType.data, isNotNull);
    });
  });
}

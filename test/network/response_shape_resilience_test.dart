// R7-N6 (third half): an ERROR-SHAPED or VERSION-SKEWED response body must not
// crash the parser.
//
// test/controllers/nested_api_read_test.dart proves the twenty-four
// `data['a']['b']` sites behave, and
// test/controllers/no_unguarded_nested_subscript_test.dart ratchets that exact
// pattern. Neither covers the OTHER half of the same defect, which is where the
// remaining sites live:
//
//     json['data'] != null ? Model.fromJson(json['data']) : null
//
// `!= null` guards null and NOTHING ELSE. `Model.fromJson` is declared
// `fromJson(Map<String, dynamic> json)`, so passing a List or a String is an
// implicit-downcast TypeError at the call. And `"data": []` is not a
// hypothetical: Laravel serialises an EMPTY Eloquent collection as a JSON
// array, so the same endpoint that answers `{"data": {...}}` with one row
// answers `{"data": []}` with none. `as List?` / `as Map<String, dynamic>` have
// the mirror-image hole: they guard the type and throw on it rather than
// degrading.
//
// WHAT THIS TEST DOES, and why it is behavioural rather than a grep: for every
// response model it reads that model's OWN source, harvests every
// `json['key']` literal the parser actually reads, and builds a payload in
// which every one of those keys carries a skewed value -- an empty list, a
// populated list, a bare string, a number, a bool, an empty object. Then it
// calls the real `fromJson`. A parser that throws on any of them fails.
//
// Harvesting the keys from the source is deliberate: a hand-written payload
// covers the keys whoever wrote the test remembered, and goes stale the moment
// a field is added. This one cannot go stale, and it is why the matrix is
// 27 models x 13 payload shapes rather than a handful of spot checks.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:store_go_app/core/model/categories_model.dart';
import 'package:store_go_app/core/model/coupon_model.dart';
import 'package:store_go_app/core/model/create_product_model.dart';
import 'package:store_go_app/core/model/currency_model.dart';
import 'package:store_go_app/core/model/customer_model.dart';
import 'package:store_go_app/core/model/customer_orders_model.dart';
import 'package:store_go_app/core/model/dashboard_model.dart';
import 'package:store_go_app/core/model/delivery_boy_model.dart';
import 'package:store_go_app/core/model/email_setting_model.dart';
import 'package:store_go_app/core/model/get_user_review_model.dart';
import 'package:store_go_app/core/model/image_base_url_model.dart';
import 'package:store_go_app/core/model/language_model.dart';
import 'package:store_go_app/core/model/my_plan_model.dart';
import 'package:store_go_app/core/model/notification_model.dart';
import 'package:store_go_app/core/model/order_detail_model.dart';
import 'package:store_go_app/core/model/order_model.dart';
import 'package:store_go_app/core/model/payment_model.dart';
import 'package:store_go_app/core/model/product_detail_model.dart';
import 'package:store_go_app/core/model/product_model.dart';
import 'package:store_go_app/core/model/review_model.dart';
import 'package:store_go_app/core/model/shipping_model.dart';
import 'package:store_go_app/core/model/static_model.dart';
import 'package:store_go_app/core/model/store_info_model.dart';
import 'package:store_go_app/core/model/tax_model.dart';
import 'package:store_go_app/core/model/top_order_model.dart';
import 'package:store_go_app/core/model/view_used_coupon_model.dart';
import 'package:store_go_app/core/model/wallet_model.dart';

import '../support/source_tree.dart';

/// One response model: the file its parser lives in (for key harvesting) and
/// the entry point a controller actually calls.
class _Entry {
  const _Entry(this.name, this.source, this.parse);

  final String name;
  final String source;
  final void Function(Map<String, dynamic> json) parse;
}

final _entries = <_Entry>[
  _Entry('CategoriesModel', 'categories_model.dart',
      (j) => CategoriesModel.fromJson(j)),
  _Entry('CouponModel', 'coupon_model.dart', (j) => CouponModel.fromJson(j)),
  _Entry('CreateProductModel', 'create_product_model.dart',
      (j) => CreateProductModel.fromJson(j)),
  _Entry('CurrencyResponse', 'currency_model.dart',
      (j) => CurrencyResponse.fromJson(j)),
  _Entry('CurrencyRatesResponse', 'currency_model.dart',
      (j) => CurrencyRatesResponse.fromJson(j)),
  _Entry('CustomerModel', 'customer_model.dart',
      (j) => CustomerModel.fromJson(j)),
  _Entry('CustomerCityModel', 'customer_model.dart',
      (j) => CustomerCityModel.fromJson(j)),
  _Entry('CustomerOrdersModel', 'customer_orders_model.dart',
      (j) => CustomerOrdersModel.fromJson(j)),
  _Entry('DashboardModel', 'dashboard_model.dart',
      (j) => DashboardModel.fromJson(j)),
  _Entry('DashboardData', 'dashboard_model.dart',
      (j) => DashboardData.fromJson(j)),
  _Entry('DeliveryBoyModel', 'delivery_boy_model.dart',
      (j) => DeliveryBoyModel.fromJson(j)),
  _Entry('EmailSettingModel', 'email_setting_model.dart',
      (j) => EmailSettingModel.fromJson(j)),
  _Entry('GetReviewUser', 'get_user_review_model.dart',
      (j) => GetReviewUser.fromJson(j)),
  _Entry('ImageBaseUrlModel', 'image_base_url_model.dart',
      (j) => ImageBaseUrlModel.fromJson(j)),
  _Entry('ImageUrlData', 'image_base_url_model.dart',
      (j) => ImageUrlData.fromJson(j)),
  _Entry('LanguageResponse', 'language_model.dart',
      (j) => LanguageResponse.fromJson(j)),
  _Entry('CurrentPlanResponse', 'my_plan_model.dart',
      (j) => CurrentPlanResponse.fromJson(j)),
  _Entry('NotificationModel', 'notification_model.dart',
      (j) => NotificationModel.fromJson(j)),
  _Entry('OrderDetailModel', 'order_detail_model.dart',
      (j) => OrderDetailModel.fromJson(j)),
  _Entry('OrderModel', 'order_model.dart', (j) => OrderModel.fromJson(j)),
  _Entry('PaymentMethod', 'payment_model.dart',
      (j) => PaymentMethod.fromJson(j)),
  _Entry('ProductDetailModel', 'product_detail_model.dart',
      (j) => ProductDetailModel.fromJson(j)),
  _Entry('ProductModel', 'product_model.dart', (j) => ProductModel.fromJson(j)),
  _Entry('ReviewModel', 'review_model.dart', (j) => ReviewModel.fromJson(j)),
  _Entry('ShippingModel', 'shipping_model.dart',
      (j) => ShippingModel.fromJson(j)),
  _Entry('StaticsDataModel', 'static_model.dart',
      (j) => StaticsDataModel.fromJson(j)),
  _Entry('StoreInfoResponse', 'store_info_model.dart',
      (j) => StoreInfoResponse.fromJson(j)),
  _Entry('StoreInfoData', 'store_info_model.dart',
      (j) => StoreInfoData.fromJson(j)),
  _Entry('TaxModel', 'tax_model.dart', (j) => TaxModel.fromJson(j)),
  _Entry('TopOrderModel', 'top_order_model.dart',
      (j) => TopOrderModel.fromJson(j)),
  _Entry('ViewUsedCouponModel', 'view_used_coupon_model.dart',
      (j) => ViewUsedCouponModel.fromJson(j)),
  _Entry('WalletData', 'wallet_model.dart', (j) => WalletData.fromJson(j)),
];

/// The skewed values a key may carry. Each is a real server answer, not a
/// fuzzer's idea of one.
const _skews = <String, dynamic>{
  'empty list (Laravel empty collection)': <dynamic>[],
  'populated list': <dynamic>[
    {'id': 1}
  ],
  'list of scalars': <dynamic>['a', 'b'],
  'bare string': 'ok',
  'number': 7,
  'bool': true,
  'empty object': <String, dynamic>{},
  'explicit null': null,
};

/// The keys in [sourceFile] whose value the parser treats as a CONTAINER:
/// handed to a nested `fromJson`, cast `as List` / `as Map`, or iterated with
/// `.forEach` / `.map` / `.values`.
///
/// Deliberately NOT every key. Setting `status` to a List asserts that
/// `int? status = json['status']` must tolerate a List, which is scalar-type
/// coercion -- a different and far larger class than the one the register
/// records, and one no server actually produces. The container keys are the
/// ones where a missing key or Laravel's empty-collection `[]` crashes the
/// parse, which is the defect this test exists for. Measured: the unrestricted
/// matrix reports 143 rows red across 26 of 32 models, almost all of them
/// `'String' is not a subtype of 'int?'` on a scalar field; the container
/// matrix reports the sites below, and those are real.
///
/// Harvested from the parser's OWN source so it cannot go stale when a field
/// is added.
Set<String> _containerKeysReadBy(String sourceFile) {
  final matches = Directory(packageRoot().path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('/core/model/$sourceFile'));

  if (matches.isEmpty) {
    throw StateError('model source not found: $sourceFile');
  }

  // `commentsStripped`, NOT `codeOnly`: codeOnly blanks STRING LITERALS, and
  // the key IS a string literal, so harvesting from codeOnly returns the empty
  // set for every file and makes the whole matrix below assert nothing against
  // an empty map. That is exactly what happened on the first run of this test,
  // and the `no row is vacuous` test below is what caught it.
  final code = commentsStripped(matches.first.readAsStringSync());

  // Exact expression contexts, not a proximity window. A window around the
  // read picks up neighbouring SCALAR keys -- `coupon_model.dart` casts
  // `discount` `as num?` two lines from a `fromJson`, so a +/-160 character
  // window called `discount` a container and demanded it tolerate a List.
  // Measured: the window harvest reports 92 rows red, the exact harvest
  // reports the sites that are really containers.
  final contexts = <RegExp>[
    // handed to a nested parser: `X.fromJson(json['k'])`, with an optional
    // cast or `?? {}` in between.
    RegExp(
        r"""fromJson\(\s*json\s*\[\s*['"]([^'"\]]+)['"]\s*\]""",
        multiLine: true),
    // cast to a container: `json['k'] as List`, `json['k'] as Map<...>`
    RegExp(r"""json\s*\[\s*['"]([^'"\]]+)['"]\s*\]\s*as\s+(?:List|Map)"""),
    // iterated or walked as a container
    RegExp(
        r"""json\s*\[\s*['"]([^'"\]]+)['"]\s*\]\s*[!?]?\s*\.\s*(?:forEach|values|keys|map\(|whereType|cast<)"""),
    // type-tested as a container -- the ALREADY-GUARDED sites. Included on
    // purpose: they are the ones that must stay green, so a regression that
    // removes a guard turns a passing row red instead of silently dropping
    // the key from the matrix.
    RegExp(
        r"""json\s*\[\s*['"]([^'"\]]+)['"]\s*\]\s*is\s+!?\s*(?:List|Map)"""),
    // coerced through the helpers in lib/network/result.dart. These MUST be
    // here: the fix replaced `json['k'] as List? ?? []` with
    // `jsonList(json['k'])`, and without this context the harvest stopped
    // seeing four models' container keys the moment they were fixed -- so the
    // matrix would have gone green by losing its coverage rather than by the
    // code getting safer. The `no row is vacuous` test below is what caught
    // that, on this file's third run.
    RegExp(
        r"""json(?:Map|List)\(\s*json\s*\[\s*['"]([^'"\]]+)['"]\s*\]"""),
  ];

  final keys = <String>{};

  for (final context in contexts) {
    for (final m in context.allMatches(code)) {
      keys.add(m.group(1)!);
    }
  }

  return keys;
}

void main() {
  // The guard on this whole file. A harvest that silently returns the empty
  // set turns every row below into `parse({})`, which passes for anything.
  // That has happened TWICE while this file was being written -- once because
  // `codeOnly` blanks string literals, and once because the fix replaced the
  // `as List?` spelling the harvest recognised -- so the harvest is asserted
  // rather than trusted.
  test('no model row is vacuous: only the genuinely flat model has no '
      'container key', () {
    // `payment_model.dart` is the one response model with no nested
    // container at all: `PaymentMethod.fromJson` reads four scalars
    // (payment_model.dart:10-20) and hands nothing to another parser. Named
    // here rather than skipped, so a model that LOSES its container keys to a
    // refactor fails this test instead of quietly dropping out of the matrix.
    const flatByDesign = <String>{'payment_model.dart'};

    final empty = <String>{};
    for (final entry in _entries) {
      if (_containerKeysReadBy(entry.source).isEmpty) empty.add(entry.source);
    }

    expect(
      empty,
      equals(flatByDesign),
      reason: 'A model with no harvested container keys is fed `{}` by every '
          'row below, so those rows assert nothing. Either the harvest in '
          '_containerKeysReadBy has stopped recognising a spelling, or a '
          'parser genuinely has no nested container and belongs in '
          'flatByDesign.',
    );
  });

  group('an error-shaped body does not crash the parser', () {
    // The two bodies a failing Laravel endpoint actually returns. Neither
    // carries a `data` object at all, which is the shape that made
    // `data['data']['message']` throw twenty-six times.
    const errorBodies = <String, Map<String, dynamic>>{
      'status 0 with a message and no data': {
        'status': 0,
        'message': 'Unauthenticated.',
      },
      'a 422 validation envelope': {
        'message': 'The given data was invalid.',
        'errors': {
          'name': ['The name field is required.']
        },
      },
      'an empty body': <String, dynamic>{},
    };

    for (final entry in _entries) {
      for (final body in errorBodies.entries) {
        test('${entry.name} survives ${body.key}', () {
          expect(
            () => entry.parse(jsonDecode(jsonEncode(body.value))
                as Map<String, dynamic>),
            returnsNormally,
          );
        });
      }
    }
  });

  group('a version-skewed body does not crash the parser', () {
    // THREE nesting depths, not one. A flat payload that sets EVERY container
    // key to the same skew closes the outermost gate before the inner keys are
    // ever read: with `{"data": ["a","b"]}`, `StaticsDataModel` finds
    // `json['data']` is not a Map, never builds `StaticData`, and `topurl` is
    // never touched -- so a missing element guard three levels down showed as
    // GREEN. Measured, not assumed: deleting the element guard on
    // `static_model.dart`'s `topurl` left the flat-only matrix at
    // "353: All tests passed!". The nested shapes below turn that same
    // deletion red.
    //
    //   depth 1  {k: skew}                 the top-level handoff
    //   depth 2  {k: {k2: skew}}           one level in, through a Map gate
    //   depth 3  {k: [{k2: skew}]}         one level in, through a List gate
    final shapes = <String, Map<String, dynamic> Function(Set<String>, dynamic)>{
      'at the top level': (keys, skew) =>
          <String, dynamic>{for (final k in keys) k: skew},
      'one object deep': (keys, skew) => <String, dynamic>{
            for (final k in keys)
              k: <String, dynamic>{for (final k2 in keys) k2: skew}
          },
      'one list-of-objects deep': (keys, skew) => <String, dynamic>{
            for (final k in keys)
              k: <dynamic>[
                <String, dynamic>{for (final k2 in keys) k2: skew}
              ]
          },
    };

    for (final entry in _entries) {
      final keys = _containerKeysReadBy(entry.source);

      for (final shape in shapes.entries) {
        for (final skew in _skews.entries) {
          test('${entry.name} survives every container key as ${skew.key} '
              '${shape.key}', () {
            // Round-trip through JSON so the runtime types are exactly the
            // ones `jsonDecode` produces in the app -- `_Map<String, dynamic>`
            // and `List<dynamic>` -- and not Dart literal types, which would
            // make the `is Map<String, dynamic>` guards behave differently.
            final payload = jsonDecode(jsonEncode(shape.value(keys, skew.value)))
                as Map<String, dynamic>;

            expect(() => entry.parse(payload), returnsNormally);
          });
        }
      }
    }
  });
}

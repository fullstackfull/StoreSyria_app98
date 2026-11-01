// WS K. "1250.00 null" on the five most money-salient cards a merchant sees.
//
// THE BACKEND PUTS THE SYMBOL ON THE ENVELOPE, NEVER ON AN ITEM.
// `Api\DashboardController::Top_orders` computes it at
// DashboardController.php:7287-7296 and places it at `data.currency_symbol`
// (:7341). The per-item `map()` at :7311-7330 builds nine keys and
// `currency_symbol` is not among them, and the `->select()` at :7306 omits the
// column too — so even `$order->currency_symbol` inside that map would be null.
//
// THE APP READS IT AT THE WRONG LEVEL AND DISCARDS IT AT THE RIGHT ONE.
// `TopOrderItem.fromJson` runs `json['currency_symbol']` against the ITEM
// (top_order_model.dart:75) → null. `TopOrderData` has no such field at all, so
// the envelope value is dropped on the floor. `toOrderData()` copies the null
// through, and `order_screen.dart:456` interpolates it:
//
//     price: '${order.finalPrice} ${order.currencySymbol}'
//
// Dart's `'$x'` is `x.toString()`, and `null.toString()` is the four characters
// n-u-l-l. This repository has met that exact shape before —
// `test/controllers/nested_api_read_test.dart:501-504` records a cached store id
// that became "null" the same way.
//
// So the merchant reads "1250.00 null" on the five largest orders by value, in
// both languages and both themes.
//
// ------------------------------------------------------------------------
// THREE RENDER SITES, NOT ONE, AND TWO OF THEM CANNOT BE FIXED BY THE ENVELOPE.
//
//   1. the Top Orders strip   (order_screen.dart:456) — envelope symbol exists
//   2. the ordinary list      (:635) — per-row `orders.currency_symbol`, which
//      is NULLABLE with no backfill, so every pre-migration order renders "null"
//      (2026_10_12_000102_…:37-40 and :80-84 say so in terms)
//   3. the SEARCH list        (:635 again, fed by searchResults) — `/searchdata`
//      answers a BARE LIST with no envelope at all
//
// Hence two halves. The `?? ''` + `.trim()` at both interpolation sites is what
// covers 2 and 3; threading the envelope through `TopOrderData` is what makes 1
// show the real symbol instead of nothing.
//
// AND THE ENVELOPE SYMBOL CAN ITSELF BE NULL. `currency_rates.symbol` is
// `varchar(20) DEFAULT NULL` (docs/GATE-F-VERIFIED-SCHEMA.md:191) and
// DashboardController.php:7296 tests whether the ROW exists, not whether its
// symbol is set. So this is graceful degradation, not a guarantee the symbol
// appears — which is why `apiText` (fallback '') is right and a non-null
// assertion would be wrong.
//
// `apiText` SPELLING IS LOAD-BEARING: `response_shape_resilience_test` harvests
// container keys by the literal spelling `jsonMap(`/`jsonList(`, so using either
// here would add `currency_symbol` to TopOrderModel's skew set and demand it
// tolerate a List. `apiText` is not a harvested spelling.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/model/top_order_model.dart';

void main() {
  Map<String, dynamic> envelope({
    Object? symbol = 'ل.س',
    Object? itemSymbol,
    bool includeSymbolKey = true,
  }) =>
      <String, dynamic>{
        'status': 1,
        'data': <String, dynamic>{
          'store_id': 1,
          'store_name': 'Damascus Textiles',
          'count': 1,
          if (includeSymbolKey) 'currency_symbol': symbol,
          'top_orders': <dynamic>[
            <String, dynamic>{
              'id': 7,
              'order_number': '#1001',
              'customer_id': 3,
              'customer_name': 'Amina',
              'order_date': '2026-11-01',
              'final_price': '1250.00',
              'payment_status': 'Paid',
              'delivered_status': 1,
              'delivered_status_text': 'Delivered',
              if (itemSymbol != null) 'currency_symbol': itemSymbol,
            },
          ],
        },
      };

  group('the envelope symbol reaches the card', () {
    test('TopOrderData picks it up', () {
      final model = TopOrderModel.fromJson(envelope());

      expect(
        model.data?.currencySymbol,
        'ل.س',
        reason: 'the symbol the backend sends at data.currency_symbol is being '
            'discarded, so the strip has nothing to render but null',
      );
    });

    test('and toOrderData applies it when the item carries none', () {
      final model = TopOrderModel.fromJson(envelope());
      final item = model.data!.topOrders!.single;

      final order = item.toOrderData(
        fallbackCurrencySymbol: model.data!.currencySymbol,
      );

      expect(order.currencySymbol, 'ل.س');
      expect('${order.finalPrice} ${order.currencySymbol ?? ''}'.trim(),
          '1250.00 ل.س');
    });

    test('an item value, if one ever appears, wins over the envelope', () {
      final model = TopOrderModel.fromJson(envelope(itemSymbol: r'$'));
      final item = model.data!.topOrders!.single;

      expect(
        item.toOrderData(fallbackCurrencySymbol: 'ل.س').currencySymbol,
        r'$',
        reason: 'the per-item symbol must take precedence, or a future backend '
            'that starts sending one per row would be overridden by the '
            'envelope',
      );
    });
  });

  group('the literal word "null" never reaches a merchant', () {
    test('when the envelope symbol is absent', () {
      final model = TopOrderModel.fromJson(envelope(includeSymbolKey: false));
      final item = model.data!.topOrders!.single;
      final order =
          item.toOrderData(fallbackCurrencySymbol: model.data!.currencySymbol);

      final rendered = '${order.finalPrice} ${order.currencySymbol ?? ''}'.trim();

      expect(rendered, isNot(contains('null')));
      expect(rendered, '1250.00',
          reason: 'trim() is load-bearing: without it an absent symbol leaves '
              'a trailing space');
    });

    test('when the envelope symbol is explicitly null — which production can '
        'really send', () {
      // `currency_rates.symbol` is nullable and DashboardController tests
      // whether the ROW exists, not whether the symbol is set.
      final model = TopOrderModel.fromJson(envelope(symbol: null));
      final item = model.data!.topOrders!.single;
      final order =
          item.toOrderData(fallbackCurrencySymbol: model.data!.currencySymbol);

      expect('${order.finalPrice} ${order.currencySymbol ?? ''}'.trim(),
          isNot(contains('null')));
    });

    test('and when the symbol arrives as a non-string, which apiText absorbs',
        () {
      final model = TopOrderModel.fromJson(envelope(symbol: 7));

      expect(model.data?.currencySymbol, '7',
          reason: 'apiText coerces rather than throwing; a raw subscript into '
              'a String? field would be an unguarded dynamic assignment');
    });
  });

  group('the two interpolation sites are guarded in source', () {
    // The strip is covered by the envelope above. The ordinary list and the
    // SEARCH list are not — `orders.currency_symbol` is nullable with no
    // backfill, and `/searchdata` sends no envelope at all — so the `??` and
    // the `.trim()` at the render sites are the only cover they have.
    test('order_screen.dart interpolates no bare currencySymbol', () {
      final source =
          File('lib/view/screen/order_screen/order_screen.dart').readAsStringSync();

      expect(
        RegExp(r'\$\{order\.currencySymbol\}').hasMatch(source),
        isFalse,
        reason: 'a bare \${order.currencySymbol} prints the four characters '
            'n-u-l-l for any order whose symbol is null — every pre-migration '
            'row in the ordinary list, and every row in the search list, which '
            'no envelope can reach',
      );
    });
  });
}

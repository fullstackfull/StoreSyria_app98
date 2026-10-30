import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/new_widgets/filter_tabs.dart';

/// P2-07-12 / WS K11 — the status filter must offer every value the column holds.
///
/// `orders.delivered_status` holds NINE values and this filter offered seven. The two it left out
/// are not fulfilment states: 7 is Partially Paid (a payment state) and 8 is Pre Order (an order
/// type), both sharing the column. The web's filter offers all nine and states the failure mode in
/// as many words (`order/partials/filters.blade.php:12-14`):
///
///   "Typing a list by hand is how a filter ends up offering 0–6 and quietly hiding those orders
///    from the one screen a merchant uses to find them."
///
/// It was not only hidden: `api/admin/orderlist` validated `in:0,1,2,3,4,5,6` and answered **422**
/// for either, while F29 had already taught the API to RENDER both names. A merchant could see a
/// partially-paid order in the list and had no way to ask for one.
///
/// THE INDEX MAPPING IS LOAD-BEARING. `order_screen.dart` sends `selectedStatus - 1`, with index 0
/// meaning "all orders" — so the tabs must stay in the column's own order, and the two new ones
/// must be APPENDED rather than inserted. A test on the labels alone would not catch a reordering
/// that silently filters for the wrong status, so the order is asserted too.
void main() {
  setUp(() {
    Get.clearTranslations();
    Get.addTranslations(<String, Map<String, String>>{'en_US': en});
    Get.locale = const Locale('en', 'US');
  });

  Widget host(Widget child) => ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, _) => GetMaterialApp(
          translations: _Translations(),
          locale: const Locale('en', 'US'),
          home: Scaffold(body: child),
        ),
      );

  testWidgets('every status the column holds is offered', (tester) async {
    await tester.pumpWidget(host(
      Builder(
        builder: (context) => orderStatusTabsWidget(
          context: context,
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    for (final label in const <String>[
      'All Orders',
      'Pending',
      'Delivered',
      'Cancelled',
      'Return',
      'Confirmed',
      'Picked Up',
      'Shipped',
    ]) {
      expect(find.text(label), findsOneWidget, reason: '$label is missing from the filter');
    }

    // The two that were missing. The leading dot marks them as not fulfilment stages.
    expect(find.text('• Partially Paid'), findsOneWidget,
        reason: 'partially-paid orders cannot be found from the screen a merchant looks on');
    expect(find.text('• Pre Order'), findsOneWidget,
        reason: 'pre-orders cannot be found from the screen a merchant looks on');
  });

  /// THE ORDER, because the caller maps index to status arithmetically. A reordering would filter
  /// for the wrong status while every label is still present.
  testWidgets('the tabs stay in the column order the caller assumes', (tester) async {
    await tester.pumpWidget(host(
      Builder(
        builder: (context) => orderStatusTabsWidget(
          context: context,
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final labels = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();

    expect(labels, <String>[
      'All Orders',
      'Pending',          // index 1 -> delivered_status 0
      'Delivered',        // 2 -> 1
      'Cancelled',        // 3 -> 2
      'Return',           // 4 -> 3
      'Confirmed',        // 5 -> 4
      'Picked Up',        // 6 -> 5
      'Shipped',          // 7 -> 6
      '• Partially Paid', // 8 -> 7
      '• Pre Order',      // 9 -> 8
    ], reason: 'order_screen.dart sends `selectedStatus - 1`, so the position IS the status');
  });

  /// The source-level counterpart: the two indices must be the LAST two, so appending stays
  /// appending. A future tab inserted in the middle would shift every status below it.
  test('the two new tabs are appended, not inserted', () {
    final source = File('lib/view/new_widgets/filter_tabs.dart').readAsStringSync();

    final partiallyPaid = source.indexOf('partially_paid');
    final preOrder = source.indexOf('pre_order');
    final shipped = source.indexOf('"shipped"');

    expect(shipped, greaterThan(-1));
    expect(partiallyPaid, greaterThan(shipped),
        reason: 'partially_paid must come after shipped or every index below it shifts');
    expect(preOrder, greaterThan(partiallyPaid));
  });
}

class _Translations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => <String, Map<String, String>>{'en_US': en};
}

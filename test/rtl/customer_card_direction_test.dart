// WS K. The customer and delivery-man cards read as two layouts stacked in
// Arabic — and a PASSING TEST was holding the cause in place.
//
// `customer_widget.dart:76-77` and `delivery_boy_widget.dart:77-78` wrap the
// card's header row in
//
//     Directionality(textDirection: TextDirection.ltr, ...)
//
// so in an Arabic UI the customer's name sits flush against the physical LEFT
// edge while the three info rows beneath it — city, order count, phone — all
// begin at the physical RIGHT, because only the header is pinned.
//
// ------------------------------------------------------------------------
// THE TEST THAT KEPT IT THERE, AND WHY ITS PREMISE IS MEASURABLY FALSE.
//
// `test/localization/app_root_wiring_test.dart` has a case called "the two
// deliberate LTR pins are still deliberate" whose comment reads "pin LTR for
// numeric rows ... a phone number or an amount reads left-to-right in an Arabic
// UI too", and whose failure reason says "$path pins LTR deliberately for a
// numeric row."
//
// THE PINNED REGION CONTAINS NO NUMBER. Read it: the wrapper opens at :76 and
// closes at :113, and between them are exactly three things — the name `Text`,
// a `statusPill`, and an `AppPopupMenu`. The numbers are the `_customerInfoRow`
// calls that start at :114, OUTSIDE the wrapper. The same is true of the
// delivery-man card.
//
// So the test was green, the reason it gave was untrue of the code it pointed
// at, and it blocked the fix. That is this project's recurring shape: not an
// open defect, but an open defect with a note on it saying it was intended.
//
// AND THE EARLIER FIX INSIDE IT WAS INERT ON ARRIVAL. `textAlign: TextAlign.start`
// at customer_widget.dart:86 was added to make the name follow the reading
// direction — but `start` resolves against the ambient `Directionality`, and the
// ambient direction there was the hard-coded LTR two lines above. It could never
// have done anything.
//
// ------------------------------------------------------------------------
// THIS FILE PUMPS THE REAL WIDGET rather than reading source, because the defect
// is a resolved direction: `TextAlign.start` and `Directionality.of(context)`
// are both questions only a built tree can answer. The source-level half — that
// no hard-coded LTR pin returns — is one assertion at the end.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/model/customer_model.dart';
import 'package:store_go_app/core/model/delivery_boy_model.dart';
import 'package:store_go_app/view/new_widgets/customer_widget.dart';
import 'package:store_go_app/view/new_widgets/delivery_boy_widget.dart';

void main() {
  CustomerData customer() => CustomerData.fromJson(<String, dynamic>{
        'id': 1,
        'customer_info': <String, dynamic>{
          'name': 'أمينة حداد',
          'email': 'amina@example.test',
          'mobile': '0911222333',
        },
        'status': 1,
      });

  /// The card, built inside ScreenUtilInit under an ambient direction.
  ///
  /// ScreenUtil is required because the card sizes itself with .w/.h/.sp, and
  /// the widget must be BUILT INSIDE the builder — calling it eagerly outside
  /// throws LateInitializationError before an expectation can run.
  Widget host(TextDirection direction, Widget Function(BuildContext) build) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Builder(builder: (inner) => build(inner)),
          ),
        ),
      ),
    );
  }

  /// The direction the NAME actually resolves under, read from the built tree.
  TextDirection directionOfName(WidgetTester tester, String name) {
    final text = tester.widget<Text>(find.text(name));
    expect(text.textAlign, TextAlign.start,
        reason: 'the name stopped using TextAlign.start, so this measurement '
            'no longer describes the thing under test');

    return Directionality.of(tester.element(find.text(name)));
  }

  group('the customer card follows the reading direction', () {
    testWidgets('in Arabic the name resolves RTL, like the rows beneath it',
        (tester) async {
      await tester.pumpWidget(host(
        TextDirection.rtl,
        (context) => customerWidget(context: context, customer: customer()),
      ));
      await tester.pumpAndSettle();

      expect(
        directionOfName(tester, 'أمينة حداد'),
        TextDirection.rtl,
        reason: 'the name is pinned LTR while the city, order count and phone '
            'rows beneath it run RTL, so the card reads as two layouts '
            'stacked. `TextAlign.start` on the name resolves against this '
            'direction, so the pin also made that earlier fix inert.',
      );
    });

    testWidgets('and in English it still resolves LTR', (tester) async {
      await tester.pumpWidget(host(
        TextDirection.ltr,
        (context) => customerWidget(context: context, customer: customer()),
      ));
      await tester.pumpAndSettle();

      expect(directionOfName(tester, 'أمينة حداد'), TextDirection.ltr,
          reason: 'removing the pin must not invert the English layout — the '
              'card should follow the ambient direction, not replace one '
              'hard-coded direction with another');
    });
  });

  group('the delivery-man card has the identical defect', () {
    testWidgets('in Arabic its name resolves RTL too', (tester) async {
      await tester.pumpWidget(host(
        TextDirection.rtl,
        (context) => deliveryBoyWidget(
          context: context,
          deliveryBoy: DeliveryBoyData.fromJson(<String, dynamic>{
            'id': 2,
            'name': 'سامر خليل',
            'email': 'samer@example.test',
            'contact': '0911444555',
            'is_active': 1,
          }),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        Directionality.of(tester.element(find.text('سامر خليل'))),
        TextDirection.rtl,
      );
    });
  });

  test('neither card hard-codes a direction any more', () {
    for (final path in const [
      'lib/view/new_widgets/customer_widget.dart',
      'lib/view/new_widgets/delivery_boy_widget.dart',
    ]) {
      expect(
        File(path).readAsStringSync(),
        isNot(contains('TextDirection.ltr')),
        reason: '$path pins a direction again. The region it used to pin held '
            'a name, a status pill and a menu — no number — so the "numeric '
            'row" justification that app_root_wiring_test used to assert was '
            'never true of this code.',
      );
    }
  });
}

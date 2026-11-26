// ROUTE 1 · the status-badge CATALOGUE baselines — every status in one picture, per type.
// =================================================================================================
//
// WHY A COLUMN AND NOT ONE BADGE PER IMAGE. `CommonStatusBadge` is the single most repeated piece
// of chrome in the shipped admin app: it paints on every order list row, every order detail header,
// the top-orders dashboard card, the payment sheet and the notification list. It has **nineteen
// distinct colour pairs** — nine order statuses plus a default, each in a light and a dark set, plus
// the two payment pairs — and `order_status_badge.dart` carries them as HARDCODED `Color(0x...)`
// literals rather than theme tokens, which is the condition under which this project has repeatedly
// found contrast defects. One baseline per badge would be 40 files for the order type alone. One
// COLUMN per type is four files that show every pair at once, side by side, where a reviewer's eye
// compares them against each other rather than against memory.
//
// AND THIS IS EXACTLY WHERE THE DEFECTS HAVE BEEN. Three of the original seven light order pairs
// shipped below WCAG AA for small text and are recorded verbatim at `order_status_badge.dart:35-37`
// — status 6 Shipped at **1.85:1**, a pale amber word on a pale amber chip, effectively unreadable.
// A dark set did not exist at all: `order_status_badge.dart` contained no `Theme.of(context)`, no
// `isDark` and no `Brightness` reference, so every light pair rendered unchanged on the navy dark
// card at 12.49:1–14.24:1 — near-white tiles glaring off a dark page. Both were found by
// MEASUREMENT (`test/widgets/order_status_label_test.dart` computes every ratio) and neither had
// ever been SEEN. These four images are the first time the repaired set is looked at.
//
// THE ROWS ARE THE WIDGET'S OWN LABELS, so no scaffolding text identifies them and the picture is
// nothing but pixels the app really paints. Read top to bottom:
//
//   order type    0 Pending · 1 Delivered · 2 Cancelled · 3 Return · 4 Confirmed · 5 Picked Up
//                 6 Shipped · 7 Partially Paid · 8 Pre Order · then the DEFAULT branch, driven by
//                 an out-of-range integer, which must read "Status not recognised" and never the
//                 bare lowercase key.
//   payment type  Paid · Unpaid · a NULL status (the `?? 'Unpaid'` fallback, which must look
//                 identical to the row above it) · Paid with a Latin method name · Paid with an
//                 Arabic method name.
//
// TWO SHAPES PER ROW, BECAUSE BOTH SHIP. Every call site uses one of exactly two configurations and
// no other: `isCard: true, showArrow: false` is the compact chip inside a list card
// (`top_orders.dart:146/153/371/378`, `payment_status_bottom_sheet.dart:516`) and
// `isCard: false, showArrow: true` is the tappable form in the order detail header
// (`order_detail_screen.dart:535/1172`). They differ in padding, radius, icon size, text size and
// inter-element spacing — six measurements apiece, every one of them a `.w/.h/.sp` that only a
// render resolves. Both are in every image, the compact on the leading side.
//
// `customLabel` IS NOT RENDERED, deliberately: no call site in `lib/` passes it. It is reachable API
// with no caller, and `order_detail_screen.dart:538` records that the one call site which DID pass
// it was defective — `customLabel` short-circuits the badge's own translation, so the server's
// English string defeated `getOrderLabel` entirely. A baseline for a path nothing calls would
// freeze a picture no merchant can reach.
//
// `Wrap`, NOT `Row`, FOR THE TWO SHAPES. The longest label — "Status not recognised" — is about
// 180pt in the detail shape and 135pt in the compact one, which together exceed the 336pt of usable
// width at the 360pt design size. A `Row` would throw a RenderFlex overflow and fail the capture; a
// `Wrap` puts the second shape on its own run and the picture SHOWS that the pair does not fit on
// one line, which is information rather than a crash.
//
// FOUR COMBINATIONS EACH — Arabic (RTL) and English (LTR), light and dark — and the badges are the
// surface where that matters most, because the dark pairs are the newest code in the file and the
// Arabic labels are longer than the English ones in six of the ten order rows.
//
// NOTHING IS ASSERTED UNTIL A HUMAN HAS LOOKED. Each case skips while its baseline is absent. See
// `test/support/golden_harness.dart` for why a baseline committed by the agent that wrote the test
// is worth nothing.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/view/new_widgets/order_status_badge.dart';

import '../support/golden_harness.dart';

/// Every `delivered_status` integer the badge has a named config for, plus one that it does not.
///
/// NINE AND A DEFAULT, NOT SEVEN. `orders.delivered_status` carries 0..8 and the two beyond the
/// seven fulfilment states are the awkward ones — 7 is Partially Paid, a PAYMENT state, and 8 is
/// Pre Order, an order TYPE, both recorded in the same integer column (`order_status_badge.dart:151-157`).
/// They were falling through to the grey default, which is also what a corrupt value gets, so a
/// real Pre Order looked like an error.
///
/// `99` IS NOT PADDING. It drives the `default:` branch of both `getOrderConfig` and
/// `getOrderLabel`, and that branch has already shipped broken once: `'unknown'` has no key in
/// either translation file and GetX returns the key when a lookup misses, so the badge rendered the
/// literal lowercase word `unknown` in both languages. The repaired branch returns
/// `'status_unrecognised'.tr`. The last row of every order image is the proof.
const List<int> kOrderStatusesRendered = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 99];

/// The payment states the badge can be asked for, as (status, method) pairs.
///
/// A NULL STATUS IS A REAL CASE, not a defensive one: `order_detail_screen.dart:1181` passes
/// `model.paymentStatus ?? 'Unpaid'` because the field is nullable on the wire, and
/// `getPaymentConfig`/`_getLabel` each apply their own `?? 'Unpaid'` on top. The third row must
/// therefore be pixel-identical to the second; if it is not, two code paths disagree about what an
/// absent payment status looks like.
///
/// BOTH BIDI DIRECTIONS ARE EXERCISED. `paid_by2` is `'Paid by @method'` / `'تم الدفع عبر @method'`
/// and the method name is a server string that is NOT translated, so one of the two runs inside that
/// label is always foreign to the line it sits in. A Latin method in the Arabic image and an Arabic
/// method in the English image are the two shapes that reorder, and reordering inside a chip whose
/// text is `maxLines: 1` with an ellipsis is exactly the thing an assertion cannot see.
const List<(String?, String?)> kPaymentStatesRendered = <(String?, String?)>[
  ('Paid', null),
  ('Unpaid', null),
  (null, null),
  ('Paid', 'Stripe'),
  ('Paid', 'الدفع عند التسليم'),
];

/// The gutter between the chips and the viewport edge.
///
/// SCAFFOLDING, AND THE ONLY SCAFFOLDING IN THESE IMAGES. Every real call site wraps the badge in a
/// padded card or row, so a chip flush against the physical edge of the surface is a framing the app
/// never draws — and the chip's own 1px border, which is what identifies it as a chip on the dark
/// page (SC 1.4.11, `order_status_badge.dart:285-287`), cannot be judged against a viewport edge it
/// is touching. Symmetric, so it adds no direction signal of its own.
const double kCatalogueGutter = 12;

/// One row of the catalogue: the same status in both shipped shapes.
Widget _bothShapes({required Widget compact, required Widget detail}) => Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 6.h,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[compact, detail],
      ),
    );

Widget _catalogue(List<Widget> rows) => Padding(
      padding: EdgeInsets.all(kCatalogueGutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );

void main() {
  setUpAll(loadAppFonts);

  // See trap 2 in golden_harness.dart: ThemeController.theme mutates the process-global AppColor,
  // so without this a dark case leaves every later light case rendering dark values. The badge
  // itself reads Theme.of(context).brightness rather than those globals, but the rule is the rule
  // and the next surface added to this file may not be so independent.
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  // THE SKIP IS AT RUNTIME, NOT `skip:`. `testWidgets`'s `skip` is typed `bool?` — not `dynamic`
  // like `test()`'s — so a String reason cannot be passed to it and does not compile. The first
  // version of customer_card_golden_test.dart learned this the expensive way: `goldenSkipReason()`
  // was never called and eight cases skipped in SILENCE inside a gate this repository declares
  // blocking and 100 per cent. `markTestSkipped` carries the reason into the run output.
  bool skipUnlessCaptured(String surface, GoldenCombination combination) {
    if (goldenReady(surface, combination)) return false;
    markTestSkipped(goldenSkipReason(surface, combination));
    return true;
  }

  for (final combination in kFourCombinations) {
    testWidgets(
      'every order status renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('order-status-badge-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          // Built inside a Builder: the badge sizes every one of its six measurements with
          // .w/.h/.sp/.r, so it must be constructed under the ScreenUtilInit subtree.
          // Constructing it eagerly outside throws LateInitializationError before an expectation
          // can run — recorded in customer_card_direction_test.dart:66-69.
          child: Builder(
            builder: (context) => _catalogue(<Widget>[
              for (final status in kOrderStatusesRendered)
                _bothShapes(
                  compact: CommonStatusBadge(
                    type: StatusBadgeType.order,
                    orderStatus: status,
                    isCard: true,
                  ),
                  detail: CommonStatusBadge(
                    type: StatusBadgeType.order,
                    orderStatus: status,
                    showArrow: true,
                  ),
                ),
            ]),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('order-status-badge-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'every payment status renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('payment-status-badge-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          child: Builder(
            builder: (context) => _catalogue(<Widget>[
              for (final (status, method) in kPaymentStatesRendered)
                _bothShapes(
                  compact: CommonStatusBadge(
                    type: StatusBadgeType.payment,
                    paymentStatus: status,
                    paymentMethod: method,
                    isCard: true,
                  ),
                  detail: CommonStatusBadge(
                    type: StatusBadgeType.payment,
                    paymentStatus: status,
                    paymentMethod: method,
                    showArrow: true,
                  ),
                ),
            ]),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('payment-status-badge-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );
  }
}

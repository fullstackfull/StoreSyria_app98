// What the My Plan screen shows a merchant whose plan has no ceiling.
//
// THE CRASH CAME FIRST. `Api\DashboardController` returns the STRING
// 'Unlimited' for an unlimited quota, in six places
// (DashboardController.php:7505-7519), while `PlanLimit` declared
// `final int max` and parsed it as `json['max'] ?? 0`. `??` substitutes for
// null ONLY, so the String went into an `int` field and `fromJson` threw a
// TypeError — a merchant on a top-tier plan could not open the screen at all.
// `response_shape_resilience_test.dart` covers that half, and explains why its
// own thousands of generated cases could not reach it: the generator harvests
// only CONTAINER keys, so a scalar arriving as the wrong type is invisible to
// every one of them.
//
// THIS FILE COVERS THE OTHER HALF, which the model fix alone would have left
// broken in a quieter way. `PlanLimit` normalises 'Unlimited' to the backend's
// own `-1` sentinel; `usageCard` interpolated `'$used / $max'`. So the screen
// would have stopped crashing and started reading
//
//     12 / -1
//
// over a progress bar at whatever `percentage` happened to hold. That is the
// same defect the Laravel dashboard's storage card carried before F249, which
// printed WorkDo's unlimited sentinel as `(MB / -1MB)` above a donut reading
// `0% Used`: a sentinel rendered as a quantity, beside a percentage of nothing.
//
// A model test cannot see any of that. These pump the real widget.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/core/model/my_plan_model.dart';
import 'package:store_go_app/translations/ar.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/view/new_widgets/my_plan_widget.dart';

void main() {
  setUpAll(() {
    Get.addTranslations({'en': en, 'ar': ar});
  });

  setUp(() {
    Get.locale = const Locale('en', 'US');
  });

  /// ScreenUtil is required because the card sizes itself with .w/.h/.r/.sp —
  /// and the card must be BUILT INSIDE the builder, not passed in as a child.
  /// `usageCard()` reads `.w`/`.r` while it constructs, so calling it eagerly
  /// outside throws `LateInitializationError` before a single expectation runs.
  Widget host(
    Widget Function() build, {
    TextDirection direction = TextDirection.ltr,
  }) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(body: SingleChildScrollView(child: build())),
        ),
      ),
    );
  }

  Widget Function() cardFor(PlanLimit limit) => () => usageCard(
        title: 'Products',
        used: limit.used,
        max: limit.max,
        remaining: limit.remaining,
        percentage: limit.percentage,
        icon: Icons.shopping_bag_outlined,
        isDark: false,
      );

  /// The payload the server really sends for an unlimited quota.
  PlanLimit unlimited() => PlanLimit.fromJson(<String, dynamic>{
        'max': 'Unlimited',
        'used': 12,
        'remaining': 'Unlimited',
        'percentage': 0,
      });

  PlanLimit numbered() => PlanLimit.fromJson(<String, dynamic>{
        'max': 50,
        'used': 12,
        'remaining': 38,
        'percentage': 24.0,
      });

  group('an unlimited quota', () {
    testWidgets('never renders the sentinel as a number', (tester) async {
      await tester.pumpWidget(host(cardFor(unlimited())));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('-1'),
        findsNothing,
        reason: 'The card is printing the unlimited sentinel as a quantity. A '
            'merchant reads "12 / -1" as a broken screen, which it is.',
      );
    });

    testWidgets('says unlimited, in the language the merchant chose',
        (tester) async {
      await tester.pumpWidget(host(cardFor(unlimited())));
      await tester.pumpAndSettle();
      expect(find.textContaining('12 / Unlimited'), findsOneWidget);
      expect(find.textContaining('Unlimited Remaining'), findsOneWidget);

      Get.locale = const Locale('ar', 'SA');
      await tester.pumpWidget(
        host(cardFor(unlimited()), direction: TextDirection.rtl),
      );
      await tester.pumpAndSettle();

      // `findsWidgets`, not `findsOneWidget`: the card legitimately says it
      // twice — once on the quota line and once on the "N remaining" line,
      // which carries the same sentinel and was the half this test caught.
      expect(
        find.textContaining('غير محدود'),
        findsWidgets,
        reason: 'An Arabic merchant is being shown the English word, which is '
            'how an untranslated key reaches production without anyone seeing '
            'it — the string is still readable, just not theirs.',
      );
      expect(find.textContaining('Unlimited'), findsNothing);
    });

    testWidgets('shows no progress, because a percentage of unlimited is not '
        'a number', (tester) async {
      await tester.pumpWidget(host(cardFor(unlimited())));
      await tester.pumpAndSettle();

      final bars = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      expect(
        bars,
        isNotEmpty,
        reason: 'no progress bar rendered at all, so this test measured nothing',
      );
      for (final bar in bars) {
        expect(
          bar.value,
          0.0,
          reason: 'The bar is showing a fraction of a quota that has no '
              'ceiling. Whatever it draws is meaningless.',
        );
      }
    });
  });

  group('a numbered quota is untouched', () {
    testWidgets('renders both numbers', (tester) async {
      await tester.pumpWidget(host(cardFor(numbered())));
      await tester.pumpAndSettle();

      expect(find.textContaining('12 / 50'), findsOneWidget);
      expect(find.textContaining('Unlimited'), findsNothing);
    });

    testWidgets('and its progress bar reflects the real percentage',
        (tester) async {
      await tester.pumpWidget(host(cardFor(numbered())));
      await tester.pumpAndSettle();

      final bars = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bars, isNotEmpty);
      for (final bar in bars) {
        expect(bar.value, closeTo(0.24, 0.001));
      }
    });
  });

  group('the quota a merchant has actually filled', () {
    testWidgets('a full quota does not overflow the bar', (tester) async {
      // The server computes the percentage; nothing stops it exceeding 100
      // when `used` has passed `max` — which happens on a plan downgrade.
      await tester.pumpWidget(host(cardFor(PlanLimit.fromJson(
        <String, dynamic>{
          'max': 10,
          'used': 14,
          'remaining': 0,
          'percentage': 140.0,
        },
      ))));
      await tester.pumpAndSettle();

      final bars = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bars, isNotEmpty);
      for (final bar in bars) {
        expect(
          bar.value,
          1.0,
          reason: 'A bar past 1.0 throws in release mode rather than drawing '
              'a longer bar.',
        );
      }
      expect(find.textContaining('14 / 10'), findsOneWidget);
    });
  });
}

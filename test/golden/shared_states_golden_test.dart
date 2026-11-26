// ROUTE 1 · wave 3 — the shared STATE surfaces: empty, error, stale and the blocking loader.
// =================================================================================================
//
// WHY THESE, AND WHY THEY ARE WORTH A PICTURE. The Phase 2.5 inventory carries "Shared empty /
// error / stale states" and "Shared buttons / loader" as surfaces of their own, and it is right to:
// each one replaces a whole screen's body, so a defect in it is a defect on every list in the app
// at once. Three of them have already shipped broken, and every repair was driven by a MEASUREMENT
// rather than by anyone seeing the result:
//
//   * `EmptyState` painted its icon and its message in `Colors.grey.shade400` in light mode —
//     1.88:1 on the light background. A merchant whose list was empty was shown a sentence they
//     could not read telling them why (`error_empty_state.dart:62-79`).
//   * `ErrorState`'s offline glyph was `Colors.grey` at 2.68:1, under the 3:1 WCAG 1.4.11 asks of
//     a graphic that carries meaning (`:139-146`).
//   * `StaleDataNotice` shipped with a single `#D97706` amber for both themes — 2.86:1 in light —
//     and a `#777777` body line at 4.01:1 (`:232-262`).
//
// `test/a11y/empty_state_contrast_test.dart` and `stale_notice_contrast_test.dart` already assert
// the repaired ratios, and they are stronger than a picture. What no assertion covers is whether
// the three read as a coherent family, whether the Arabic lines break where they should, and
// whether the stale notice's directional inset really follows the reading direction. Those are
// questions only the image answers.
//
// THE READING ORDER, since nothing in the picture labels the specimens — the same choice
// `status_badge_golden_test.dart` made, and for the same reason: a caption is scaffolding the app
// never draws, and each of these three is visually unmistakable.
//
//   empty-error-stale-column   EmptyState (inbox glyph, one line) · ErrorState (wifi-off glyph in
//                              a tinted circle, a heading, a message and a round retry button) ·
//                              StaleDataNotice (the amber inline strip with its own retry link).
//   blocking-loader            `LoadingWidget`, the dialog `Loader.showLoader()` puts over the
//                              screen. It is one centred spinner and nothing else, which is the
//                              point: until P2.5-P2 it rendered NOTHING at all, because
//                              `showLoader()` constructed it as an expression and threw it away.
//                              Four live call sites showed the merchant no loader whatsoever.
//
// BOUNDED HEIGHTS ARE REQUIRED, NOT CHOSEN. `EmptyState` and `ErrorState` each build a
// `CustomScrollView` with a `SliverFillRemaining` (`error_empty_state.dart:49`, `:127`): they are
// full-viewport bodies, not inline blocks, and in an unbounded column they throw "Vertical viewport
// was given unbounded height". The heights below are the ones `component_gallery_capture_test.dart`
// already proved render, so the two evidence sets photograph the same box.
//
// `pumpAndSettle` IS BANNED ON THE LOADER, and this is the trap that distinguishes this file from
// the three golden files before it. `LoadingWidget` is a bare `CircularProgressIndicator`
// (`loading_widget.dart:96-100`) — an INDETERMINATE animation that never completes, so
// `pumpAndSettle` has nothing to settle to and times out. A fixed pump schedule is used instead,
// which is deterministic because a widget test drives a fake clock: the same two pumps always land
// the spinner on the same frame. Verified by capturing twice and comparing the files byte for byte.
//
// NOTHING IS ASSERTED UNTIL A HUMAN HAS LOOKED. Each case skips while its baseline is absent and
// says in its skip reason how to capture it. See `test/support/golden_harness.dart` for why a
// baseline committed by the agent that wrote the test is worth nothing.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:store_go_app/view/widget/error_empty_state.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';

import '../support/golden_harness.dart';

// The gutter between a specimen and the viewport edge — the only scaffolding in these images, for
// the reason `status_badge_golden_test.dart` records: every real call site sits inside a padded
// body, so a component flush against the physical edge is a framing the app never draws.
// Symmetric, so it adds no direction signal of its own.
const double kStateGutter = 12;

// The bounded boxes the two full-viewport components are given.
//
// 190 FOR THE EMPTY STATE IS `component_gallery_capture_test.dart`'s, kept so the two evidence
// sets photograph the same box. 300 FOR THE ERROR STATE IS NOT, AND THE REASON IS A DEFECT THIS
// FILE'S FIRST CAPTURE FOUND IN ITSELF.
//
// The gallery gives `ErrorState` 210, and 210 IS TOO SHORT: the component stacks a 90pt circle,
// a 24pt gap, a 20sp heading, a 12pt gap, a two-line 15sp message, a 28pt gap and a round retry
// `IconButton` (`error_empty_state.dart:133-192`), which comes to roughly 270. At 210 the
// `SliverFillRemaining` is scrolled and the RETRY BUTTON IS CLIPPED — in the first four images
// captured here only a blue crescent of it showed above the notice below. A baseline that froze
// that would be pinning a framing the app never draws, and the control a merchant has to press to
// recover would be the part missing from the picture.
//
// Worth recording beyond this file: the same 210 is in the gallery's own specimen, so
// `evidence/flutter-components2-2026-11-10/`'s error-state captures clip the retry button too.
// Not changed from here — that is a reviewed evidence set — but it is wrong in the same way.
const double kEmptyStateBox = 190;
const double kErrorStateBox = 300;

void main() {
  setUpAll(loadAppFonts);

  // See trap 2 in golden_harness.dart: ThemeController.theme mutates the process-global AppColor,
  // so without this a dark case leaves every later light case rendering dark values.
  setUp(resetThemeColours);
  tearDown(resetThemeColours);

  // THE SKIP IS AT RUNTIME, NOT `skip:`. `testWidgets`'s `skip` is typed `bool?` — not `dynamic`
  // like `test()`'s — so a String reason cannot be passed to it and does not compile. The first
  // version of customer_card_golden_test.dart learned this the expensive way: eight cases skipped
  // in SILENCE inside a gate this repository declares blocking and 100 per cent.
  bool skipUnlessCaptured(String surface, GoldenCombination combination) {
    if (goldenReady(surface, combination)) return false;
    markTestSkipped(goldenSkipReason(surface, combination));
    return true;
  }

  for (final combination in kFourCombinations) {
    testWidgets(
      'the empty, error and stale states render as their baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('empty-error-stale-column', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          // Built inside a Builder: every measurement in these three is a .w/.h/.sp/.r, so they
          // must be constructed under the ScreenUtilInit subtree. Constructing eagerly outside
          // throws LateInitializationError before an expectation can run.
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(kStateGutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: kEmptyStateBox,
                    child: EmptyState(message: 'no_orders_found'.tr),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: kErrorStateBox,
                    child: ErrorState(message: 'connection_failed'.tr, onRetry: () {}),
                  ),
                  SizedBox(height: 8.h),
                  // THE MESSAGE IS A SERVER STRING, NOT A KEY, and the specimen that invented a
                  // key was wrong: every call site is
                  // `StaleDataNotice(message: controller.errorMessage.value, ...)`, so a key
                  // rendered here would read as a missing translation in the component itself.
                  StaleDataNotice(message: 'connection_failed'.tr, onRetry: () {}),
                ],
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('empty-error-stale-column', combination)),
        );
      },
      tags: const <String>['golden'],
    );

    testWidgets(
      'the blocking loader renders as its baseline — ${combination.name}',
      (tester) async {
        if (skipUnlessCaptured('blocking-loader', combination)) return;

        pinGoldenSurface(tester);

        await tester.pumpWidget(goldenHost(
          dark: combination.dark,
          direction: combination.direction,
          // THE WHOLE SURFACE, because that is the loader's real framing: `showLoader()` puts
          // it up with `Get.dialog(const LoadingWidget(), barrierDismissible: false)`
          // (`loading_widget.dart:70-72`), so it covers the screen and centres in it. A 160pt
          // box would have centred the spinner somewhere no merchant ever sees it.
          //
          // WHAT THE PICTURE DOES NOT HOLD, said plainly: the dialog ROUTE is not pumped, so the
          // barrier scrim `Get.dialog` paints behind it is absent. The spinner, its size, its
          // stroke and its per-theme colour are the real thing; the backdrop is the plain
          // scaffold.
          child: SizedBox(
            width: kGoldenDesignSize.width,
            height: kGoldenDesignSize.height,
            child: const LoadingWidget(),
          ),
        ));

        // A FIXED SCHEDULE, NOT `pumpAndSettle` — see this file's header. The spinner is
        // indeterminate, so there is no quiescent state to settle to; these two pumps put it on
        // the same frame every run because the test clock is fake and advances only here.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(goldenPath('blocking-loader', combination)),
        );
      },
      tags: const <String>['golden'],
    );
  }
}

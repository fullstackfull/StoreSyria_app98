# Tests

## These tests ARE executed — and this file said the opposite until 2026-11-01

**1367 tests pass** on Flutter 3.47.7 / Dart 3.13.5 (`flutter test`, measured
2026-11-01 in the Phase 02 container). They are run as a gate, not written and
left.

This page used to open with *"These tests have NOT been executed — there is no
Dart or Flutter SDK in the environment where they were written"* and describe
every file as an **unexecuted deliverable**. That was true when it was written
and has been false for the whole of Phase 02. It is corrected here rather than
quietly overwritten, because a README that understates the evidence is as
misleading as one that overstates it: the next reader either redoes work that is
done, or distrusts a green run that is real.

The file table below had also stopped covering the tree: it listed 8 files
against 56 on disk.

## What is here

56 test files. Grouped by what they protect rather than listed one by one,
because the list is what went stale last time.

| Directory | Guards |
|---|---|
| `support/` | shared helpers: package root, `lib/` walk, and two lexers — `codeOnly` (comments *and* string literals blanked) and `commentsStripped` (comments blanked, literals kept) |
| `security/` (17) | credential logging, the single Bearer-scheme site, release signing with no debug-keystore fallback, TLS not weakened, forced-logout behaviour, token storage, FCM token ownership, store-switch cache isolation, merchant permission gating, and that a refusal reads as a refusal rather than an empty success |
| `network/` (10) | status-code classification, 401/403/422/429 handling, the defensive decode, nested reads, rate-limit backoff, blank-message fallback, response-shape resilience, currency symbols |
| `contract/` (3) | the server API contract: endpoint shapes, newly gated endpoints, permission-gated endpoints |
| `controllers/` (5) | no unguarded nested subscript, no unguarded parser handoff, a success toast requires a `status == 1` check, the login refusal reaches the user |
| `ui/` (6) | dashboard figure honesty, order-filter status coverage, screen-state census, setting-gate rendering, the stale-list notice, stock-state parity with the web |
| `a11y/` (4) | icon-button accessible names, state announcements, and two contrast suites — toast icon types and the stale-data notice |
| `localization/` (3) | translation-key completeness, ambient direction, app-root wiring |
| `rtl/` (2) | directional positioning and card direction under RTL |
| `widgets/` (4) | balance card, icon tint, order-status label, plan-usage card |
| `translations/` | localization completeness as a ratchet over a measured baseline |
| `utils/` | the redaction logic in `app_log` |

## What genuinely CANNOT be verified here, stated plainly

These are real limitations of this environment, not of the tests. None of them
is hidden under a green run.

- **No physical device and no emulator.** `flutter test` runs on the Dart VM
  with a headless test harness. Nothing here proves behaviour on an Android or
  iOS device: not a release APK's logcat output, not Crashlytics breadcrumbs,
  not real keyboard or locale switching, not performance.
- **No golden/screenshot verification.** There are no `matchesGoldenFile`
  baselines, so no test compares a *rendered image*. The contrast suites that
  can render do (`a11y/stale_notice_contrast_test.dart` pumps the widget in both
  themes and reads the resolved colours off the rendered `Container`); the one
  that cannot says so in its own docblock.
- **Overlay-based toasts cannot be pumped.** `Get.overlayContext` resolves to a
  `_Theater` with no `Overlay` ancestor under `flutter_test`, so
  `a11y/toast_type_contrast_test.dart` pins the per-theme palette map, the
  accessor's body and a count of its consumption sites at source instead of
  measuring painted pixels. That is a weaker proof and the file says which part
  is weaker and why.
- **Source-reading guards are source-reading guards.** Several suites decide
  their question from the sources rather than by running the app — see the next
  section for why that is the right trade for those specific questions, and note
  that it means they answer *"did somebody add this back?"*, not *"what does the
  app do on a handset?"*.
- **`flutter analyze` and `flutter build` mutate `analysis_options.yaml`.** Both
  re-inject an `analyzer: exclude:` block listing the platform directories. It
  is reverted after every run and must never be committed; a diff of that file
  after a tooling run is the tool's doing, not a change anybody made.

## Why some of them read source instead of running the app

The behavioural question behind the logging findings — *does a credential reach
logcat in a release build?* — needs a physical device and a signed release APK.
The question that actually regresses in review is *did somebody add a debugging
line back?*, and that is decidable from the sources. These tests are cheap, have
no device dependency, and fail in the pull request rather than in an incident.

The lexers matter: a guard that cannot tell `print(` in code from `print(` in a
comment cries wolf once and then gets suppressed forever.

## One test per case, deliberately

Element-tree reuse across `expect`s inside a single `testWidgets` has produced
false readings here, so a widget case that needs a fresh tree gets its own
`testWidgets`. A suite that bundles several scenarios into one case can pass on
the first and never reach the rest.

## `test/widget_test.dart` was deleted, deliberately

It was the unmodified `flutter create` counter template — `'Counter increments
smoke test'`, `expect(find.text('0'), …)`, `tester.tap(find.byIcon(Icons.add))`
— against an app that has no counter. It could not even reach its assertions:
`pumpWidget` throws on a null `getStorage` because `GetStorage.init()` never
runs in a test. Any CI added on top of it would have gone red on day one and
taught the team to ignore the test job.

## Pairing requirement

`security/no_credential_logging_test.dart` must stay **green** before
`firebase_crashlytics_collection_enabled` is ever flipped to `true` in the
Android manifest. Crashlytics uploads recent log output as crash breadcrumbs,
so enabling it while a credential can reach the log would ship merchant
passwords and bearer tokens to a third party with a retention period. The two
must move together.

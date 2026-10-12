# Tests

## These tests have NOT been executed

There is no Dart or Flutter SDK in the environment where they were written, so
`flutter test`, `flutter analyze`, `flutter build` and `dart` are all
unavailable. Every test here is an **unexecuted deliverable**. Each assertion
was checked by porting its logic to a script and running that against the real
sources — which proves the *predicate* holds today, and does **not** prove the
Dart compiles. Run `flutter analyze && flutter test` on a machine with the SDK
before relying on any of it.

## What is here

| File | Guards |
|---|---|
| `support/source_tree.dart` | shared helpers: package root, `lib/` walk, and two lexers — `codeOnly` (comments *and* string literals blanked) and `commentsStripped` (comments blanked, literals kept) |
| `security/no_credential_logging_test.dart` | SEC-20a / R7-02, SEC-20b / R7-03, SEC-20c / R7-04 — no `print(`, no credential or response body in a log call, the seam is `kReleaseMode`-guarded |
| `security/authorization_header_single_site_test.dart` | R7-N1 — the Bearer scheme is built in exactly one place |
| `security/release_signing_test.dart` | SEC-21 / R7-01 — no debug-keystore fallback, signing read from an untracked `key.properties`, release build fails loudly without it, no keystore in the tree |
| `security/no_certificate_validation_override_test.dart` | R7-09 — TLS verification is not weakened and no cleartext endpoint exists |
| `network/api_error_handling_test.dart` | 401 / 403 / 422 / 429 handling and the defensive decode |
| `translations/translation_keys_test.dart` | localization completeness, as a ratchet over a measured baseline |
| `utils/app_log_test.dart` | the only behavioural suite here: it actually exercises the redaction logic |

## Why most of them read source instead of running the app

The behavioural question behind the logging findings — *does a credential reach
logcat in a release build?* — needs a physical device and a signed release APK.
The question that actually regresses in review is *did somebody add a debugging
line back?*, and that is decidable from the sources. These tests are cheap, have
no device dependency, and fail in the pull request rather than in an incident.

The lexers matter: a guard that cannot tell `print(` in code from `print(` in a
comment cries wolf once and then gets suppressed forever.

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

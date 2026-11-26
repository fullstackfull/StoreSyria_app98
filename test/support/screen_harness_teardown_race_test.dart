// P06-WS8-FLAKE-01 — the intermittent `test/screens/` failure, pinned at its actual cause.
// =================================================================================================
//
// WHAT WAS HAPPENING, FROM A CAPTURED FAILURE RATHER THAN A HYPOTHESIS. `test/screens/` failed
// roughly one run in ten, on a different test name each time, and passed on re-run. Three names
// were seen across the observed failures — `bottom_sheet_editors_capture_test` (the category
// sheet, light-ltr), `operations_screen_capture_test` (wallet, light-ltr) and
// `auth_flow_capture_test` (onboarding, light-ltr) — and one of them was on the UNMODIFIED tree
// at `5b3c6bb`, so it is not anybody's change. Ten runs were captured in full; run 7 failed and
// its log is the evidence:
//
//     01:05 +318: auth_flow_capture_test.dart: (tearDownAll)
//     01:05 +317 -1: auth_flow_capture_test.dart: onboarding renders in light-ltr [E]
//       PlatformException(error, Null check operator used on a null value, null, null)
//       package:flutter/src/services/platform_channel.dart  MethodChannel._invokeMethod
//       package:get_storage/src/storage/io.dart 124:20      StorageImpl._getFile
//       package:get_storage/src/storage/io.dart  48:5       StorageImpl._madeBackup
//       package:get_storage/src/storage/io.dart  44:5       StorageImpl.flush
//       package:get_storage/src/storage_impl.dart 146:23    GetStorage._flush
//       ... GetQueue ... GetStorage._addToQueue ... Microtask.exec ... GetStorage._tryFlush
//
// **THE ERROR ARRIVES AFTER `(tearDownAll)`.** That one line explains every confusing property of
// this flake. It is not the named test failing; it is an unhandled asynchronous error that
// `flutter_test` attributes to whichever test in the file is still open when it lands, which is
// why the name moves and why it looked like a different bug each time.
//
// THE MECHANISM, read out of `get_storage` 2.1.1 rather than guessed:
//
//   1. a screen writes through `CacheService`, or `resetScreenHarness()` removes a `cache_*` key;
//   2. `GetStorage._tryFlush()` schedules the write through `GetQueue` — fire and forget;
//   3. `StorageImpl.flush()` finishes by calling `_madeBackup()`, which is `_getFile(true).then(...)`
//      — **not awaited by anything**, so its failure is an unhandled async error, not a rejected
//      Future somebody is holding;
//   4. `_getFile` → `_fileDb` → `_getImplicitDir` → `getApplicationDocumentsDirectory()`, which is
//      a **platform channel call** this harness mocks;
//   5. `disposeScreenHarness()` ran in `tearDownAll` and set `_storageDir = null`;
//   6. the mock handler was `(call) async => _storageDir!.path`. The `!` throws, the throw is
//      encoded as an error envelope, and `MethodChannel._invokeMethod` turns it into the
//      `PlatformException` above.
//
// So it is a race between a fire-and-forget disk write and teardown, and under load — a kernel
// rebuild after a tree change, four test processes on four cores — the write is still in flight
// more often. Run 7 was the first run after `lib/` changed.
//
// IT IS THE ONLY MOCK IN THIS REPOSITORY SHAPED THAT WAY, which is why only `test/screens/` ever
// flaked. The other eight `path_provider` mocks — `nested_api_read_test`, `setting_gate_rendering_test`,
// `list_cards_golden_test`, `rate_limit_backoff_test`, `newly_gated_endpoints_test`,
// `token_storage_test`, `permission_store_switch_test`, `merchant_permissions_test` — all capture
// a NON-NULLABLE local `storageDir` in the closure, so none of them can throw however late it is
// called. `screen_harness.dart` was the one that read a field teardown clears.
//
// WHAT THIS TEST PINS, AND WHY IT IS DETERMINISTIC WHERE THE DEFECT WAS NOT. The race is not
// reproducible on demand; the broken line is. This drives the mocked channel directly, AFTER
// teardown — exactly the call `_madeBackup()` makes late — and asserts it answers rather than
// throwing. Before the fix it fails with the same `PlatformException(error, Null check operator
// used on a null value)` the captured run shows; after it returns a path.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screen_harness.dart';

const _channel = 'plugins.flutter.io/path_provider';
const _codec = StandardMethodCodec();

/// Asks the mocked channel for the documents directory, the way `get_storage` does.
///
/// Returns whatever the handler answered. Throws `PlatformException` if the handler threw, because
/// that is what `decodeEnvelope` does with an error envelope — the same translation
/// `MethodChannel._invokeMethod` performs in the stack above.
Future<Object?> _askForDocumentsDirectory(TestWidgetsFlutterBinding binding) async {
  final envelope = await binding.defaultBinaryMessenger.send(
    _channel,
    _codec.encodeMethodCall(const MethodCall('getApplicationDocumentsDirectory')),
  );

  expect(envelope, isNotNull,
      reason: 'nothing answered $_channel, so the harness is no longer mocking it at all and '
          'get_storage would fail with MissingPluginException instead');

  return _codec.decodeEnvelope(envelope!);
}

void main() {
  late TestWidgetsFlutterBinding binding;

  setUpAll(() async {
    binding = TestWidgetsFlutterBinding.ensureInitialized();
    await initScreenHarness();
  });

  test('premise: the mocked path_provider channel answers while the harness is up', () async {
    // Without this the assertion below could pass for the wrong reason — a channel that answers
    // nothing at all would also "not throw".
    final path = await _askForDocumentsDirectory(binding);

    expect(path, isA<String>());
    expect(path as String, isNotEmpty);
    expect(path, contains('ss_screen_harness'),
        reason: 'the harness should be answering with its own throwaway directory');
  });

  test('the mocked channel still answers AFTER disposeScreenHarness, and does not throw', () async {
    // The real caller is `get_storage`'s `_madeBackup()`, a fire-and-forget write that can reach
    // the channel after `tearDownAll` has run. It has no error handling of its own, so anything
    // this handler throws becomes an unhandled async error charged to an unrelated test.
    disposeScreenHarness();

    final path = await _askForDocumentsDirectory(binding);

    expect(path, isA<String>(),
        reason: 'the path_provider mock threw after teardown. That is the whole flake: '
            'get_storage finishes every flush with an un-awaited `_madeBackup()`, and if this '
            'handler throws when it lands late, flutter_test reports a PlatformException against '
            'whichever test in the file is still open. Keep the PATH for the life of the process; '
            'the DIRECTORY may be deleted, because `_getFile` re-creates it with '
            '`createSync(recursive: true)`');
    expect(path as String, isNotEmpty);
  });

  test('and it keeps answering on a second call, so the fix is not a one-shot', () async {
    // `disposeScreenHarness` is idempotent and a late write may arrive more than once.
    disposeScreenHarness();
    disposeScreenHarness();

    expect(await _askForDocumentsDirectory(binding), isA<String>());
  });
}

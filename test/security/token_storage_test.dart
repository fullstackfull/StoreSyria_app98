// Executable coverage for how the app holds and presents Sanctum's token.
//
// The app stores the server's own `plainTextToken` and replays it as a bearer
// credential. Everything about that is already guarded at the SOURCE level --
// authorization_header_single_site_test.dart proves the header is built in
// exactly one place, no_credential_logging_test.dart proves no log call can
// take a credential-bearing expression, and app_log_test.dart proves the
// redaction itself works. What none of them could do is EXECUTE the path:
// Prefs reads through GetStorage, which needs path_provider, which has no
// implementation under `flutter test`.
//
// Mocking that one channel onto a temp directory makes the whole token
// lifecycle testable for the first time, so these tests assert the four
// properties that actually matter on a device:
//
//   1. the token round-trips through storage;
//   2. it is presented as `Bearer <token>` on exactly one header;
//   3. an ABSENT token produces NO Authorization header at all -- not an empty
//      `Bearer `, which a server may well parse as a malformed credential and
//      answer 401, turning a merely-anonymous request into a forced logout;
//   4. clearing the session -- what a 401 does -- really removes it, and the
//      next request built afterwards is anonymous.
//
// Property 4 is the one that closes the loop with
// status_code_classification_test.dart: that file proves 401 CALLS the forced
// logout and 403 does not. This file proves the forced logout's clear actually
// de-authenticates the next request.
//
// WHAT THIS STILL CANNOT PROVE: that the token is at rest in a *secure* store.
// GetStorage writes an unencrypted JSON container in the app's documents
// directory, so on a rooted or jailbroken device the token is readable. That
// is a real, open finding and not something a test can close -- it needs
// flutter_secure_storage or the Keychain/Keystore, which is a dependency
// change this agent does not own. Recorded rather than asserted.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/utils/prefer.dart';

void main() {
  late Directory storageDir;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    // get_storage asks path_provider for the documents directory. Pointing it
    // at a throwaway directory is the whole trick that makes Prefs executable
    // here; nothing else about the production path is replaced.
    storageDir = Directory.systemTemp.createTempSync('store_go_token_test');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDir.path,
    );

    await GetStorage.init();
    app.getStorage = GetStorage();
  });

  tearDownAll(() {
    if (storageDir.existsSync()) {
      // See nested_api_read_test.dart: can fail with errno 39 on a cleanup race.
      try {
        storageDir.deleteSync(recursive: true);
      } catch (_) {
        // Intentionally ignored.
      }
    }
  });

  setUp(() async {
    await Prefs.clear();
  });

  group('the token round-trips through storage', () {
    test('what was written is what is read back', () {
      Prefs.setToken('1|abcdefGHIJKL0123456789');

      expect(Prefs.getToken(), '1|abcdefGHIJKL0123456789');
    });

    test('an absent token reads as empty, not null', () {
      // Every caller treats the result as a non-nullable String, so a null
      // here would be a crash on cold start before login.
      expect(Prefs.getToken(), '');
      expect(Prefs.getToken(), isA<String>());
    });

    test("a Sanctum token's pipe and base64 characters survive intact", () {
      // plainTextToken is "<id>|<40 random chars>". A store that mangled the
      // pipe would produce a token the server cannot match.
      const token = '42|aB3dE6fG9hI2jK5lM8nO1pQ4rS7tU0vW3xY6zZ';
      Prefs.setToken(token);

      expect(Prefs.getToken(), token);
      expect(Prefs.getToken(), contains('|'));
    });
  });

  group('the token is presented as a bearer credential', () {
    test('authHeaders carries exactly one Authorization header', () {
      Prefs.setToken('tok-123');

      final headers = NetworkHttps.authHeaders();

      // Map keys are unique, so "exactly one" is really "present, and spelled
      // the way the server expects".
      expect(headers['authorization'], 'Bearer tok-123');
      expect(
        headers.keys.where((k) => k.toLowerCase() == 'authorization').length,
        1,
      );
    });

    test('the scheme is "Bearer" with a single space', () {
      // `Bearer  tok` and `bearer tok` are both things a hand-rolled header
      // has produced in this codebase before.
      Prefs.setToken('tok-123');

      expect(NetworkHttps.authHeaders()['authorization'], startsWith('Bearer '));
      expect(
        NetworkHttps.authHeaders()['authorization'],
        isNot(contains('Bearer  ')),
      );
    });

    test('the base headers come along with it', () {
      Prefs.setToken('tok-123');

      final headers = NetworkHttps.authHeaders();

      expect(headers['content-type'], contains('application/json'));
      expect(headers['accept'], 'application/json');
      expect(headers['cache-control'], 'no-cache');
    });
  });

  group('an absent token produces no Authorization header', () {
    test('no header at all, rather than an empty Bearer', () {
      // An empty `Bearer ` is a MALFORMED credential, not an absent one. A
      // server that answers 401 to it would trip this client's forced logout
      // (network.dart case 401) on a request that was only ever anonymous --
      // logging out a merchant who was in the middle of signing in.
      expect(Prefs.getToken(), '');

      final headers = NetworkHttps.authHeaders();

      expect(headers.containsKey('authorization'), isFalse);
      expect(headers.values, isNot(contains('Bearer ')));
    });

    test('the base headers are still present when anonymous', () {
      // Login itself is an anonymous POST and still needs the JSON headers.
      final headers = NetworkHttps.authHeaders();

      expect(headers['content-type'], contains('application/json'));
      expect(headers['accept'], 'application/json');
    });
  });

  group('authHeaders does not mutate the shared base headers', () {
    test('the static baseHeaders map never gains an Authorization key', () {
      // If authHeaders() wrote into baseHeaders instead of a copy, the token
      // would be welded onto the shared map: it would ride along on every
      // later request, including after logout, and would outlive Prefs.clear()
      // for the lifetime of the process.
      Prefs.setToken('tok-123');
      NetworkHttps.authHeaders();

      expect(
        NetworkHttps.baseHeaders.containsKey('authorization'),
        isFalse,
        reason: 'authHeaders() must build from a COPY of baseHeaders.',
      );
    });

    test('a second call after a token change reflects the new token', () {
      // Proves the headers are rebuilt per call rather than memoised, which is
      // what makes the clear in property 4 take effect immediately.
      Prefs.setToken('first');
      expect(NetworkHttps.authHeaders()['authorization'], 'Bearer first');

      Prefs.setToken('second');
      expect(NetworkHttps.authHeaders()['authorization'], 'Bearer second');
    });
  });

  group('clearing the session de-authenticates the next request', () {
    test('Prefs.clear removes the token', () {
      // This is what the 401 path does (network.dart handleUnauthorized ->
      // Prefs.clear). If it did not actually remove the token, an expired
      // credential would be replayed forever.
      Prefs.setToken('tok-123');
      expect(Prefs.getToken(), isNotEmpty);

      Prefs.clear();

      expect(Prefs.getToken(), '');
    });

    test('headers built after a clear carry no credential', () {
      Prefs.setToken('tok-123');
      expect(NetworkHttps.authHeaders()['authorization'], isNotNull);

      Prefs.clear();

      expect(
        NetworkHttps.authHeaders().containsKey('authorization'),
        isFalse,
        reason: 'A cleared session must not keep presenting the old token.',
      );
    });

    test('clear also removes the other session-scoped identifiers', () {
      // A partial clear is worse than none: a stale store id or user id left
      // behind gets sent with the NEXT merchant's token.
      Prefs.setToken('tok-123');
      Prefs.setUserID('7');
      Prefs.setStoreID('99');

      Prefs.clear();

      expect(Prefs.getToken(), '');
      expect(Prefs.getUserID(), '');
      expect(Prefs.getStoreID(), '');
    });
  });
}

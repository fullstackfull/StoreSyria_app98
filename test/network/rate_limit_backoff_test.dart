// NEW-429-RETRY-STORM -- the client's own brake on the server's new throttle.
//
// WHY THIS IS A NEW PROBLEM AND NOT AN OLD ONE. Repo A's integration branch
// applies `$middleware->throttleApi('120,1')` in bootstrap/app.php. Before
// that, the RateLimiter named `api` was defined in RouteServiceProvider and
// never attached to anything, so all 211 API route declarations were
// UNTHROTTLED. A client that fired the same request over and over was wasting
// bandwidth; it was not being refused. Now the 121st request in a minute comes
// back 429.
//
// AND THIS APP HAS A SHAPE THAT REACHES 121. Six screens drive pagination from
// a ScrollController listener that fires whenever the viewport is within 200px
// of the bottom (products_screen.dart:64-80, category_screen.dart:49,
// customer_screen.dart:60, customers_details.dart, and the two picker bottom
// sheets). Its only brake is the controller's `isLoading`, cleared in a
// `finally` the moment the request settles -- product_controller.dart:168-170.
// A FAILING page load settles faster than a successful one and, unlike a
// successful one, appends no rows, so the viewport stays inside the trigger
// band. Every further scroll notification therefore spends another request.
// One 429 becomes a stream of them, each with its own toast, and the throttle
// window stays full for as long as the merchant keeps dragging -- which is
// exactly while they are waiting for the list to recover.
//
// WHAT IS ASSERTED HERE, AND WHY IT IS NOT A PROXY. The property that matters
// is "no further request reaches the wire while the server's Retry-After
// window is open". Asserting the returned Failure's `reason` alone would NOT
// prove that: `rateLimited` is also what a real 429 produces, so a gate that
// passed the request through and let the server refuse it again would look
// identical from the outside. That is the vacuous-status-assertion trap.
//
// So these tests count the thing that actually differs: whether an HttpClient
// was constructed. `package:http`'s top-level verbs and
// `BaseRequest.send()` both build a `Client()`, which on dart:io is an
// `IOClient` wrapping `HttpClient()` -- and `HttpClient()` routes through
// `HttpOverrides.global`. Installing a counting override therefore observes
// request ATTEMPTS directly, with no dependence on what any server answers:
//
//   gate open  -> one client constructed   (the request left the process)
//   gate shut  -> zero clients constructed (nothing left the process)
//
// `API.baseUrl` is pointed at the loopback interface for the open-gate half so
// nothing in these tests can reach a real host. Each verb is covered
// separately, because the gate is five separate call sites.

import 'dart:io';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/main.dart' as app;
import 'package:store_go_app/network/network.dart';
import 'package:store_go_app/network/result.dart';
import 'package:store_go_app/translations/en.dart';
import 'package:store_go_app/utils/base_api.dart';

import '../support/source_tree.dart';

/// Counts every HttpClient the process builds, then hands back the real one.
///
/// This is how "did the request leave the process?" is observed without
/// trusting any server to answer in a particular way -- and this container
/// does intercept loopback traffic, so a connection-refused signal would have
/// been wrong here.
class _CountingHttpOverrides extends HttpOverrides {
  int created = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    created++;
    return super.createHttpClient(context);
  }
}

void main() {
  // Loopback, so the open-gate half of each assertion cannot reach a real
  // host. What it answers is irrelevant: the assertion is on the client count.
  const deadHost = 'http://127.0.0.1:9';

  late String realBaseUrl;
  late DateTime fakeNow;
  late Directory storageDir;
  late _CountingHttpOverrides clients;
  HttpOverrides? previousOverrides;
  var forcedLogouts = 0;

  setUpAll(() async {
    Get.addTranslations({'en': en});
    Get.locale = const Locale('en', 'US');

    // The verbs call authHeaders() -> Prefs.getToken(), which dereferences the
    // GetStorage container. Without a real one every verb throws before it
    // reaches the gate, and this file would be testing the throw.
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    storageDir =
        Directory.systemTemp.createTempSync('store_go_rate_limit_test');

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDir.path,
    );

    await GetStorage.init();
    app.getStorage = GetStorage();
  });

  tearDownAll(() {
    // See nested_api_read_test.dart and forced_logout_test.dart: GetStorage
    // flushes in the background and can recreate a file mid-walk, so this
    // delete can fail with errno 39 (ENOTEMPTY) even with recursive: true.
    // A cleanup race must not redden a green suite.
    try {
      if (storageDir.existsSync()) storageDir.deleteSync(recursive: true);
    } catch (_) {
      // Intentionally ignored.
    }
  });

  setUp(() {
    realBaseUrl = API.baseUrl;
    API.baseUrl = deadHost;

    previousOverrides = HttpOverrides.current;
    clients = _CountingHttpOverrides();
    HttpOverrides.global = clients;

    fakeNow = DateTime.utc(2026, 1, 1, 12, 0, 0);
    NetworkHttps.clock = () => fakeNow;

    NetworkHttps.resetRateLimitBackoff();

    // The production forced logout clears GetStorage and drives a navigator.
    // Counted here instead, so every test in this file can assert that the
    // gate did not become a new route to it.
    forcedLogouts = 0;
    NetworkHttps.onUnauthorized = () async {
      forcedLogouts++;
    };
  });

  tearDown(() {
    HttpOverrides.global = previousOverrides;
    API.baseUrl = realBaseUrl;
    NetworkHttps.clock = DateTime.now;
    NetworkHttps.resetRateLimitBackoff();
    NetworkHttps.onUnauthorized = NetworkHttps.handleUnauthorized;
  });

  void classify(int status, {Map<String, String> headers = const {}}) {
    NetworkHttps.classifyErrorResponse<Map<String, dynamic>>(
      http.Response('', status, headers: headers),
    );
  }

  // ---------------------------------------------------------------------------
  group('a 429 arms the gate', () {
    test('and only a 429 does', () {
      for (final status in const [400, 401, 403, 404, 422, 500, 502, 503]) {
        NetworkHttps.resetRateLimitBackoff();
        classify(status);

        expect(
          NetworkHttps.rateLimitBackoffRemaining(),
          isNull,
          reason: 'HTTP $status must not stop the app from making requests.',
        );
      }

      classify(429, headers: {'retry-after': '7'});
      expect(NetworkHttps.rateLimitBackoffRemaining(), isNotNull);

      // 401 is the one code in that list that legitimately ends the session,
      // and exactly one of the eight did so. Asserted rather than left
      // implicit, because a gate that swallowed the 401 branch would make the
      // loop above pass for the wrong reason.
      expect(forcedLogouts, 1);
    });

    test('for exactly the window the server named', () {
      classify(429, headers: {'retry-after': '7'});

      expect(
        NetworkHttps.rateLimitBackoffRemaining(),
        const Duration(seconds: 7),
      );
    });

    test('reading Retry-After regardless of header casing', () {
      classify(429, headers: {'Retry-After': '9'});

      expect(
        NetworkHttps.rateLimitBackoffRemaining(),
        const Duration(seconds: 9),
      );
    });

    test('falling back to a short default when the header is absent', () {
      classify(429);

      expect(
        NetworkHttps.rateLimitBackoffRemaining(),
        const Duration(seconds: 2),
      );
    });

    test('falling back on a non-numeric or zero Retry-After', () {
      for (final raw in const ['soon', '', '0', '-5']) {
        NetworkHttps.resetRateLimitBackoff();
        classify(429, headers: {'retry-after': raw});

        expect(
          NetworkHttps.rateLimitBackoffRemaining(),
          const Duration(seconds: 2),
          reason: 'Retry-After: "$raw" must not disable or extend the gate.',
        );
      }
    });

    test('clamped, so a hostile or silly value cannot bench the app', () {
      // A proxy answering `Retry-After: 3600` must not make the app look
      // broken for an hour. The cap self-corrects: one request goes through
      // when it lapses, and a still-open window re-arms the gate.
      classify(429, headers: {'retry-after': '3600'});

      expect(
        NetworkHttps.rateLimitBackoffRemaining(),
        const Duration(seconds: 60),
      );
    });

    test('never shortened by a later 429 carrying a smaller window', () {
      // Several requests are in flight when a throttle trips, and the last
      // 429 to land is not necessarily the one with the most time left.
      classify(429, headers: {'retry-after': '30'});
      classify(429, headers: {'retry-after': '2'});

      expect(
        NetworkHttps.rateLimitBackoffRemaining(),
        const Duration(seconds: 30),
      );
    });

    test('and it lapses when the window has passed', () {
      classify(429, headers: {'retry-after': '7'});
      expect(NetworkHttps.rateLimitBackoffRemaining(), isNotNull);

      fakeNow = fakeNow.add(const Duration(seconds: 6));
      expect(
        NetworkHttps.rateLimitBackoffRemaining(),
        const Duration(seconds: 1),
      );

      fakeNow = fakeNow.add(const Duration(seconds: 1));
      expect(
        NetworkHttps.rateLimitBackoffRemaining(),
        isNull,
        reason: 'The gate must open again by itself.',
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('while the gate is shut no request reaches the network', () {
    // The distinguishing evidence: `network` means a connection to the dead
    // port was attempted, `rateLimited` means nothing left the process.

    Future<void> expectSuppressed(
      String label,
      Future<Result<Map<String, dynamic>>> Function() call,
    ) async {
      NetworkHttps.resetRateLimitBackoff();

      // With the gate open the request must actually go out. This half is what
      // stops the half below from being vacuous: if the verb never built a
      // client here either, the assertion that it does not build one later
      // would prove nothing about the gate.
      clients.created = 0;
      await call();
      expect(
        clients.created,
        1,
        reason: '$label: with the gate open the request must reach the wire. '
            'If this is 0 the suppression assertion below is vacuous.',
      );

      classify(429, headers: {'retry-after': '7'});

      clients.created = 0;
      final after = await call();

      expect(
        clients.created,
        0,
        reason: '$label: a request was put on the wire during the server\'s '
            'own Retry-After window. That is the retry storm this gate exists '
            'to stop.',
      );

      expect(
        (after as Failure).reason,
        FailureReason.rateLimited,
        reason: '$label: the caller must see the same reason a real 429 '
            'produces, so nothing above this layer has to change.',
      );
    }

    test('GET', () async {
      await expectSuppressed(
        'getRequest',
        () => NetworkHttps.getRequest('/orderlist?store_id=1&page=1'),
      );
    });

    test('POST', () async {
      await expectSuppressed(
        'postRequest',
        () => NetworkHttps.postRequest('/orders/notes/create', const {}),
      );
    });

    test('PUT', () async {
      await expectSuppressed(
        'putRequest',
        () => NetworkHttps.putRequest('/update-customer', const {}),
      );
    });

    test('DELETE', () async {
      await expectSuppressed(
        'deleteRequest',
        () => NetworkHttps.deleteRequest('/orders/notes/delete?store_id=1'),
      );
    });

    test('MULTIPART', () async {
      await expectSuppressed(
        'multipartRequest',
        () => NetworkHttps.multipartRequest(
          endPoint: '/addproduct',
          fields: const {'store_id': '1'},
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('the suppressed failure is indistinguishable from the real one', () {
    test('same reason and the same wording, with a live countdown', () async {
      classify(429, headers: {'retry-after': '7'});

      final suppressed =
          await NetworkHttps.getRequest('/orderlist') as Failure;

      expect(suppressed.reason, FailureReason.rateLimited);
      expect(
        suppressed.message,
        'too_many_requests_retry_after'.trParams({'seconds': '7'}),
      );

      // Not the untranslated key, and not blank: a caller that shows
      // Failure.message must have something to show.
      expect(suppressed.message, isNot('too_many_requests_retry_after'));
      expect(suppressed.message.trim(), isNotEmpty);
    });

    test('the countdown rounds up, never down', () async {
      classify(429, headers: {'retry-after': '7'});

      fakeNow = fakeNow.add(const Duration(milliseconds: 6500));

      final suppressed =
          await NetworkHttps.getRequest('/orderlist') as Failure;

      // 500ms left. Telling the merchant "0s" invites a retry the gate will
      // still refuse.
      expect(
        suppressed.message,
        'too_many_requests_retry_after'.trParams({'seconds': '1'}),
      );
    });

    test('it carries no validation errors to confuse a form', () async {
      classify(429, headers: {'retry-after': '7'});

      final suppressed =
          await NetworkHttps.postRequest('/addtax', const {}) as Failure;

      expect(suppressed.validationErrors, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  group('the gate does not break legitimate traffic', () {
    test('an untouched app makes requests normally', () async {
      expect(NetworkHttps.rateLimitBackoffRemaining(), isNull);

      clients.created = 0;
      await NetworkHttps.getRequest('/dashboard');

      expect(
        clients.created,
        1,
        reason: 'With no 429 behind it, a request must reach the wire.',
      );
    });

    test('a 403 denial leaves the app able to make its next request',
        () async {
      // The server answers 403 for an authorization denial precisely so that
      // one refused action does not take anything else with it. A gate that
      // armed on 403 would turn a single denied tap into a dead app.
      classify(
        403,
        headers: {'content-type': 'application/json'},
      );

      clients.created = 0;
      await NetworkHttps.getRequest('/orderlist');

      expect(clients.created, 1);
      expect(forcedLogouts, 0);
    });

    test('a 401 still reaches the forced-logout path, not the gate', () async {
      classify(401);

      expect(forcedLogouts, 1);
      expect(
        NetworkHttps.rateLimitBackoffRemaining(),
        isNull,
        reason: 'An expired session is not a throttle.',
      );
    });

    test('once the window lapses the very next request goes out', () async {
      classify(429, headers: {'retry-after': '7'});

      clients.created = 0;
      expect(
        (await NetworkHttps.getRequest('/orderlist') as Failure).reason,
        FailureReason.rateLimited,
      );
      expect(clients.created, 0);

      fakeNow = fakeNow.add(const Duration(seconds: 7));

      clients.created = 0;
      await NetworkHttps.getRequest('/orderlist');
      expect(
        clients.created,
        1,
        reason: 'The gate must not outlive the window it was given.',
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('every verb consults the gate', () {
    test('all five request verbs, with none added unguarded later', () {
      // A sixth verb added without a preflight would reopen the storm for
      // whatever it serves, and no behavioural test can catch a verb that does
      // not exist yet. So the verbs are enumerated from the source and each
      // one is required to consult the gate.
      //
      // Comments are stripped but string literals kept, so the prose in
      // network.dart cannot satisfy this and cannot break it either.
      final source = commentsStripped(
        File('${packageRoot().path}/lib/network/network.dart')
            .readAsStringSync(),
      );

      final verbs = RegExp(
        r'static Future<Result<Map<String, dynamic>>> (\w+)\(',
      ).allMatches(source).map((m) => m.group(1)!).toList()
        ..sort();

      expect(
        verbs,
        const <String>[
          'deleteRequest',
          'getRequest',
          'multipartRequest',
          'postRequest',
          'putRequest',
        ],
        reason: 'A request verb was added or renamed. Give it a '
            '_rateLimitPreflight call and list it here.',
      );

      // Count the CALL sites only: the declaration is generic over T, the
      // call sites are all concrete. Five verbs, five call sites.
      final callSites = RegExp(
        r'_rateLimitPreflight<Map<String, dynamic>>\(',
      ).allMatches(source).length;

      expect(
        callSites,
        verbs.length,
        reason: 'Every request verb must consult the rate-limit gate before '
            'touching the network. Found $callSites call sites for '
            '${verbs.length} verbs.',
      );

      // And the preflight must come BEFORE the request is issued in each one,
      // which is the whole point -- a check after `await http.get` would
      // suppress nothing.
      for (final verb in verbs) {
        final body = source.substring(
          source.indexOf('> $verb('),
        );

        final preflightAt = body.indexOf('_rateLimitPreflight');
        final sendAt = RegExp(r'await (http\.\w+\(|request\.send\(\))')
            .firstMatch(body)
            ?.start;

        expect(preflightAt, greaterThanOrEqualTo(0), reason: verb);
        expect(sendAt, isNotNull, reason: verb);
        expect(
          preflightAt,
          lessThan(sendAt!),
          reason: '$verb consults the gate only after it has already sent '
              'the request, which suppresses nothing.',
        );
      }
    });
  });
}

// NEW-duplicate-fcm-services.
//
// FirebaseMessagingService and FcmTokenService were both initialized from
// main() and both called
// `FirebaseMessaging.instance.onTokenRefresh.listen(...)`, so one token
// rotation ran two handlers with two different ideas of where the token
// belongs. One of them POSTed it to API.fcmTokenUrl; the other logged it and
// returned true from a method whose HTTP call was commented out.
//
// These are source-level assertions, not behavioural ones, and the limit is
// worth stating: FirebaseMessaging.instance needs a platform channel, so a
// unit test cannot subscribe to a real onTokenRefresh and count handlers. What
// IS decidable here, and what actually regresses when someone adds a listener
// back, is how many subscription sites exist in the tree.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

void main() {
  group('a single FCM token owner', () {
    test('onTokenRefresh is subscribed to in exactly one file', () {
      final subscribers = <String, List<int>>{};

      for (final file in libDartFiles()) {
        final hits = matchingLines(file.readAsStringSync(), 'onTokenRefresh');
        if (hits.isNotEmpty) subscribers[relative(file)] = hits;
      }

      expect(
        subscribers.keys,
        ['lib/core/services/fcm_token_service.dart'],
        reason:
            'The FCM token has one owner: FcmTokenService. A second '
            'onTokenRefresh subscription means two handlers run per rotation. '
            'Found: $subscribers',
      );

      expect(
        subscribers.values.single,
        hasLength(1),
        reason: 'One subscription, not several within the one owner.',
      );
    });

    test('only the token owner reads or deletes the FCM token', () {
      // getToken()/deleteToken() are the other half of ownership: whoever
      // calls them decides what the current token is.
      //
      // Scoped to files that import firebase_messaging, because `getToken()`
      // is also the name of the Prefs accessor for the *auth* bearer token --
      // an unscoped match reports auth_controller.dart, network.dart and
      // welcome_screen.dart, none of which touch FCM. A guard test that
      // conflates the two names would fail for a reason that has nothing to do
      // with the finding.
      final callers = <String, List<int>>{};

      for (final file in libDartFiles()) {
        final source = file.readAsStringSync();
        // The import path lives in a string literal, which codeOnly() blanks,
        // so this one check reads the raw source.
        if (!source.contains('firebase_messaging/firebase_messaging.dart')) {
          continue;
        }

        final hits = <int>[
          ...matchingLines(source, '.getToken('),
          ...matchingLines(source, '.deleteToken('),
        ]..sort();
        if (hits.isNotEmpty) callers[relative(file)] = hits;
      }

      expect(
        callers.keys,
        ['lib/core/services/fcm_token_service.dart'],
        reason: 'Found FCM token reads/deletes outside the owner: $callers',
      );
    });

    test('the Prefs FCM-token accessors are written by the owner alone', () {
      // Prefs.setFcmToken is the local record of the current token. Two
      // writers is the same bug one layer down.
      final writers = <String, List<int>>{};

      for (final file in libDartFiles()) {
        if (relative(file) == 'lib/utils/prefer.dart') continue;

        final hits = matchingLines(file.readAsStringSync(), 'setFcmToken(');
        if (hits.isNotEmpty) writers[relative(file)] = hits;
      }

      expect(
        writers.keys,
        ['lib/core/services/fcm_token_service.dart'],
        reason: 'Found FCM token writers outside the owner: $writers',
      );
    });

    test('the notification service holds no token state', () {
      final source = File(
        '${packageRoot().path}/lib/core/services/firebase_messaging_service.dart',
      ).readAsStringSync();

      final code = codeOnly(source);

      for (final removed in const [
        '_fcmToken',
        'sendFcmTokenToBackend',
        '_sendTokenToBackend',
        'deleteFcmToken',
        'getCurrentToken',
      ]) {
        expect(
          code,
          isNot(contains(removed)),
          reason:
              '$removed was the duplicated token path in '
              'FirebaseMessagingService. It is FcmTokenService\'s job now.',
        );
      }
    });

    test('main() still initializes both services, in order', () {
      // Deduplication, not deletion: the notification service is still needed
      // for permission, display and tap routing. This pins that main() was not
      // "fixed" by dropping one of them.
      final main = File('${packageRoot().path}/lib/main.dart')
          .readAsStringSync();
      final code = codeOnly(main);

      final notifications = code.indexOf('FirebaseMessagingService().initialize()');
      final token = code.indexOf('FcmTokenService().initialize()');

      expect(notifications, greaterThan(-1));
      expect(token, greaterThan(-1));
      expect(
        notifications,
        lessThan(token),
        reason:
            'Permission must be requested before the token is read, or iOS '
            'returns no APNS token.',
      );
    });

    test('the real send path is the one app code calls', () {
      // The stubbed duplicate returned true unconditionally, so a caller could
      // not tell a delivered token from a dropped one. The surviving path goes
      // through the network layer.
      final owner = File(
        '${packageRoot().path}/lib/core/services/fcm_token_service.dart',
      ).readAsStringSync();

      expect(codeOnly(owner), contains('API.fcmTokenUrl'));
      expect(codeOnly(owner), contains('NetworkHttps.postRequest'));
    });
  });
}

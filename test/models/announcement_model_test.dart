import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_go_app/core/model/announcement_model.dart';

/// SUPPORT-002 — THE ANNOUNCEMENT PAYLOAD MUST SURVIVE THE DAY THERE IS NOTHING
/// TO SAY.
/// ===========================================================================
///
/// This is the model most likely in the whole app to meet the empty-collection
/// case, because an empty announcement list is the NORMAL state on most days.
/// `network/result.dart` records the measurement that matters here: 132 of 353
/// rows red across 25 of 32 response models, because `json['data'] != null`
/// guards null and nothing else, and **Laravel serialises an empty Eloquent
/// collection as a JSON ARRAY** — so the parse that worked all through testing
/// throws the first time a merchant has no rows.
///
/// So the cases below are not "does it parse". They are the four shapes the
/// server can really send and a client has historically crashed on: the full
/// object, `"data": []`, a missing `data`, and a scalar where an object was
/// expected.
///
/// EVERY PAYLOAD IS ROUND-TRIPPED THROUGH `jsonDecode`, for the reason the
/// sibling product-rating test gives: that is what decides whether `1` arrives
/// as `int` and `true` as `bool`. Writing the map by hand would let the test
/// pass against types the network never produces.
void main() {
  dynamic decoded(Object? payload) => jsonDecode(jsonEncode(payload));

  Map<String, Object?> announcement({
    Object? id = 7,
    String title = 'Scheduled maintenance tonight',
    String body = 'The panel will be read-only.',
    String severity = 'urgent',
    String startsAt = '2026-11-27 22:00:00',
    String endsAt = '2026-11-27 23:00:00',
    Object? isLive = true,
  }) =>
      {
        'id': id,
        'title': title,
        'body': body,
        'severity': severity,
        'starts_at': startsAt,
        'ends_at': endsAt,
        'is_live': isLive,
      };

  group('the announcement feed', () {
    test('a full payload parses every field the screen prints', () {
      final model = AnnouncementModel.fromJson(decoded({
        'status': 1,
        'message': 'announcements',
        'data': {
          'locale': 'ar',
          'live_count': 1,
          'announcements': [announcement()],
        },
      }));

      expect(model.locale, 'ar');
      expect(model.liveCount, 1);
      expect(model.announcements, hasLength(1));

      final row = model.announcements.first;

      expect(row.id, 7);
      expect(row.title, 'Scheduled maintenance tonight');
      expect(row.body, 'The panel will be read-only.');
      expect(row.severity, 'urgent');
      expect(row.isUrgent, isTrue);
      expect(row.startsAt, '2026-11-27 22:00:00');
      expect(row.endsAt, '2026-11-27 23:00:00');
      expect(row.isLive, isTrue);
    });

    test('an empty day is an empty list, not a crash', () {
      // The shape Laravel really sends when nothing is live: `data.announcements`
      // is an empty JSON ARRAY.
      final model = AnnouncementModel.fromJson(decoded({
        'status': 1,
        'data': {'locale': 'en', 'live_count': 0, 'announcements': <Object>[]},
      }));

      expect(model.announcements, isEmpty);
      expect(model.liveCount, 0);
      expect(model.locale, 'en');
    });

    test('`data` arriving as an ARRAY does not throw', () {
      // This is the documented failure: an empty Eloquent collection serialises
      // as `[]`, and `Model.fromJson(json['data'])` is declared
      // `fromJson(Map<String, dynamic>)`, so a List there is a TypeError.
      final model = AnnouncementModel.fromJson(decoded({
        'status': 1,
        'data': <Object>[],
      }));

      expect(model.announcements, isEmpty);
      expect(model.liveCount, 0);
    });

    test('a refusal envelope with no data at all does not throw', () {
      final model = AnnouncementModel.fromJson(decoded({
        'status': 0,
        'message': 'This action is not allowed.',
      }));

      expect(model.announcements, isEmpty);
    });

    test('a scalar where the row object was expected is skipped, not fatal', () {
      final model = AnnouncementModel.fromJson(decoded({
        'data': {
          'announcements': ['not an object', 42, null],
        },
      }));

      expect(model.announcements, hasLength(3));
      // Each one parses to a blank row rather than throwing. A blank row is
      // dropped by the screen's own `title.isNotEmpty` test; a TypeError here
      // would take the whole screen down.
      expect(model.announcements.every((row) => row.title.isEmpty), isTrue);
    });

    test('an id sent as a quoted string still reads as a number', () {
      // `result.dart` records the opposite asymmetry crashing a screen
      // (`reward_point` unquoted into a non-nullable String), and several
      // older handlers in repo A quote their integers.
      final model = AnnouncementModel.fromJson(decoded({
        'data': {'announcements': [announcement(id: '7')]},
      }));

      expect(model.announcements.first.id, 7);
    });

    test('an unparseable id is 0 rather than an exception', () {
      final model = AnnouncementModel.fromJson(decoded({
        'data': {'announcements': [announcement(id: 'seven')]},
      }));

      expect(model.announcements.first.id, 0);
    });

    test('`is_live` sent as 1 is still live', () {
      final model = AnnouncementModel.fromJson(decoded({
        'data': {'announcements': [announcement(isLive: 1)]},
      }));

      expect(model.announcements.first.isLive, isTrue);
    });

    test('`is_live` absent is NOT live', () {
      // Fails CLOSED on absence, deliberately. An ended announcement shown as
      // "happening now" tells a merchant the platform is going down when it is
      // not; the other way round it is merely stale.
      final row = Announcement.fromJson(decoded({'id': 1, 'title': 'x'}));

      expect(row.isLive, isFalse);
    });

    test('an unrecognised severity is read as the quieter badge', () {
      // The SERVER already folds this; the client must not invent a third
      // branch for a value it has never been sent.
      final model = AnnouncementModel.fromJson(decoded({
        'data': {'announcements': [announcement(severity: 'CATASTROPHE')]},
      }));

      expect(model.announcements.first.isUrgent, isFalse,
          reason: 'anything that is not exactly `urgent` must render as the '
              'quiet badge');
    });

    test('the empty constant is usable as an initial state', () {
      expect(AnnouncementModel.empty.announcements, isEmpty);
      expect(AnnouncementModel.empty.liveCount, 0);
    });
  });

  group('the help topics', () {
    test('a full payload parses, and the fallback flag survives', () {
      final topics = HelpTopics.fromJson(decoded({
        'status': 1,
        'data': {
          'locale': 'ar',
          'surface': 'products',
          'known': true,
          'articles': [
            {
              'id': 'products/add-a-product',
              'title': 'إضافة منتج',
              'summary': 'كيف تضيف منتجاً إلى متجرك.',
              'url': 'https://storesyria.com/platform/docs/products/add-a-product',
              'locale': 'ar',
              'is_fallback': false,
            },
            {
              'id': 'products/import-from-a-file',
              'title': 'Import from a file',
              'summary': '',
              'url': 'https://storesyria.com/platform/docs/products/import-from-a-file',
              'locale': 'en',
              'is_fallback': true,
            },
          ],
        },
      }));

      expect(topics.locale, 'ar');
      expect(topics.surface, 'products');
      expect(topics.known, isTrue);
      expect(topics.articles, hasLength(2));
      expect(topics.articles.first.isFallback, isFalse);
      expect(topics.articles.last.isFallback, isTrue,
          reason: 'the screen prints a notice from this flag; without it a '
              'missing Arabic translation is invisible to the merchant AND to '
              'us');
    });

    test('a surface the server does not know is `known: false` with no articles', () {
      final topics = HelpTopics.fromJson(decoded({
        'status': 1,
        'data': {
          'locale': 'en',
          'surface': 'wallet',
          'known': false,
          'articles': <Object>[],
        },
      }));

      expect(topics.known, isFalse);
      expect(topics.articles, isEmpty);
    });

    test('`known` absent reads as false, so a drift is never hidden', () {
      // An older server that does not send `known` must not be read as
      // "this key is fine": the screen's two sentences differ on this flag,
      // and the one that says "update the app" is the useful one.
      final topics = HelpTopics.fromJson(decoded({'data': {'surface': 'x'}}));

      expect(topics.known, isFalse);
    });

    test('an articles array of the wrong type does not throw', () {
      final topics = HelpTopics.fromJson(decoded({
        'data': {'articles': 'nope'},
      }));

      expect(topics.articles, isEmpty);
    });

    test('the empty constant is usable as an initial state', () {
      expect(HelpTopics.empty.articles, isEmpty);
      expect(HelpTopics.empty.known, isFalse);
    });
  });
}

import 'package:store_go_app/network/result.dart';

/// SUPPORT-002 -- what the platform is telling this merchant, and the help for a
/// screen.
///
/// EVERY FIELD IS READ THROUGH THE SHAPE-SAFE HELPERS IN `network/result.dart`,
/// not through `json['k']`. That file records the measurement: 132 of 353 rows
/// red across 25 of 32 response models, because `json['data'] != null` guards
/// null and nothing else and Laravel serialises an EMPTY Eloquent collection as
/// a JSON ARRAY -- so the parse that worked all through testing throws the first
/// time a merchant has no rows. An announcement list is empty on most days, which
/// makes this model the single most likely one in the app to meet that case.
///
/// `isLive` IS NOT DERIVED HERE. The server computes it from the operator's
/// publish flag and the window, and the four-state rule (draft / scheduled /
/// live / ended) lives in one place on the server so the web panel and this app
/// cannot disagree about what was announced. A client that re-derived it from
/// `endsAt` would be a second copy of that rule, and it would be wrong whenever
/// the phone's clock is.
class AnnouncementModel {
  final String locale;
  final int liveCount;
  final List<Announcement> announcements;

  const AnnouncementModel({
    required this.locale,
    required this.liveCount,
    required this.announcements,
  });

  factory AnnouncementModel.fromJson(dynamic json) {
    final data = jsonMap(apiValueAt(json, ['data']));

    return AnnouncementModel(
      locale: apiText(data, ['locale'], fallback: 'ar'),
      liveCount: _asInt(data['live_count']),
      // GROWABLE, DELIBERATELY. These lists are assigned into an `RxList`
      // (`announcements.value = model.announcements`) and the controller later
      // calls `.clear()` on it -- `clear()` on a fixed-length list throws
      // UnsupportedError, at runtime, on the second open of the help sheet.
      announcements: jsonList(data['announcements'])
          .map((entry) => Announcement.fromJson(entry))
          .toList(),
    );
  }

  static const AnnouncementModel empty = AnnouncementModel(
    locale: 'ar',
    liveCount: 0,
    announcements: <Announcement>[],
  );
}

class Announcement {
  final int id;
  final String title;
  final String body;

  /// `notice` or `urgent`. Anything else the server has already folded to
  /// `notice`, the quieter of the two, so this app never has to decide what an
  /// unrecognised severity means.
  final String severity;

  final String startsAt;
  final String endsAt;
  final bool isLive;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.startsAt,
    required this.endsAt,
    required this.isLive,
  });

  bool get isUrgent => severity == 'urgent';

  factory Announcement.fromJson(dynamic json) {
    final row = jsonMap(json);

    return Announcement(
      id: _asInt(row['id']),
      title: apiText(row, ['title']),
      body: apiText(row, ['body']),
      severity: apiText(row, ['severity'], fallback: 'notice'),
      startsAt: apiText(row, ['starts_at']),
      endsAt: apiText(row, ['ends_at']),
      // `== true` rather than a cast: the server sends a JSON bool, and a cast
      // throws on the `1` a differently configured serialiser would send.
      isLive: row['is_live'] == true || row['is_live'] == 1,
    );
  }
}

/// SUPPORT-002 -- one documentation article offered as help for a screen.
class HelpArticle {
  final String id;
  final String title;
  final String summary;
  final String url;
  final String locale;

  /// True when the documentation centre served a language the reader did not
  /// ask for. The screen says so: a missing Arabic translation that is invisible
  /// to the merchant is also invisible to us.
  final bool isFallback;

  const HelpArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.url,
    required this.locale,
    required this.isFallback,
  });

  factory HelpArticle.fromJson(dynamic json) {
    final row = jsonMap(json);

    return HelpArticle(
      id: apiText(row, ['id']),
      title: apiText(row, ['title']),
      summary: apiText(row, ['summary']),
      url: apiText(row, ['url']),
      locale: apiText(row, ['locale'], fallback: 'ar'),
      isFallback: row['is_fallback'] == true || row['is_fallback'] == 1,
    );
  }
}

/// SUPPORT-002 -- the answer to `help-topics?surface=<key>`.
///
/// `known` IS NOT THE SAME QUESTION AS "are there articles". Both answer with an
/// empty list and they are different facts: no help for this screen yet is
/// expected on most screens, whereas a key the server does not recognise means
/// this app and the server have drifted and somebody should look.
class HelpTopics {
  final String locale;
  final String surface;
  final bool known;
  final List<HelpArticle> articles;

  const HelpTopics({
    required this.locale,
    required this.surface,
    required this.known,
    required this.articles,
  });

  factory HelpTopics.fromJson(dynamic json) {
    final data = jsonMap(apiValueAt(json, ['data']));

    return HelpTopics(
      locale: apiText(data, ['locale'], fallback: 'ar'),
      surface: apiText(data, ['surface']),
      known: data['known'] == true || data['known'] == 1,
      // Growable, for the reason given on `announcements` above.
      articles: jsonList(data['articles'])
          .map((entry) => HelpArticle.fromJson(entry))
          .toList(),
    );
  }

  static const HelpTopics empty = HelpTopics(
    locale: 'ar',
    surface: '',
    known: false,
    articles: <HelpArticle>[],
  );
}

/// A JSON number that may arrive as a string.
///
/// Laravel hands integers back unquoted from a cast and quoted from several
/// older handlers, and `result.dart` records a crash from exactly that
/// asymmetry (`reward_point` assigned straight into a non-nullable String).
int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

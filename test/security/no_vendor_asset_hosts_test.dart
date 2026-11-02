// No screen may fetch an image from the upstream vendor's demo server.
//
// `lib/utils/images.dart` carried five absolute URLs on apps.rajodiya.com --
// the upstream eCommerceGo vendor's own demo installation. One of them,
// profileImg, was LIVE: it was the `errorWidget` of the merchant avatar on two
// production screens, so whenever a merchant had no avatar of their own, their
// device requested an image from a third party nobody here has a contract
// with. Three problems in one line:
//
//   * availability -- a screen's fallback depends on someone else's uptime;
//   * a traffic and IP leak -- that third party sees a request per avatar
//     miss, which is a usable signal about this product's user base;
//   * branding -- the fallback face shipped to Syrian merchants belonged to
//     another company's demo data.
//
// The local `Icon(Icons.person)` was ALREADY the terminal fallback behind it,
// so removing the network hop changes no end state a user ever reaches on
// purpose -- it only removes the detour through the vendor.
//
// This guard is deliberately about HOSTS, not about that one constant: the
// defect was a habit (five of them were written), and a sixth would be just as
// wrong. Comments are blanked but string literals kept (commentsStripped), so
// the prose above cannot trip it while a real URL in code does.

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

/// Hosts no screen in this app may fetch from.
///
/// `rajodiya.com` is the upstream vendor's demo installation. The others are
/// the usual placeholder services, listed so that "just point it at a
/// placeholder" is not the next version of this defect.
const _forbiddenHosts = <String>[
  'rajodiya.com',
  'placeholder.com',
  'via.placeholder',
  'placehold.it',
  'placekitten.com',
  'picsum.photos',
  'gravatar.com',
  'dummyimage.com',
];

void main() {
  test('no file in lib/ references a vendor or placeholder image host', () {
    final offenders = <String>[];

    for (final file in libDartFiles()) {
      final src = commentsStripped(file.readAsStringSync());
      final lines = src.split('\n');

      for (var i = 0; i < lines.length; i++) {
        for (final host in _forbiddenHosts) {
          if (lines[i].contains(host)) {
            offenders.add('${relative(file)}:${i + 1}  ($host)');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'A merchant\'s device must not fetch an image from a third '
          'party. Bundle the asset, or fall back to a local widget:\n  '
          '${offenders.join('\n  ')}',
    );
  });

  test('the host detector finds a URL when one is really there', () {
    // Anti-vacuity. A guard that cannot fire is worse than no guard, and this
    // one is a substring search over a filtered source -- exactly the shape
    // that silently stops matching when the filter changes.
    const probe =
        "static String x = 'https://apps.rajodiya.com/ecommercego-saas/a.png';";
    expect(commentsStripped(probe).contains('rajodiya.com'), isTrue);

    // ...and that a comment mentioning the host does NOT fire it.
    const inComment = '// apps.rajodiya.com was the old fallback\nvar y = 1;';
    expect(commentsStripped(inComment).contains('rajodiya.com'), isFalse);
  });
}

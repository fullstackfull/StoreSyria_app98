// Guard test for R7-09 — certificate pinning.
//
// PINNING IS DELIBERATELY NOT IMPLEMENTED, and this test is not a substitute
// for it. It locks in the good state that exists today instead.
//
// The reasoning, recorded here because it is the kind of decision that gets
// quietly reversed: pinning a certificate in an app that has NO forced-update
// mechanism means that when the certificate is rotated -- routinely, by the
// hosting provider, possibly without telling anyone -- every installed copy of
// the merchant console stops working at once and cannot be fixed remotely.
// Bricking the whole fleet is a larger risk than the one pinning removes,
// given that TLS verification is already on and no cleartext endpoint exists.
// Pinning becomes affordable once there is a minimum-supported-version gate;
// until then it is an owner decision, not a code fix.
//
// What this test does guard is the single most likely way this area actually
// regresses: a developer debugging against a self-signed staging certificate
// adds a `badCertificateCallback` that returns true, and it ships.

import 'package:flutter_test/flutter_test.dart';

import '../support/source_tree.dart';

/// The shapes that disable or replace certificate validation, and the list of
/// their names.
///
/// Hoisted to file scope so the self-checks exercise the SAME objects the
/// scans use -- a self-check against a second, retyped copy of the pattern
/// proves nothing about the one that runs.
const _forbiddenNames = <String>[
  'badCertificateCallback',
  'onBadCertificate',
  'allowBadCertificates',
  'HttpOverrides',
  'setTrustedCertificatesBytes',
  'SecurityContext(',
];

final _forbidden = RegExp(
  r'badCertificateCallback'
  r'|onBadCertificate'
  r'|allowBadCertificates'
  r'|HttpOverrides'
  r'|setTrustedCertificatesBytes'
  r'|SecurityContext\(',
);

final _cleartext = RegExp(r'''["']http://[A-Za-z0-9]''');

void main() {
  group('TLS verification is not weakened', () {
    test('no certificate validation override anywhere in lib/', () {
      final hits = <String>[];

      for (final file in libDartFiles()) {
        final lines = codeOnly(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (_forbidden.hasMatch(lines[i])) {
            hits.add('${relative(file)}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      expect(
        hits,
        isEmpty,
        reason:
            'Certificate validation must not be overridden. If you need to '
            'test against a self-signed staging certificate, add the CA to '
            'the device rather than disabling verification in code -- a '
            'callback that returns true will ship. Found:\n'
            '${hits.join('\n')}',
      );
    });

    test('no cleartext http:// endpoint is configured', () {
      // `http://` followed by a host, not the bare scheme string: helper.dart
      // legitimately tests whether a URL already carries a scheme.
      final hits = <String>[];

      for (final file in libDartFiles()) {
        final lines = commentsStripped(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (_cleartext.hasMatch(lines[i])) {
            hits.add('${relative(file)}:${i + 1}  ${lines[i].trim()}');
          }
        }
      }

      expect(
        hits,
        isEmpty,
        reason:
            'Every endpoint must be https. Found:\n${hits.join('\n')}',
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('the guards match the shapes they are supposed to catch', () {
    // BOTH tests above assert isEmpty on a list a regex fills, and nothing
    // proved that regex could match anything. A dropped alternative, or a
    // transposition inside one, would silently stop guarding that shape while
    // the suite stayed green. The same class of mistake has already produced
    // a wrongly-REFUTED finding in this project, and an unescaped dot once
    // made 'contact.us' match contact_us_banner_title -- so the pattern is
    // tested rather than trusted.

    test('every forbidden alternative really is matched', () {
      // One realistic line per alternative, in the shape it would appear in.
      const shapes = <String, String>{
        'badCertificateCallback':
            'client.badCertificateCallback = (cert, host, port) => true;',
        'onBadCertificate': 'adapter.onBadCertificate = (cert) => true;',
        'allowBadCertificates': 'allowBadCertificates: true,',
        'HttpOverrides': 'HttpOverrides.global = _MyOverrides();',
        'setTrustedCertificatesBytes':
            'context.setTrustedCertificatesBytes(bytes);',
        'SecurityContext(':
            'final ctx = SecurityContext(withTrustedRoots: false);',
      };

      // Keeps the map and the pattern from drifting apart: an alternative
      // added to one and not the other fails here.
      expect(shapes.keys.toList(), _forbiddenNames);

      shapes.forEach((name, line) {
        expect(
          _forbidden.hasMatch(line),
          isTrue,
          reason: 'The guard no longer matches $name. An alternative was '
              'dropped or mistyped: $line',
        );
      });
    });

    test('the pattern still names every alternative verbatim', () {
      // The match test above cannot catch a TRUNCATION: `onBadCertificat`
      // still matches `onBadCertificate`, because these are substring
      // searches. Harmless in itself -- a shorter prefix matches more, not
      // less -- but it means "it still matches" is not the same as "it is
      // still the pattern that was reviewed". Found while probing this very
      // test with that exact typo and watching it stay green.
      for (final name in _forbiddenNames) {
        expect(
          _forbidden.pattern.contains(RegExp.escape(name).replaceAll(
              r'\(', r'\(')),
          isTrue,
          reason: '$name is no longer written out in the pattern.',
        );
      }

      // Six alternatives, so one cannot be deleted and the loop above still
      // pass over what remains.
      expect(_forbidden.pattern.split('|').length, 6);
    });

    test('and it does not fire on ordinary networking code', () {
      // A guard that cried wolf on normal code gets suppressed, so the
      // negative direction matters as much as the positive one.
      for (final line in const [
        'final response = await http.get(Uri.parse(url), headers: headers);',
        'final request = http.MultipartRequest("POST", Uri.parse(url));',
        'static const Duration _timeout = Duration(seconds: 30);',
        'headers[HttpHeaders.authorizationHeader] = authValue;',
      ]) {
        expect(_forbidden.hasMatch(line), isFalse, reason: line);
      }
    });

    test('the cleartext pattern catches a URL and spares a scheme test', () {
      expect(
        _cleartext.hasMatch("baseUrl = 'http://staging.example.com';"),
        isTrue,
      );
      expect(_cleartext.hasMatch('baseUrl = "http://10.0.2.2:8000";'), isTrue);

      // helper.dart legitimately asks whether a URL already carries a scheme.
      // Matching that would make the guard noisy, which is how guards die.
      expect(
        _cleartext.hasMatch("if (url.startsWith('http://') || x) {}"),
        isFalse,
        reason: 'The bare scheme string is a scheme TEST, not an endpoint.',
      );
      expect(
        _cleartext.hasMatch("baseUrl = 'https://storesyria.com';"),
        isFalse,
      );
    });
  });
}

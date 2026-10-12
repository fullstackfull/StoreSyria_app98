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

void main() {
  group('TLS verification is not weakened', () {
    test('no certificate validation override anywhere in lib/', () {
      final forbidden = RegExp(
        r'badCertificateCallback'
        r'|onBadCertificate'
        r'|allowBadCertificates'
        r'|HttpOverrides'
        r'|setTrustedCertificatesBytes'
        r'|SecurityContext\(',
      );

      final hits = <String>[];

      for (final file in libDartFiles()) {
        final lines = codeOnly(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (forbidden.hasMatch(lines[i])) {
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
      final cleartext = RegExp(r'''["']http://[A-Za-z0-9]''');

      final hits = <String>[];

      for (final file in libDartFiles()) {
        final lines = commentsStripped(file.readAsStringSync()).split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (cleartext.hasMatch(lines[i])) {
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
}

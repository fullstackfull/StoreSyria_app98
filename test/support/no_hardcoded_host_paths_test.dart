import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_tree.dart';

/// A TEST MAY NOT OPEN A FILE THROUGH A HARD-CODED ABSOLUTE HOST PATH.
/// ===============================================================================================
///
/// WHY THIS EXISTS, and it is a defect this suite shipped rather than a hypothetical.
/// `test/localization/nav_labels_follow_locale_test.dart` pinned a GetX implementation detail by
/// reading the vendored source, and named it:
///
///     File('/root/.pub-cache/hosted/pub.dev/get-4.7.3/lib/get_navigation/src/'
///          'extension_navigation.dart')
///
/// Real in the development container (`HOME=/root`), absent on the GitHub runner
/// (`HOME=/home/runner`). The test's own premise assertion failed there and PR #7 went red on a
/// case that had just passed locally 1484/1484. The assertion was right; the path was not. A test
/// that is green on one machine only is worse than one that fails on all of them, because the
/// green run is the one people believe.
///
/// ------------------------------------------------------------------------------------------------
/// IT ASKS WHETHER THE PATH IS OPENED, NOT WHETHER IT APPEARS. The first draft of this file
/// flagged any host path in any non-comment line and reported TWO hits: the real defect, and
/// `test/security/release_signing_test.dart:413`
///
///     'storeFile = "/Users/dev/release.jks"',
///
/// which is a NEGATIVE-CONTROL FIXTURE -- a sample fed to that test's own hard-coded-path detector
/// to prove the detector fires. "Fixing" it would have broken a working test to satisfy a check
/// that had misread it. So this looks for a host-path literal reaching a file constructor, and the
/// second case below pins both directions so the narrowing cannot quietly widen again.
///
/// It uses `commentsStripped` from `source_tree.dart` rather than a `//`-eating regex: that helper
/// lexes, so it tells a path in prose from a path in code, and it KEEPS string literals, which is
/// what this check is about. `test/security/no_credential_logging_test.dart` quotes an SDK path in
/// its reasoning and must stay unflagged.
void main() {
  // The one pattern, defined once so the scan and its self-test cannot drift apart.
  //
  // `Uri.parse` AND FRIENDS ARE IN HERE BECAUSE THE BITE FOUND THEM MISSING. The first version
  // matched only `File(` / `Directory(`, so the bite -- replacing the repaired resolution with
  // `Uri.parse('file:///root/.pub-cache/...')` and opening THAT -- sailed straight through, and
  // the ratchet reported green on the very defect it exists to catch. A host path reaching a file
  // through a Uri variable is the same defect with one more hop.
  final opensHostPath = RegExp(
    r"""(File|Directory)\s*(\.fromUri)?\s*\(\s*(?:[^)]{0,80}?)['"](/root/|/home/[^/'"]+/|/Users/[^/'"]+/)"""
    r"""|Uri\s*\.\s*(parse|file|directory)\s*\(\s*(?:[^)]{0,80}?)['"](file://)?(/root/|/home/[^/'"]+/|/Users/[^/'"]+/)""",
    dotAll: true,
  );

  test('no test opens a file through a hard-coded absolute host path', () {
    final testRoot = Directory('${packageRoot().path}/test');
    expect(testRoot.existsSync(), isTrue, reason: 'premise: the test tree is where it is expected');

    final hits = <String>[];
    var filesScanned = 0;

    for (final entity in testRoot.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('no_hardcoded_host_paths_test.dart')) continue; // its own examples
      filesScanned++;

      final code = commentsStripped(entity.readAsStringSync());

      for (final m in opensHostPath.allMatches(code)) {
        final line = code.substring(0, m.start).split('\n').length;
        hits.add('${relative(entity)}:$line: ${m.group(0)!.replaceAll('\n', ' ')}');
      }
    }

    // PREMISE: the scan really walked the tree. Without it the assertion below is satisfied by a
    // scan that found no files at all -- the commonest way a census test passes for nothing.
    expect(filesScanned, greaterThan(50),
        reason: 'premise: the scan should reach the whole test tree; it saw $filesScanned files');

    expect(
      hits,
      isEmpty,
      reason: 'These tests open a path that exists on one machine only, so they pass locally and '
          'fail in CI. Use packageSourceRoot() from test/support/source_tree.dart instead:\n'
          '${hits.join('\n')}',
    );
  });

  test('the detector fires on the shape that shipped, and not on fixture data', () {
    expect(opensHostPath.hasMatch("File('/root/.pub-cache/hosted/pub.dev/get-4.7.3/lib/x.dart')"),
        isTrue, reason: 'the shape that shipped');
    expect(
        opensHostPath.hasMatch(
            "File('/root/.pub-cache/hosted/pub.dev/get-4.7.3/lib/'\n'x.dart')"),
        isTrue,
        reason: 'the same, split over two lines by adjacent-string concatenation');
    expect(opensHostPath.hasMatch('Directory("/home/runner/work/x")'), isTrue);
    expect(opensHostPath.hasMatch("File.fromUri(Uri.parse('/Users/dev/x'))"), isTrue);

    // THE SHAPE THE BITE USED, which the first version of this pattern missed entirely.
    expect(opensHostPath.hasMatch("Uri.parse('file:///root/.pub-cache/hosted/pub.dev/get-4.7.3/')"),
        isTrue, reason: 'a host path reaching a file through a Uri variable is the same defect');
    expect(opensHostPath.hasMatch("Uri.file('/home/runner/work/x')"), isTrue);
    expect(opensHostPath.hasMatch("Uri.directory('/Users/dev/cache')"), isTrue);

    // The negative controls are the point: the first draft matched the first of these, and it is
    // a real line in test/security/release_signing_test.dart.
    expect(opensHostPath.hasMatch('storeFile = "/Users/dev/release.jks"'), isFalse,
        reason: "fixture data for another test's detector, not a file this test opens");
    expect(opensHostPath.hasMatch("File('pubspec.lock')"), isFalse, reason: 'relative is correct');
    expect(opensHostPath.hasMatch("File('\${root.path}/.pub-cache/x')"), isFalse,
        reason: 'interpolated from a resolved root, which is what this file asks for');
    expect(opensHostPath.hasMatch("Uri.parse(someResolvedRoot)"), isFalse,
        reason: 'a Uri built from a resolved value is fine; only a literal host path is not');
    expect(opensHostPath.hasMatch("Uri.parse('https://example.test/root/x')"), isFalse,
        reason: 'an http URL whose path happens to contain /root/ is not a host path');
  });

  /// THE HOST-INDEPENDENCE PROOF, and it exists because the obvious one is impossible.
  ///
  /// The natural way to show the repair works is to point `package_config.json` at a
  /// `/home/runner`-style cache and watch the old code fail. That cannot be done through
  /// `flutter test`: it REGENERATES `.dart_tool/package_config.json` before the suite runs --
  /// measured, an edited `rootUri` came back as the real one with the test none the wiser. So the
  /// resolver takes its config file as an argument, and this drives it against a synthetic one in
  /// a temp directory. That is a stronger check than the simulation would have been: it shows the
  /// resolution follows whatever the config says, on any prefix, rather than only that one case.
  test('packageSourceRoot follows the config rather than the host', () {
    final tmp = Directory.systemTemp.createTempSync('pkgcfg');
    addTearDown(() => tmp.deleteSync(recursive: true));

    final fakeCache = Directory('${tmp.path}/home/runner/.pub-cache/hosted/pub.dev/get-9.9.9')
      ..createSync(recursive: true);
    Directory('${fakeCache.path}/lib/get_navigation/src').createSync(recursive: true);
    File('${fakeCache.path}/lib/get_navigation/src/extension_navigation.dart')
        .writeAsStringSync('// stand-in for the vendored source\n');

    final config = File('${tmp.path}/package_config.json')
      ..writeAsStringSync(jsonEncode({
        'configVersion': 2,
        'packages': [
          {'name': 'get', 'rootUri': fakeCache.uri.toString(), 'packageUri': 'lib/'},
        ],
      }));

    final root = packageSourceRootFrom(config, 'get');

    // The version directory survives: this is the trailing-slash defect, which dropped it.
    expect(root.path, contains('get-9.9.9'),
        reason: 'the version segment must survive resolution; resolved $root');

    final resolved = File.fromUri(root.resolve('lib/get_navigation/src/extension_navigation.dart'));
    expect(resolved.existsSync(), isTrue,
        reason: 'the resolver found the file under a /home/runner-style prefix: ${resolved.path}');

    // And a relative rootUri, which the spec also permits.
    final relConfig = File('${tmp.path}/rel.json')
      ..writeAsStringSync(jsonEncode({
        'configVersion': 2,
        'packages': [
          {'name': 'get', 'rootUri': 'home/runner/.pub-cache/hosted/pub.dev/get-9.9.9'},
        ],
      }));
    expect(
      File.fromUri(packageSourceRootFrom(relConfig, 'get')
          .resolve('lib/get_navigation/src/extension_navigation.dart')).existsSync(),
      isTrue,
      reason: 'a rootUri relative to the config file resolves too',
    );

    // A package that is not there is a clear error, not a silently wrong path.
    expect(() => packageSourceRootFrom(config, 'not_a_package'), throwsStateError);
  });
}

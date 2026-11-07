// ROUTE 1 · the guard on the golden infrastructure itself. NOTHING HERE SKIPS.
// =================================================================================================
//
// The golden CASES in this directory skip while their baselines are absent, which is deliberate —
// see `test/support/golden_harness.dart`. But a suite full of silent skips is how a gap becomes
// permanent: it is green, nobody is told, and a year later the baselines still do not exist.
//
// So this file always runs, and it answers the questions a skipped case cannot:
//
//   * do the fonts a baseline will be painted with actually exist, and does the harness's list
//     still match what `pubspec.yaml` declares? A font added to the app and not to the harness
//     would silently stop appearing in captures, and the only symptom would be a pixel diff
//     nobody can account for.
//   * is the design size the baselines are captured at the same size the APP lays out against?
//   * is any baseline set HALF captured? Three green pictures out of four look like coverage and
//     are not — the direction defect that motivated these goldens existed in exactly one of the
//     four combinations.
//   * does the capture job route 1 step 1 describes actually EXIST in CI, is it
//     `workflow_dispatch`-only, and does it upload rather than commit?
//   * and — the one that protects the existing gate — does the blocking `flutter test` step still
//     run WITHOUT excluding the golden tag? Narrowing that gate by a flag is the easy way to make
//     this infrastructure look finished, and it is exactly what must not happen.
//
// It also prints the capture state as a plain count, so `flutter test` output says how much of the
// baseline set exists rather than leaving it to be inferred from skip lines.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden_harness.dart';
import '../support/source_tree.dart';

/// The surfaces this directory has golden cases for. Asserted against the test sources below, so
/// adding a case without listing it here fails rather than going uncounted.
const List<String> kGoldenSurfaces = <String>[
  'customer-card',
  'delivery-boy-card',
];

void main() {
  final root = packageRoot().path;

  group('the fonts a baseline will be painted with', () {
    test('every face the harness lists exists on disk', () {
      final missing = kAppFontFaces.keys
          .where((p) => !File('$root/$p').existsSync())
          .toList();

      expect(missing, isEmpty,
          reason: 'the harness would paint these in the fallback font, so a baseline captured now '
              'would record glyphs the app never draws: ${missing.join(', ')}');
    });

    test('the harness list matches what pubspec.yaml declares, in both directions', () {
      final pubspec = File('$root/pubspec.yaml').readAsStringSync();

      // The fonts: block, read as text rather than parsed: this repository has no yaml dependency
      // and adding one for a guard test would be a larger change than the guard.
      final declared = RegExp(r'-\s*asset:\s*(assets/fonts/[^\s]+)')
          .allMatches(pubspec)
          .map((m) => m.group(1)!)
          .toSet();

      expect(declared, isNotEmpty,
          reason: 'premise: pubspec.yaml really declares font assets. If this fails the regex has '
              'drifted from the manifest and every other assertion here is meaningless');

      expect(kAppFontFaces.keys.toSet(), declared,
          reason: 'the harness and the manifest disagree about which font faces the app has. '
              'A face in the manifest but not the harness never reaches a baseline; a face in the '
              'harness but not the manifest makes loadAppFonts() throw');
    });
  });

  group('the size a baseline is captured at', () {
    test('is the size the app itself lays out against', () {
      final appSource = File('$root/lib/store_go.dart').readAsStringSync();
      final match = RegExp(r'designSize:\s*const\s+Size\(\s*(\d+)\s*,\s*(\d+)\s*\)')
          .firstMatch(appSource);

      expect(match, isNotNull,
          reason: 'premise: lib/store_go.dart states its own designSize. If this fails, read the '
              'file — the harness constant can no longer be checked against the app');

      final appSize = Size(
        double.parse(match!.group(1)!),
        double.parse(match.group(2)!),
      );

      expect(kGoldenDesignSize, appSize,
          reason: 'baselines would be captured at a size the app never lays out against, so every '
              'picture would show ScreenUtil scaling that no device produces');
    });
  });

  group('the baseline set', () {
    test('is never HALF captured — all four combinations or none', () {
      final report = <String, List<String>>{};

      for (final surface in kGoldenSurfaces) {
        final present = kFourCombinations
            .where((c) => File('$root/test/golden/${goldenPath(surface, c)}').existsSync())
            .map((c) => c.name)
            .toList();
        report[surface] = present;
      }

      final partial = report.entries
          .where((e) => e.value.isNotEmpty && e.value.length != kFourCombinations.length)
          .map((e) => '${e.key} has only ${e.value.join(', ')}')
          .toList();

      expect(partial, isEmpty,
          reason: 'a partly captured surface is worse than an uncaptured one: the present '
              'combinations go green and read as coverage while the missing one — which is where '
              'the direction defect that motivated these goldens actually lived — is silently '
              'unchecked. ${partial.join('; ')}');

      // Not an assertion: the capture state, said out loud.
      final captured = report.values.where((v) => v.length == kFourCombinations.length).length;
      // ignore: avoid_print
      print('[golden] $captured of ${kGoldenSurfaces.length} surfaces have a reviewed baseline set '
          '(${captured * kFourCombinations.length} of '
          '${kGoldenSurfaces.length * kFourCombinations.length} images). '
          '${captured == kGoldenSurfaces.length ? 'Complete.' : 'Route 1 step 2 is outstanding: '
              'run the capture job, review the PNGs, commit them.'}');
    });

    test('every golden case in this directory is listed in kGoldenSurfaces', () {
      final files = Directory('$root/test/golden')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('_golden_test.dart'))
          .toList();

      expect(files, isNotEmpty, reason: 'premise: this directory holds golden test files');

      final referenced = <String>{};
      for (final file in files) {
        for (final m in RegExp(r"goldenPath\(\s*'([a-z0-9-]+)'")
            .allMatches(file.readAsStringSync())) {
          referenced.add(m.group(1)!);
        }
      }

      expect(referenced, kGoldenSurfaces.toSet(),
          reason: 'a golden case names a surface this file does not count, or this file counts one '
              'that no case renders, so the capture report above is wrong');
    });
  });

  group('the CI wiring route 1 step 1 describes', () {
    late String workflow;
    late String workflowCode;

    setUp(() {
      workflow = File('$root/.github/workflows/ci.yml').readAsStringSync();

      // THE PROSE MUST NOT BE SEARCHED, and the first draft of this file got it wrong in a way
      // worth keeping the note for. `--exclude-tags` is the flag that would narrow the blocking
      // gate, and the comment block explaining WHY it was not used naturally contains the string.
      // So the whole-file search failed on this repository's own explanation of the thing it was
      // checking had not happened. Comments are stripped, the way
      // `test/support/source_tree.dart::codeOnly` does it for Dart.
      workflowCode = workflow
          .split('\n')
          .where((line) => !line.trimLeft().startsWith('#'))
          .join('\n');
    });

    test('a capture job exists and runs --update-goldens', () {
      expect(workflowCode, contains('--update-goldens'),
          reason: 'route 1 step 1 is a job that regenerates the baselines and uploads them for '
              'human review. Without it the skip reason on every golden case points at nothing');
    });

    test('the capture job is workflow_dispatch-only', () {
      expect(workflowCode, contains('workflow_dispatch'),
          reason: 'the capture job must be triggered by hand. A capture that ran on every push '
              'would regenerate the baselines from whatever the code currently draws, which turns '
              'the pixel comparison into a no-op and removes the human review step entirely');

      final captureJob = RegExp(r'if:\s*github\.event_name\s*==\s*.workflow_dispatch.')
          .hasMatch(workflowCode);
      expect(captureJob, isTrue,
          reason: 'the capture job has no event guard, so it would also run on pull_request and '
              'push — see the reason above');
    });

    test('it uploads the images instead of committing them', () {
      expect(workflowCode, contains('upload-artifact'),
          reason: 'the captured PNGs must leave CI as an artifact a human downloads and reviews. A '
              'job that committed them would be the agent approving its own baselines');

      expect(workflowCode.contains('git commit') && workflowCode.contains('--update-goldens'), isFalse,
          reason: 'the workflow both captures baselines and commits — route 1 step 2 is a human '
              'review, and this would bypass it');
    });

    test('THE EXISTING BLOCKING GATE IS NOT NARROWED', () {
      // The honest alternative to self-skipping cases was `flutter test --exclude-tags golden`,
      // which would have removed a flag's worth of coverage from the one gate that is declared
      // blocking and 100%. This asserts that was not done.
      expect(workflowCode, isNot(contains('--exclude-tags')),
          reason: 'the blocking `flutter test` step now excludes a tag. The golden cases skip '
              'themselves while their baselines are absent precisely so this gate did not have to '
              'be narrowed — restore the gate and let the cases skip');

      // And the gate itself is still there, unqualified. Asserting only the absence of a flag
      // would pass if somebody deleted the step outright.
      expect(workflowCode, contains('run: flutter test --reporter expanded'),
          reason: 'the blocking, unfiltered `flutter test` step is gone from ci.yml');
    });
  });

  group('the golden cases themselves', () {
    test('are tagged, so the capture job can select exactly them', () {
      final files = Directory('$root/test/golden')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('_golden_test.dart'));

      for (final file in files) {
        final source = file.readAsStringSync();
        final goldenCalls = RegExp('matchesGoldenFile').allMatches(source).length;
        final tags = RegExp(r"tags:\s*const\s*<String>\[\s*'golden'\s*\]")
            .allMatches(source)
            .length;

        expect(tags, goldenCalls,
            reason: '${relative(file)} has $goldenCalls golden expectations but $tags tagged '
                'cases. An untagged case is not selected by `--tags golden`, so the capture job '
                'would never generate its baseline and it would skip for ever');
      }
    });

    test('the tag is declared, so the runner does not reject it', () {
      final config = File('$root/dart_test.yaml');
      expect(config.existsSync(), isTrue,
          reason: 'dart_test.yaml must declare the `golden` tag. An undeclared tag makes '
              '`--tags golden` print a warning and, with the runner configured strictly, fail');
      expect(config.readAsStringSync(), contains('golden'));
    });
  });
}

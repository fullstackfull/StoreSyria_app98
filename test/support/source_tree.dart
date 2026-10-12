// Helpers shared by the source-level guard tests.
//
// These tests read the repository's own sources rather than running the app.
// That is the right shape for them: the behavioural question behind
// "does a credential reach logcat in a release build?" needs a physical device
// and a release APK, which no CI runner here has. The source-level question —
// "can a credential reach a log call at all?" — is decidable statically, and it
// is the one that actually regresses when somebody adds a debugging line.

import 'dart:io';

/// Package root, found by walking up until `pubspec.yaml` appears.
///
/// `flutter test` runs with the package root as cwd, but an IDE may not, so
/// this does not assume it.
Directory packageRoot() {
  var dir = Directory.current;

  for (var i = 0; i < 8; i++) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  throw StateError(
    'Could not find pubspec.yaml above ${Directory.current.path}',
  );
}

/// Every `.dart` file under `lib/`, sorted for stable failure messages.
List<File> libDartFiles() {
  final lib = Directory('${packageRoot().path}/lib');

  final files = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

/// Path relative to the package root, for readable failure messages.
String relative(File file) {
  final root = packageRoot().path;
  return file.path.startsWith(root)
      ? file.path.substring(root.length + 1)
      : file.path;
}

/// Reads [file] with every comment and string literal blanked out.
///
/// Guard tests must not fire on prose. A test that cannot tell `print(` in code
/// from `print(` in a comment is a test that gets suppressed the first time it
/// cries wolf, so this does the lexing instead of using a naive grep.
///
/// Line structure is preserved — blanked characters become spaces, newlines are
/// kept — so a reported line number still matches the real file.
String codeOnly(String source) {
  final out = StringBuffer();
  var i = 0;
  final n = source.length;

  void blank(int count) {
    for (var k = 0; k < count; k++) {
      out.write(' ');
    }
  }

  while (i < n) {
    final c = source[i];

    // ---- line comment ----
    if (c == '/' && i + 1 < n && source[i + 1] == '/') {
      while (i < n && source[i] != '\n') {
        out.write(' ');
        i++;
      }
      continue;
    }

    // ---- block comment (Dart nests them) ----
    if (c == '/' && i + 1 < n && source[i + 1] == '*') {
      var depth = 1;
      blank(2);
      i += 2;
      while (i < n && depth > 0) {
        if (source[i] == '/' && i + 1 < n && source[i + 1] == '*') {
          depth++;
          blank(2);
          i += 2;
          continue;
        }
        if (source[i] == '*' && i + 1 < n && source[i + 1] == '/') {
          depth--;
          blank(2);
          i += 2;
          continue;
        }
        out.write(source[i] == '\n' ? '\n' : ' ');
        i++;
      }
      continue;
    }

    // ---- string literal ----
    if (c == '"' || c == "'") {
      final isRaw = i > 0 && source[i - 1] == 'r';
      final triple = i + 3 <= n &&
          (source.substring(i, i + 3) == '"""' ||
              source.substring(i, i + 3) == "'''");
      final quote = triple ? source.substring(i, i + 3) : c;

      blank(quote.length);
      i += quote.length;

      while (i < n) {
        if (!isRaw && source[i] == '\\') {
          blank(2);
          i += 2;
          continue;
        }
        if (i + quote.length <= n &&
            source.substring(i, i + quote.length) == quote) {
          blank(quote.length);
          i += quote.length;
          break;
        }
        // An interpolation is real code and must stay visible.
        if (!isRaw && source[i] == '\$') {
          if (i + 1 < n && source[i + 1] == '{') {
            var depth = 1;
            out.write('  ');
            i += 2;
            while (i < n && depth > 0) {
              if (source[i] == '{') depth++;
              if (source[i] == '}') depth--;
              out.write(depth == 0 ? ' ' : source[i]);
              i++;
            }
            continue;
          }
          out.write(' ');
          i++;
          while (i < n && RegExp(r'[A-Za-z0-9_]').hasMatch(source[i])) {
            out.write(source[i]);
            i++;
          }
          continue;
        }
        out.write(source[i] == '\n' ? '\n' : ' ');
        i++;
      }
      continue;
    }

    out.write(c);
    i++;
  }

  return out.toString();
}

/// Reads [file] with comments blanked out but STRING LITERALS KEPT.
///
/// [codeOnly] is wrong for checks about string contents — it blanks
/// `'Bearer $token'` away entirely. This variant keeps literals, so a test can
/// ask "where in real code does this text appear?" without being fooled by
/// prose in a comment.
String commentsStripped(String source) {
  final out = StringBuffer();
  var i = 0;
  final n = source.length;

  while (i < n) {
    final c = source[i];

    if (c == '/' && i + 1 < n && source[i + 1] == '/') {
      while (i < n && source[i] != '\n') {
        out.write(' ');
        i++;
      }
      continue;
    }

    if (c == '/' && i + 1 < n && source[i + 1] == '*') {
      var depth = 1;
      out.write('  ');
      i += 2;
      while (i < n && depth > 0) {
        if (source[i] == '/' && i + 1 < n && source[i + 1] == '*') {
          depth++;
          out.write('  ');
          i += 2;
          continue;
        }
        if (source[i] == '*' && i + 1 < n && source[i + 1] == '/') {
          depth--;
          out.write('  ');
          i += 2;
          continue;
        }
        out.write(source[i] == '\n' ? '\n' : ' ');
        i++;
      }
      continue;
    }

    // Inside a string literal a `//` is not a comment, so copy the literal
    // through verbatim rather than re-lexing it.
    if (c == '"' || c == "'") {
      final isRaw = i > 0 && source[i - 1] == 'r';
      final triple = i + 3 <= n && _isTripleQuote(source.substring(i, i + 3));
      final quote = triple ? source.substring(i, i + 3) : c;

      out.write(quote);
      i += quote.length;

      while (i < n) {
        if (!isRaw && source[i] == '\\') {
          out.write(source.substring(i, i + 2 > n ? n : i + 2));
          i += 2;
          continue;
        }
        if (i + quote.length <= n &&
            source.substring(i, i + quote.length) == quote) {
          out.write(quote);
          i += quote.length;
          break;
        }
        out.write(source[i]);
        i++;
      }
      continue;
    }

    out.write(c);
    i++;
  }

  return out.toString();
}

bool _isTripleQuote(String s) => s == '"""' || s == "'''";

/// 1-based line numbers in [source] whose code part matches [pattern].
List<int> matchingLines(String source, Pattern pattern) {
  final lines = codeOnly(source).split('\n');
  final hits = <int>[];

  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains(pattern)) hits.add(i + 1);
  }

  return hits;
}

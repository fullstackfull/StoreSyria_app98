// The single logging seam for the Store Syria merchant app.
//
// WHY THIS FILE EXISTS — Phase 1B, findings SEC-20a / R7-02, SEC-20b / R7-03,
// SEC-20c / R7-04.
//
// Before this seam existed the app wrote the merchant's e-mail together with
// their PLAINTEXT password to the device log on every login attempt, printed the
// bearer token on every cold start before `runApp`, and logged every full HTTP
// response body — including the login response that carries the token. There
// was no release guard of any kind: `grep -rn "kReleaseMode\|kDebugMode" lib/`
// returned zero hits.
//
// THE THREE RULES THIS SEAM ENFORCES
//
//  1. RELEASE BUILDS EMIT NOTHING. Every method short-circuits on `kReleaseMode`
//     and the underlying logger's level is `Level.off` in release. A shipped APK
//     writes no application log line at all, so `adb logcat` on a merchant's
//     device yields nothing and Firebase Crashlytics — which uploads recent log
//     output as crash breadcrumbs — has nothing to upload. That last point is
//     the hard ordering dependency recorded in the implementation plan:
//     Crashlytics must not be enabled while credentials can reach the log.
//
//  2. CREDENTIALS ARE NEVER LOGGED AT ANY LEVEL, NOT EVEN IN DEBUG. Passwords
//     are not loggable through this seam at all — there is no code path that
//     accepts one. Tokens pass through [redact] or [safe], which replace the
//     value with a fixed marker.
//
//  3. CALL SITES LOG THROUGH [safe], NOT RAW OBJECTS. [safe] walks maps and
//     lists and masks sensitive keys, and scrubs `Bearer <token>` and
//     `"token": "..."` out of free-form strings, so a future server field
//     rename cannot silently reintroduce a leak.
//
// Deliberately NOT done here: this seam does not ship logs anywhere, does not
// buffer them, and adds no dependency. It wraps the `logger` package that
// `pubspec.yaml` already declares.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLog {
  AppLog._();

  /// Replaces any redacted value. Fixed-width on purpose: it leaks neither the
  /// value nor its length.
  static const String redacted = '***redacted***';

  /// Written as a whole literal rather than interpolated so that the only
  /// `Bearer <interpolation>` expression under lib/ stays the one place the
  /// header is actually built (finding R7-N1).
  static const String _bearerRedacted = 'Bearer ***redacted***';

  /// Map keys whose VALUE must never reach a log line. Compared
  /// case-insensitively after stripping `-` and `_`.
  static const Set<String> _sensitiveKeys = <String>{
    'password',
    'passwordconfirmation',
    'currentpassword',
    'oldpassword',
    'newpassword',
    'confirmpassword',
    'token',
    'accesstoken',
    'refreshtoken',
    'apitoken',
    'authtoken',
    'bearertoken',
    'fcmtoken',
    'devicetoken',
    'authorization',
    'cookie',
    'setcookie',
    'secret',
    'clientsecret',
    'apikey',
    'privatekey',
    'otp',
    'pin',
    'cardnumber',
    'cvv',
    'cvc',
  };

  /// `Bearer eyJ...` in any casing, anywhere in a string.
  static final RegExp _bearerPattern = RegExp(
    r'bearer\s+[A-Za-z0-9\-._~+/=|]+',
    caseSensitive: false,
  );

  /// `"token": "..."` / `'password':'...'` in a serialised body.
  ///
  /// Built by concatenating raw strings so the quote characters stay readable.
  static final RegExp _jsonSecretPattern = RegExp(
    r"""["'](""" +
        _sensitiveKeyAlternation +
        r""")["']\s*:\s*["'][^"']*["']""",
    caseSensitive: false,
  );

  static const String _sensitiveKeyAlternation =
      'password|password_confirmation|current_password|old_password|'
      'new_password|confirm_password|token|access_token|refresh_token|'
      'api_token|auth_token|bearer_token|fcm_token|device_token|'
      'authorization|secret|client_secret|api_key|private_key|otp|pin|'
      'card_number|cvv|cvc';

  static final Logger _logger = Logger(
    // ProductionFilter defers entirely to [level]; it does not second-guess the
    // build mode the way DevelopmentFilter does.
    filter: ProductionFilter(),
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  /// True only where logging is permitted. Exposed so a caller can skip
  /// building an expensive message string in release.
  static bool get isEnabled => !kReleaseMode;

  static void d(Object? message) {
    if (kReleaseMode) return;
    _logger.d(safe(message));
  }

  static void i(Object? message) {
    if (kReleaseMode) return;
    _logger.i(safe(message));
  }

  static void w(Object? message) {
    if (kReleaseMode) return;
    _logger.w(safe(message));
  }

  static void e(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    _logger.e(
      safe(message),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Masks a single secret. Use at the call site so the intent is visible in
  /// the diff: `AppLog.d('token=${AppLog.redact(token)}')`.
  static String redact(String? secret) {
    if (secret == null || secret.isEmpty) return '(empty)';
    return redacted;
  }

  /// Returns [value] with every sensitive value masked.
  ///
  /// Maps and lists are copied (the caller's object is never mutated) and any
  /// entry whose key is sensitive is replaced by [redacted]. Strings are
  /// scrubbed of `Bearer <token>` and of `"<sensitive key>": "<value>"` pairs,
  /// which is what makes it safe to log a raw HTTP response body.
  static Object? safe(Object? value) {
    return _safe(value, 0);
  }

  static Object? _safe(Object? value, int depth) {
    // Bound the walk: a cyclic or pathologically nested structure must not turn
    // a log call into a hang.
    if (depth > 8) return redacted;

    if (value == null) return null;

    if (value is String) return scrubString(value);

    if (value is num || value is bool) return value;

    if (value is Map) {
      final out = <String, Object?>{};
      value.forEach((key, entry) {
        final name = key.toString();
        if (isSensitiveKey(name)) {
          out[name] = redacted;
        } else {
          out[name] = _safe(entry, depth + 1);
        }
      });
      return out;
    }

    if (value is Iterable) {
      return value.map((entry) => _safe(entry, depth + 1)).toList();
    }

    return scrubString(value.toString());
  }

  /// True when a map key's value must be masked.
  static bool isSensitiveKey(String key) {
    final normalised =
        key.toLowerCase().replaceAll('-', '').replaceAll('_', '').trim();
    return _sensitiveKeys.contains(normalised);
  }

  /// Removes bearer tokens and `"<secret>": "<value>"` pairs from free text.
  static String scrubString(String input) {
    if (input.isEmpty) return input;

    var out = input.replaceAll(_bearerPattern, _bearerRedacted);

    out = out.replaceAllMapped(
      _jsonSecretPattern,
      (match) => '"${match.group(1)}": "$redacted"',
    );

    return out;
  }

  /// Pretty-prints a JSON-ish payload with every secret masked. Returns a
  /// single-line fallback when the value will not encode.
  static String prettyJson(Object? data) {
    Object? decoded = data;

    if (data is String) {
      try {
        decoded = jsonDecode(data);
      } catch (_) {
        return scrubString(data);
      }
    }

    try {
      return const JsonEncoder.withIndent('  ').convert(safe(decoded));
    } catch (_) {
      return scrubString(decoded.toString());
    }
  }
}

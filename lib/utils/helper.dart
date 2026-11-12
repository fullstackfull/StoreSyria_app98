import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

String parseHtmlString(String? htmlString) {
  var document = parse(htmlString);
  return parse(document.body!.text).documentElement!.text;
}

DateTime parseDateTime(String strDate) => DateTime.parse(strDate);

/// THE ACTIVE LOCALE, OR ENGLISH. `Get.locale` is null before the app's locale is applied --
/// which is the case in a plain widget test -- so this falls back rather than throwing.
String _activeDateLocale() {
  final code = Get.locale?.languageCode;

  return (code == null || code.isEmpty) ? 'en' : code;
}

/// FORMATS IN THE MERCHANT'S LANGUAGE, not in en_US.
///
/// `DateFormat(format)` with no locale always resolves `MMM` to an English abbreviation, so an
/// Arabic screen printed `Nov` -- and a Latin date inside an RTL line reorders, which is how the
/// coupon redemption history came to read `Nov 2026 01`. The symbols are loaded once in `main()`
/// by `initializeDateFormatting()`; without that call this constructor throws for `ar`.
DateFormat formatDateTime(String format) => DateFormat(format, _activeDateLocale());

String dateFormatted({required String date, required String formatType}) =>
    formatDateTime(formatType).format(parseDateTime(date));

enum FormatType {
  dateTime,
  dateTime2,
  date,
  time,
  ddMMMYYYY,
}


String formatForDateTime(FormatType formatType) {
  switch (formatType) {
    case FormatType.date:
      {
        return "dd MMM yyyy";
      }
    case FormatType.dateTime:
      {
        return "dd-MM-yyyy hh:mm a";
      }
    case FormatType.dateTime2:
      {
        return "dd MMM hh:mm a";
      }
    case FormatType.time:
      {
        return "hh:mm a";
      }
    case FormatType.ddMMMYYYY:
      {
        return "dd MMM,yyyy";
      }
  }
}

class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex = "FF${hex.toUpperCase().replaceAll("#", "")}";
    return int.parse(formattedHex, radix: 16);
  }

  HexColor(final String hex) : super(_getColor(hex));
}

String getImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) {
    return "";
  }
  if (url.startsWith("http://") || url.startsWith("https://")) {
    return url;
  }
  String cleanedPath = url;
  while (cleanedPath.startsWith('/')) {
    cleanedPath = cleanedPath.substring(1);
  }
  return "https://storesyria.com/$cleanedPath";
}

double parsePriceSafe(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 0.0;

  String cleaned = raw.replaceAll(RegExp(r'[^\d.]'), '').trim();

  if (cleaned.isEmpty) return 0.0;


  final parts = cleaned.split('.');
  if (parts.length > 2) {
    final decimalPart = parts.removeLast();
    cleaned = parts.join('') + '.' + decimalPart;
  }

  return double.tryParse(cleaned) ?? 0.0;
}
String formatPriceRaw(dynamic raw) {
  if (raw == null) return '';
  final value = raw.toString().trim();
  return value;
}


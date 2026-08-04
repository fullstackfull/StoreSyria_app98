import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

String parseHtmlString(String? htmlString) {
  var document = parse(htmlString);
  return parse(document.body!.text).documentElement!.text;
}

DateTime parseDateTime(String strDate) => DateTime.parse(strDate);

DateFormat formatDateTime(String format) => DateFormat(format);

String dateFormatted({required String date, required String formatType}) =>
    formatDateTime(formatType).format(parseDateTime(date));

enum FormatType {
  dateTime,
  date,
  time,
  ddMMMYYYY,
}


String formatForDateTime(FormatType formatType) {
  switch (formatType) {
    case FormatType.date:
      {
        return "MMM dd,yyyy";
      }
    case FormatType.dateTime:
      {
        return "dd-MM-yyyy hh:mm a";
      }
    case FormatType.time:
      {
        return "hh:mm a";
      }
    case FormatType.ddMMMYYYY:
      {
        return "dd MMM,yyyy";
      }
    default:
      {
        return "";
      }
  }
}

double parseWcPrice(String? price) => (double.tryParse(price ?? "0") ?? 0);

enum SymbolPositionType { left, right }

const SymbolPositionType appCurrencySymbolPosition = SymbolPositionType.left;

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


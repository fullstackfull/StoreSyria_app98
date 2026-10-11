import 'package:get/get.dart';

String convertToAgo(DateTime input) {
  Duration diff = DateTime.now().difference(input);

  if (diff.inDays >= 30) {
    return 'months_ago'.trParams({
      'count': (diff.inDays / 30).toStringAsFixed(0),
    });
  } else if (diff.inDays >= 1) {
    return 'days_ago'.trParams({
      'count': diff.inDays.toString(),
    });
  } else if (diff.inHours >= 1) {
    return 'hours_ago'.trParams({
      'count': diff.inHours.toString(),
    });
  } else if (diff.inMinutes >= 1) {
    return 'minutes_ago'.trParams({
      'count': diff.inMinutes.toString(),
    });
  } else if (diff.inSeconds >= 1) {
    return 'seconds_ago'.trParams({
      'count': diff.inSeconds.toString(),
    });
  } else {
    return 'just_now'.tr;
  }
}
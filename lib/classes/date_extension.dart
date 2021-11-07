import 'package:intl/intl.dart';

extension DateMethods on DateTime {
  bool isSameDay(DateTime value) {
    return day == value.day && month == value.month && year == value.year;
  }

  String smartString({DateTime? from}) {
    var now = from ?? DateTime.now();
    var diff = now.difference(this);
    if (diff.inHours < 24) {
      if (diff.inMinutes > 59) {
        return diff.inHours.toString() + ' hours ago';
      } else {
        return diff.inMinutes.toString() + ' minutes ago';
      }
    }
    if (now.day - day == 1) {
      var format = DateFormat.jm();
      return 'Yesterday at ' + format.format(this);
    }
    var format = now.year != year ? DateFormat.yMd() : DateFormat.MMMMd();

    format = format.add_jm();

    return format.format(this);
  }
}

import 'package:intl/intl.dart';

extension DateMethods on DateTime {
  bool isSameDay(DateTime value) {
    return day == value.day && month == value.month && year == value.year;
  }

  String smartString() {
    var now = DateTime.now();
    var diff = now.difference(this);
    if (now.isSameDay(this)) {
      if (diff.inMinutes > 59) {
        return diff.inHours.toString() + ' hours ago';
      } else {
        return diff.inMinutes.toString() + ' minutes ago';
      }
    }
    if (diff.inDays == 1) {
      var format = DateFormat.jm();
      return 'Yesterday at ' + format.format(this);
    }
    var format = now.year != year ? DateFormat.yMd() : DateFormat.MMMMd();

    format = format.add_jm();

    return format.format(this);
  }
}

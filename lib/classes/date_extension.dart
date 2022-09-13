import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateMethods on DateTime {
  bool isSameDay(DateTime value) {
    return day == value.day && month == value.month && year == value.year;
  }

  String smartString({DateTime? from}) {
    // requires a locale initialization using the initializeDateFromatting()
    var now = from ?? DateTime.now();
    var diff = now.difference(this);

    if (now.day - day == 1) {
      var format = DateFormat.jm(localeStr);
      return "Yesterday at ${format.format(this)}";
    }

    if (diff.inHours < 24) {
      if (diff.inMinutes > 59) {
        return diff.inHours.toString() + ' hours ago';
      } else {
        return diff.inMinutes.toString() + ' minutes ago';
      }
    }
    var format = now.year != year
        ? DateFormat.yMd(localeStr)
        : DateFormat.MMMMd(localeStr);

    return asStringTime(fmt: format);
  }

  String asStringTime({DateFormat? fmt}) {
    var p = (fmt ?? DateFormat.yMd(localeStr)).format(this);
    return "$p ${timeFormat.format(this)}";
  }

  static Locale? locale;
  static String get localeStr => locale?.toString() ?? "uk_UA";

  static DateFormat timeFormat = DateFormat("kk:mm", localeStr);

  static set mediaQueryData(MediaQueryData mediaQueryData) {
    timeFormat = mediaQueryData.alwaysUse24HourFormat
        ? timeFormat = DateFormat("kk:mm", localeStr)
        : timeFormat = DateFormat("KK:mm a", localeStr);
  }
}

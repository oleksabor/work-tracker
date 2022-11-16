import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:work_tracker/classes/date_extension.dart';

void main() {
  test('to smart string conversion', () {
    initializeDateFormatting("en_US", null);
    var d = DateTime(2021, 11, 7, 13, 49);
    var yesterday = d.subtract(Duration(days: 1));

    var str = yesterday.smartString(from: d);

    expect(str.split(" ")[0], "Yesterday");

    yesterday = d.subtract(Duration(minutes: 20));
    str = yesterday.smartString(from: d);
    expect(str.split(" ")[1], "minutes");
    expect(str.split(" ")[0], "20");

    yesterday = d.subtract(Duration(hours: 10));
    str = yesterday.smartString(from: d);
    expect(str.split(" ")[1], "hours");
    expect(str.split(" ")[0], "10");

    yesterday = d.subtract(Duration(hours: 26));
    str = yesterday.smartString(from: d);
    expect(str.split(" ")[0], "Yesterday");
  });

  test('to smart string conversion yesterday', () {
    initializeDateFormatting("en_US", null);
    var d = DateTime(2021, 11, 7, 8, 19);
    var yesterday = d.subtract(const Duration(hours: 10));

    var str = yesterday.smartString(from: d);
    expect(str.split(" ")[0], "Yesterday");
  });

  test('as month abbr', () {
    initializeDateFormatting("en_US", null);
    var d = DateTime(2021, 11, 7, 8, 19);
    var str = d.getMonthABBR();
    expect(str, "Nov");
  });
}

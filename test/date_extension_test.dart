import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/date_extension.dart';

void main() {
  test('Counter value should be incremented', () {
    var d = DateTime(2021, 11, 7, 13, 49);
    var yesterday = d.subtract(Duration(days: 1));

    var str = yesterday.smartString(from: d);

    expect(str.split(" ")[0], "Yesterday");

    yesterday = d.subtract(Duration(minutes: 20));
    str = yesterday.smartString(from: d);
    expect(str.split(" ")[1], "minutes");
    expect(str.split(" ")[0], "20");

    yesterday = d.subtract(Duration(hours: 20));
    str = yesterday.smartString(from: d);
    expect(str.split(" ")[1], "hours");
    expect(str.split(" ")[0], "20");

    yesterday = d.subtract(Duration(hours: 26));
    str = yesterday.smartString(from: d);
    expect(str.split(" ")[0], "Yesterday");
  });
}

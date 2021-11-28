import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:work_tracker/classes/iterable_extension.dart';

void main() {
  test('groupBy int', () {
    var src = [DataInt(1), DataInt(2), DataInt(3), DataInt(1)];
    var res = src.groupBy((p0) => p0.id);
    expect(res.length, 3);
  });
  test('groupBy str', () {
    var src = [DataStr("1"), DataStr("2"), DataStr("3"), DataStr("1")];
    var res = src.groupBy((p0) => p0.id);
    expect(res.length, 3);
  });
  test('groupBy strDate', () {
    var d1 = DateTime(2021, 11, 27);
    var d2 = DateTime(2021, 11, 25);

    var src = [
      DataStr(DateFormat.yMd().format(d1)),
      DataStr(DateFormat.yMd().format(d1)),
      DataStr(DateFormat.yMd().format(d1)),
      DataStr(DateFormat.yMd().format(d2))
    ];
    var res = src.groupBy((p0) => p0.id);
    expect(res.length, 2);
  });
}

class DataInt {
  int id;
  DataInt(this.id);
}

class DataStr {
  String id;
  DataStr(this.id);
}

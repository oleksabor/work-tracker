import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/calendar.dart';
import 'work_view_model_test.dart';
import 'package:collection/collection.dart';
import 'package:work_tracker/classes/date_extension.dart';

void main() async {
  test('calendar items by kind', () {
    var sut = Calendar();

    var wk1 = WorkKindTest(123)..title = "ttt";
    var wk2 = WorkKindTest(456)..title = "yyy";

    var k1 = sut.getKind([wk1, wk2], 123);
    expect(k1.kindId, 123);
    var k2 = sut.getKind([wk1, wk2], 456);
    expect(k2.kindId, 456);

    var k3 = sut.getKind([wk1, wk2], 1);
    expect(k3.kindId, -1);
  });

  test('calendar days from work items', () {
    var wk1 = WorkKindTest(123)..title = "ttt";
    var wk2 = WorkKindTest(456)..title = "yyy";

    var sut = Calendar();
    var now = DateTime(2021, 11, 21);

    var dt1 = DateTime(2021, 11, 20, 18, 08);
    var dt2 = DateTime(2021, 11, 15, 18, 08);
    var dt3 = DateTime(2021, 11, 5, 18, 08);
    var all = [
      addWI(wk1, dt1, qty: 1),
      addWI(wk1, dt1, qty: 2),
      addWI(wk1, dt2, qty: 3),
      addWI(wk1, dt3, qty: 4),
      addWI(wk2, dt3, qty: 5),
      addWI(wk2, dt2, qty: 6),
    ];
    var def = Day(dt1);

    var days = sut.load(all, now, [wk1, wk2]).toList();
    var d21 = days.firstWhere((e) => e.date.isSameDay(now), orElse: () => def);
    var d20 = days.firstWhere((e) => e.date.isSameDay(dt1), orElse: () => def);
    var d5 = days.firstWhere((e) => e.date.isSameDay(dt3), orElse: () => def);
    expect(days.first.date.day, now.subtract(const Duration(days: 30)).day);
    expect(days.last.date, now);
    expect(d20.result?.isNotEmpty, true);
    expect(d20.result!.map((_) => _.qty).sum, 3);
    expect(d5.result?.isNotEmpty, true);
    expect(d5.result!.map((_) => _.qty).sum, 9);
    expect(d21.result, null);
  });
}

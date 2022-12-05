import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/calendar.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'work_view_model_test.dart';
import 'package:collection/collection.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  test('calendar days title', () {
    var dt1 = DateTime(2021, 11, 1, 18, 08);
    var dt2 = DateTime(2021, 11, 2, 18, 08);
    var dt3 = DateTime(2021, 12, 1, 2, 08);
    initializeDateFormatting("en_US", null);

    var items1 = [WorkKind.m("test1")];

    var sut = Calendar();
    var data = [
      CalendarData(dt1, items1),
      CalendarData(dt1.add(Duration(days: 2)), <WorkKind>[]),
      CalendarData(dt1.add(Duration(days: 3)), <WorkKind>[]),
      CalendarData(dt2, [WorkKind.m("test2")]),
      CalendarData(dt2.add(Duration(days: 2)), <WorkKind>[]),
      CalendarData(dt2.add(Duration(days: 3)), <WorkKind>[]),
      CalendarData(dt2.add(Duration(days: 4)), <WorkKind>[]),
      CalendarData(dt2.add(Duration(days: 5)), <WorkKind>[]),
      CalendarData(dt3, [WorkKind.m("test3")]),
    ];

    var res = sut.getDataTitle(data);
    expect(res[0].title, "Nov:");
    expect(res[0].isData, false);
    expect(res[1].title, "1");
    expect(res[1].date.month, 11);
    expect(res[1].isData, true);

    expect(res[9].title, "Dec:");
    expect(res[9].isData, false);
    expect(res[10].title, "1");
    expect(res[10].date.month, 12);
    expect(res[10].isData, true);
  });
}

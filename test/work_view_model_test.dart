import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';

WorkItem addWI(WorkKind kind, DateTime created, {int? qty}) {
  var res = WorkItem();
  res.created = created;
  res.qty = qty ?? ++id;
  res.kind = kind.title;
  if (kind.kindId >= 0) {
    // res.kindId is -1 by default so it is not getting value from kind.kindId
    res.kindId = kind.kindId;
  }
  return res;
}

class WorkKindTest extends WorkKind {
  WorkKindTest(int id) {
    super.kindId = id;
  }
}

int id = 0;

void main() async {
  test('items should be filtered', () async {
    var sut = WorkViewModel();
    var dt1 = DateTime(2021, 11, 20, 18, 08);
    var dt2 = DateTime(2021, 11, 15, 18, 08);
    var dt3 = DateTime(2021, 11, 5, 18, 08);
    var wk1 = WorkKindTest(123)..title = "ttt";
    var wk2 = WorkKindTest(456)..title = "yyy";
    var all = [
      addWI(wk1, dt1),
      addWI(wk1, dt1),
      addWI(wk1, dt2),
      addWI(wk1, dt3),
      addWI(wk2, dt3),
      addWI(wk2, dt2),
    ];
    var items = await sut.itemsByKindBeforeDate(all, wk1, dt1);
    expect(items.first.kind, "ttt");
    expect(items.first.kindId, 123);
    expect(items.length, 2);
    items = await sut.itemsByKindBeforeDate(all, wk1, dt2);
    expect(items.length, 1);
    items = await sut.itemsByKindBeforeDate(all, wk1, dt3);
    expect(items.length, 1);

    items = await sut.itemsByKindBeforeDate(
        all, wk1, dt2.subtract(Duration(days: 5)));
    expect(items.length, 1);
  });
  test('items without kindId value', () async {
    var sut = WorkViewModel();
    var dt1 = DateTime(2021, 11, 20, 18, 08);
    var dt2 = DateTime(2021, 11, 15, 18, 08);
    var dt3 = DateTime(2021, 11, 5, 18, 08);
    var wk1 = WorkKindTest(-2)
      ..title = "ttt"; // -2 to make not equal WorkItem.kindId default value
    var wk2 = WorkKindTest(456)..title = "yyy";
    var all = [
      addWI(wk1, dt1),
      addWI(wk1, dt1),
      addWI(wk1, dt2),
      addWI(wk1, dt3),
      addWI(wk2, dt3),
      addWI(wk2, dt2),
    ];
    // emulating old records from old structure database
    // wk1 kindid is -2 but workItems.kindId is -1 by default
    var items = await sut.itemsByKindBeforeDate(all, wk1, dt1);
    expect(items.first.kind, "ttt");
    expect(items.first.kindId, -2);
    expect(items.length, 2);
    items = await sut.itemsByKindBeforeDate(all, wk1, dt2);
    expect(items.length, 1);
    items = await sut.itemsByKindBeforeDate(all, wk1, dt3);
    expect(items.length, 1);

    items = await sut.itemsByKindBeforeDate(
        all, wk1, dt2.subtract(Duration(days: 5)));
    expect(items.length, 1);
  });
}

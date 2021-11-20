import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_view_model.dart';

WorkItem addWI(String kind, DateTime created) {
  var res = WorkItem();
  res.created = created;
  res.qty = ++id;
  res.kind = kind;
  return res;
}

int id = 0;

void main() async {
  test('items should be filtered', () async {
    var sut = WorkViewModel();
    var dt1 = DateTime(2021, 11, 20, 18, 08);
    var dt2 = DateTime(2021, 11, 15, 18, 08);
    var dt3 = DateTime(2021, 11, 5, 18, 08);
    var all = [
      addWI("ttt", dt1),
      addWI("ttt", dt1),
      addWI("ttt", dt2),
      addWI("ttt", dt3),
      addWI("yyy", dt3),
      addWI("yyy", dt2),
    ];
    var items = await sut.itemsByKindDate(all, "ttt", dt1);
    expect(items.first.kind, "ttt");
    expect(items.length, 4);
    items = await sut.itemsByKindDate(all, "ttt", dt2);
    expect(items.length, 2);
    items = await sut.itemsByKindDate(all, "ttt", dt3);
    expect(items.length, 1);

    items =
        await sut.itemsByKindDate(all, "ttt", dt2.subtract(Duration(days: 5)));
    expect(items.length, 0);
  });
}

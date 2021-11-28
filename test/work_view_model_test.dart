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

WorkItem create(int q, DateTime d) {
  var w = WorkItem();
  w.qty = q;
  w.created = d;
  return w;
}

void main() async {
  test('items by period', () async {
    var w1 = create(22, DateTime(2021, 11, 27));
    var w2 = create(22, DateTime(2021, 11, 27));

    var w3 = create(21, DateTime(2021, 11, 26));
    var w4 = create(10, DateTime(2021, 11, 20));
    var w5 = create(10, DateTime(2020, 11, 20));
    var items = [w1, w2, w3, w4, w5];
    var sut = WorkViewModel();
    var bd = await sut.loadItemsFor(180, Future.value(items));
    expect(bd.length, 4);
  });
  test('items by date', () async {
    var w1 = create(22, DateTime(2021, 11, 27));
    var w2 = create(22, DateTime(2021, 11, 27));

    var w3 = create(21, DateTime(2021, 11, 26));
    var w4 = create(10, DateTime(2021, 11, 20));
    var items = [w1, w2, w3, w4];
    var md = WorkViewModel();
    var sum = md.sumByDate(items);
    expect(sum.length, 3);
    expect(sum[0].qty, 44);
    expect(sum[1].qty, 21);
    expect(sum[2].qty, 10);
  });
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
    expect(items.length, 2);
    items = await sut.itemsByKindDate(all, "ttt", dt2);
    expect(items.length, 1);
    items = await sut.itemsByKindDate(all, "ttt", dt3);
    expect(items.length, 1);

    items =
        await sut.itemsByKindDate(all, "ttt", dt2.subtract(Duration(days: 5)));
    expect(items.length, 1);
  });
}

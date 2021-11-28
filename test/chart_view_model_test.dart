import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/chart_view_model.dart';
import 'package:work_tracker/classes/work_item.dart';

WorkItem addWI(String kind, DateTime created) {
  var res = WorkItem();
  res.created = created;
  res.qty = ++id;
  res.kind = kind;
  return res;
}

int id = 0;

WorkItem create(int q, DateTime d, {String kind = "t1"}) {
  var w = WorkItem();
  w.qty = q;
  w.created = d;
  w.kind = kind;
  return w;
}

var itemsByPeriod = [
  create(22, DateTime(2021, 11, 27)),
  create(22, DateTime(2021, 11, 27)),
  //
  create(21, DateTime(2021, 11, 26)),
  //
  create(10, DateTime(2021, 11, 20)),
  create(10, DateTime(2021, 11, 20, 3, 44, 55)),
  //
  create(10, DateTime(2021, 11, 18)),
  create(10, DateTime(2021, 11, 18)),
  create(10, DateTime(2021, 11, 18)),
  //
  create(10, DateTime(2021, 11, 15)),
  create(5, DateTime(2021, 11, 15)),
  create(5, DateTime(2021, 11, 15)),
  //
  create(10, DateTime(2021, 11, 10)),
  create(5, DateTime(2021, 11, 10)),
  create(5, DateTime(2021, 11, 10)),
  // very old
  create(5, DateTime(2019, 11, 15)),
];

void main() async {
  test('items by period', () async {
    var sut = ChartViewModel();
    var bd = await sut.loadItemsFor(180, Future.value(itemsByPeriod),
        now: itemsByPeriod.first.created);
    expect(bd.length, 14);
  });
  test('items by date', () async {
    var md = ChartViewModel();
    var sum = md.sumByDate(itemsByPeriod);
    expect(sum.length, 7);
    expect(sum[0].qty, 44);
    expect(sum[1].qty, 21);
    expect(sum[2].qty, 20);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/chart_view_model.dart';
import 'package:work_tracker/classes/config_graph.dart';
import 'package:work_tracker/classes/work_item.dart';

WorkItem create(int q, DateTime d, {String kind = "t1", double weight = 0}) {
  var w = WorkItem();
  w.qty = q;
  w.created = d;
  w.kind = kind;
  w.weight = weight;
  return w;
}

var itemsByPeriod = [
  create(22, DateTime(2021, 11, 27)),
  create(22, DateTime(2021, 11, 27), weight: 10),
  //
  create(21, DateTime(2021, 11, 26), weight: 10),
  //
  create(10, DateTime(2021, 11, 20)),
  create(10, DateTime(2021, 11, 20, 3, 44, 55), weight: 10),
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
  test('items by period', () {
    var sut = ChartViewModel();
    var bd =
        sut.loadItemsFor(180, itemsByPeriod, now: itemsByPeriod.first.created);
    expect(bd.length, 14);
  });
  test('items by date', () {
    var md = ChartViewModel();
    var config = ConfigGraph()
      ..weight4graph = false
      ..bodyWeight = 100;
    var sum = md.sumByDate(itemsByPeriod, config);
    expect(sum.length, 7);
    expect(sum[0].value, 44);
    expect(sum[1].value, 21);
    expect(sum[2].value, 20);
  });
  test('items by date with body weight', () {
    var md = ChartViewModel();
    var config = ConfigGraph()
      ..weight4graph = true
      ..bodyWeight = 100;
    var sum = md.sumByDate(itemsByPeriod, config);
    expect(sum.length, 7);
    expect(sum[0].value, 46.2);
    expect(sum[1].value, 23.1);
    expect(sum[2].value, 21);
  });
}

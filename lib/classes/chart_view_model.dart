import 'dart:math';
import 'package:collection/collection.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
import 'package:work_tracker/classes/work_item.dart';

class ChartViewModel {
  List<WorkItem> loadItemsFor(int days, List<WorkItem> items, {DateTime? now}) {
    now = now ?? DateTime.now();
    var startDate = now.subtract(Duration(days: days));
    var itemsData = items
        .where((_) => _.created.isAfter(startDate))
        .toList(growable: false);
    return itemsData;
  }

  Map<DateTime, List<WorkItem>> groupByDate(Iterable<WorkItem> items) {
    var dateData = items.groupBy(
        (p0) => DateTime(p0.created.year, p0.created.month, p0.created.day));
    return dateData;
  }

  List<WorkItem> sumByDate(Iterable<WorkItem> items) {
    var dateData = groupByDate(items);

    var res = <WorkItem>[];
    for (var k in dateData.entries) {
      var wi = WorkItem();
      wi.created = k.key;
      wi.qty = k.value.map((i) => i.qty).sum;
      wi.weight = k.value.map((e) => e.weight).sum;
      res.add(wi);
    }
    return res;
  }

  List<WorkItem> avgByDate(Iterable<WorkItem> items) {
    var dateData = groupByDate(items);

    var res = <WorkItem>[];
    for (var k in dateData.entries) {
      var wi = WorkItem();
      wi.created = k.key;
      wi.weight = k.value.map((i) => i.qty).average;
      res.add(wi);
    }
    return res;
  }

  List<WorkItem> maxByDate(Iterable<WorkItem> items) {
    var dateData = groupByDate(items);

    var res = <WorkItem>[];
    for (var k in dateData.entries) {
      var wi = WorkItem();
      wi.created = k.key;
      wi.qty = k.value.map((i) => i.qty).reduce(max);
      res.add(wi);
    }
    return res;
  }
}

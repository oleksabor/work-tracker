import 'dart:math';
import 'package:collection/collection.dart';
import 'package:work_tracker/classes/chart_data.dart';
import 'package:work_tracker/classes/config_graph.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
import 'package:work_tracker/classes/work_item.dart';

class ChartViewModel {
  List<WorkItem> loadItemsFor(int days, List<WorkItem> items, {DateTime? now}) {
    now = now ?? DateTime.now();
    var startDate = now.subtract(Duration(days: days));
    var itemsData = items
        .where((_) => _.created.isAfter(startDate))
        .sortedByCompare((_) => _.created, dateDesc)
        .toList(growable: false);
    return itemsData;
  }

  int dateDesc(DateTime d1, DateTime d2) {
    return -1 * d1.compareTo(d2);
  }

  ChartData mapWI(WorkItem src, ConfigGraph cg) {
    var res = ChartData(src.created, value: src.qty.toDouble());
    if (cg.weight4graph && cg.bodyWeight > 0) {
      res.value += res.value * src.weight / cg.bodyWeight;
    }
    return res;
  }

  Map<DateTime, List<ChartData>> groupByDate(
      Iterable<WorkItem> items, ConfigGraph config) {
    var dateData = items.map((e) => mapWI(e, config)).groupBy(
        (p0) => DateTime(p0.created.year, p0.created.month, p0.created.day));
    return dateData;
  }

  List<ChartData> sumByDate(Iterable<WorkItem> items, ConfigGraph config) {
    var dateData = groupByDate(items, config);

    var res = <ChartData>[];
    for (var k in dateData.entries) {
      var wi = ChartData(k.key, value: k.value.map((i) => i.value).sum);
      res.add(wi);
    }
    return res;
  }

  List<ChartData> avgByDate(Iterable<WorkItem> items, ConfigGraph config) {
    var dateData = groupByDate(items, config);

    var res = <ChartData>[];
    for (var k in dateData.entries) {
      var wi = ChartData(k.key, value: k.value.map((i) => i.value).average);
      res.add(wi);
    }
    return res;
  }

  List<ChartData> maxByDate(Iterable<WorkItem> items, ConfigGraph config) {
    var dateData = groupByDate(items, config);

    var res = <ChartData>[];
    for (var k in dateData.entries) {
      var wi = ChartData(k.key, value: k.value.map((i) => i.value).reduce(max));
      res.add(wi);
    }
    return res;
  }
}

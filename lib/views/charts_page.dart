import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_view_model.dart';

/// items list on day
class ChartItemsView extends StatelessWidget {
  final WorkViewModel model;
  const ChartItemsView({Key? key, required this.model}) : super(key: key);

  String get pageTitle => "Charts";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
        ),
        body: getChart());
  }

  Widget getChart() {
    return FutureBuilder<List<charts.Series<WorkItem, num>>>(
        future: getChartData(),
        builder:
            (ctx, AsyncSnapshot<List<charts.Series<WorkItem, num>>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return charts.LineChart(
              snapshot.data as List<charts.Series<dynamic, num>>,
              defaultRenderer:
                  charts.LineRendererConfig(includeArea: true, stacked: true),
              animate: true,
              behaviors: [charts.SeriesLegend()],
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Future<List<charts.Series<WorkItem, num>>> getChartData() async {
    var now = DateTime.now();
    var startDate = now.subtract(const Duration(days: 180));
    var items = await model.loadItems();
    var itemsData = items?.where((_) => _.created.isAfter(startDate));

    var kindsData = itemsData?.groupBy((i) => i.kind).entries;
    if (kindsData != null) {
      var res = kindsData
          .map((i) => charts.Series<WorkItem, int>(
              id: i.key,
              data: sumByDate(i.value),
              displayName: i.key,
              domainFn: (WorkItem wi, _) => wi.created.difference(now).inDays,
              measureFn: (WorkItem wi, _) => wi.qty))
          .toList();
      return res;
    }
    return <charts.Series<WorkItem, int>>[];
  }

  List<WorkItem> sumByDate(Iterable<WorkItem> items) {
    var dateData = items.groupBy(
        (p0) => DateTime(p0.created.year, p0.created.month, p0.created.day));

    var res = <WorkItem>[];
    for (var k in dateData.entries) {
      var wi = WorkItem();
      wi.created = k.key;
      wi.qty = k.value.fold(0, (p, e) => p + e.qty);
      wi.weight = k.value.fold(0, (p, e) => p + e.weight);
      res.add(wi);
    }
    return res;
  }
}

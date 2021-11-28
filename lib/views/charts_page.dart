import 'package:charts_flutter/flutter.dart' as flcharts;
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/chart_view_model.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_view_model.dart';

/// items list on day
class ChartItemsView extends StatelessWidget {
  final WorkViewModel data;
  final ChartViewModel charts = ChartViewModel();

  ChartItemsView({Key? key, required this.data}) : super(key: key);

  String get pageTitle => "Charts";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
        ),
        body: getChartFuture());
  }

  Widget getChartFuture() {
    return FutureBuilder<List<flcharts.Series<WorkItem, num>>>(
        future: getChartData(),
        builder: (ctx,
            AsyncSnapshot<List<flcharts.Series<WorkItem, num>>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return getChart(snapshot.data!);
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Widget getChart(List<flcharts.Series<WorkItem, num>> data) {
    return flcharts.LineChart(
      data,
      animate: true,
      behaviors: [flcharts.SeriesLegend()],
      defaultRenderer: flcharts.LineRendererConfig(includeArea: true),
    );
  }

  Future<List<flcharts.Series<WorkItem, num>>> getChartData() async {
    var items = data.loadItems();
    var itemsData = await charts.loadItemsFor(180, items);

    var kindsData = itemsData.groupBy((i) => i.kind).entries;
    var res = kindsData
        .map((i) => flcharts.Series<WorkItem, int>(
            id: i.key,
            data: charts.maxByDate(i.value),
            displayName: i.key,
            domainFn: (WorkItem wi, _) =>
                wi.created.difference(DateTime.now()).inDays,
            measureFn: (WorkItem wi, _) => wi.qty))
        .toList();
    return res;
  }
}

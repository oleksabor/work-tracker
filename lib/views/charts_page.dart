import 'package:charts_flutter/flutter.dart' as flcharts;
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/chart_view_model.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// items list on day
class ChartItemsView extends StatefulWidget {
  final WorkViewModel data;

  ChartItemsView(this.data);

  @override
  State<StatefulWidget> createState() {
    return ChartItemsViewState();
  }
}

enum GroupChart { avg, max, sum }

class ChartItemsViewState extends State<ChartItemsView> {
  final ChartViewModel charts = ChartViewModel();
  GroupChart? groupChart = GroupChart.max;

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(t!.titleWinChart),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              createRadio(),
              getChartFuture(getChartData(getAggr(), getMeasure()))
            ]));
  }

  Widget createRadio() {
    return Row(children: <Widget>[
      Expanded(
          child: ListTile(
        title: const Text('Max'),
        leading: Radio<GroupChart>(
          value: GroupChart.max,
          groupValue: groupChart,
          onChanged: (GroupChart? value) {
            setState(() {
              groupChart = value;
            });
          },
        ),
      )),
      Expanded(
          child: ListTile(
        title: const Text('Avg'),
        leading: Radio<GroupChart>(
          value: GroupChart.avg,
          groupValue: groupChart,
          onChanged: (GroupChart? value) {
            setState(() {
              groupChart = value;
            });
          },
        ),
      )),
      Expanded(
          child: ListTile(
        title: const Text('Sum'),
        leading: Radio<GroupChart>(
          value: GroupChart.sum,
          groupValue: groupChart,
          onChanged: (GroupChart? value) {
            setState(() {
              groupChart = value;
            });
          },
        ),
      )),
    ]);
  }

  List<WorkItem> Function(ChartViewModel model, List<WorkItem> src) getAggr() {
    switch (groupChart) {
      case GroupChart.avg:
        return getAvg;
      case GroupChart.sum:
        return getSum;
      default:
        return getMax;
    }
  }

  num? Function(WorkItem, num?) getMeasure() {
    switch (groupChart) {
      case GroupChart.avg:
        return (wi, _) => wi.weight;
      default:
        return (wi, _) => wi.qty;
    }
  }

  List<WorkItem> getSum(ChartViewModel model, List<WorkItem> items) {
    return model.sumByDate(items);
  }

  List<WorkItem> getMax(ChartViewModel model, List<WorkItem> items) {
    return model.maxByDate(items);
  }

  List<WorkItem> getAvg(ChartViewModel model, List<WorkItem> items) {
    return model.avgByDate(items);
  }

  Widget getChartFuture(
      Future<List<flcharts.Series<WorkItem, num>>> chartData) {
    return Expanded(
        flex: 10,
        child: FutureBuilder<List<flcharts.Series<WorkItem, num>>>(
            future: chartData,
            builder: (ctx, snapshot) {
              return snapshot.hasData && snapshot.data != null
                  ? getChart(snapshot.data!)
                  : const CircularProgressIndicator();
            }));
  }

  Widget getChart(List<flcharts.Series<WorkItem, num>> data) {
    return flcharts.LineChart(
      data,
      animate: true,
      behaviors: [flcharts.SeriesLegend()],
      defaultRenderer: flcharts.LineRendererConfig(includeArea: true),
    );
  }

  Future<List<flcharts.Series<WorkItem, num>>> getChartData(
      List<WorkItem> Function(ChartViewModel, List<WorkItem>) aggr,
      num? Function(WorkItem, num?) measure) async {
    var items = await widget.data.loadItems();
    var itemsData = charts.loadItemsFor(180, items);
    var kinds = await widget.data.loadKinds();

    var kindsData = itemsData.groupBy((i) => i.kindId).entries;
    var res = kindsData
        .map((i) => flcharts.Series<WorkItem, int>(
            id: "${i.key}",
            data: aggr(charts, i.value),
            displayName: kinds
                .firstWhere((k) => k.key == i.key,
                    orElse: () => WorkKind.m("unknown ${i.key}"))
                .title,
            domainFn: (WorkItem wi, _) =>
                wi.created.difference(DateTime.now()).inDays,
            measureFn: measure))
        .toList();
    return res;
  }
}

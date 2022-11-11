import 'package:charts_flutter/flutter.dart' as flcharts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/classes/chart_data.dart';
import 'package:work_tracker/classes/chart_view_model.dart';
import 'package:work_tracker/classes/config_graph.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// items list on day
class ChartItemsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChartItemsViewState();
  }
}

enum GroupChart { avg, max, sum }

class ChartItemsViewState extends State<ChartItemsView> {
  final ChartViewModel charts = ChartViewModel();
  GroupChart? groupChart = GroupChart.max;
  late ConfigModel configModel;

  @override
  void initState() {
    super.initState();
    configModel = RepositoryProvider.of<ConfigModel>(context);
  }

  /// screen size to calculate legend columns
  late Size screen;
  late double pixelRatio;

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);
    var mediaQuery = MediaQuery.of(context);
    screen = mediaQuery.size;
    pixelRatio = mediaQuery.devicePixelRatio;
    var wm = RepositoryProvider.of<WorkViewModel>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(t!.titleWinChart),
        ),
        body: Column(children: [
          createRadio(),
          getChartFuture(getChartData(getAggr(), getMeasure(), wm))
        ]));
  }

  Widget createRadioItem(
    String title,
    GroupChart value,
  ) {
    return Flexible(
        child: RadioListTile<GroupChart>(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      groupValue: groupChart,
      onChanged: (GroupChart? value) {
        setState(() {
          groupChart = value;
        });
      },
    ));
  }

  Widget createRadio() {
    return Row(children: <Widget>[
      createRadioItem('Max', GroupChart.max),
      createRadioItem('Avg', GroupChart.avg),
      createRadioItem('Sum', GroupChart.sum),
    ]);
  }

  List<ChartData> Function(
      ChartViewModel model, List<WorkItem> src, ConfigGraph config) getAggr() {
    switch (groupChart) {
      case GroupChart.avg:
        return getAvg;
      case GroupChart.sum:
        return getSum;
      default:
        return getMax;
    }
  }

  num? Function(ChartData, num?) getMeasure() {
    switch (groupChart) {
      default:
        return (wi, _) => wi.value;
    }
  }

  List<ChartData> getSum(
      ChartViewModel model, List<WorkItem> items, ConfigGraph config) {
    return model.sumByDate(items, config);
  }

  List<ChartData> getMax(
      ChartViewModel model, List<WorkItem> items, ConfigGraph config) {
    return model.maxByDate(items, config);
  }

  List<ChartData> getAvg(
      ChartViewModel model, List<WorkItem> items, ConfigGraph config) {
    return model.avgByDate(items, config);
  }

  Widget getChartFuture(
      Future<List<flcharts.Series<ChartData, num>>> chartData) {
    return Expanded(
        flex: 10,
        child: FutureBuilder<List<flcharts.Series<ChartData, num>>>(
            future: chartData,
            builder: (ctx, snapshot) {
              return snapshot.hasData && snapshot.data != null
                  ? getChart(snapshot.data!)
                  : const CircularProgressIndicator();
            }));
  }

  final defaultColumns = 3;
  final columnWidth = 107;

  int getColumns(Size screen) {
    // should it use pixelRatio also ?
    var columns = screen.width ~/ columnWidth;
    if (columns < defaultColumns) {
      columns = defaultColumns;
    }
    return columns;
  }

  Widget getChart(List<flcharts.Series<ChartData, num>> data) {
    return flcharts.LineChart(
      data,
      animate: true,
      behaviors: [flcharts.SeriesLegend(desiredMaxColumns: getColumns(screen))],
      defaultRenderer: flcharts.LineRendererConfig(includeArea: true),
    );
  }

  final daysBack = 180;

  Future<List<flcharts.Series<ChartData, num>>> getChartData(
    List<ChartData> Function(ChartViewModel, List<WorkItem>, ConfigGraph) aggr,
    num? Function(ChartData, num?) measure,
    WorkViewModel wm,
  ) async {
    var config = await configModel.load();
    var items = await wm.loadItems();
    var itemsData = charts.loadItemsFor(daysBack, items);
    var kinds = await wm.loadKinds();

    var kindsData = itemsData.groupBy((i) => i.kindId).entries;
    var res = kindsData
        .map((i) => flcharts.Series<ChartData, int>(
            id: "${i.key}",
            data: aggr(charts, i.value, config.graph),
            displayName: kinds
                .firstWhere((k) => k.key == i.key,
                    orElse: () => WorkKind.m("unknown ${i.key}"))
                .title,
            domainFn: (ChartData wi, _) =>
                wi.created.difference(DateTime.now()).inDays,
            measureFn: measure))
        .toList();
    return res;
  }
}

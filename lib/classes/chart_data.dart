import 'package:work_tracker/classes/config_graph.dart';

/// calculated result for graph.
/// the final chart [value] may be altered with [ConfigGraph.bodyWeight]
class ChartData {
  late double value;
  DateTime created;
  ChartData(this.created, {double? value}) {
    this.value = value ?? 0;
  }
}

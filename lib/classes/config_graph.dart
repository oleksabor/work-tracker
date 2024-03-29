import 'package:hive/hive.dart';
import 'package:work_tracker/classes/hive_type_values.dart';
import 'package:work_tracker/classes/weight_body.dart';

part 'config_graph.g.dart';

@HiveType(typeId: HiveTypesEnum.configGraph)
class ConfigGraph {
  @HiveField(0)
  bool weight4graph = false;

  /// last entered weight value
  @HiveField(1)
  double bodyWeight = 0;

  /// list of weight values (per day)
  @HiveField(2)
  List<WeightBody> bodyWeightList = <WeightBody>[];
}

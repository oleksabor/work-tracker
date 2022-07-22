import 'package:hive/hive.dart';
import 'package:work_tracker/classes/hive_type_values.dart';

part 'config_graph.g.dart';

@HiveType(typeId: HiveTypesEnum.configGraph)
class ConfigGraph {
  @HiveField(0)
  bool weight4graph = false;
  @HiveField(1)
  double bodyWeight = 0;
}

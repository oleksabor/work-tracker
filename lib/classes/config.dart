import 'package:hive/hive.dart';
import 'package:work_tracker/classes/config_graph.dart';
import 'package:work_tracker/classes/config_log.dart';
import 'package:work_tracker/classes/config_notify.dart';
import 'package:work_tracker/classes/config_ui.dart';
import 'package:work_tracker/classes/hive_type_values.dart';

part 'config.g.dart';

@HiveType(typeId: HiveTypesEnum.config)
class Config extends HiveObject {
  @HiveField(0)
  ConfigGraph graph = ConfigGraph();
  @HiveField(1)
  ConfigLog log = ConfigLog();
  @HiveField(2)
  ConfigNotify notify = ConfigNotify();
  @HiveField(3)
  ConfigUI ui = ConfigUI();
}

//flutter packages pub run build_runner build --delete-conflicting-outputs

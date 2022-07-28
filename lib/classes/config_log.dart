import 'package:simple_logger/simple_logger.dart';
import 'package:hive/hive.dart';
import 'package:work_tracker/classes/hive_type_values.dart';

part 'config_log.g.dart';

@HiveType(typeId: HiveTypesEnum.configLog)
class ConfigLog {
  @HiveField(0)
  String logLevel;
  @HiveField(1)
  bool includeCallerInfo;

  ConfigLog()
      : logLevel = Level.INFO.name,
        includeCallerInfo = false;

  Level getLevel(String name) {
    var res = Level.LEVELS.firstWhere((l) => l.name == name);
    return res;
  }

  List<String> getAll() {
    var res = Level.LEVELS.map((l) => l.name).toList(growable: false);
    return res;
  }

  String defaultLevel() {
    return Level.INFO.name;
  }
}

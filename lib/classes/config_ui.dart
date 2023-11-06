import 'package:hive/hive.dart';
import 'package:work_tracker/classes/hive_type_values.dart';

part 'config_ui.g.dart';

@HiveType(typeId: HiveTypesEnum.configUI)
class ConfigUI {
  @HiveField(0)
  double qtyFontMulti;

  ConfigUI() : qtyFontMulti = 1.0;
}

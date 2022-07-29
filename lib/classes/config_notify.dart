import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:work_tracker/classes/hive_type_values.dart';
part 'config_notify.g.dart';

@HiveType(typeId: HiveTypesEnum.configNotify)
class ConfigNotify {
  @HiveField(0)
  double volume;

  @HiveField(1)
  double frequency;

  @HiveField(2)
  int sampleRate;

  @HiveField(3)
  int period;

  @HiveField(4)
  String waveType;

  ConfigNotify()
      : frequency = 20,
        volume = 1,
        sampleRate = 9600,
        period = 2,
        waveType = "SINUSOIDAL";
}

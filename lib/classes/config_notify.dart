import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:work_tracker/classes/hive_type_values.dart';
part 'config_notify.g.dart';

/// configuration for next exercise notification
/// has toJson and fromJson methods to pass the configuration to the AlarmManager callback function
@HiveType(typeId: HiveTypesEnum.configNotify)
class ConfigNotify {
  @HiveField(0)
  double volume;

  @HiveField(1)
  double frequency;

  /// have default value and is not changed in the SoundGenerator example
  @HiveField(2)
  int sampleRate;

  /// how long the sound should be played
  @HiveField(3)
  int period;

  @HiveField(4)
  String waveType;

  /// delay in seconds between exercises
  @HiveField(5)
  int delay;

  @HiveField(6)
  bool playAfterNewResult;

  ConfigNotify()
      : frequency = 20,
        volume = 1,
        sampleRate = 9600,
        period = 2,
        waveType = "SINUSOIDAL",
        delay = 300,
        playAfterNewResult = true;

  ConfigNotify.fromJson(Map<String, dynamic> data)
      : frequency = data['frequency'],
        volume = data['volume'],
        sampleRate = data['sampleRate'],
        period = data['period'],
        waveType = data['waveType'],
        delay = data['delay'],
        playAfterNewResult = data['playAfterNewResult'];

  Map<String, dynamic> toJson() => {
        'playAfterNewResult': playAfterNewResult,
        'volume': volume,
        'sampleRate': sampleRate,
        'period': period,
        'waveType': waveType,
        'delay': delay,
        'frequency': frequency
      };
}

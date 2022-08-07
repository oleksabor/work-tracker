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

  /// internal notification sound
  @HiveField(1)
  String notification;

  /// delay in seconds between an exercise and the notification
  @HiveField(2)
  int delay;

  @HiveField(3)
  bool playAfterNewResult;

  @HiveField(4)
  NotificationKind kind;

  /// plays sound overriding silent or vibrate mode
  @HiveField(5)
  bool asAlarm;

  ConfigNotify()
      : volume = 1,
        delay = 300,
        playAfterNewResult = false,
        notification = '',
        kind = NotificationKind.system,
        asAlarm = true;

  ConfigNotify.fromJson(Map<String, dynamic> data)
      : volume = data['volume'],
        delay = data['delay'],
        notification = data['notification'],
        playAfterNewResult = data['playAfterNewResult'],
        kind = data['systemNotification'],
        asAlarm = data['asAlarm'];

  Map<String, dynamic> toJson() => {
        'playAfterNewResult': playAfterNewResult,
        'volume': volume,
        'delay': delay,
        'notification': notification,
        'systemNotification': kind,
        'asAlarm': asAlarm
      };
}

enum NotificationKind {
  /// system notification sound
  system,

  /// mp3 from resources
  inbuilt,

  /// external file
  external,
}

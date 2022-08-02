import 'dart:async';
import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:sound_generator/sound_generator.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_notify.dart';
import 'package:sound_generator/waveTypes.dart';
import 'package:work_tracker/classes/init_get.dart';

@injectable
class NotifyModel {
  StreamSubscription<bool>? _onData;

  void init(Config config, {void Function(bool value)? opc}) {
    _isPlaying = false;

    SoundGenerator.init(config.notify.sampleRate);
    releasePlayingChanged();
    if (opc != null) {
      _onData = SoundGenerator.onIsPlayingChanged.listen((value) {
        opc(value);
      });
    }
    // SoundGenerator.onOneCycleDataHandler.listen((value) {
    //   setState(() {
    //     oneCycleData = value;
    //   });
    // });
    setFrequency(config.notify.frequency);
    setVolume(config.notify.volume);
    setWaveType(config.notify.waveType);

    SoundGenerator.setAutoUpdateOneCycleSample(true);
    //Force update for one time
    SoundGenerator.refreshOneCycleData();
  }

  void releasePlayingChanged() {
    if (_onData != null) {
      _onData?.cancel();
    }
  }

  bool _isPlaying = false;
  static const int helloAlarmID = 0;
  static bool _isScheduled = false;

  /// schedules to play notification sound
  /// for [ConfigNotify.period] seconds after [ConfigNotify.delay] seconds.
  /// Stores current [ConfigNotify] instance as [SharedPreferences] json string using [saveShared]
  /// Is executed by [AndroidAlarmManager] isolated from main app instance
  static void playSchedule(ConfigNotify? config) async {
    if (/*_isScheduled ||*/ config == null) {
      return;
    }
    var logger = await getIt.getAsync<SimpleLogger>();
    var dr = Duration(seconds: config.delay);
    await saveShared(config);
    if (!await AndroidAlarmManager.oneShot(dr, helloAlarmID, playImpl,
        exact: true)) {
      logger.warning("failed to set the alarm for $dr");
    } else {
      _isScheduled = true;
      logger.fine("scheduled alarm for $dr");
    }
  }

  /// stores current [ConfigNotify] instance as [SharedPreferences] json string
  static Future<void> saveShared(ConfigNotify? config) async {
    if (config == null) return;
    final prefs = await SharedPreferences.getInstance();
    var str = jsonEncode(config);
    if (kDebugMode) {
      print('configNotify saved as $str');
    }
    if (prefs.containsKey(configNotifyName)) {
      await prefs.remove(configNotifyName);
    }
    await prefs.setString(configNotifyName, str);
  }

  static const String configNotifyName = 'configNotify';

  /// loads the [ConfigNotify] instance from [SharedPreferences] json string
  /// Returns null if no shared preference was found
  static Future<ConfigNotify?> loadShared() async {
    final prefs = await SharedPreferences.getInstance();
    var str = prefs.getString(configNotifyName);
    if (kDebugMode) {
      print('configNotify loaded from $str');
    }
    return loadFromString(str);
  }

  static ConfigNotify? loadFromString(String? v) {
    return v == null ? null : ConfigNotify.fromJson(jsonDecode(v));
  }

  /// alarm manager handler to start sound playing
  /// stops to play sound after [ConfigNotify.period]
  static void playImpl() async {
    var config = await loadShared();

    if (config == null) {
      return;
    }
    _isScheduled = true;
    SoundGenerator.init(config.sampleRate);
    SoundGenerator.setFrequency(config.frequency);
    SoundGenerator.setVolume(config.volume);
    SoundGenerator.setWaveType(parseWave(config.waveType));
    SoundGenerator.setAutoUpdateOneCycleSample(true);
    //Force update for one time
    SoundGenerator.refreshOneCycleData();
    SoundGenerator.play();
    Future.delayed(
        // it starts in "background" no await is required
        Duration(seconds: config.period),
        stopSchedule);
  }

  static void stopSchedule() async {
    SoundGenerator.stop();
    AndroidAlarmManager.cancel(helloAlarmID);
    _isScheduled = false;
  }

  /// play notification sound until [stop] method is called
  void playTest() {
    if (isPlaying) {
      return;
    }
    SoundGenerator.play();
    _isPlaying = true;
  }

  void stop() {
    if (isPlaying) {
      SoundGenerator.stop();
    }
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;

  void dispose() {
    releasePlayingChanged();
    SoundGenerator.release();
  }

  void setWaveType(String newValue) {
    SoundGenerator.setWaveType(parseWave(newValue));
  }

  void setFrequency(double value) {
    SoundGenerator.setFrequency(value);
  }

  void setVolume(double value) {
    SoundGenerator.setVolume(value);
  }

  static waveTypes parseWave(String newValue) {
    return waveTypes.values.byName(newValue);
  }

  List<String> getWaveTypes() {
    return waveTypes.values
        .map((waveTypes classType) => classType.name)
        .toList();
  }
}

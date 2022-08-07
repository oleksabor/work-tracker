import 'dart:async';
import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/config_notify.dart';
import 'package:work_tracker/classes/init_get.dart';

@injectable
class NotifyModel {
  static final AudioCache _ac = AudioCache();
  static AudioPlayer? _player;
  void Function(bool)? _onPlayingChanged;

  void init(Config config, {void Function(bool value)? opc}) {
    _isScheduled = _isPlaying = false;

    releasePlayingChanged();
    _onPlayingChanged = opc;
  }

  void releasePlayingChanged() {
    if (_player != null) {
      _player!.release();
    }
    _onPlayingChanged = null;
  }

  bool _isPlaying = false;
  static const int helloAlarmID = 0;
  static bool _isScheduled = false;

  /// schedules to play notification sound
  /// after [ConfigNotify.delay] seconds.
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
    var logger = await getIt.getAsync<SimpleLogger>();
    if (config == null) return;
    final prefs = await SharedPreferences.getInstance();
    var str = jsonEncode(config);
    logger.fine('configNotify saving as $str');
    if (prefs.containsKey(configNotifyName)) {
      await prefs.remove(configNotifyName);
    }
    await prefs.setString(configNotifyName, "no data");
    await prefs.setString(configNotifyName, str);
  }

  static const String configNotifyName = 'configNotify';

  /// loads the [ConfigNotify] instance from [SharedPreferences] json string
  /// Returns null if no shared preference was found
  static Future<ConfigNotify?> loadShared() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var str = prefs.getString(configNotifyName);
    if (kDebugMode) {
      print('configNotify loaded from $str');
    }
    var res = loadFromString(str);
    // await prefs.setString(configNotifyName,
    //     "cleared"); // requires saveShared to be called before each loadShared
    return res;
  }

  static ConfigNotify? loadFromString(String? v) {
    return v == null ? null : ConfigNotify.fromJson(jsonDecode(v));
  }

  /// alarm manager handler to start sound playing
  static void playImpl() async {
    var config = await loadShared();

    if (config == null || _isScheduled) {
      return;
    }
    _isScheduled = true;

    await _ac.play(config.notification, volume: config.volume);

    _isScheduled = false;
  }

  /// play notification sound until [stop] method is called
  void playTest(ConfigNotify config) {
    if (isPlaying) {
      return;
    }
    _isPlaying = true;
    updateIsPlaying(_isPlaying);
    var playerF = _ac.play(config.notification, volume: config.volume);
    playerF.then((ap) {
      _isPlaying = false;
      updateIsPlaying(_isPlaying);
    }).onError((error, stackTrace) {
      _isPlaying = false;
      updateIsPlaying(_isPlaying);
    });
  }

  void updateIsPlaying(bool v) {
    if (_onPlayingChanged != null) {
      _onPlayingChanged!(v);
    }
  }

  void stop() {
    if (isPlaying) {}
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;

  void dispose() {
    releasePlayingChanged();
    _onPlayingChanged = null; // is it like unsubscribe
  }

  List<String> getNotifications() {
    return ConfigModel.notifications;
  }
}

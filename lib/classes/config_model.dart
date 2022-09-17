import 'package:injectable/injectable.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_graph.dart';
import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/weight_body.dart';

@injectable
class ConfigModel {
  ConfigModel(this.db);
  DbLoader db;

  static var notifications = [
    '',
    'CarLock.mp3',
    'Breaklock.mp3',
    'CarSecurityLock.mp3',
    'Mgs4Lock.mp3',
    'LockOn.mp3'
  ];

  static const String configBox = "config";

  Future<Config> load() async {
    try {
      var box = await db.openBox<Config>(configBox);
      if (box.values.isEmpty) {
        throw "no config value was loaded";
      }
      return box.values.first;
    } catch (e, st) {
      print(e);
      return Config();
    }
  }

  saveImpl(Config? value) async {
    if (value != null) {
      setWeight(value.graph, DateTime.now());
      if (value.isInBox) {
        await value.save();
      } else {
        var box = await db.openBox<Config>(configBox);
        box.add(value);
        box.close(); // like commit
      }
    }
  }

  save(Config? value) async {
    try {
      await saveImpl(value);
    } catch (e) {
      print("failed to save configuration");
      print(e);
      try {
        await db.clearBox(configBox); // clear broken configuration box
      } catch (e2) {
        print("failed to delete box $configBox");
        print(e2);
      }
      await saveImpl(value);
    }
  }

  /// set current [ConfigGraph.bodyWeight] to [ConfigGraph.bodyWeightList]
  setWeight(ConfigGraph config, DateTime now) {
    var bw = config.bodyWeightList.firstWhere((e) => now.isSameDay(e.date),
        orElse: () {
      var r = WeightBody.d(now, config.bodyWeight);
      config.bodyWeightList.add(r);
      return r;
    });
    bw.weight = config.bodyWeight;
  }
}

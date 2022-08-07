import 'package:injectable/injectable.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/db_loader.dart';

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

  Future<Config> load() async {
    try {
      var box = await db.openBox<Config>("config");
      if (box.values.isEmpty) {
        throw "no config value was loaded";
      }
      return box.values.first;
    } catch (e, st) {
      print(e);
      //db.clearBox("config");
      return Config();
    }
  }

  save(Config? value) async {
    if (value != null) {
      if (value.isInBox) {
        await value.save();
      } else {
        var box = await db.openBox<Config>("config");
        box.add(value);
        box.close(); // like commit
      }
    }
  }
}

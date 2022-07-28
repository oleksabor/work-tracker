import 'package:injectable/injectable.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/db_loader.dart';

@injectable
class ConfigModel {
  ConfigModel(this.db);
  DbLoader db;

  Future<Config> load() async {
    var box = await db.openBox<Config>("config");
    if (box.values.isEmpty) {
      return Config();
    } else {
      return box.values.first;
    }
  }

  save(Config? value) async {
    if (value != null) {
      if (value.isInBox) {
        await value.save();
      } else {
        var box = await db.openBox<Config>("config");
        box.add(value);
      }
    }
  }
}

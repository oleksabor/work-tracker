import 'dart:io';
import 'package:async/async.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_graph.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as Path;

class DbLoader {
  static bool initialized = false;

  Stream<String> getDbFolders() async* {
    var d1 = await getApplicationDocumentsDirectory();
    yield d1.path;
    var d2 = await getExternalDir();
    if (d2 != null) yield d2.path;
  }

  Future<Directory?> getExternalDir() async {
    try {
      return await getExternalStorageDirectory();
    } on UnimplementedError {
      return null;
    }
  }

  Future<String> findDbFile(Stream<String> directories) async {
    String? hiveDb;
    await for (var dir in directories) {
      hiveDb = "$dir/fl_db";

      if (await checkHive(hiveDb)) {
        break;
      }
    }
    if (hiveDb == null) {
      throw Exception("failed to find a place for hive db");
    }
    return hiveDb;
  }

  Future<bool> checkHive(String path) async {
    var exists = await Directory(path).exists();
    return exists;
  }

  Future moveDb2Dir(String newPath) async {
    //openedBox?.close();
    var hiveDb = await findDbFile(getDbFolders());
    var dbFile = Directory(hiveDb);
    if (dbFile.path == newPath) {
      throw Exception("can't move hive $hiveDb to the same path");
    }

    var newDir = Directory("$newPath/fl_db");
    if (await newDir.exists()) {
      await newDir.delete(recursive: true);
    }
    await newDir.create();
    await copyPath(dbFile.path, newDir.path);
    await dbFile.delete(recursive: true);

    initialized = false;
  }

  ///should be from io but failed to find
  ///https://pub.dev/documentation/io/latest/io/copyPath.html
  Future<void> copyPath(String from, String to) async {
    await Directory(to).create(recursive: true);
    await for (final file in Directory(from).list(recursive: true)) {
      final copyTo = Path.join(to, Path.relative(file.path, from: from));
      if (file is Directory) {
        await Directory(copyTo).create(recursive: true);
      } else if (file is File) {
        await File(file.path).copy(copyTo);
      } else if (file is Link) {
        await Link(copyTo).create(await file.target(), recursive: true);
      }
    }
  }

  final _initDBMemoizer = AsyncMemoizer();

  Future<Box<T>> openBox<T>(dynamic name) async {
    if (!initialized) {
      var hiveDb = await findDbFile(getDbFolders());
      _initDBMemoizer.runOnce(() {
        Hive.init(hiveDb);
        if (kDebugMode) {
          print("data storage dir is $hiveDb");
        }
        //flutter packages pub run build_runner build --delete-conflicting-outputs
        Hive.registerAdapter(WorkItemAdapter());
        Hive.registerAdapter(WorkKindAdapter());
        Hive.registerAdapter(ConfigAdapter());
        Hive.registerAdapter(ConfigGraphAdapter());
      });
      initialized = true;
    }
    var box2 = await Hive.openBox<T>(name);
    return box2;
  }
}

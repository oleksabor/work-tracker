import 'dart:io';
import 'package:async/async.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as Path;
import 'package:work_tracker/classes/iterable_extension.dart';

class WorkViewModel {
  final boxName = "workData";
  final itemsName = "items";
  final kindsName = "kinds";

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
      hiveDb = dir + '/' + "fl_db";

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
    openedBox?.close();
    var hiveDb = await findDbFile(getDbFolders());
    var dbFile = Directory(hiveDb);
    if (dbFile.path == newPath) {
      throw Exception("can't move hive $hiveDb to the same path");
    }

    var newDir = Directory(newPath + '/' + "fl_db");
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
          print("data storage dir is " + hiveDb);
        }

        Hive.registerAdapter(WorkItemAdapter());
        Hive.registerAdapter(WorkKindAdapter());
      });
      initialized = true;
    }
    var box2 = await Hive.openBox<T>(name);
    return box2;
  }

  Box<WorkItem>? openedBox;

  Future<List<WorkItem>> loadItems() async {
    openedBox = await openBox<WorkItem>(itemsName);
    if (openedBox != null) {
      return openedBox!.values.toList();
    }
    return <WorkItem>[];
  }

  Future<List<WorkItem>> loadItemsByDate(String kind, DateTime? when) async {
    var all = await loadItems();
    return itemsByKindDate(all, kind, when);
  }

  Future<List<WorkItem>> itemsByKindDate(
      List<WorkItem>? all, String kind, DateTime? when) async {
    var ondate = await filterItemsByKind(all, kind, when);
    if (all != null && ondate.isEmpty) {
      var latest = all.where(($_) =>
          $_.kind == kind && (when == null || $_.created.isBefore(when)));
      if (latest.isNotEmpty) {
        var last = latest.last;
        ondate = await filterItemsByKind(all, kind, last.created);
      }
    }
    return ondate.toList();
  }

  Future<List<WorkItem>> filterItemsByKind(
      List<WorkItem>? res, String kind, DateTime? when) async {
    if (res != null && res.isNotEmpty) {
      var filtered = res.where(($i) =>
          $i.kind == kind && (when == null || when.isSameDay($i.created)));
      return filtered.toList();
    }
    return [];
  }

  Future<List<WorkKind>> loadKinds() async {
    var b = await openBox<WorkKind>(kindsName);
    var kinds = b.values.toList();
    if (kinds == null || kinds.isEmpty) {
      kinds = WorkKind.kinds;
      b.putAll(kinds.asMap());
    }
    return kinds;
  }

  Future<List<WorkKindToday>> loadWork(DateTime when) async {
    var kinds = await loadKinds();
    var wkEmpty = kinds.map(($k) => WorkKindToday($k, null));
    var res = await createWork(wkEmpty.toList(), when);
    return res;
  }

  Future<List<WorkKindToday>> createWork(
      List<WorkKindToday> kinds, DateTime when) async {
    var work2return = kinds.toList();
    var items = await loadItems();
    for (WorkKindToday k in work2return) {
      var work = await filterItemsByKind(items, k.kind.title, when);
      if (work.isEmpty) {
        // no work was found for today, lets try to find a previous day work
        work = await filterItemsByKind(items, k.kind.title, null);
      }
      k.todayWork = work;
    }
    return kinds.toList();
  }

  ///appends [item] to the [openedBox]
  WorkItem store(WorkItem item) {
    if (openedBox != null) {
      openedBox?.add(item);
    }
    return item;
  }

  void updateItem(WorkItem item) {
    if (openedBox != null) {
      item.save();
    }
  }

  void removeItem(WorkItem item) {
    if (openedBox != null) {
      item.delete();
    }
  }

  void dispose() {
    if (openedBox != null) {
      openedBox?.close();
    }
  }

  Future<List<WorkItem>> loadItemsFor(int days, Future<List<WorkItem>> src,
      {DateTime? now}) async {
    now = now ?? DateTime.now();
    var startDate = now.subtract(Duration(days: days));
    var items = await src;
    var itemsData = items
        .where((_) => _.created.isAfter(startDate))
        .toList(growable: false);
    return itemsData;
  }

  List<WorkItem> sumByDate(Iterable<WorkItem> items) {
    var dateData = items.groupBy(
        (p0) => DateTime(p0.created.year, p0.created.month, p0.created.day));

    var res = <WorkItem>[];
    for (var k in dateData.entries) {
      var wi = WorkItem();
      wi.created = k.key;
      wi.qty = k.value.fold(0, (p, e) => p + e.qty);
      wi.weight = k.value.fold(0, (p, e) => p + e.weight);
      res.add(wi);
    }
    return res;
  }
}

class WorkKindToday {
  WorkKind kind;
  List<WorkItem>? todayWork;
  WorkKindToday(this.kind, this.todayWork);
}

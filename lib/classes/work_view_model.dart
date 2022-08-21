import 'dart:io';
import 'package:async/async.dart';
import 'package:injectable/injectable.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as Path;
import 'package:work_tracker/classes/db_loader.dart';

@injectable
class WorkViewModel {
  final boxName = "workData";
  final itemsName = "items";
  final kindsName = "kinds";
  DbLoader db = DbLoader();

  Box<WorkItem>? openedBox;
  Box<WorkKind>? _boxKinds;
  Future<Box<WorkKind>> boxKinds() async =>
      _boxKinds = (_boxKinds ?? await db.openBox<WorkKind>(kindsName));

  Future<List<WorkItem>> loadItems() async {
    openedBox = await db.openBox<WorkItem>(itemsName);
    if (openedBox != null) {
      return openedBox!.values.toList();
    }
    return <WorkItem>[];
  }

  Future<List<WorkItem>> loadItemsByDate(WorkKind kind, DateTime? when) async {
    var all = await loadItems();
    return itemsByKindBeforeDate(all, kind, when);
  }

  Future<List<WorkItem>> itemsByKindBeforeDate(
      List<WorkItem>? all, WorkKind kind, DateTime? when) async {
    var ondate = await filterItemsByKind(all, kind, when);
    if (all != null && ondate.isEmpty) {
      var latest = all.where(($_) =>
          $_.kindId == kind.kindId &&
          (when == null || $_.created.isBefore(when)));
      if (latest.isNotEmpty) {
        var last = latest.last;
        ondate = await filterItemsByKind(all, kind, last.created);
      }
    }
    return ondate.toList();
  }

  Future<List<WorkItem>> filterItemsByKind(
      List<WorkItem>? res, WorkKind kind, DateTime? when) async {
    if (res != null && res.isNotEmpty) {
      return Future.microtask(() {
        var emptyIds = res.where((e) => e.kindId < 0);
        for (var e in emptyIds.toList()) {
          // set WorkItem.kindId for old records
          if (e.kind == kind.title) {
            e.kindId = kind.kindId;
          }
        }
        var filtered = res.where(($i) =>
            $i.kindId == kind.kindId &&
            (when == null || when.isSameDay($i.created)));
        return filtered.toList();
      });
    }
    return [];
  }

  Future<List<WorkKind>> loadKinds() async {
    var b = await boxKinds();
    var kinds = b.values.toList();
    if (kinds == null || kinds.isEmpty) {
      kinds = WorkKind.kinds;
      b.putAll(kinds.asMap());
    }
    return kinds;
  }

  Future<List<WorkKindToday>> loadWork(DateTime when) async {
    var kinds = await loadKinds();
    var wkEmpty = kinds.map(($k) => WorkKindToday($k));
    var res = await createWork(wkEmpty.toList(), when);
    return res;
  }

  Future<List<WorkKindToday>> createWork(
      List<WorkKindToday> kinds, DateTime when) async {
    var work2return = kinds.toList();
    var items = await loadItems();
    for (WorkKindToday k in work2return) {
      var work = await filterItemsByKind(items, k.kind, when);
      if (work.isEmpty) {
        // no work was found for today, lets try to find a previous day work
        work = await filterItemsByKind(items, k.kind, null);
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

  Future<void> removeItem(WorkItem item) async {
    if (openedBox != null) {
      await item.delete();
    }
  }

  void dispose() {
    if (openedBox != null) {
      openedBox?.close();
      openedBox = null;
    }
    if (_boxKinds != null) {
      _boxKinds?.close();
      _boxKinds = null;
    }
  }

  Future<void> updateKind(WorkKind item) async {
    if (item.isInBox) {
      await item.save();
    } else {
      var b = await boxKinds();
      await b.add(item);
      //TODO check case when item is being added and then removed
    }
  }

  Future<void> removeKind(WorkKind item, List<WorkItem>? children) async {
    if (item.isInBox) {
      await item.delete();
      if (children != null) {
        for (var c in children) {
          await removeItem(c);
        }
      }
    }
  }
}

class WorkKindToday {
  WorkKind kind;
  List<WorkItem>? todayWork;
  WorkKindToday(this.kind, {this.todayWork});
}

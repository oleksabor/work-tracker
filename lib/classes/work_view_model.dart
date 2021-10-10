import 'package:fl_starter/classes/work_item.dart';
import 'package:fl_starter/classes/work_kind.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_date/dart_date.dart';

class WorkViewModel {
  final boxName = "workData";

  Future<Box<dynamic>> openBox() async {
    var appDir = await getApplicationDocumentsDirectory();
    var hiveDir = appDir.path + '/' + "fl_db";
    Hive.init(hiveDir);
    var box2 = await Hive.openBox(boxName);
    return box2;
  }

  Future<List<WorkItem>> loadItems() async {
    var box2 = await openBox();
    var res = box2.get("items");
    if (res == null) {
      var kinds = await loadKinds();
      res = kinds.map(($k) => WorkItem.k($k.title)).toList();
    }
    return res;
  }

  Future<List<WorkItem>> loadItemByKind(String kind, DateTime when) async {
    var b = await openBox();
    var res = await loadItems();
    if (res != null && res.isNotEmpty) {
      var filtered =
          res.where(($i) => $i.kind == kind && when.isSameDay($i.created));
      return filtered.toList();
    }
    return [];
  }

  Future<List<WorkKind>> loadKinds() async {
    var b = await openBox();
    var kinds = b.get("kinds", defaultValue: WorkKind.kinds);
    return kinds;
  }

  Future<List<WorkKindToday>> loadWork(DateTime when) async {
    var b = await openBox();
    var kinds = await loadKinds();
    var res = kinds.map(($k) => WorkKindToday($k, null));
    return await createWork(res, when);
  }

  Future<List<WorkKindToday>> createWork(
      Iterable<WorkKindToday> kinds, DateTime when) async {
    for (WorkKindToday k in kinds) {
      var work = await loadItemByKind(k.kind.title, when);
      k.todayWork = work;
    }
    return kinds.toList();
  }
}

class WorkKindToday {
  WorkKind kind;
  List<WorkItem>? todayWork;
  WorkKindToday(this.kind, this.todayWork);
}

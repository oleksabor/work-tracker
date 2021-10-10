import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_date/dart_date.dart';

class WorkViewModel {
  final boxName = "workData";
  final itemsName = "items";
  final kindsName = "kinds";

  static bool initialized = false;

  Future<Box<T>> openBox<T>(dynamic name) async {
    if (!initialized) {
      var appDir = await getApplicationDocumentsDirectory();
      var hiveDir = appDir.path + '/' + "fl_db";
      Hive.init(hiveDir);
      Hive.registerAdapter(WorkItemAdapter());
      Hive.registerAdapter(WorkKindAdapter());
      initialized = true;
    }
    var box2 = await Hive.openBox<T>(name);
    return box2;
  }

  Box<WorkItem>? openedBox;

  Future<List<WorkItem>> loadItems() async {
    openedBox = await openBox<WorkItem>(itemsName);
    if (openedBox == null) throw Exception("failed to open the work item box");
    var res = openedBox?.values.toList();
    if (res == null || res.isEmpty) {
      var kinds = await loadKinds();
      res = kinds.map(($k) => WorkItem.k($k.title)).toList();
    }
    return res;
  }

  Future<List<WorkItem>> loadItemByKind(String kind, DateTime when) async {
    var res = await loadItems();
    if (res != null && res.isNotEmpty) {
      var filtered =
          res.where(($i) => $i.kind == kind && when.isSameDay($i.created));
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
    for (WorkKindToday k in work2return) {
      var work = await loadItemByKind(k.kind.title, when);
      k.todayWork = work;
    }
    return kinds.toList();
  }

  WorkItem store(WorkItem item) {
    if (openedBox != null) {
      openedBox?.add(item);
    }
    return item;
  }
}

class WorkKindToday {
  WorkKind kind;
  List<WorkItem>? todayWork;
  WorkKindToday(this.kind, this.todayWork);
}

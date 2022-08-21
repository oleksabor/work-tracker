import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/debug_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'work_view_model_test.dart';

void main() {
  test('upgradeDbImpl', () async {
    var sut = DebugModel(WorkViewModel());
    var kinds = [WorkKindTest(1)..title = "11"];
    var wi = WorkItem.k("11");
    expect(wi.kindId, -1, reason: "default value violated");
    var items = [
      wi, // the only one has kindId adjusted
      WorkItem.i(1),
      WorkItem.i(2),
      WorkItem.k("22")
    ];
    var res = await sut.upgradeDbImpl(
        items, kinds, (_) async => Future.delayed(Duration(milliseconds: 10)));

    expect(res, 1, reason: "one should be updated");
    expect(wi.kindId, 1, reason: "kindId not updated");
  });
  test('group work items by kind', () async {
    var kinds = [
      WorkKindTest(11)..title = "t11",
      WorkKindTest(12)..title = "t12",
    ];
    var items = [
      WorkItem.i(10)..kind = "k10",
      WorkItem.i(10)..kind = "k10",
      WorkItem.i(11)..kind = "k11",
      WorkItem.i(12)..kind = "k12",
      WorkItem.i(12)..kind = "k12",
      WorkItem.k("k12"),
    ];
    var wm = WVMDebug(kinds, items);
    var dm = DebugModel(wm);
    var grouped = await dm.groupByKinds();
    expect(grouped.length, 4);
    expect(firstW(grouped, 11).todayWork?.length, 1);
    expect(firstW(grouped, 10).todayWork?.length, 2);
  });
}

WorkKindToday firstW(List<WorkKindToday> items, int id) {
  return items.firstWhere((element) => element.kind.kindId == id);
}

class WVMDebug extends WorkViewModel {
  List<WorkKind> kinds;
  List<WorkItem> items;
  WVMDebug(
    this.kinds,
    this.items,
  );
  @override
  Future<List<WorkKind>> loadKinds() async {
    return Future.value(kinds);
  }

  @override
  Future<List<WorkItem>> loadItems() async {
    return Future.value(items);
  }
}

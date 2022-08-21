import 'package:injectable/injectable.dart';
import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';

@injectable
class DebugModel {
  final WorkViewModel _model;
  DebugModel(this._model);

  Future<int> upgradeDb(WorkViewModel workModel) async {
    var items = await workModel.loadItems();
    var kinds = await workModel.loadKinds();
    return await upgradeDbImpl(items, kinds, (wi) async {
      wi.save();
    });
  }

  Future<int> upgradeDbImpl(List<WorkItem> items, List<WorkKind> kinds,
      Future<void> Function(WorkItem) saveImpl) async {
    var old = items.where((i) => i.kindId < 0).toList(growable: false);
    var errors = 0;
    for (var o in old) {
      try {
        var k = kinds.firstWhere((element) => element.title == o.kind);
        o.kindId = k.kindId;
        await saveImpl(o);
      } on StateError catch (se) {
        errors++;
      }
    }
    return old.length - errors;
  }

  Future moveDb() async {
    var vm = DbLoader();
    var externalDir = await vm.getExternalDir();

    if (externalDir != null) await vm.moveDb2Dir(externalDir.path);
  }

  void dispose() {
    closeDb(_model);
  }

  /// disposes [model]
  void closeDb(WorkViewModel model) {
    model.dispose();
  }

  /// groups [WorkViewModel.loadItems] output by [WorkItem.kindId]
  Future<List<WorkKindToday>> groupByKinds() async {
    var items = await _model.loadItems();
    var kinds = await _model.loadKinds();

    var group = items.groupBy((i) => i.kindId);
    var res = group.map((k, v) {
      try {
        var kind = kinds.singleWhere((element) => element.kindId == k);
        return MapEntry<WorkKind, List<WorkItem>>(kind, v);
      } on StateError catch (e) {
        return MapEntry<WorkKind, List<WorkItem>>(
            WorkKind()
              ..title = "gen$k"
              ..kindId = k,
            v);
      }
    });
    var data = res.entries
        .map((e) => WorkKindToday(e.key, todayWork: e.value))
        .toList();
    return data;
  }
}

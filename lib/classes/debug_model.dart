import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';

class DebugModel {
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

  /// disposes [model]
  Future closeDb(WorkViewModel model) async {
    model.dispose();
  }
}

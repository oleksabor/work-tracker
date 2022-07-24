import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';

class DebugModel {
  Future upgradeDb(WorkViewModel workModel) async {
    var items = await workModel.loadItems();
    var kinds = await workModel.loadKinds();
    await upgradeDbImpl(items, kinds);
  }

  Future<int> upgradeDbImpl(List<WorkItem> items, List<WorkKind> kinds) async {
    var old = items.where((i) => i.kindId < 0);
    for (var o in old) {
      var k = kinds.firstWhere((element) => element.title == o.kind);
      o.kindId = k.kindId;
      await o.save();
    }
    return old.length;
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

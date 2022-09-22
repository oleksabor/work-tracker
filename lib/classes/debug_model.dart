import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/export.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

@injectable
class DebugModel {
  final WorkViewModel _model;
  final DbLoader dbLoader;

  DebugModel(this._model, this.dbLoader);

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

  Export asExport(WorkKindToday src) {
    return Export(src.kind, src.todayWork ?? <WorkItem>[]);
  }

  Future exportJson(String fileName, List<WorkKindToday> source) async {
    var json = exportAsJson(source);
    var file = File(fileName);
    if (kDebugMode) {
      print("exporting $fileName");
    }
    var path = file.path.substring(0, file.path.lastIndexOf('/'));
    var dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    if (await file.exists()) {
      await file.delete();
    } else {
      await file.create();
    }
    var sink = file.openWrite();
    await file.writeAsString(json);
    await sink.flush();
    await sink.close();
  }

  String exportAsJson(List<WorkKindToday> source) {
    var exported = source.map(asExport).toList();
    var json = jsonEncode(exported);
    return json;
  }

  Future<List<WorkKindToday>> importJson(String fileName) async {
    if (kDebugMode) {
      print("importing $fileName");
    }
    var file = File(fileName);
    var string = await file.readAsString();
    return importAsJson(string);
  }

  List<WorkKindToday> importAsJson(String json) {
    var data = jsonDecode(json);
    List<Export> res = <Export>[];
    for (var i in data) {
      res.add(Export.fromJson(i));
    }
    return res.map((e) => WorkKindToday(e.kind, todayWork: e.items)).toList();
  }

  Future import2db2(WorkKindToday wkt) async {
    var kind = await _model.updateKind(wkt.kind);
    if (wkt.todayWork != null) {
      for (var i in wkt.todayWork!) {
        i.kindId = kind.kindId;
        await _model.store(i);
      }
    }
    await _model.flush();
  }

  Future import2db(List<WorkKindToday> source) async {
    for (var wkt in source) {
      await import2db2(wkt);
    }
  }

  share(String fileName) async {
    await Share.shareFiles([fileName], text: 'share file');
  }

  delete() async {
    await dbLoader.clearBox(ConfigModel.configBox);
    await dbLoader.clearBox(WorkViewModel.itemsName);
    await dbLoader.clearBox(WorkViewModel.kindsName);
  }
}

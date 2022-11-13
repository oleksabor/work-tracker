import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/db_loader.dart';
import 'package:work_tracker/classes/history_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'dart:convert';

import 'package:work_tracker/classes/work_view_model.dart';

import 'work_view_model_test.dart';

void main() {
  test('history items on date', () async {
    var items = await WorkViewModelDumbData()
        .sut()
        .getItems((_) => _.created == WorkViewModelDumbData.now);
    expect(items.length, 2);
  });

  test('history items back', () async {
    var history = WorkViewModelDumbData().sut();
    var items = await history.getItemsBefore(WorkViewModelDumbData.now);
    expect(items.length, 4);
    items = await history.getItemsBefore(WorkViewModelDumbData.beforeNow);
    expect(items.isEmpty, true);
  });

  test('history items forward', () async {
    var history = WorkViewModelDumbData().sut();
    var items = await history.getItemsAfter(WorkViewModelDumbData.beforeNow);
    expect(items.length, 2);
    items = await history.getItemsAfter(WorkViewModelDumbData.now);
    expect(items.isEmpty, true);
  });
}

class WorkViewModelDumb extends WorkViewModel {
  WorkViewModelDumb(this.items, this.kinds) : super(DbLoader());

  List<WorkItem> items;
  List<WorkKind> kinds;

  @override
  Future<List<WorkItem>> loadItems() async {
    return Future.value(items);
  }

  @override
  Future<List<WorkKind>> loadKinds() async {
    return Future.value(kinds);
  }
}

class WorkViewModelDumbData {
  static final now = DateTime(2022, 11, 13);
  static final kherson = DateTime(2022, 11, 11);
  static final beforeNow = DateTime(2022, 11, 10);
  HistoryModel sut() {
    var kind = WorkKindTest(1)..title = "test1";
    var kind2 = WorkKindTest(2)..title = "test2";

    var sut = HistoryModel(
      WorkViewModelDumb([
        addWI(kind, now, qty: 1),
        addWI(kind, now, qty: 33),
        addWI(kind2, kherson, qty: 33),
        addWI(kind2, kherson, qty: 22),
        addWI(kind2, kherson.subtract(Duration(days: 1)), qty: 11),
        addWI(kind, beforeNow, qty: 2),
        addWI(kind, beforeNow, qty: 3),
        addWI(kind, beforeNow, qty: 4),
        addWI(kind, beforeNow, qty: 5),
        addWI(kind2, now, qty: 3),
        addWI(kind2, beforeNow, qty: 6),
      ], [
        kind,
        kind2
      ]),
      kind,
      now,
    );
    return sut;
  }
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/debug_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';

import 'work_view_model_test.dart';

void main() {
  test('upgradeDbImpl', () async {
    var sut = DebugModel();
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
}

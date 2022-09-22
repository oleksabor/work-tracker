import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/export.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'dart:convert';

void main() {
  test('export work item to json', () {
    var wi = WorkItem.i(11)
      ..created = DateTime.now()
      ..qty = 22
      ..weight = 33;
    var map = wi.toJson();
    var json = jsonEncode(map);
    var data = jsonDecode(json);
    var res = WorkItem.fromJson(data);
    expect(res.created, wi.created);
    expect(res.qty, wi.qty);
    expect(res.weight, wi.weight);
  });
  test('direct export work item to json', () {
    var wi = WorkItem.i(11)
      ..created = DateTime.now()
      ..qty = 22
      ..weight = 33;
    var json = jsonEncode(wi);
    var data = jsonDecode(json);
    var res = WorkItem.fromJson(data);
    expect(res.created, wi.created);
    expect(res.qty, wi.qty);
    expect(res.weight, wi.weight);
  });
  test('export to json ', () {
    var created = DateTime.now();
    var kind = WorkKind.m("test1")..kindId = 11;
    var items = [
      WorkItem.i(11)
        ..created = created
        ..qty = 1,
      WorkItem.i(11)
        ..created = created
        ..qty = 2
        ..weight = 3
    ];
    var sut = Export(kind, items);
    var maps = sut.toJson();
    var jsonString = jsonEncode(maps);
    var resMaps = jsonDecode(jsonString);
    var res = Export.fromJson(resMaps);
    expect(res.kind.kindId, sut.kind.kindId);
    expect(res.items.length, sut.items.length);
    expect(res.items[1].qty, sut.items[1].qty);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/doc_dir.dart';

void main() {
  test('safeDir execution with error', () async {
    var err = await DirData.safeDir(() => throw Exception("test"));
    expect(err, null, reason: "no error should be raised");
  });
  test('DirData iteration', () async {
    var sut =
        DirData(appDocuments: "docs", extStorage: "ext", appLibrary: "lib");
    var i = sut.iterator;
    expect(i.moveNext(), true, reason: "no documents");
    expect(i.current.path, "docs");
    expect(i.moveNext(), true, reason: "no storage");
    expect(i.current.path, "lib");
    expect(i.moveNext(), true, reason: "no lib");
    expect(i.current.path, "ext");
  });
  test('safeDir execution', () async {
    var td = await DirData.safeDir(() => Directory("test"));
    expect(td!.path, "test");
  });
}

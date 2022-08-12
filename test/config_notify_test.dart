import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/config_notify.dart';

void main() {
  test('toJson conversion', () async {
    var cn = ConfigNotify()
      ..asAlarm = true
      ..delay = 25
      ..notification = "testSound.mp3"
      ..kind = NotificationKind.system;
    var json = cn.toJson();
    var str = jsonEncode(json);
    var json2 = jsonDecode(str);
    var cn2 = ConfigNotify.fromJson(json2);
    expect(cn.kind, cn2.kind, reason: "kind enum serialization");
    expect(cn.notification, cn2.notification,
        reason: "kind enum serialization");
    expect(cn.delay, cn2.delay, reason: "kind enum serialization");
  });
}

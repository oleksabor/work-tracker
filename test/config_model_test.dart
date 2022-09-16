import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:work_tracker/classes/config_graph.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/db_loader.dart';

void main() {
  test('set body weight ', () async {
    var sut = ConfigModel(DbLoader());
    var config = ConfigGraph();

    var d1 = DateTime(2022, 9, 16);

    config.bodyWeight = 11;
    sut.setWeight(config, d1);
    expect(config.bodyWeightList.length, 1);
    var c0 = config.bodyWeightList[0];
    expect(c0.weight, 11);
    expect(c0.date, d1);

    config.bodyWeight = 22;
    sut.setWeight(config, d1);
    expect(config.bodyWeightList.length, 1);
    expect(config.bodyWeightList[0].weight, 22);

    var d2 = DateTime(2022, 9, 15);
    config.bodyWeight = 33;
    sut.setWeight(config, d2);
    var c1 = config.bodyWeightList[1];
    expect(config.bodyWeightList.length, 2);
    expect(c1.weight, 33);
    expect(c1.date, d2);
  });
}

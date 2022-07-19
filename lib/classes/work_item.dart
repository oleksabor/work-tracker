import 'package:work_tracker/classes/hive_type_values.dart';
import 'package:hive/hive.dart';
import 'hive_type_values.dart';

part 'work_item.g.dart';

@HiveType(typeId: HiveTypesEnum.workItem)
class WorkItem extends HiveObject {
  @HiveField(0)
  String kind = '';

  @HiveField(1)
  DateTime created = DateTime.now();

  @HiveField(2)
  int qty = 0;

  @HiveField(3)
  double weight = 0;

  // reference to the work kind key value
  @HiveField(4, defaultValue: -1)
  int kindId = 0;

  WorkItem.k(this.kind);
  WorkItem.i(this.kindId);
  WorkItem();
  factory WorkItem.from(WorkItem src) {
    var res = WorkItem.i(src.kindId);
    res.created = src.created;
    res.qty = src.qty;
    res.weight = src.weight;
    return res;
  }
}

    // if (numOfFields < 5) {
    //   // old structure and no kindId in the file
    //   res.kindId = -1;
    // } else {
    //   res.kindId = fields[4] as int;
    // }

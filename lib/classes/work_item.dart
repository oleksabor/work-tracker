import 'package:work_tracker/classes/hive_type_values.dart';
import 'package:hive/hive.dart';

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
  @HiveField(4)
  int kindId = -1;

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

  WorkItem.fromJson(Map<String, dynamic> data)
      : created = DateTime.parse(data['created']),
        qty = data['qty'],
        weight = data['weight']; // there is no need to store kindId

  Map<String, dynamic> toJson() =>
      {'created': created.toIso8601String(), 'weight': weight, 'qty': qty};

  WorkItem copyWith(
      {int? qty, DateTime? created, double? weight, int? kindId}) {
    return WorkItem()
      ..created = created ?? this.created
      ..kindId = kindId ?? this.kindId
      ..qty = qty ?? this.qty
      ..weight = weight ?? this.weight;
  }
}

    // if (numOfFields < 5) {
    //   // old structure and no kindId in the file
    //   res.kindId = -1;
    // } else {
    //   res.kindId = fields[4] as int;
    // }

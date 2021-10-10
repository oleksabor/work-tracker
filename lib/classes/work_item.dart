import 'package:work_tracker/classes/hive_type_vales.dart';
import 'package:hive/hive.dart';
import 'hive_type_vales.dart';

part 'work_item.g.dart';

@HiveType(typeId: HiveTypesEnum.workItem)
class WorkItem {
  @HiveField(0)
  String kind = '';

  @HiveField(1)
  DateTime created = DateTime.now();

  @HiveField(2)
  int qty = 0;

  @HiveField(3)
  double weight = 0;

  WorkItem.k(this.kind);
  WorkItem();
}

import 'package:work_tracker/classes/hive_type_values.dart';
import 'package:hive/hive.dart';

part 'weight_body.g.dart';

@HiveType(typeId: HiveTypesEnum.weightBody)
class WeightBody extends HiveObject {
  @HiveField(0)
  DateTime date = DateTime(2022, 09, 16);
  @HiveField(1)
  double weight = 1;

  WeightBody();
  WeightBody.d(this.date, this.weight);
}

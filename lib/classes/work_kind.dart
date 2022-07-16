import 'package:hive/hive.dart';
import 'hive_type_vales.dart';

part 'work_kind.g.dart';

@HiveType(typeId: HiveTypesEnum.workKind)
class WorkKind extends HiveObject {
  @HiveField(0)
  String title = '';
  @HiveField(1)
  int parentHash = 0;

  // wrapper over HiveObject.key
  int get kindId => key;

  WorkKind();
  WorkKind.m(this.title);

  static List<WorkKind> kinds = [
    WorkKind.m("Push-ups"),
    WorkKind.m("Pull-ups"),
    WorkKind.m("Crouch"),
  ];

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}

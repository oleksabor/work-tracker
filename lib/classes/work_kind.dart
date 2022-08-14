import 'package:hive/hive.dart';
import 'hive_type_values.dart';

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

  /// [key] is read-only so all other item's properties have to be set individually
  WorkKind assignFrom(WorkKind item) {
    title = item.title;
    parentHash = item.parentHash;
    return this;
  }
}

import 'package:hive/hive.dart';
import 'hive_type_vales.dart';

part 'work_kind.g.dart';

@HiveType(typeId: HiveTypesEnum.workKind)
class WorkKind {
  @HiveField(0)
  String title = '';
  @HiveField(1)
  int parentHash = 0;

  WorkKind();
  WorkKind.m(this.title);

  @override
  int get hashCode => title.hashCode;

  static List<WorkKind> kinds = [
    WorkKind.m("віджимання"),
    WorkKind.m("підтягування"),
    WorkKind.m("присідання"),
  ];

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}

import 'package:hive/hive.dart';
import 'hive_type_values.dart';

part 'work_kind.g.dart';

@HiveType(typeId: HiveTypesEnum.workKind)
class WorkKind extends HiveObject {
  @HiveField(0)
  String title = '';
  @HiveField(1)
  int parentHash = 0;

  int? _okey;
  // wrapper over HiveObject.key
  int get kindId => _okey ?? key ?? -1;
  set kindId(i) => _okey = i; // artificial setter

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

  WorkKind.fromJson(Map<String, dynamic> data)
      : _okey = data['kindId'],
        title = data['title'],
        parentHash = data['parentHash']; // there is no need to store kindId

  Map<String, dynamic> toJson() =>
      {'kindId': kindId, 'title': title, 'parentHash': parentHash};
}

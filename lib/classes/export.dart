import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';

class Export {
  WorkKind kind;
  List<WorkItem> items;

  Export(this.kind, this.items);

  Export.fromJson(Map<String, dynamic> data)
      : kind = WorkKind.fromJson(data['kind']),
        items =
            data['items'].map<WorkItem>((_) => WorkItem.fromJson(_)).toList();

  Map<String, dynamic> toJson() => {
        'kind': kind.toJson(),
        'items': items.map((_) => _.toJson()).toList(growable: false)
      };
}

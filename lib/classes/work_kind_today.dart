import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';

class WorkKindToday {
  WorkKind kind;
  List<WorkItem>? todayWork;
  WorkKindToday(this.kind, {this.todayWork});
}

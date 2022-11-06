import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';

class Calendar {
  /// [items] ordered by date and mapped as [Day]
  Iterable<Day> load(
      List<WorkItem> items, DateTime now, List<WorkKind> kinds) sync* {
    var daysBack = 30;
    var monthAgo = now.subtract(Duration(days: daysBack));
    var monthData = items.where((_) => _.created.isAfter(monthAgo));
    for (var i = 0; i <= daysBack; i++) {
      var dt = monthAgo.add(Duration(days: i));
      var md = monthData.where((_) => _.created.isSameDay(dt));
      var day = Day(DateTime(dt.year, dt.month, dt.day));
      if (md.isNotEmpty) {
        day.result = <Result>[];
        for (var e in md) {
          var kind = getKind(kinds, e.kindId);
          var result = day.result!.firstWhere((_) => _.kindId == kind.kindId,
              orElse: () => Result(0, kind.title, kind.kindId));
          if (result.qty == 0) {
            // new item should be added to the result list
            day.result!.add(result);
          }
          result.qty += e.qty;
        }
      }
      yield day;
    }
  }

  WorkKind getKind(List<WorkKind> kinds, int id) {
    return kinds.firstWhere((element) => element.kindId == id,
        orElse: () => WorkKind.m("unknown"));
  }
}

class Day {
  DateTime date;
  Day(this.date);

  /// exercise results if any
  List<Result>? result;
}

class Result {
  int qty;
  int kindId;
  String title;
  Result(this.qty, this.title, this.kindId);
}

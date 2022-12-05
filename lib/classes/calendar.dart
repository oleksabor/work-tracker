import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/iterable_extension.dart';
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

  List<CalendarData> getData(
      List<WorkItem> items, List<WorkKind> kinds, DateTime now, int daysBack) {
    var res = <CalendarData>[];
    for (var q = daysBack; q >= 0; q--) {
      var d = now.subtract(Duration(days: q));
      var work = items.where((_) => _.created.isSameDay(d));
      var kinded = work.groupBy((_) => _.kindId).map((key, value) =>
          MapEntry(kinds.firstWhere((_) => _.kindId == key), value));
      res.add(CalendarData(d, kinded.keys.toList()));
    }
    return res;
  }

  /// updates [CalendarData.title] with text value
  /// adds month name as first element and before 1st day of a month
  List<CalendarData> getDataTitle(List<CalendarData> data) {
    var res = <CalendarData>[];
    for (var cd in data) {
      if (cd.date.day == 1 || res.isEmpty) {
        res.add(getMonth(cd));
      }
      cd.title = cd.date.day.toString();
      res.add(cd);
    }
    return res;
  }

  CalendarData getMonth(CalendarData cd) {
    return cd.copyWith(cd.date, <WorkKind>[], "${cd.date.getMonthABBR()}:");
  }
}

class CalendarData {
  DateTime date;
  List<WorkKind> items;

  CalendarData(this.date, this.items, {this.title});

  bool get isData => items.isNotEmpty;
  String? title;

  CalendarData copyWith(
    DateTime? dt,
    List<WorkKind>? items,
    String? title,
  ) {
    return CalendarData(
      dt ?? date,
      items ?? this.items,
      title: title ?? this.title,
    );
  }
}

/// helper class used to display calendar
class Day {
  DateTime date;
  Day(this.date);

  /// exercise results if any
  List<Result>? result;
}

/// helper class used to display calendar
class Result {
  int qty;
  int kindId;
  String title;
  Result(this.qty, this.title, this.kindId);
}

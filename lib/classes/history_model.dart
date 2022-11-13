import 'package:intl/intl.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryModel {
  WorkViewModel model;

  /// what kind of items are loaded
  WorkKind kind;
  HistoryModel(this.model, this.kind, this.date);

  /// date to get items on
  final DateTime date;

  String asDate(DateTime value, AppLocalizations? t) {
    var diff = value.difference(DateTime.now());
    if (diff.inDays == 0) {
      return t!.todayCap;
    }
    if (diff.inDays == -1) {
      return t!.yesterdayCap;
    }
    return DateFormat.MMMMd(DateMethods.localeStr).format(value);
  }

  /// all items of [kind] are cached
  List<WorkItem>? _cache;

  Future<List<WorkItem>> getItems(bool Function(WorkItem wi) filter) async {
    _cache = _cache ?? await model.loadItems();
    var all = await model.filterItemsByKind(_cache, kind, null);
    var itemsPrev = all.where((i) => filter(i));
    if (itemsPrev.isNotEmpty) {
      return itemsPrev.toList();
    }
    return [];
  }

  Future<List<WorkItem>> getItemsBefore(DateTime adate) async {
    adate = DateTime(adate.year, adate.month, adate.day);
    var prevItems = await getItems((wi) => wi.created.isBefore(adate));
    if (prevItems.isNotEmpty) {
      var date = prevItems.last.created;
      prevItems = prevItems.where((i) => i.created.isSameDay(date)).toList();
      return prevItems;
    }
    return [];
  }

  Future<List<WorkItem>> getItemsAfter(DateTime adate) async {
    adate = DateTime(adate.year, adate.month, adate.day)
        .add(const Duration(days: 1));
    var prevItems = await getItems((wi) => wi.created.isAfter(adate));
    if (prevItems.isNotEmpty) {
      var date = prevItems.first.created;
      prevItems = prevItems.where((i) => i.created.isSameDay(date)).toList();
      return prevItems;
    }
    return [];
  }

  Future<List<WorkItem>> delete(WorkItem i, List<WorkItem> items) async {
    await i.delete();
    resetCache();
    items.remove(i);
    return items;
  }

  void resetCache() {
    _cache = null;
  }
}

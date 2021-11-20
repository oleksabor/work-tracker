import 'dart:io';

import 'package:intl/intl.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:work_tracker/views/work_item_page.dart';

/// items list on day
class WorkItemsView extends StatefulWidget {
  final Future<List<WorkItem>> items;
  final DateTime date;
  final String kind;

  final WorkViewModel model;
  WorkItemsView(
      {required this.items,
      required this.date,
      required this.kind,
      required this.model});
  @override
  State<StatefulWidget> createState() {
    return WorkItemsViewState();
  }
}

///[items] list view  per day
class WorkItemsViewState extends State<WorkItemsView> {
  Future<List<WorkItem>>? localItems;
  Future<List<WorkItem>> get items => localItems ?? widget.items;
  set items(Future<List<WorkItem>> v) {
    localItems = v;
  }

  DateTime? localDate;
  DateTime get date => localDate ?? widget.date;
  set date(DateTime v) {
    localDate = v;
  }

  String get kind => widget.kind;

  WorkViewModel get model => widget.model;

  String get todayCaption => "today";
  String get yesterdayCaption => "yesterday";

  String get widgetTitle => kind + " on " + asDate(date);

  String asDate(DateTime value) {
    var diff = value.difference(DateTime.now());
    if (diff.inDays == 0) {
      return todayCaption;
    }
    if (diff.inDays == -1) {
      return yesterdayCaption;
    }
    return DateFormat.MMMMd(DateMethods.localeStr).format(value);
  }

  Future<List<WorkItem>> getItems(bool Function(WorkItem wi) filter) async {
    var all = await model.loadItems();
    if (all == null) return [];

    var itemsPrev = all.where((i) => i.kind == kind && filter(i));
    if (itemsPrev.isNotEmpty) {
      itemsPrev = itemsPrev;
      return itemsPrev.toList();
    }
    return [];
  }

  void getItemsBefore(DateTime adate) async {
    adate = DateTime(adate.year, adate.month, adate.day);
    var prevItems = await getItems((wi) => wi.created.isBefore(adate));
    if (prevItems.isNotEmpty) {
      date = prevItems.last.created;
      prevItems = prevItems.where((i) => i.created.isSameDay(date)).toList();
      items = Future.value(prevItems);
    }
  }

  void getItemsAfter(DateTime adate) async {
    adate = DateTime(adate.year, adate.month, adate.day).add(Duration(days: 1));
    var prevItems = await getItems((wi) => wi.created.isAfter(adate));
    if (prevItems.isNotEmpty) {
      date = prevItems.first.created;
      prevItems = prevItems
          .where((i) => i.created.isSameDay(prevItems.last.created))
          .toList();
      items = Future.value(prevItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widgetTitle),
        ),
        body: Column(children: <Widget>[
          Flexible(
              child: FutureBuilder<List>(
            future: items,
            initialData: [],
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (ctx, i) {
                        return _buildRow(ctx, snapshot.data![i]);
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            },
          )),
          Row(children: [
            IconButton(
              onPressed: () {
                getItemsBefore(date);

                setState(() {});
              },
              color: Theme.of(context).primaryColor,
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () {
                getItemsAfter(date);

                setState(() {});
              },
              color: Theme.of(context).primaryColor,
              icon: const Icon(Icons.arrow_forward),
            )
          ])
        ]));
  }

  String get qtyCaption => "quantity";
  String get weightCaption => "weight";

  Widget _buildRow(BuildContext context, WorkItem i) {
    var st = qtyCaption + ": " + i.qty.toString();
    var stw = "";
    if (i.weight > 0) {
      stw = weightCaption + ": " + i.weight.toInt().toString();
    }
    return ListTile(
        title: Text(st + " " + stw),
        subtitle: Text(i.created.smartString()),
        onTap: () {
          editItem(context, i);
        });
  }

  void editItem(BuildContext context, WorkItem item) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => WorkItemPage(item: WorkItem.from(item))),
    );
    if (res != null) {
      item.qty = res.qty;
      item.weight = res.weight;
      model.updateItem(item);
      setState(() {});
    }
  }
}

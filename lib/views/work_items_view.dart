import 'dart:io';

import 'package:intl/intl.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:flutter/material.dart';

class WorkItemsView extends StatelessWidget {
  WorkItemsView(
      {Key? key, required this.items, required this.date, required this.kind})
      : super(key: key);

  final Future<List<WorkItem>> items;
  final DateTime date;
  final String kind;

  String get todayCaption => "today";
  String get yesterdayCaption => "yesterday";

  String get widgetTitle => kind + " on " + asDate(date);
  String defaultLocale = Platform.localeName;

  String asDate(DateTime value) {
    var diff = value.difference(DateTime.now());
    if (diff.inDays == 0) {
      return todayCaption;
    }
    if (diff.inDays == -1) {
      return yesterdayCaption;
    }
    return DateFormat.MMMMd(defaultLocale).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widgetTitle),
        ),
        body: FutureBuilder<List>(
          future: items,
          initialData: [],
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, i) {
                      return _buildRow(snapshot.data![i]);
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ));
  }

  String get qtyCaption => "quantity";
  String get weightCaption => "weight";

  Widget _buildRow(WorkItem i) {
    var st = qtyCaption + ": " + i.qty.toString();
    var stw = "";
    if (i.weight > 0) {
      stw = weightCaption + ": " + i.weight.toInt().toString();
    }
    return ListTile(
      title: Text(st + " " + stw),
      subtitle: Text(i.created.smartString()),
    );
  }
}

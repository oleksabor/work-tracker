import 'dart:async';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/history_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:work_tracker/views/work_item_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// items list on day
class WorkItemsView extends StatefulWidget {
  final DateTime date;
  final WorkKind kind;
  late HistoryModel history;
  late Future<List<WorkItem>> items;

  final WorkViewModel model;
  WorkItemsView(
      {Key? key, required this.date, required this.kind, required this.model})
      : super(key: key) {
    history = HistoryModel(model, kind, date);
    items = history.getItems((d) => date.isSameDay(d.created));
  }
  @override
  State<StatefulWidget> createState() {
    return WorkItemsViewState();
  }
}

///[items] list view  per day
class WorkItemsViewState extends State<WorkItemsView> {
  HistoryModel get history => widget.history;

  DateTime? localDate;
  DateTime get date => localDate ?? widget.date;
  set date(DateTime v) {
    localDate = v;
  }

  WorkKind get kind => widget.kind;

  WorkViewModel get model => widget.model;

  String getWidgetTitle(String kind, DateTime date, AppLocalizations? t) {
    return "$kind ${t!.onCap} ${history.asDate(date, t)}";
  }

  Future<List<WorkItem>> getItems(Future<List<WorkItem>> items) async {
    var res = await items;
    if (res.isNotEmpty) {
      date = history.date;
      return res;
    } else {
      return widget.items;
    }
  }

  Future<List<WorkItem>> getItemsBefore(DateTime adate) async {
    return getItems(history.getItemsBefore(adate));
  }

  Future<List<WorkItem>> getItemsAfter(DateTime adate) async {
    return getItems(history.getItemsAfter(adate));
  }

  static const String tagDelete = "deleteMenu";
  void contextMenuClick(String? v, WorkItem i) {
    widget.items = history.delete(i, widget.items);
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    var colorBtn = Theme.of(context).iconTheme.color;
    final menuTags = {
      tagDelete: t.menuDelete,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(getWidgetTitle(kind.title, date, t)),
      ),
      body: FutureBuilder<List<WorkItem>>(
        future: widget.items,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.data!.isEmpty) {
            return Column(children: [Text(t.noDataLabel)]);
          }
          var itemsMenu = menuTags.entries
              .map((e) => PopupMenuItem<String>(
                  value: e.key,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete), // TODO add icon to the menuTags
                      Text(e.value),
                    ],
                  )))
              .toList();
          return snapshot.hasData
              ? Column(children: <Widget>[
                  Flexible(
                      child: ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, i) {
                      return GestureDetector(
                          onTapDown: _storePosition,
                          onLongPress: () {
                            final RenderBox overlay = Overlay.of(ctx)
                                ?.context
                                .findRenderObject() as RenderBox;

                            showMenu<String>(
                                    context: ctx,
                                    items: itemsMenu,
                                    position: RelativeRect.fromRect(
                                        _tapPosition &
                                            const Size(40,
                                                40), // smaller rect, the touch area
                                        Offset.zero &
                                            overlay
                                                .size // Bigger rect, the entire screen
                                        ))
                                .then((v) {
                              if (v != null) {
                                contextMenuClick(v, snapshot.data![i]);
                                setState(() {});
                              }
                            });
                          },
                          child: _buildRow(ctx, snapshot.data![i], t));
                    },
                  )),
                  Row(children: [
                    IconButton(
                      onPressed: () async {
                        widget.items = getItemsBefore(date).then((v) {
                          setState(() {});
                          return v;
                        });
                      },
                      color: colorBtn,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    IconButton(
                      onPressed: () async {
                        widget.items = getItemsAfter(date).then((v) {
                          setState(() {});
                          return v;
                        });
                      },
                      color: colorBtn,
                      icon: const Icon(Icons.arrow_forward),
                    )
                  ])
                ])
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  late Offset _tapPosition;

  Widget _buildRow(BuildContext context, WorkItem i, AppLocalizations? t) {
    var st = "${t?.qtyCap}: ${i.qty}";
    var stw = "";
    if (i.weight > 0) {
      stw = "${t?.weightCap}: ${i.weight.toInt()}";
    }
    return ListTile(
        title: Text("$st $stw"),
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

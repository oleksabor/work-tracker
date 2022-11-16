import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/history_list/history_list_bloc.dart';
import 'package:work_tracker/classes/history_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/views/work_item_page.dart';

class WorkItemsListView extends StatefulWidget {
  List<WorkItem> items;
  HistoryModel history;
  WorkKind kind;

  WorkItemsListView(this.items, this.history, this.kind);

  @override
  State<StatefulWidget> createState() {
    return _WorkItemsListViewState();
  }
}

class _WorkItemsListViewState extends State<WorkItemsListView> {
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  late Offset _tapPosition;

  static const String tagDelete = "deleteMenu";
  void contextMenuClick(String? v, WorkItem i) async {
    widget.items = await widget.history.delete(i, widget.items);

    var bloc = context.read<HistoryListBloc>();
    bloc.add(HistoryItemRemoved(i));
  }

  List<PopupMenuItem<String>> getPopupMenu(Map<String, String> menuTags) {
    var itemsMenu = menuTags.entries
        .map((e) => PopupMenuItem<String>(
            value: e.key,
            child: Row(
              children: <Widget>[
                const Icon(Icons.delete), // TODO add icon to the menuTags
                Text(e.value),
              ],
            )))
        .toList();
    return itemsMenu;
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    final menuTags = {
      tagDelete: t.menuDelete,
    };
    var itemsMenu = getPopupMenu(menuTags);
    var bloc = context.read<HistoryListBloc>();
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: widget.items.length,
      itemBuilder: (ctx, i) {
        return GestureDetector(
            onTapDown: _storePosition,
            onLongPress: () => longPress(ctx, itemsMenu, i, bloc),
            child: _buildRow(ctx, widget.items[i], t, bloc));
      },
    );
  }

  void longPress(
    BuildContext ctx,
    List<PopupMenuItem<String>> itemsMenu,
    int idx,
    HistoryListBloc bloc,
  ) {
    final RenderBox overlay =
        Overlay.of(ctx)?.context.findRenderObject() as RenderBox;

    showMenu<String>(
            context: ctx,
            items: itemsMenu,
            position: RelativeRect.fromRect(
                _tapPosition &
                    const Size(40, 40), // smaller rect, the touch area
                Offset.zero & overlay.size // Bigger rect, the entire screen
                ))
        .then((v) {
      if (v != null) {
        contextMenuClick(v, widget.items[idx]);
        bloc.add(HistoryLoadListEvent(when: bloc.state.when));
      }
    });
  }

  Widget _buildRow(
    BuildContext context,
    WorkItem i,
    AppLocalizations? t,
    HistoryListBloc bloc,
  ) {
    var st = "${t?.qtyCap}: ${i.qty}";
    var stw = "";
    if (i.weight > 0) {
      stw = "${t?.weightCap}: ${i.weight.toInt()}";
    }
    return ListTile(
        title: Text("$st $stw"),
        subtitle: Text(i.created.smartString()),
        onTap: () async {
          await Navigator.push(context, WorkItemPage.route(widget.kind, i));
          bloc.add(HistoryLoadListEvent(when: bloc.state.when));
        });
  }
}

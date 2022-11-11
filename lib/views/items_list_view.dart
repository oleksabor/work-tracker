import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:work_tracker/classes/communicator.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:work_tracker/classes/items_list/list_bloc.dart';
import 'package:work_tracker/classes/notify_model.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_kind/kind_bloc.dart';
import 'package:work_tracker/classes/work_kind/kind_event.dart';
import 'package:work_tracker/classes/work_kind/kind_state.dart';
import 'package:work_tracker/classes/work_kind_today.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:work_tracker/views/charts_page.dart';
import 'package:work_tracker/views/config_page.dart';
import 'package:work_tracker/views/main_items_page.dart';
import 'package:work_tracker/views/pop_menu_data.dart';
import 'package:work_tracker/views/work_item_page.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/views/work_items_view.dart';
import 'package:work_tracker/views/work_kind_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemsListView extends StatelessWidget {
  ItemsListView({super.key});
  static const tagEdit = "edit";
  static const tagDelete = "delete";
  late AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
    kindPopup = MenuContext<String, WorkKindToday>([
      PopupMenuData(tagEdit, t.menuEdit,
          icon: Icons.edit,
          onClick: (bc, wkt) =>
              Navigator.of(context).push(WorkKindView.route(wkt.kind))),
      PopupMenuData(tagDelete, t.menuDelete,
          icon: Icons.delete, onClick: deleteKind)
    ]);

    return BlocBuilder<ListBloc, ListState>(builder: (context, state) {
      if (state.data.isEmpty) {
        if (state.status == ItemListStatus.loading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state.status != ItemListStatus.success) {
          return const SizedBox();
        } else {
          return Center(
            child: Text(
              "empty items list",
              style: Theme.of(context).textTheme.caption,
            ),
          );
        }
      }

      return getItemsListView(state.data);
    });
  }

  void deleteKind(BuildContext context, WorkKindToday item) async {
    var res = true;
    if (item.todayWork != null && item.todayWork!.isNotEmpty) {
      var t = AppLocalizations.of(context)!;
      var existingQty = t.itemsExist(item.todayWork!.length);
      res = await WorkItemsContext.showConfirmationDialog(
              res, t.confirmRemoval, existingQty, context) ??
          false;
    }
    if (res) {
      var bloc = context.read<EditKindBloc>();
      bloc.add(KindDeleted(item.kind, items: item.todayWork));
    }
  }

  ListView getItemsListView(List<dynamic>? items) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(10.0),
      itemCount: items!.length,
      itemBuilder: (ctx, i) {
        return GestureDetector(
            onLongPress: () =>
                kindPopup.show(ctx, items[i], kindPopup.tapPosition),
            onTapDown: kindPopup.storePosition,
            onTap: () => workItemsView(ctx, items[i]),
            child: _buildRow(ctx, items[i]));
      },
    );
  }

  late MenuContext<String, WorkKindToday> kindPopup;

  String dateAsString(DateTime? value) {
    if (value == null) {
      return "-";
    }
    return value.smartString();
  }

  Widget _buildRow(BuildContext ctx, WorkKindToday i) {
    var tw = i.todayWork;
    var last = tw != null && tw.isNotEmpty ? tw.last : null;

    var dateStr = dateAsString(last?.created);

    var subtitle = last == null ? "-" : '$dateStr [${last.qty}]';

    return ListTile(
        title: Text(i.kind.title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          onPressed: () {
            workItemAdd(ctx, i);
          },
          color: Theme.of(ctx).iconTheme.color,
          icon: const Icon(Icons.add),
        ));
  }

  void workItemAdd(BuildContext context, WorkKindToday kToday) async {
    var wi = WorkItem.i(kToday.kind.key);
    var todayWork = kToday.todayWork;
    if (todayWork != null && todayWork.isNotEmpty) {
      wi.qty = todayWork.last.qty;
      wi.weight = todayWork.last.weight;
    }
    await Navigator.of(context).push(WorkItemPage.route(kToday.kind, wi));
    //TODO restore notification

    // var res = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (ctx) => WorkItemPage(item: wi, title: kToday.kind.title)),
    // );
    // if (res != null) {
    //   var item = await _model.store(res);
    //   kToday.todayWork ??= [];
    //   setState(() {
    //     kToday.todayWork?.add(item);
    //   });
    //   await notify();
    // }
  }

// TODO get config model from context
  // Future notify() async {
  //   var configModel = getIt<ConfigModel>();
  //   var config = await configModel.load();
  //   if (config.notify.playAfterNewResult) {
  //     var scheduled = await NotifyModel.playSchedule(config.notify);
  //     var min = config.notify.delay / 60;
  //     var sec = config.notify.delay % 60;

  //     var message = scheduled
  //         ? t.notificationScheduled(min.toInt(), twoDig.format(sec))
  //         : t.scheduleFailed;
  //     showNotification(scheduled, message);
  //   }
  // }

  void workItemsView(BuildContext context, WorkKindToday kind) async {
    var d = DateTime.now();
    if (kind.todayWork != null && kind.todayWork!.isNotEmpty) {
      d = kind.todayWork!.last.created;
    }

    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (ctx) =>
    //           WorkItemsView(date: d, kind: kind.kind, model: _model)),
    // );
  }
}

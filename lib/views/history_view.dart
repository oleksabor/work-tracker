import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/classes/history_list/history_list_bloc.dart';
import 'package:work_tracker/classes/history_model.dart';
import 'package:work_tracker/classes/item_list_status.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_kind_today.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:work_tracker/views/work_items_list_view.dart';

/// items list on day
class HistoryView extends StatefulWidget {
  final DateTime date;
  final WorkKind kind;

  HistoryView({Key? key, required this.date, required this.kind})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HistoryViewState();
  }

  static Route<void> route(
      DateTime d, WorkKindToday kind, BuildContext context) {
    var wm = RepositoryProvider.of<WorkViewModel>(context);
    var history = HistoryModel(wm, kind.kind, d);
    return MaterialPageRoute(
        builder: (ctx) => BlocProvider(
              create: (_) => HistoryListBloc(history, when: d)
                ..add(HistoryLoadListEvent()),
              child: HistoryView(date: d, kind: kind.kind),
            ));
  }
}

///[items] list view  per day
class HistoryViewState extends State<HistoryView> {
  // HistoryModel get history => widget.history;

  WorkKind get kind => widget.kind;

  Widget emptyDataPlaceholder(ItemListStatus status, AppLocalizations t) {
    if (status == ItemListStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (status != ItemListStatus.success) {
      return const SizedBox();
    } else {
      return Center(
        child: Text(
          t.noDataLabel,
          style: Theme.of(context).textTheme.caption,
        ),
      );
    }
  }

  Widget getTitle(String title, String subtitle, ThemeData theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style:
              TextStyle(fontSize: theme.appBarTheme.titleTextStyle?.fontSize)),
      Text(subtitle,
          style:
              TextStyle(fontSize: theme.primaryTextTheme.bodyMedium?.fontSize)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    return BlocBuilder<HistoryListBloc, HistoryListState>(
        builder: (ctx, state) {
      var bloc = ctx.read<HistoryListBloc>();
      var theme = Theme.of(context);
      var history = bloc.model;
      var body = state.data.isEmpty
          ? emptyDataPlaceholder(state.status, t)
          : Flexible(
              child: WorkItemsListView(state.data, history, widget.kind),
            );

      return Scaffold(
          appBar: AppBar(
            title: getTitle(
              kind.title,
              "${t.onCap} ${history.asDate(bloc.state.when, t)}",
              theme,
            ),
          ),
          body: Column(children: <Widget>[
            body,
            Row(children: [
              getNavigation(
                  () => bloc.add(HistoryBackEvent()), Icons.arrow_back),
              getNavigation(
                  () => bloc.add(HistoryForwardEvent()), Icons.arrow_forward),
            ])
          ]));
    });
  }

  Widget getNavigation(void Function() pressed, IconData icon) {
    var colorBtn = Theme.of(context).iconTheme.color;
    return IconButton(
      onPressed: pressed,
      color: colorBtn,
      icon: Icon(icon),
    );
  }
}

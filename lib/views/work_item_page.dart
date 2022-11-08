import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/work_item/item_bloc.dart';
import 'package:work_tracker/classes/work_item/item_event.dart';
import 'package:work_tracker/classes/work_item/item_state.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:work_tracker/views/numeric_step_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// [item] edit view
class WorkItemPage extends StatelessWidget {
  /// [item] edit view
  const WorkItemPage({Key? key}) : super(key: key);

  static Route<void> route(WorkKind kind, WorkItem? item) {
    return MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) {
          return BlocProvider(
            create: (context) => EditItemBloc(
                itemsRepository: RepositoryProvider.of<WorkViewModel>(context),
                //context.read<WorkViewModel>(),
                initialItem: item,
                kind: kind),
            child: const WorkItemPage(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditItemBloc, EditItemState>(
      listenWhen: (p, c) {
        return c.status == EditItemStatus.success;
      },
      listener: (context, state) => Navigator.of(context).pop(true),
      child: WorkItemView(),
    );
  }
}

class WorkItemView extends StatelessWidget {
  WorkItemView({super.key});

  late EditItemState state;

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    state = context.select(
      (EditItemBloc bloc) => bloc.state,
    );
    item = state.initialItem!;
    return Scaffold(
        appBar: AppBar(
          title: Text(state.workKind.title),
        ),
        body: Builder(builder: (context) {
          var rows = buildRows(state.initialItem!, t, context);
          rows.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: state.status.isLoadingOrSuccess
                  ? null
                  : () => context.read<EditItemBloc>().add(ItemAdded()),
              child: Text(t.okCap),
            ),
          ));
          var res = Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: rows));
          return res;
        }));
  }

  List<Widget> buildRows(
      WorkItem item, AppLocalizations t, BuildContext context) {
    final bloc = context.read<EditItemBloc>();
    var res = [
      buildNumericRow(
          t.qtyCap, (v) => bloc.add(ItemQtyChanged(v)), bloc.state.qty, 1, t),
      buildNumericRow(
          t.weightCap,
          (v) => bloc.add(ItemWeightChanged(v.toDouble())),
          bloc.state.weight.toInt(),
          0,
          t),
    ];
    if (!item.created.isSameDay(DateTime.now())) {
      res.add(Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(
            flex: 5,
          ),
          Text(t.createdCap),
          const Spacer(
            flex: 1,
          ),
          Text(item.created.smartString()),
          const Spacer(
            flex: 5,
          ),
        ]),
      ));
    }
    return res;
  }

  late WorkItem item;

  Widget buildNumericRow(String caption, Function(int) diff, int value,
      final int minValue, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(caption),
        NumericStepButton(
            minValue: minValue,
            onChanged: diff,
            value: value,
            decrementContent: t.decrementLabel,
            incrementContent: t.incrementLabel)
      ]),
    );
  }
}

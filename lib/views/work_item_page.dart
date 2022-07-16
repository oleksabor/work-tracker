import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/views/numeric_step_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// [item] edit view
class WorkItemPage extends StatelessWidget {
  /// [item] edit view
  const WorkItemPage({Key? key, required this.item}) : super(key: key);

  // Declare a field that holds the Item.
  final WorkItem item;

  void changedQty(int value) {
    item.qty = value;
  }

  void changedWeight(int value) {
    item.weight = value.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(item.kind),
        ),
        body: Builder(builder: (context) {
          var rows = buildRows(item, t);
          rows.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, item);
              },
              child: Text(t!.okCap),
            ),
          ));
          var res = Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: rows));
          return res;
        }));
  }

  List<Widget> buildRows(WorkItem item, AppLocalizations? t) {
    var res = [
      buildNumericRow(t!.qtyCap, changedQty, item.qty, 1),
      buildNumericRow(t.weightCap, changedWeight, item.weight.toInt(), 0),
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

  Widget buildNumericRow(
      String caption, Function(int) diff, int value, final int minValue) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(caption),
        NumericStepButton(
          minValue: minValue,
          onChanged: diff,
          value: value,
        )
      ]),
    );
  }
}

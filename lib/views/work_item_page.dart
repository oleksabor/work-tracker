import 'package:work_tracker/classes/work_item.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/views/numeric_step_button.dart';

class WorkItemPage extends StatelessWidget {
  // In the constructor, require a Todo.
  const WorkItemPage({Key? key, required this.item}) : super(key: key);

  // Declare a field that holds the Todo.
  final WorkItem item;

  void changedQty(int value) {
    item.qty = value;
  }

  void changedWeight(int value) {
    item.weight = value.toDouble();
  }

  String get okCaption => "Ok";

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
        appBar: AppBar(
          title: Text(item.kind),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Quantity"),
              NumericStepButton(
                minValue: 0,
                onChanged: changedQty,
                value: item.qty,
              )
            ]),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Weight"),
                NumericStepButton(
                  minValue: 0,
                  onChanged: changedWeight,
                  value: item.weight.toInt(),
                ),
              ])),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, item);
              },
              child: Text(okCaption),
            ),
          ),
        ])));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_tracker/classes/work_kind.dart';

class WorkKindView extends StatefulWidget {
  final WorkKind kind;
  const WorkKindView(this.kind, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WorkKindViewState();
  }
}

class WorkKindViewState extends State<WorkKindView> {
  void changedTitle(String v) {
    widget.kind.title = v;
  }

  final _formKey = GlobalKey<FormState>();

  Future<bool> onWillPop() async {
    if (_formKey.currentState == null || _formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  late TextEditingController kindController;

  @override
  void initState() {
    kindController = TextEditingController(text: widget.kind.title);

    super.initState();
  }

  @override
  void dispose() {
    kindController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: AppBar(
              title: Text(t.workKindTitle),
            ),
            body: Column(children: [
              Row(
                children: [
                  Expanded(flex: 3, child: Text(t.workKindTitle)),
                  Expanded(
                      flex: 7,
                      child: TextFormField(
                        validator: (v) => validateNotEmpty(v, t),
                        controller: kindController,
                        onChanged: changedTitle,
                        onFieldSubmitted: changedTitle,
                      ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (await onWillPop()) {
                      Navigator.pop(context, widget.kind);
                    }
                  },
                  child: Text(t.okCap),
                ),
              )
            ])));
  }

  String? validateNotEmpty(String? v, AppLocalizations t) {
    if (v == null || v.isEmpty) {
      return t.titleEmptyValidation;
    }
    return null;
  }
}

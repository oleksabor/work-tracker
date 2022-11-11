import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/classes/edit_item_status.dart';
import 'package:work_tracker/classes/work_kind/kind_bloc.dart';
import 'package:work_tracker/classes/work_kind/kind_event.dart';
import 'package:work_tracker/classes/work_kind/kind_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkKindForm extends StatelessWidget {
  WorkKindForm(this._formKey, this.kindController, {super.key});
  GlobalKey<FormState> _formKey;

  TextEditingController kindController;
  late BuildContext context;

  void changedTitle(String v) {
    context.read<EditKindBloc>().add(KindTitleChanged(v));
  }

  String? validateNotEmpty(String? v, AppLocalizations t) {
    if (v == null || v.isEmpty) {
      return t.titleEmptyValidation;
    }
    return null;
  }

  late EditKindState state;

  @override
  Widget build(BuildContext context) {
    state = context.watch<EditKindBloc>().state;
    var t = AppLocalizations.of(context)!;
    this.context = context;
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
                  onPressed: state.status.isLoadingOrSuccess
                      ? null
                      : () async {
                          if (await onWillPop()) {
                            context.read<EditKindBloc>().add(KindAdjusted());
                          }
                        },
                  child: Text(t.okCap),
                ),
              )
            ])));
  }

  Future<bool> onWillPop() async {
    if (_formKey.currentState == null || _formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }
}

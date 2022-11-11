import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_tracker/classes/edit_item_status.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_kind/kind_bloc.dart';
import 'package:work_tracker/classes/work_kind/kind_state.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:work_tracker/views/work_kind_form.dart';

class WorkKindView extends StatefulWidget {
  const WorkKindView({super.key});

  @override
  State<StatefulWidget> createState() {
    return WorkKindViewState();
  }

  static Route<void> route(WorkKind? kind) {
    return MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) {
          return BlocProvider(
            create: (context) => EditKindBloc(
              itemsRepository: RepositoryProvider.of<WorkViewModel>(context),
              //context.read<WorkViewModel>(),
              initialItem: kind,
            ),
            child: const WorkKindView(),
          );
        });
  }
}

class WorkKindViewState extends State<WorkKindView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController kindController;

  @override
  void initState() {
    kindController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    kindController.dispose();
    super.dispose();
  }

  late EditKindState state;

  @override
  Widget build(BuildContext context) {
    state = context.select(
      (EditKindBloc bloc) => bloc.state,
    );
    kindController.value = TextEditingValue(text: state.title);
    return BlocListener<EditKindBloc, EditKindState>(
      listenWhen: (p, c) {
        return c.status == EditItemStatus.success;
      },
      listener: (context, state) => Navigator.of(context).pop(true),
      child: WorkKindForm(_formKey, kindController),
    );
  }
}

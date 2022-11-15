import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/classes/calendar.dart';
import 'package:work_tracker/classes/calendar_strip/strip_bloc.dart';
import 'package:work_tracker/classes/item_list_status.dart';
import 'package:work_tracker/classes/items_list/list_bloc.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final loadEvent = StripLoadEvent(DateTime.now(), 30);
    return BlocProvider<StripBloc>(
      create: (ctx) {
        var wm = RepositoryProvider.of<WorkViewModel>(ctx);
        var ca = RepositoryProvider.of<Calendar>(ctx);
        return StripBloc(wm, ca)..add(loadEvent);
      },
      child: BlocListener<ListBloc, ListState>(
          listener: ((context, state) =>
              context.read<StripBloc>().add(loadEvent)),
          child: const CalendarDays()),
    );
  }
}

class CalendarDays extends StatelessWidget {
  const CalendarDays({super.key});

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    var theme = Theme.of(context);
    var bl = BlocListener<ListBloc, ListState>(
      listener: (ctx, st) {},
    );
    return BlocBuilder<StripBloc, StripState>(builder: (context, state) {
      var body = state.data.isEmpty
          ? emptyDataPlaceholder(state.status, t)
          : Wrap(
              spacing: 2,
              children: getDaysStrip(state.data, theme),
            );
      return body;
    });
  }

  List<Widget> getDaysStrip(List<CalendarData> data, ThemeData theme) {
    return data.map((_) => getDay(_, theme)).toList();
  }

  Widget getDay(CalendarData cd, ThemeData theme) {
    var background =
        theme.textTheme.bodyMedium?.backgroundColor ?? Colors.white;
    var isData = cd.items.isNotEmpty;
    var color = !isData ? background : Colors.green;
    var deco = isData
        ? ShapeDecoration(
            color: background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: color, width: 3),
            ))
        : null;
    var pad = !isData ? const EdgeInsets.only(top: 3) : null;
    return Container(
        decoration: deco,
        padding: pad,
        child: Text(cd.date.day.toString(), textAlign: TextAlign.center));
  }

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
        ),
      );
    }
  }
}

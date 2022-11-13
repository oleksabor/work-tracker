import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:work_tracker/classes/date_extension.dart';
import 'package:work_tracker/classes/history_model.dart';
import 'package:work_tracker/classes/item_list_status.dart';
import 'package:work_tracker/classes/list_state_base.dart';
import 'package:work_tracker/classes/work_item.dart';

part 'history_list_event.dart';
part 'history_list_state.dart';

class HistoryListBloc extends Bloc<HistoryListEvent, HistoryListState> {
  final HistoryModel model;
  HistoryListBloc(this.model, {DateTime? when})
      : super(HistoryListState(
            ItemListStatus.initial, <WorkItem>[], when ?? DateTime.now())) {
    on<HistoryLoadListEvent>(_onLoadListRequest);
    on<HistoryBackEvent>(_onBack);
    on<HistoryForwardEvent>(_onForward);
  }

  Future<void> populate(
    Emitter<HistoryListState> emitter,
    Future<List<WorkItem>> Function() loader, {
    List<WorkItem> Function()? defData,
    DateTime Function()? defWhen,
  }) async {
    emitter(state.copyWith(status: () => ItemListStatus.loading));
    try {
      var data = await loader();
      var stateData =
          data.isNotEmpty ? data : (defData == null ? data : defData());
      var stateWhen = data.isNotEmpty
          ? data.first.created
          : (defWhen == null ? state.when : defWhen());
      emitter(state.copyWith(
        status: () => ItemListStatus.success,
        data: () => stateData,
        when: stateWhen,
      ));
    } catch (e) {
      emitter(state.copyWith(
        status: () => ItemListStatus.failure,
      ));
    }
  }

  Future<List<WorkItem>> getItems(DateTime when) async {
    return model.getItems((wi) => wi.created.isSameDay(when));
  }

  Future<void> _onLoadListRequest(
    HistoryLoadListEvent event,
    Emitter<HistoryListState> emitter,
  ) async {
    await populate(emitter, () => getItems(state.when));
  }

  FutureOr<void> _onBack(
    HistoryBackEvent event,
    Emitter<HistoryListState> emitter,
  ) async {
    await populate(
      emitter,
      () => model.getItemsBefore(state.when),
      defData: () => state.data,
    );
  }

  FutureOr<void> _onForward(
    HistoryForwardEvent event,
    Emitter<HistoryListState> emitter,
  ) async {
    await populate(
      emitter,
      () => model.getItemsAfter(state.when),
      defData: () => state.data,
    );
  }
}

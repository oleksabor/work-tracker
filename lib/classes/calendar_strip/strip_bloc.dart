import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:work_tracker/classes/calendar.dart';
import 'package:work_tracker/classes/item_list_status.dart';
import 'package:work_tracker/classes/list_state_base.dart';
import 'package:work_tracker/classes/work_view_model.dart';

part 'strip_event.dart';
part 'strip_state.dart';

/// calendar strip loading
class StripBloc extends Bloc<StripEvent, StripState> {
  final WorkViewModel wm;
  final Calendar ca;

  StripBloc(this.wm, this.ca)
      : super(StripState(ItemListStatus.initial, <CalendarData>[])) {
    on<StripLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(
    StripLoadEvent event,
    Emitter<StripState> emitter,
  ) async {
    emitter(state.copyWith(status: () => ItemListStatus.loading));
    var items = await wm.loadItems();
    var kinds = await wm.loadKinds();
    var data = ca.getData(items, kinds, event.when, event.daysBack);
    emitter(
        state.copyWith(status: () => ItemListStatus.success, data: () => data));
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:work_tracker/classes/item_list_status.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_kind_today.dart';
import 'package:work_tracker/classes/work_view_model.dart';
import 'package:work_tracker/classes/list_state_base.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  final WorkViewModel _workModel;
  ListBloc(this._workModel)
      : super(ListState(ItemListStatus.initial, <WorkKindToday>[])) {
    on<LoadListEvent>(_onLoadListRequest);
    on<KindDeleted>(_onDeleted);
  }

  void _onDeleted(KindDeleted event, Emitter<ListState> emit) async {
    emit(state.copyWith(status: () => ItemListStatus.loading));
    _workModel.removeKind(event.kind, event.items);
    emit(state.copyWith(status: () => ItemListStatus.success));
  }

  Future<void> _onLoadListRequest(
      LoadListEvent event, Emitter<ListState> emit) async {
    emit(state.copyWith(status: () => ItemListStatus.loading));
    try {
      var dataLoaded = await _workModel.loadWork(event.when ?? DateTime.now());

      emit(state.copyWith(
        status: () => ItemListStatus.success,
        data: () => dataLoaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => ItemListStatus.failure,
      ));
    }
  }
}

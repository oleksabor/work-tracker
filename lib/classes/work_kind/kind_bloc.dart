import 'package:bloc/bloc.dart';
import 'package:work_tracker/classes/edit_item_status.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind/kind_event.dart';
import 'package:work_tracker/classes/work_kind/kind_state.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';

class EditKindBloc extends Bloc<KindEvent, EditKindState> {
  EditKindBloc(
      {required WorkViewModel itemsRepository,
      required WorkKind? initialItem,
      List<WorkItem>? items})
      : _itemsRepository = itemsRepository,
        super(
          EditKindState(
            initialItem: initialItem,
            title: initialItem?.title ?? "",
          ),
        ) {
    on<KindAdded>(_onSubmitted);
    on<KindAdjusted>(_onSubmitted);
    on<KindUpdated>(_onSubmitted);
    on<KindTitleChanged>(_onTitle);
    on<KindDeleted>(_onDeleted);
  }

  final WorkViewModel _itemsRepository;

  void _onTitle(KindTitleChanged event, Emitter<EditKindState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onDeleted(KindDeleted event, Emitter<EditKindState> emit) async {
    emit(state.copyWith(status: EditItemStatus.saving));
    _itemsRepository.removeKind(event.kind, event.items);
    emit(state.copyWith(status: EditItemStatus.success, initialItem: null));
  }

  Future<void> _onSubmitted(
    KindAdjusted event,
    Emitter<EditKindState> emit,
  ) async {
    emit(state.copyWith(status: EditItemStatus.saving));
    var item = state.initialItem ?? WorkKind();
    item.title = state.title;

    try {
      await _itemsRepository.updateKind(item);
      emit(state.copyWith(status: EditItemStatus.success));
    } on Exception catch (e) {
      emit(state.copyWith(status: EditItemStatus.failure));
    }
  }
}

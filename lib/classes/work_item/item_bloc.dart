import 'package:bloc/bloc.dart';
import 'package:work_tracker/classes/edit_item_status.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_item/item_event.dart';
import 'package:work_tracker/classes/work_item/item_state.dart';
import 'package:work_tracker/classes/work_kind.dart';
import 'package:work_tracker/classes/work_view_model.dart';

class EditItemBloc extends Bloc<ItemEvent, EditItemState> {
  EditItemBloc({
    required WorkViewModel itemsRepository,
    required WorkItem? initialItem,
    required WorkKind kind,
  })  : _itemsRepository = itemsRepository,
        super(
          EditItemState(
            initialItem: initialItem,
            qty: initialItem?.qty ?? 1,
            weight: initialItem?.weight ?? 0,
            workKind: kind,
          ),
        ) {
    on<ItemAdded>(_onSubmitted);
    on<ItemQtyChanged>(_onQty);
    on<ItemWeightChanged>(_onWeight);
  }

  final WorkViewModel _itemsRepository;

  void _onQty(ItemQtyChanged event, Emitter<EditItemState> emit) {
    emit(state.copyWith(qty: event.qty));
  }

  void _onWeight(ItemWeightChanged event, Emitter<EditItemState> emit) {
    emit(state.copyWith(weight: event.weight));
  }

  Future<void> _onSubmitted(
    ItemAdded event,
    Emitter<EditItemState> emit,
  ) async {
    emit(state.copyWith(status: EditItemStatus.saving));
    var item = state.initialItem ?? WorkItem.i(state.workKind.kindId);
    // qty and weight are populated from UI
    item.qty = state.qty;
    item.weight = state.weight;

    try {
      await _itemsRepository.store(item);
      emit(state.copyWith(status: EditItemStatus.success));
    } on Exception catch (e) {
      emit(state.copyWith(
          status: EditItemStatus.failure, message: e.toString()));
    }
  }
}

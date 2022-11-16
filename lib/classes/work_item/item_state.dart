import 'package:equatable/equatable.dart';
import 'package:work_tracker/classes/edit_item_status.dart';
import 'package:work_tracker/classes/work_item.dart';
import 'package:work_tracker/classes/work_kind.dart';

class EditItemState extends Equatable {
  const EditItemState({
    this.status = EditItemStatus.initial,
    this.initialItem,
    required this.workKind,
    this.qty = 0,
    this.weight = 0,
    this.message,
  });

  final EditItemStatus status;
  final WorkItem? initialItem;
  final WorkKind workKind;
  final int qty;
  final double weight;
  final String? message;

  bool get isNewItem => initialItem == null;

  EditItemState copyWith({
    EditItemStatus? status,
    WorkItem? initialItem,
    WorkKind? workKind,
    int? qty,
    double? weight,
    String? message,
  }) {
    return EditItemState(
        status: status ?? this.status,
        initialItem: initialItem ?? this.initialItem,
        workKind: workKind ?? this.workKind,
        qty: qty ?? this.qty,
        weight: weight ?? this.weight,
        message: message);
  }

  @override
  List<Object?> get props =>
      [status, initialItem, qty, weight, workKind, message];
}

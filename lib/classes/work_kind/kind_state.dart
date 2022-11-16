import 'package:equatable/equatable.dart';
import 'package:work_tracker/classes/edit_item_status.dart';
import 'package:work_tracker/classes/work_kind.dart';

class EditKindState extends Equatable {
  const EditKindState({
    this.status = EditItemStatus.initial,
    this.initialItem,
    this.title = "",
  });

  final EditItemStatus status;
  final WorkKind? initialItem;
  final String title;

  bool get isNewItem => initialItem == null;

  EditKindState copyWith({
    EditItemStatus? status,
    WorkKind? initialItem,
    String? title,
  }) {
    return EditKindState(
      status: status ?? this.status,
      initialItem: initialItem ?? this.initialItem,
      title: title ?? this.title,
    );
  }

  @override
  List<Object?> get props => [status, initialItem, title];
}

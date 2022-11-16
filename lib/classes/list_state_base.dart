import 'package:equatable/equatable.dart';
import 'package:work_tracker/classes/item_list_status.dart';

abstract class ListStateBase<T> extends Equatable {
  ListStateBase(this.status, this.data);
  ItemListStatus status;

  @override
  List<Object?> get props => [status, data];

  List<T> data;
}

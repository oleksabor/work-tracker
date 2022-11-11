part of 'list_bloc.dart';

abstract class ListEvent extends Equatable {}

class LoadListEvent extends ListEvent {
  DateTime? when;

  LoadListEvent({this.when});

  @override
  List<Object?> get props => [when];
}

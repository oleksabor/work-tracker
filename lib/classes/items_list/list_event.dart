part of 'list_bloc.dart';

abstract class ListEvent extends Equatable {}

class LoadListEvent extends ListEvent {
  DateTime? when;

  LoadListEvent({this.when});

  @override
  List<Object?> get props => [when];
}

class KindDeleted extends ListEvent {
  WorkKind kind;
  List<WorkItem>? items;

  KindDeleted(this.kind, {this.items});

  @override
  List<Object?> get props => [kind, items];
}

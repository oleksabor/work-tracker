part of 'history_list_bloc.dart';

abstract class HistoryListEvent extends Equatable {
  DateTime? when;

  HistoryListEvent({this.when});

  @override
  List<Object?> get props => [when];
}

class HistoryLoadListEvent extends HistoryListEvent {
  HistoryLoadListEvent({super.when});
}

class HistoryBackEvent extends HistoryListEvent {
  HistoryBackEvent({super.when});
}

class HistoryForwardEvent extends HistoryListEvent {
  HistoryForwardEvent({super.when});
}

class HistoryItemRemoved extends HistoryListEvent {
  HistoryItemRemoved(this.item);
  WorkItem item;

  @override
  List<Object?> get props => [item];
}

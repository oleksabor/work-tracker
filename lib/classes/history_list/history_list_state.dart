part of 'history_list_bloc.dart';

class HistoryListState extends ListStateBase<WorkItem> {
  HistoryListState(super.status, super.data, this.when);
  DateTime when;

  HistoryListState copyWith({
    ItemListStatus Function()? status,
    List<WorkItem> Function()? data,
    DateTime? when,
  }) {
    return HistoryListState(
      status != null ? status() : this.status,
      data != null ? data() : this.data,
      when ?? this.when,
    );
  }
}

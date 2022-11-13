part of 'list_bloc.dart';

class ListState extends ListStateBase<WorkKindToday> {
  ListState(super.status, super.data);

  ListState copyWith(
      {ItemListStatus Function()? status,
      List<WorkKindToday> Function()? data}) {
    return ListState(
      status != null ? status() : this.status,
      data != null ? data() : this.data,
    );
  }
}
